# Architecture decisions

## D001 — Own the complete native analysis journey

**Decision:** Capacity, scanning, visual comparison, filtering, navigation, exact inspection, and agent guidance form one self-contained Omarchy surface.

**Why:** The compact native flow already answers the primary storage question. An external graphical hand-off adds dependency state, install UI, and context switching without improving that core journey.

**Consequence:** Runtime code contains no package installation or secondary analyzer adapter. Specialist integrations require a new product case and acceptance plan.

## D002 — No destructive native actions

**Decision:** The panel can navigate, inspect, open, refresh, and request read-only guidance, but cannot delete or clean.

**Why:** A compact system panel is a poor place for ambiguous, high-impact cleanup.

**Consequence:** Any future cleanup feature needs a new product contract, threat model, undo/recovery design, and acceptance suite.

## D003 — Capacity polling is separate from recursive scanning

**Decision:** Cheap filesystem capacity may refresh periodically; recursive scans occur only on explicit request.

**Why:** Continuous traversal wastes I/O, changes performance unpredictably, and surprises users.

**Consequence:** Results carry freshness and completeness metadata. The bar never implies that its percentage came from the last directory scan.

## D004 — Immediate-child scans enable progressive drill-down

**Decision:** Scan and visualize the immediate children of one scope, then measure a drilled scope only when it has no completed in-memory snapshot.

**Why:** This bounds the UI model and makes cancellation and partial results tractable.

**Consequence:** A full retained filesystem tree is not part of the current contract.

## D005 — One canonical result model serves treemap and list

**Decision:** Treemap and ranked list are projections of the same scan, filter, selection, and totals model.

**Why:** Two data paths drift, confuse selection, and make accessibility unreliable.

**Consequence:** Visual grouping cannot erase access to underlying entries in the list and inspector.

## D006 — Do not parse human-formatted `dua` output

**Decision:** Use a small versioned helper protocol instead of treating presentation output as an API.

**Why:** Presentation parsing is fragile across versions, locales, and path edge cases.

**Consequence:** A different backend requires a stable machine contract and measured benefit.

## D007 — Publish claims only after real shell acceptance

**Decision:** Install and use claims move to present tense only after the exact candidate passes disposable Plugin Lab acceptance.

**Why:** A valid manifest or attractive screenshot does not prove hot loading, pointer routing, cancellation, or lifecycle cleanup.

**Consequence:** Release evidence is a first-class artifact and the README calls the project a development preview until every public-release gate passes.

## D008 — Ask the maintained Omarchy agent, never build a cleanup agent

**Decision:** Send a selected directory through `omarchy agent prompt` with its measured allocation and a fixed read-only explanation request. Disk Lens does not parse the answer or execute a cleanup result.

**Why:** Users need help interpreting unfamiliar caches and application data, but embedded destructive automation would duplicate Omarchy and expand the trust boundary.

**Consequence:** The panel closes after dispatch, and the configured agent's provider, network, approval, and sandbox policies still apply.

## D009 — Motion belongs only to live scan activity

**Decision:** Use one restrained rotating ring only while the owned scan job is active, duplicated in literal text, controls, and accessibility metadata.

**Why:** A recursive traversal otherwise looks stalled, while perpetual decorative motion adds noise.

**Consequence:** Motion stops immediately when scanning completes, fails, or is cancelled. Composed reduced-motion behavior remains a release gate.

## D010 — Back restores bounded results; Refresh remeasures

**Decision:** Keep a bounded service-lifetime LRU of validated completed scopes, retain Home when it fits, and use it for Back navigation. Only explicit Refresh promises a new measurement.

**Why:** Navigation should be immediate and predictable, while silently rescanning on Back destroys context, burns I/O, and changes results without the user asking.

**Consequence:** Restored scopes keep their original timestamp. The cache is capped at eight scopes and 12,000 total entries, is never persisted, and may fall back to a scan after eviction.

## D011 — Browse folders inside the panel

**Decision:** Use a shallow, NUL-safe helper and a theme-native inline browser instead of a native `QtQuick.Dialogs` folder dialog.

**Why:** The native dialog reproducibly aborted Quickshell in the disposable lab inside the GTK/GVFS directory-monitor path. The inline browser avoids toolkit lifecycle mixing and can share the panel's path validation and styling.

**Consequence:** Browsing never measures disk usage, hidden directories are present, 5,000 entries are accepted, and at most 80 rows are rendered. A different external picker requires crash-free disposable-shell evidence.

## D012 — Batch scanner post-processing

**Decision:** Keep one GNU `du` traversal and batch common-case UTF-8 validation, metadata lookup, and JSON emission instead of spawning helper processes per entry.

**Why:** Per-entry process startup dominated small and dense scopes without improving measurement accuracy.

**Consequence:** A source regression enforces bounded process counts for 1,024 entries; invalid UTF-8 retains its isolated slower path so hostile-name safety is not traded for speed.
