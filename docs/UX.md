# UX contract

## Character

Disk Lens feels precise, calm, and tactile: an instrument panel rather than a generic system monitor. Hierarchy, proportion, alignment, and exact values do the work; warning colors are reserved for actual storage pressure.

## Current visual language

- Every surface, text role, border, focusable control, and semantic status derives from current Omarchy shell tokens.
- A compact monospaced presentation keeps paths, sizes, timestamps, and filesystem identifiers aligned.
- Accent marks active selection and activity; urgent color is reserved for critical capacity and failures.
- Treemap color stays categorical and area alone represents allocated size.
- Light and dark theme acceptance use the same semantic hierarchy.

## Bar widget and panel

Every bar orientation uses one square slot containing a proportional pie gauge. The percentage is absent from the bar and remains available in the tooltip, accessibility name, and panel. While a scan runs, a thin activity ring orbits the gauge without changing its capacity meaning. Middle-click refreshes capacity; ordinary click opens the host-owned `KeyboardPanel` through the live bar pointer route.

The compact panel has five stable zones:

1. slim header with the same pie gauge, pressure, and scan state;
2. condensed Home-filesystem capacity rail with exact values;
3. scope, refresh/cancel, search, view, and filter controls;
4. first-use/status surface or the analysis canvas;
5. a focused selection inspector with **Drill in**, **Open**, and **Ask Omarchy**.

The panel scrolls when content exceeds its fitted height, keeping small displays usable. No dependency or package-install row competes with the analysis result.

## Treemap and ranked list

Both views are projections of one model. Treemap area represents allocated bytes and only renders a label when its rectangle is large enough. Pointer selection updates the shared inspector; an explicit **Drill in** action changes scope.

The ranked list shows name, proportional bar, exact allocated size, and directory/file treatment. The 80-entry render bound is stated in the UI; filters expose a narrower result without changing stored scan totals. Control characters are repaired for display and invalid UTF-8 paths are not actionable.

For an actionable selected directory, **Ask Omarchy** is visually primary without displacing **Drill in** or **Open**. Activating it closes the panel and opens the configured default agent with a read-only diagnostic question.

## Filters

Current controls provide case-insensitive name search; files, directories, or all types; hidden entries off or shown; any size, at least 100 MiB, or at least 1 GiB; and any age, modified within 7 days, 30 days, or 1 year. Active controls have selected styling, **Clear filters** becomes available when needed, and the result header labels visible bytes plus visible/total entry counts.

## State model

| State | Visible behavior | Recovery |
| --- | --- | --- |
| First use | Capacity plus an explanation that no scan has run | Scan Home |
| Scanning | Activity rings, status text, and spinning cancel affordance while the last completed result remains intact | Cancel or wait |
| Ready | Timestamp, shared analysis model, and filtered totals | Refresh or drill in |
| Partial | Warning count and first warning remain above usable results | Scan a narrower scope |
| Cancelled | Last completed result remains when one exists | Refresh |
| Failed | Scoped parser/process error while capacity remains available | Retry or choose parent |
| Empty | Complete scope has no immediate entries | Scan parent |
| Filtered empty | No stored entry matches the current projection | Clear filters |
| Agent dispatched | Panel closes and the configured agent terminal owns focus | Continue there or close it |

## Accessibility boundary

The bar has a semantic button role and descriptive name. Panel controls are keyboard-focusable, the search field is the initial focus target, Escape closes the panel, and list/treemap information is duplicated in exact text and the inspector. The filtered-list keyboard input and clear action have passed real-session QMP acceptance.

Only an active scan uses custom looping motion. The same state is always communicated through literal status text, control labels, and accessibility metadata. Full keyboard traversal, treemap keyboard selection, screen-reader announcements, WCAG contrast, pointer targets, and composed reduced-motion behavior remain public-release gates.

## Proven visual matrix and gaps

The disposable lab matrix includes synthetic first-use, active scanning, compact ready treemap, selected-folder agent action, filtered list, cancelled, partial, long-scope, empty, and removed states in maintained dark and light themes. Warning/critical/unknown capacity fixtures, narrow panels, a dense 5,000-entry model, and complete assistive-technology behavior remain explicit release gaps.
