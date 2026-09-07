# Changelog

All notable changes to Omarchy Disk Lens are documented here. The format follows Keep a Changelog and the project uses Semantic Versioning.

## 0.6.11 — 2026-09-07

### Fixed

- **Panel content no longer overflows the bottom border** when a Trash toast and partial-scan warning stack above results. The list/treemap + selection footer now flex-shrink inside the remaining fitted height so banners never push past the window chrome (including on reopen when restored banners return with results).
- Corrected `KeyboardPanel` sizing to the two-argument `fittedContentHeight(implicit, cap)` form used by other Omarchy panels, so the 640px budget caps the card instead of only the pre-inset content height.

### Changed

- Bumped the manifest and loaded service/widget identities for the `0.6.11` layout overflow fix.

## 0.6.10 — 2026-09-07

### Fixed

- **Open / `o` no longer browser-downloads executables.** Selecting a binary such as `/usr/bin/deno` and pressing **o** previously handed the path to `xdg-open`, whose fallback handler is often the web browser — which then downloaded `file://` copies on every key-repeat.
- Open now routes through a guarded `scripts/disk-lens-open` helper: directories and ordinary documents still use `xdg-open`; executables, `application/octet-stream`, and unknown binaries are **revealed** in the file manager (`flea --select` when Flea is the directory handler, otherwise FreeDesktop `FileManager1.ShowItems`, else the parent folder).
- Debounced Open / `o` and the inspector Open button (~500ms) so held key-repeat cannot spawn a storm of opens.

### Changed

- Bumped the manifest and loaded service/widget identities for the `0.6.10` open-safety fix.

## 0.6.9 — 2026-09-07

### Changed

- Quieted the vertical scan beam into a **premium whisper**: lower opacity, thinner core, no neon white core or hard hairline.
- Replaced stacked-gradient banding/seams with **one coherent soft beam** (single horizontal gradient; motion-relative lead/trail still flips on L↔R reverse).
- Softened motion toward organic radar: gentler cubic ease, longer sweep, subtle opacity breathe — less static stripe sliding.
- Kept the GPU-animated transparent host (no Canvas / no opaque box / no glowing pill) for hero empty-scan and compact refresh overlays.
- Bumped the manifest and loaded service/widget identities for the `0.6.9` beam polish.

## 0.6.8 — 2026-09-07

### Changed

- Made the vertical scan beam **motion-relative**: bright leading edge in the travel direction with a soft comet trail fading behind; trail/lead flip when the L↔R ping-pong reverses.
- Kept the GPU-animated transparent stripe (no Canvas / no opaque host box) for hero empty-scan and compact refresh overlays.
- Bumped the manifest and loaded service/widget identities for the `0.6.8` radar-glow polish.

## 0.6.7 — 2026-09-07

### Changed

- Replaced the Canvas sweep redraw with a GPU-animated vertical scanner stripe (stacked translucent gradients, `x` ping-pong) so the beam stays transparent with no opaque bounding box or frame jank.
- Bumped the manifest and loaded service/widget identities for the `0.6.7` scan motion fix.

## 0.6.6 — 2026-09-07

### Changed

- Rebuilt scan loading as one smooth vertical scanner stripe that ping-pongs left→right→left across the results pane (soft gradient edges, no banded trail, no horizontal pill/blob).
- Hero empty-scan keeps readable status copy over the beam; compact refresh overlays the same vertical stripe on the live list/treemap.
- Redesigned the selection inspector action strip: consistent bordered controls, visible keyboard hints (**Open · o**, **Ask Omarchy · a**, **Trash · x**), and stronger DIRECTORY/date contrast.
- Removed the redundant **Drill in** button — **Enter / →** already drills folders; Ask Omarchy stays the primary directory action.
- Documented the new inspector shortcuts in the Keys sheet and README, and exposed ask/open button centers for lab pointer acceptance.
- Bumped the manifest and loaded service/widget identities for the `0.6.6` release.

## 0.6.4 — 2026-09-07

### Changed

- Replaced the thin results-pane shimmer strip with a marketing-grade full-pane horizontal accent wash: a soft vertical beam with glow trail sweeping left→right→left across the entire scan surface.
- Hero empty-scan fills the clipped results pane behind readable status copy; compact refresh overlays the same wash on the live list/treemap while keeping the last complete result intact.
- Bumped the manifest and loaded service/widget identities for the `0.6.4` motion polish.

## 0.6.3 — 2026-09-07

### Changed

- Replaced the results-pane radar glow with a simpler full-width accent shimmer that sweeps left→right→left while a scan runs (hero empty state and compact refresh strip).
- Kept the “Scanning for the heavy branch…” status copy and the bar activity ring.
- Bumped the manifest and loaded service/widget identities for the `0.6.3` motion polish.

## 0.6.2 — 2026-09-07

### Changed

- Parallelized immediate-child directory measurement with a bounded `du -s` job pool, and sized non-directory children from batched `st_blocks` instead of one serial `du --max-depth=1` walk.
- Enlarged scanner metadata/JSON batches from 64 to 256 entries and replaced linear metadata matching with associative lookups.
- Documented independent per-child allocation accounting (equivalent to `du -s -- child` for each immediate child). Cross-directory hard links may therefore appear in more than one child total; listed entry sizes remain the primary UI contract.
- Bumped the manifest and loaded service/widget identities for the `0.6.2` performance release.

### Fixed

- Cut representative Home and dense shallow-scope scan wall time without changing the NDJSON protocol, cancellation, or hostile-name handling.

## 0.6.1 — 2026-09-07

### Fixed

- Ranked-list keyboard selection (↑↓ / j k) now keeps the current row in view by scrolling only the list pane via `positionViewAtIndex`, with a thin overflow scrollbar and clipping so the outer panel does not scroll with the list.

### Changed

- Bumped the manifest and loaded service/widget identities for the `0.6.1` patch.

## 0.6.0 — 2026-09-07

### Added

- Added a theme-native radar sweep in the results pane while a scan is active: a full hero radar on first measurement, and a compact radar strip when refreshing an existing result. The bar activity ring remains.
- Added in-panel keyboard shortcuts via the stock `PanelKeyCatcher` pattern, a muted **Keys · ?** hint, and a compact shortcut sheet.
- Documented optional Hyprland **Super+Alt+D** panel toggle (same Omarchy bind pattern as Plugin Pulse).

### Changed

- Bumped the manifest and loaded service/widget identities for the `0.6.0` release.
- Scanning status copy in the empty results area now reads as an instrument panel (“Scanning for the heavy branch…”) with the live radar.

## 0.5.2 — 2026-09-01

### Changed

- Reframed the README tour and static marketplace preview around the product's central value: making the largest disk consumers visually obvious.
- Tightened the marketplace and bar-widget descriptions and bumped the manifest plus loaded service/widget identities for the `0.5.2` release.

### Fixed

- Made scanner file-kind classification independent of the desktop locale, so translated `stat` output cannot turn directories into non-actionable entries.
- Normalized valid pre-epoch modification timestamps to the existing unknown-date representation instead of rejecting the complete scan protocol.
- Centralized bounded, control-free process diagnostics before they enter panel state.
- Preserved the complete last-good warning state across refresh cancellation and report the scanner's total warning count even when only the first 20 messages are retained.

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
