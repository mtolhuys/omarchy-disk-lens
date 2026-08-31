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

**Decision:** Scan and visualize the immediate children of one scope, then rescan on drill-down.

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
