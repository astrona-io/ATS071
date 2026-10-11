---
draft: true
exam_objectives:
- Working with automated ingestion
---
# Entity Providers, Discovery Scope And Repeatable Ingestion

Automated catalog ingestion reduces manual registration work by discovering data from defined systems. An entity provider can obtain records from a source host, organization directory or another inventory. It supplies entities to the catalog under a provider identity and maintains the set it owns. Processors then perform interpretation, validation, enrichment and relationship work. The two roles cooperate but should not be treated as interchangeable.

Provider scope determines what enters the catalog. A source-host provider might consider selected organizations, repositories, paths and branches. A directory provider might consider particular users and groups. These filters are operational and security decisions. Discovering every accessible source is not necessarily the desired outcome, especially when some repositories contain confidential or unsupported metadata.

The provider's credential needs suitable reading access for that scope. Too little authority produces missed or failed discovery. Too much authority increases exposure and can allow the application to observe sources it should not publish. Credentials belong in protected server configuration, while descriptors and public catalog fields remain free of secrets. An integration token is not a substitute for defining the provider's ownership boundary.

Updates can be full or incremental, depending on the provider contract. A full update describes the provider's current owned set. An incremental update adds or removes specified entities relative to prior state. If a full discovery run accidentally returns only a small subset because a request failed, treating that subset as authoritative can affect removal behavior. The provider must distinguish incomplete collection from a genuine disappearance.

Consider a directory integration maintaining team entities. A temporary pagination failure could omit half the teams. A robust design reports the incomplete run rather than presenting the partial result as a complete directory. Otherwise relationships from software Components can lose their owners even though those teams still exist. This is a lifecycle consequence of the update contract, not a browser-rendering problem.

Scheduling controls freshness and external load. Frequent scans can update quickly but consume source-host rate limits and catalog capacity. Long intervals reduce load while increasing delay. Event-driven hints can shorten the delay, but a dependable process still needs recovery when an event is missed. The intended freshness should be observable through run status and processing evidence rather than assumed from the existence of a scheduler.

Providers own their emitted entities, so stable identity is essential. Two providers cannot safely claim the same canonical entity without deliberate coordination. A manual source may also overlap with automated discovery. Clear conventions for namespaces, source authority and retirement help avoid duplicate or conflicting records. Changing only the visible title leaves the underlying identity conflict untouched.

Automated removal needs review as carefully as automated addition. A repository becoming inaccessible is not always evidence that its service was retired. Configuration changes, token expiry and organization permissions can also remove visibility. The lifecycle policy should define how missing records, orphaned entities and deliberate retirement are handled. An inventory system should not silently equate a failed request with business deletion.

The useful evidence includes discovered scope, update completeness, provider run status and subsequent processing results. A provider can run successfully while one descriptor fails entity validation. Conversely, processors can be healthy while the provider discovers no inputs. Following both responsibilities makes automation diagnosable instead of merely convenient when everything happens to work.

## Common pitfalls

> [!WARNING]
> An incomplete discovery result must not be mistaken for a complete authoritative update. Limit discovery and credential scope, define source ownership and observe freshness. Automated ingestion does not guarantee accurate relationships or safe deletion without explicit lifecycle policy.
