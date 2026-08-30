# Product contract

## Promise

Omarchy Disk Lens makes Home-filesystem pressure understandable within seconds and provides a clear route from “the disk is filling up” to “this directory deserves investigation.” It is a fast Omarchy-native overview with an optional hand-off to QDirStat, not a replacement for QDirStat's complete desktop analyzer.

## Implemented `0.1.0` journey

1. The bar shows used capacity for the filesystem backing Home.
2. Clicking the widget opens a theme-native panel without starting a recursive scan.
3. Capacity is immediately available when `findmnt` succeeds; scan freshness is independently labelled.
4. The user explicitly starts or refreshes an immediate-child scan.
5. A squarified treemap and ranked list reveal the largest entries from the same canonical model.
6. Search and type, hidden-entry, minimum-size, and modification-age filters narrow only the visible projection.
7. Selection exposes exact allocated size, type, modification time, and safe actions.
8. An actionable directory can be drilled into, opened in the file manager, or handed to QDirStat.
9. If QDirStat is absent, an explicit action opens its AUR installation command in a visible terminal; core analysis remains available.

## Implemented capabilities

### Bar and capacity

- Home-filesystem used percentage, mount target, filesystem type, used bytes, and available bytes.
- Quiet, pressure, critical, and unavailable presentation at fixed 75% and 90% thresholds.
- One-minute capacity refresh independent from directory scans.

### Analysis panel

- One explicit, cancellable scan at a time.
- Immediate children and total allocated bytes for one absolute, same-filesystem scope.
- Parent navigation and directory drill-down.
- Ranked list and proportional treemap with shared selection.
- Name, minimum size, file/directory, hidden-entry, and recent-modification filters.
- Freshness, filtered totals, warning count, and partial-result labelling.
- First-use, scanning, ready, partial, cancelled, failed, empty, and filtered-empty states.
- Safe actions: parent, drill in, open in file manager, refresh, cancel, clear filters, and open in QDirStat.

### QDirStat

- Optional executable detection and live re-detection.
- Explicit missing-dependency copy and a visible terminal with `omarchy pkg aur add qdirstat`.
- QDirStat launch as the desktop user with the selected directory as a structural argument.
- Plugin removal leaves QDirStat installed and running.

## Quality attributes

- **Beautiful:** restrained theme-native surfaces, strong hierarchy, balanced density, semantic color, and a useful rather than decorative treemap.
- **Useful:** exact values remain reachable through the list and inspector.
- **Responsive by design:** panel opening and capacity never wait for a traversal; quantitative budgets remain release work.
- **Honest:** filesystem capacity, directory allocation, filtered totals, incomplete traversal, and Btrfs uncertainty remain distinct.
- **Recoverable:** cancellation preserves the last completed result and every current failure/dependency state names a next action.
- **Private:** all analysis stays local and no path or metadata is transmitted.

## Non-goals for `0.1.0`

- Automatic cleanup, deletion, trash management, bulk actions, or scripted recipes.
- Root scanning, a privileged GUI, or privilege handling inside Disk Lens.
- Continuous recursive indexing, filesystem watching, or persistent scan caches.
- Embedding the QDirStat window.
- QDirStat `pkg:`, `unpkg:`, or cache-file integrations.
- A complete explanation of Btrfs snapshots, reserved space, open-deleted files, sparse files, reflinks, shared extents, or compression.
- Remote, cloud, and network-share analytics or telemetry.

## Milestone success criterion

The development milestone succeeds when a user can identify a dominant synthetic directory, narrow the view, drill into it, and open that exact scope in a real QDirStat window; the same disposable-guest flow must remain understandable when QDirStat is absent, a scan is cancelled, or a directory is unreadable. Public-release criteria remain in [`RELEASE.md`](RELEASE.md).
