'use strict';
// Catalog inspector for the ATS071 labs and playgrounds.
//
// It reads the descriptor "repositories" (ConfigMaps named repo-<name> in the
// namespace catalog-source) and the catalog configuration (ConfigMap
// catalog-config, key app-config.yaml) from standard input as one Kubernetes
// ConfigMapList in JSON, then prints one JSON report.
//
// Validation of every document uses the real @backstage/catalog-model library:
// the entity policies and the kind validators that the Backstage catalog
// backend itself uses. Locations, rules, relations and providers are a small
// model of what the catalog backend does; it is not the Backstage backend.
const { parseAllDocuments } = require('yaml');
const cm = require('@backstage/catalog-model');

const DEFAULT_RULES = [{ allow: ['Component', 'System', 'API', 'Resource', 'Location'] }];
const policy = cm.EntityPolicies.allOf([
  new cm.SchemaValidEntityPolicy(),
  new cm.DefaultNamespaceEntityPolicy(),
  new cm.NoForeignRootFieldsEntityPolicy(),
  new cm.FieldFormatEntityPolicy(cm.makeValidator()),
]);
const kindValidators = [
  cm.apiEntityV1alpha1Validator, cm.componentEntityV1alpha1Validator,
  cm.domainEntityV1alpha1Validator, cm.groupEntityV1alpha1Validator,
  cm.locationEntityV1alpha1Validator, cm.resourceEntityV1alpha1Validator,
  cm.systemEntityV1alpha1Validator, cm.userEntityV1alpha1Validator,
];
const HOST = 'https://git.starfleet.example/';

function readInput() {
  let raw = '';
  process.stdin.setEncoding('utf8');
  return new Promise(resolve => {
    process.stdin.on('data', c => (raw += c));
    process.stdin.on('end', () => resolve(JSON.parse(raw || '{"items":[]}')));
  });
}

function parseYaml(text) {
  const docs = parseAllDocuments(text);
  return docs.map(d => (d.errors.length ? { error: d.errors[0].message.split('\n')[0] } : { value: d.toJSON() }));
}

function refOf(entity) {
  return cm.stringifyEntityRef(entity).toLowerCase();
}

function targetRef(value, defaults) {
  return cm.stringifyEntityRef(cm.parseEntityRef(value, defaults)).toLowerCase();
}

// The relations that the built-in kinds processor emits (forward direction).
function relationsOf(e) {
  const ns = e.metadata.namespace || 'default';
  const spec = e.spec || {};
  const out = [];
  const errors = [];
  const emit = (type, refs, defaults) => {
    for (const r of [].concat(refs || [])) {
      try {
        out.push({ type, target: targetRef(r, { defaultNamespace: ns, ...defaults }) });
      } catch (err) {
        errors.push(`${type}: ${err.message}`);
      }
    }
  };
  switch (e.kind) {
    case 'Component':
      emit('ownedBy', spec.owner, { defaultKind: 'Group' });
      emit('partOf', spec.subcomponentOf, { defaultKind: 'Component' });
      emit('partOf', spec.system, { defaultKind: 'System' });
      emit('providesApi', spec.providesApis, { defaultKind: 'API' });
      emit('consumesApi', spec.consumesApis, { defaultKind: 'API' });
      emit('dependsOn', spec.dependsOn, {});
      break;
    case 'API':
      emit('ownedBy', spec.owner, { defaultKind: 'Group' });
      emit('partOf', spec.system, { defaultKind: 'System' });
      break;
    case 'Resource':
      emit('ownedBy', spec.owner, { defaultKind: 'Group' });
      emit('partOf', spec.system, { defaultKind: 'System' });
      emit('dependsOn', spec.dependsOn, {});
      break;
    case 'System':
      emit('ownedBy', spec.owner, { defaultKind: 'Group' });
      emit('partOf', spec.domain, { defaultKind: 'Domain' });
      break;
    case 'Domain':
      emit('ownedBy', spec.owner, { defaultKind: 'Group' });
      break;
    case 'Group':
      emit('childOf', spec.parent, { defaultKind: 'Group' });
      emit('parentOf', spec.children, { defaultKind: 'Group' });
      emit('hasMember', spec.members, { defaultKind: 'User' });
      break;
    case 'User':
      emit('memberOf', spec.memberOf, { defaultKind: 'Group' });
      break;
    default:
  }
  return { relations: out, errors };
}

function ruleAllows(rules, kind, location) {
  return rules.some(rule => {
    if (rule.locations && !rule.locations.some(l => l.exact === location)) return false;
    return (rule.allow || []).some(k => String(k).toLowerCase() === String(kind).toLowerCase());
  });
}

async function main() {
  const list = await readInput();
  const repos = {};
  let appConfigText = null;
  for (const item of list.items || []) {
    const name = item.metadata.name;
    if (name.startsWith('repo-')) {
      repos[name.slice(5)] = { data: item.data || {}, annotations: item.metadata.annotations || {} };
    } else if (name === 'catalog-config') {
      appConfigText = (item.data || {})['app-config.yaml'] || null;
    }
  }

  const report = { config: null, configError: null, repos: Object.keys(repos), locations: [], entities: [], errors: [], conflicts: [], unresolved: [] };

  let catalogCfg = {};
  if (appConfigText) {
    const parsed = parseYaml(appConfigText)[0];
    if (parsed && parsed.error) report.configError = parsed.error;
    else catalogCfg = (parsed && parsed.value && parsed.value.catalog) || {};
    report.config = catalogCfg;
  }

  const rules = [];
  if (Array.isArray(catalogCfg.rules)) rules.push(...catalogCfg.rules);
  else rules.push(...DEFAULT_RULES);
  const seeds = [];
  for (const l of catalogCfg.locations || []) {
    if (Array.isArray(l.rules)) for (const r of l.rules) rules.push({ allow: r.allow, locations: [{ exact: l.target }] });
    seeds.push({ type: l.type, target: l.target, origin: 'config' });
  }

  // Entity providers: github discovery, modelled on catalog.providers.github.<id>
  const github = (catalogCfg.providers && catalogCfg.providers.github) || {};
  for (const [id, p] of Object.entries(github)) {
    const filters = p.filters || {};
    const catalogPath = String(p.catalogPath || '/catalog-info.yaml').replace(/^\//, '');
    for (const [repoName, repo] of Object.entries(repos)) {
      const a = repo.annotations;
      const topics = (a['astrona.io/topics'] || '').split(',').filter(Boolean);
      const visibility = a['astrona.io/visibility'] || 'public';
      const branch = a['astrona.io/default-branch'] || 'main';
      const fork = a['astrona.io/fork'] === 'true';
      if (a['astrona.io/organization'] && p.organization && a['astrona.io/organization'] !== p.organization) continue;
      if (filters.repository && !new RegExp(filters.repository).test(repoName)) continue;
      if (filters.branch && filters.branch !== branch) continue;
      if (filters.allowForks === false && fork) continue;
      if (filters.topic && filters.topic.include && !filters.topic.include.some(t => topics.includes(t))) continue;
      if (filters.topic && filters.topic.exclude && filters.topic.exclude.some(t => topics.includes(t))) continue;
      if (filters.visibility && !filters.visibility.includes(visibility)) continue;
      seeds.push({ type: 'url', target: `${HOST}${repoName}/blob/${branch}/${catalogPath}`, origin: `provider:github:${id}`, provider: true });
    }
  }

  const claims = {};
  const seen = new Set();
  const queue = [...seeds];
  while (queue.length) {
    const loc = queue.shift();
    const key = `${loc.type}:${loc.target}`;
    if (seen.has(key)) continue;
    seen.add(key);
    const locRec = { type: loc.type, target: loc.target, origin: loc.origin, status: 'ok', entities: [] };
    report.locations.push(locRec);
    if (loc.type !== 'url' || !String(loc.target).startsWith(HOST)) {
      locRec.status = 'unsupported-target';
      report.errors.push({ location: loc.target, stage: 'fetch', message: `No reader can read ${loc.type}:${loc.target}` });
      continue;
    }
    const parts = loc.target.slice(HOST.length).split('/');
    const [repoName, blob, branch, ...file] = parts;
    const repo = repos[repoName];
    const fileName = file.join('/');
    const repoBranch = repo ? repo.annotations['astrona.io/default-branch'] || 'main' : 'main';
    if (!repo || blob !== 'blob' || branch !== repoBranch || !(fileName in repo.data)) {
      locRec.status = 'not-found';
      report.errors.push({ location: loc.target, stage: 'fetch', message: 'NotFoundError: the file does not exist at this location' });
      continue;
    }
    for (const doc of parseYaml(repo.data[fileName])) {
      if (doc.error) {
        report.errors.push({ location: loc.target, stage: 'parse', message: `YAML parse error: ${doc.error}` });
        continue;
      }
      const e = doc.value;
      if (e === null || typeof e !== 'object') continue;
      const declared = `${String(e.kind || '').toLowerCase()}:${String((e.metadata && e.metadata.namespace) || 'default').toLowerCase()}/${String((e.metadata && e.metadata.name) || '').toLowerCase()}`;
      const rec = { location: loc.target, origin: loc.origin, kind: e.kind, declared, valid: true, errors: [] };
      try {
        await policy.enforce(e);
      } catch (err) {
        rec.valid = false;
        rec.errors.push(`policy: ${err.message}`);
      }
      if (rec.valid) {
        let handled = false;
        for (const v of kindValidators) {
          try {
            if (await v.check(e)) handled = true;
          } catch (err) {
            rec.valid = false;
            rec.errors.push(`kind: ${err.message}`);
            handled = true;
          }
        }
        rec.kindRecognized = handled;
      }
      if (rec.valid) {
        rec.ref = refOf(e);
        rec.namespace = e.metadata.namespace || 'default';
        rec.name = e.metadata.name;
        rec.allowed = ruleAllows(rules, e.kind, loc.target);
        if (!rec.allowed) {
          rec.errors.push(`rules: entity of kind ${e.kind} is not allowed from location url:${loc.target}`);
        }
        rec.metadata = e.metadata;
        rec.spec = e.spec || {};
        rec.metadata.annotations = { ...(e.metadata.annotations || {}), 'backstage.io/managed-by-location': `url:${loc.target}` };
        const rel = relationsOf(e);
        rec.relations = rel.relations;
        for (const m of rel.errors) rec.errors.push(`relations: ${m}`);
        if (rec.errors.length) rec.ingested = false;
        else rec.ingested = true;
        if (rec.ingested) {
          (claims[rec.ref] = claims[rec.ref] || []).push(loc.target);
          if (e.kind === 'Location') {
            const targets = [].concat(e.spec.target || [], e.spec.targets || []);
            for (const t of targets) {
              const resolved = /^https?:\/\//.test(t) ? t : new URL(t, loc.target).toString();
              queue.push({ type: e.spec.type || 'url', target: resolved, origin: loc.target });
            }
          }
        }
      }
      locRec.entities.push(rec.ref || `(invalid) ${declared}`);
      if (rec.errors.length) {
        for (const m of rec.errors) report.errors.push({ location: loc.target, stage: m.split(':')[0], entity: rec.ref || declared, message: m });
      }
      report.entities.push(rec);
    }
  }

  for (const [ref, locs] of Object.entries(claims)) {
    if (locs.length > 1) {
      report.conflicts.push({ ref, locations: locs });
      for (const e of report.entities) if (e.ref === ref && e.ingested && e.location !== locs[0]) e.ingested = false;
    }
  }
  const known = new Set(report.entities.filter(e => e.ingested).map(e => e.ref));
  for (const e of report.entities) {
    if (!e.ingested || !e.relations) continue;
    for (const r of e.relations) if (!known.has(r.target)) report.unresolved.push({ from: e.ref, type: r.type, target: r.target });
  }
  report.summary = {
    ingested: report.entities.filter(e => e.ingested).map(e => e.ref).sort(),
    errorCount: report.errors.length,
  };
  process.stdout.write(JSON.stringify(report));
}

main().catch(err => {
  process.stdout.write(JSON.stringify({ fatal: String(err && err.stack ? err.stack : err) }));
  process.exit(1);
});
