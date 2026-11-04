---
draft: true
exam_objectives:
- Using annotations
---
# Annotation Contracts And External Identity Mapping

This module teaches how annotations connect a catalog entity to the systems around it. By the end, the reader can say what an annotation is, decide whether a value belongs in an annotation, a label, a tag or a spec field, read the common well-known keys, and find an annotation that points at the wrong external object. The module also shows why an annotation is never a permission.

## Why this topic matters

The catalog describes software, but the facts about that software live somewhere else. The source code is in a repository. The documentation is built from a folder. The pods run in a Kubernetes cluster. The build runs in a continuous integration service. A catalog entity does not store those facts. It stores a short string that tells a plugin where to look.

That design keeps the catalog small, but it moves risk to the strings. A wrong string rarely causes an error. It causes a page that shows real data about the wrong component. An engineer who trusts the page during an incident loses time. The skills in this module are about reading these strings carefully and about knowing which component, if any, validates them.

## Learning goals

- Distinguish annotations from labels, tags and core specification fields.
- Explain how a plugin interprets an annotation value, and which component does the work.
- Recognise the well-known annotation keys and the value format each one expects.
- Explain which annotations the catalog adds itself and why authors do not write them.
- Diagnose incorrect integration mappings without treating metadata as permission.
- Repair a descriptor that has an invalid label, a non-string value, an invalid key or a copied identity.

## What to know first

The reader should know that a descriptor is a YAML file with `apiVersion`, `kind`, `metadata` and `spec`, and that the catalog backend reads descriptors from locations and turns them into entities. The module restates every other term when it first appears: entity reference, kind, owner, plugin, processor and location. Basic `kubectl` use and the ability to read JSON output are enough for the hands-on steps.

## The order of the lessons

The module has four lessons and a summary, read in this order.

The first lesson defines an annotation and follows a value from the descriptor to an external system. It shows that the catalog stores a string and checks only its format, and it uses the playground to find a component whose annotations name another component. The lesson also explains why an annotation grants no access.

The second lesson compares the four places for extra information: labels, annotations, tags and spec fields. It gives the key and value rules of each place and shows three failures in the checker: a label value that contains a colon, an annotation value that is not a string, and a required spec field that was written as an annotation.

The third lesson lists the well-known annotation keys, the value format of each key, and the two keys that the catalog backend writes itself. It ends with a repair of a descriptor that holds the values of another component.

The fourth lesson covers tags, links and the annotations that describe the source and the documentation, and shows which values the validator refuses.

The summary closes the module with the facts to remember.

## What the playground is

The playground is a kind cluster, which is a Kubernetes cluster that runs inside containers on the learner's machine. It does not run Backstage. It holds a model of the catalog input, and it holds a small checker.

The descriptor files are stored as ConfigMaps in the namespace `catalog-source`. A ConfigMap named `repo-bridge` stands for one repository called `bridge`. Each key in the ConfigMap is a file name in that repository, such as `catalog-info.yaml`. The ConfigMap `catalog-config` holds the `catalog:` block of the application configuration, including the static locations that tell the catalog which files to read.

A pod in the namespace `catalog-tools` runs a Node.js script. The script reads the ConfigMaps, parses every YAML document and validates each entity with the `@backstage/catalog-model` library, which is the same library that the Backstage catalog backend uses. It also models locations, rules and relations, and it prints one JSON report. The report lists entities, errors and a summary of what the catalog would ingest.

The learner reads the report through a shell function named `inspect_catalog`. The function sends the ConfigMaps to the pod and filters the output with `jq`. The playground guide shows the function.

## What the playground cannot do

The checker is a model of the catalog backend. It is not the Backstage backend, and it does not run plugins. It cannot call GitHub, a documentation builder or a Kubernetes plugin. That limit is useful for this module, because it makes the central point visible: the catalog accepts a well-formed string and leaves the question of whether the string is right to the plugin that reads it.

When a lesson says what a plugin does with a value, the lesson describes the documented behaviour. The playground shows what the catalog stores and what it rejects. The learner confirms the plugin side in a real installation.

## How to work through the lessons

Each lesson has one idea and a few commands. Read the explanation before the command and look at the output before moving on. When a step changes a ConfigMap, the lesson names the file first, shows its content, and then applies it. Every change can be undone by applying the earlier content again.

The playground carries three Components: `bridge`, `scout` and `shuttle`. `bridge` has a complete set of annotations. `scout` has two annotations whose values were copied from `bridge`. `shuttle` has none. The lessons use these differences as examples.

After the third lesson a graded lab starts. It uses the same estate with several mistakes and asks the learner to repair the annotations so that all three Components are ingested and every value names the right object. The task has numbered requirements and gives no hints that contain the answer.

## What the learner can do afterwards

A learner who finishes the module can open any descriptor and review its annotations in three steps. The first step confirms that every key is a known contract and is spelled exactly. The second confirms that every value has the format of its contract. The third confirms that every value names this component's object and no other. The learner can also explain the first thing to check when a plugin card shows data that looks right and belongs to someone else.

<!-- astrona:playground -->
