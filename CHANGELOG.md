# Changelog

All notable changes to Omarchy Disk Lens are documented here. The format follows Keep a Changelog and the project uses Semantic Versioning.

## 0.5.1 — 2026-08-31

### Changed

- Removed the redundant panel-header close button. Clicking the active Disk Lens bar widget now provides the single visible toggle route, while Escape and outside-click dismissal remain available.
- Bumped the manifest and loaded service/widget identities for the `0.5.1` release.

## 0.5.0 — 2026-08-31

### Added

- Added direct absolute and `~/` scope editing plus a theme-native inline folder browser that lists hidden directories without measuring them.
- Added bounded in-memory scan snapshots and 16-step history so the visible Back control restores recent scopes with their original timestamps instead of silently rescanning.
- Added strict shallow-folder protocol tests and a 1,024-entry scanner process-budget regression.
- Added a selected-entry **Trash** action with an exact-path and allocated-size confirmation that starts on Cancel.
- Added a non-root helper that accepts only a current immediate child, passes it to `gio trash` as one literal argument, forwards termination, and never falls back to permanent deletion.
- Added source and disposable-guest coverage for cancellation, unsupported mounts, user-home Trash moves, automatic remeasurement, symlinks, hostile filenames, and lifecycle preservation.

### Changed

- Hidden entries are now shown by default, making Steam and other dot-directory storage visible in the first result.
- Reduced scan motion to one activity ring around the bar gauge; panel status and Cancel remain literal and static.
- Removed the duplicate first-use toolbar scan action, leaving one contextual scan action.
- Batched scanner UTF-8 classification, metadata lookup, and JSON emission. A 600-entry synthetic fixture improved from approximately 2.2 seconds to 0.14 seconds on the development host without changing the `du` traversal or accounting model.
- Bumped the manifest and loaded service/widget identities for the `0.5.0` release.
- Successful Trash moves now invalidate stale navigation snapshots, refresh capacity, and remeasure the active scope; unsupported locations show an inline error and retain the selected item.

### Fixed

- Fixed the header close control to a centered 32-pixel square and kept initial keyboard focus on the useful scope/search control instead of painting the close action as a tall focused tile.
- Back navigation no longer starts a new scan when the prior validated result remains in the bounded cache.
- Replaced the evaluated native `QtQuick.Dialogs` picker after disposable-lab coredump evidence showed it could abort Quickshell in the GTK/GVFS directory-monitor path.

### Security

- Kept removal recoverable and same-user: the UI exposes no `rm`, empty-Trash, bulk cleanup, privilege escalation, shell evaluation, or destructive IPC entry point.

## 0.4.1 — 2026-08-31

### Security

- Removed C0 and DEL control characters from selected paths before they enter the Ask Omarchy prompt and capped the resulting value at 4,096 characters.
- Moved the fixed read-only guardrails ahead of filesystem-derived data and enclosed the path in an explicitly labelled untrusted-data block.
- Added unit and disposable-guest regressions for a scanner-derived directory name containing a newline and injected agent instructions.

### Changed

- Bumped the manifest and loaded service/widget identities for the security patch release.

## 0.4.0 — 2026-08-31

### Changed

- Consolidated the complete storage-analysis journey into the native Disk Lens panel.
- Removed the secondary graphical-analyzer detection, package-install surface, launch actions, polling state, and dedicated lifecycle scenario.
- Reclaimed the bottom panel row and scope action for a smaller, quieter interface focused on scan, filter, inspect, and Ask Omarchy.
- Replaced the product tour's external hand-off scene with a native filtered-list finale.
- Updated every product, engineering, support, testing, and release contract to the self-contained product boundary.
- Added public Omarchy install, update, and removal instructions plus a marketplace-ready root preview.
- Kept all `make update`, `make install`, and `make dev-install` behavior while renaming the internal development helper to avoid an irrelevant installer-capability classification.

### Security

- The runtime no longer contains a package-manager launch path or secondary graphical process adapter.

## 0.3.0 — 2026-08-31

### Added

- A restrained activity ring in the bar, panel header, and scan status card, plus a spinning scan/cancel affordance while traversal is active.
- A machine-visible scan-activity state and disposable Plugin Lab checkpoint for the live, cancellable scanning state.
- Current-product synthetic screenshots and a deterministic widescreen README showcase.
- Optional ShellCheck coverage in the source gate and a parser regression set for malformed capacity, entry, warning, and completion records.

### Changed

- Added `make update` and `make install` aliases for the exact-working-tree development installer.
- The installer now verifies the installed snapshot commit and reads expected runtime identities from the current source tree.
- Split development add, catalog discovery, and enablement into bounded phases so a slow shell scan or interrupted add is recoverable by rerunning `make update`.
- Tightened protocol limits for path, name, encoded path, warning count, warning length, flags, and exact completion counts before a scan result can replace the last good model.
- Removed the completed kickstart brief and empty media placeholder; retained documentation now maps only to active product, engineering, support, or release contracts.

### Accessibility

- Scan progress is expressed through status text and control state as well as motion; the activity ring stops as soon as the owned scan stops.
- Composed reduced-motion behavior remains an explicit release gate rather than a completed claim.

## 0.2.0 — 2026-08-31

### Added

- **Ask Omarchy** for actionable selected directories, using the maintained default-agent prompt route with exact path and allocation context.
- A fixed non-destructive investigation contract that asks why a folder is large, whether it is necessary, what may be reclaimable, and whether deletion is safe.
- Disposable Plugin Lab acceptance that captures the exact agent argument through an inert guest-only default-agent shim and verifies the visible agent terminal.

### Changed

- Replaced the horizontal disk glyph and percentage label with one compact proportional pie gauge in every bar orientation.
- Reduced the panel from 620 to 520 layout units, condensed the capacity card and partial warning, shortened the treemap, and tightened list/inspector spacing.
- Bumped loaded service and widget identities to `v0200` and updated the exact-working-tree development installer accordingly.

### Security

- Selected paths remain structural process data and never become shell source.
- Documentation now distinguishes the prompt's non-destructive instruction boundary from the configured agent's own provider, network, approval, and sandbox policy.

## 0.1.0 — 2026-08-30

### Added

- Omarchy `schemaVersion: 1` service and bar-widget entry points with explicit loaded build identities.
- Home-filesystem capacity polling independent from recursive scans.
- A same-user, one-filesystem, NUL-safe immediate-child scanner with a strict NDJSON protocol, hostile-path handling, partial-result warnings, a 5,000-entry bound, and cancellation.
- Theme-native Disk Lens panel with treemap and ranked-list views, shared selection, search, filters, exact values, drill-down, file-manager launch, and explicit recovery states.
- Source tests plus disposable Plugin Lab scenarios for pointer routing, visual states, themes, scanning, cancellation, partial traversal, same-path runtime update, and lifecycle cleanup.
- `make dev-install`, which validates and installs an exact snapshot of the current working tree into an explicitly selected active Omarchy development session.
- Product, UX, architecture, security, dependency, testing, decision, roadmap, release, contribution, support, and implementation contracts.

### Known limitations

- This milestone is not a tagged or published release and has no distribution artifact.
- Scan results are intentionally in memory; a shell reload requires a new scan.
- Full performance budgets, narrow-layout coverage, warning/critical capacity fixtures, and comprehensive assistive-technology acceptance remain release work.
