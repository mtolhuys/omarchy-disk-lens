# Architecture decisions

## D001 — Native overview, external deep dive

**Decision:** Build a native Omarchy capacity and directory overview, then launch QDirStat for specialist analysis.

**Why:** A launcher alone does not justify a plugin, while reimplementing all of QDirStat would create a large, weaker duplicate. The split gives Omarchy a fast, coherent daily surface and preserves QDirStat's mature tree, treemap, package, cache, and cleanup functionality.

**Consequence:** QDirStat is not embedded. The selected path and a small reviewed set of URL/cache inputs form the integration boundary.

## D002 — QDirStat remains optional and explicitly installed

**Decision:** Disk Lens works without QDirStat. Missing dependency UI opens a visible terminal with `omarchy pkg aur add qdirstat` only after a user click.

**Why:** Omarchy plugins do not gain trust by silently running AUR builds or privilege prompts. Explicit terminal ownership preserves review and cancellation.

**Consequence:** The UI models missing, launched, cancelled/unchanged, and available as distinct states.

## D003 — No destructive native actions in version 1

**Decision:** The panel can navigate, inspect, open, and refresh, but cannot delete or clean.

**Why:** A compact system panel is a poor place for ambiguous, high-impact cleanup. QDirStat already provides a more deliberate environment for those workflows.

**Consequence:** Any future cleanup feature needs a new product contract, threat model, undo/recovery design, and acceptance suite.

## D004 — Capacity polling is separate from recursive scanning

**Decision:** Cheap filesystem capacity may refresh periodically; recursive scans occur only on explicit request.

**Why:** Continuous traversal wastes I/O, can wake disks, changes performance unpredictably, and surprises users.

**Consequence:** Results carry freshness and completeness metadata. The bar never implies that its percentage came from the last directory scan.

## D005 — Immediate-child scans enable progressive drill-down

**Decision:** Version 1 scans and visualizes the immediate children of one scope, then rescans on drill-down.

**Why:** This bounds the UI model, makes cancellation and partial results tractable, and matches how users investigate dominant branches.

**Consequence:** A full retained filesystem tree or shared QDirStat cache is deferred until it demonstrates clear value and bounded cost.

## D006 — One canonical result model serves treemap and list

**Decision:** Treemap and ranked list are projections of the same scan, filter, selection, and totals model.

**Why:** Two data paths drift, confuse selection, and make accessibility unreliable.

**Consequence:** Visual grouping such as “Other” cannot erase access to underlying entries in the list/inspector.

## D007 — Do not parse human-formatted `dua` output

**Decision:** Use a small versioned helper protocol instead of treating `dua aggregate` output as an API.

**Why:** `dua` is fast and already present, but its current aggregate interface offers formatting modes rather than stable JSON. Presentation parsing is fragile across versions, locales, and path edge cases.

**Consequence:** `dua` remains available as Omarchy's terminal disk tool and may become a backend if upstream exposes a suitable machine contract.

## D008 — Publish claims only after real shell acceptance

**Decision:** Documentation may describe target behavior during development, but install/use claims move to present tense only after the exact candidate passes disposable Plugin Lab acceptance.

**Why:** A valid manifest or attractive screenshot does not prove hot loading, pointer routing, cancellation, or lifecycle cleanup.

**Consequence:** Release evidence is a first-class artifact and the README names the project as a development preview until every public-release gate passes.

## D009 — Ask the maintained Omarchy agent, never build a cleanup agent

**Decision:** A selected actionable directory can be sent through `omarchy agent prompt` with its measured allocation and a fixed, read-only explanation request. Disk Lens does not parse the answer or execute a cleanup result.

**Why:** Users need help interpreting unfamiliar caches and application data, but embedding agent selection, provider credentials, or destructive automation would duplicate Omarchy and expand the trust boundary dramatically.

**Consequence:** The selected path is a structural process argument inside one prompt, the panel closes after dispatch, and documentation states that the configured agent's provider, network, approval, and sandbox policies still apply.
