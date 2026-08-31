# Product contract

## Promise

Omarchy Disk Lens makes Home-filesystem pressure understandable within seconds and provides a clear, fully native route from “the disk is filling up” to “this directory deserves investigation.”

## Implemented `0.5.1` journey

1. The bar shows used capacity for the filesystem backing Home as a compact proportional pie gauge.
2. Clicking the widget opens a theme-native panel without starting a recursive scan.
3. Capacity is immediately available when `findmnt` succeeds; scan freshness is independently labelled.
4. The user types an absolute or Home-relative path, or chooses one through the inline folder browser; neither action measures disk usage until the user opens that scope.
5. The user explicitly starts or refreshes an immediate-child scan; one bounded bar activity ring and status text stay visible until that job ends.
6. A squarified treemap and ranked list reveal the largest entries from the same canonical model; hidden entries are included by default.
7. Search and type, hidden-entry, minimum-size, and modification-age filters narrow only the visible projection.
8. Selection exposes exact allocated size, type, modification time, and safe actions.
9. An actionable directory can be drilled into, opened in the file manager, or sent to the configured Omarchy agent with a read-only explanation request. Back restores a bounded in-memory result instead of rescanning when that scope remains cached.
10. One actionable selected file or directory can be moved to desktop Trash after an exact-target confirmation that starts on Cancel. Success invalidates stale snapshots and remeasures the current scope; failure leaves the entry untouched and visible.
11. The agent prompt includes a control-free, length-bounded path value and measured allocation after a fixed read-only trust boundary, then asks why the directory is large, whether it is necessary, what may be reclaimable, and whether deletion is safe.

## Implemented capabilities

### Bar and capacity

- Proportional pie gauge in one square bar slot, plus used percentage, mount target, filesystem type, used bytes, and available bytes inside the panel and tooltip.
- Quiet, pressure, critical, and unavailable presentation at fixed 75% and 90% thresholds.
- One-minute capacity refresh independent from directory scans.

### Analysis panel

- One explicit, cancellable scan at a time.
- One purposeful live activity ring in the bar without replacing the last completed result.
- Immediate children and total allocated bytes for one absolute, same-filesystem scope.
- Editable absolute or `~/` scope input and an inline shallow folder browser.
- Directory drill-down plus bounded history and in-memory result restoration for instant Back navigation.
- Ranked list and proportional treemap with shared selection.
- Name, minimum size, file/directory, hidden-entry, and recent-modification filters, with hidden entries shown by default.
- Freshness, filtered totals, warning count, and partial-result labelling.
- First-use, scanning, ready, partial, cancelled, failed, empty, and filtered-empty states.
- Safe native actions: Back, choose folder, drill in, open in file manager, refresh, cancel, clear filters, Ask Omarchy, and a confirmed move to desktop Trash.

### Recoverable removal

- **Trash** appears only for a selected actionable immediate child from the current validated scan.
- The modal shows the exact path and measured allocation, starts on **Cancel**, and requires an explicit second choice before launching any process.
- The helper refuses UID `0`, the scanned scope itself, the Home directory itself, a missing target, and anything outside the active scope; the path remains one structural `gio trash` argument.
- Disk Lens never empties Trash or falls back to permanent deletion. It explains that capacity is reclaimed only after Trash is emptied.
- Unsupported filesystems and mounts retain the selected item and return a dismissible inline error.

### Omarchy agent guidance

- **Ask Omarchy** appears only for a selected actionable directory.
- One structured prompt argument carries a control-free, 4,096-character-bounded path value, allocated byte count, and human-readable size through the maintained `omarchy agent prompt` contract.
- The prompt places read-only rules before an explicitly delimited untrusted-filesystem-data block, separates findings from guesses, forbids filesystem changes, and asks for explicit confirmation before any change-oriented command is proposed.
- Disk Lens closes its panel after dispatch so the agent terminal owns attention and lifecycle.

## Quality attributes

- **Beautiful:** restrained theme-native surfaces, strong hierarchy, balanced density, semantic color, and a useful rather than decorative treemap.
- **Useful:** exact values remain reachable through the list and inspector.
- **Responsive by design:** panel opening and capacity never wait for a traversal; the recursive scan uses one `du` walk and bounded metadata/JSON batches, while the folder browser performs only a shallow directory listing.
- **Honest:** filesystem capacity, directory allocation, filtered totals, incomplete traversal, and Btrfs uncertainty remain distinct.
- **Recoverable:** cancellation preserves the last completed result, selected-item removal uses desktop Trash, and every failure state names a next action.
- **Self-contained:** the full visual analysis flow needs no additional graphical package.
- **Private by default:** capacity and directory analysis stay local. The explicit agent hand-off delegates path and size data to the user's configured agent, whose provider and network behavior are outside Disk Lens.

## Non-goals for `0.5.1`

- Automatic cleanup, permanent deletion, empty-Trash management, bulk actions, or scripted recipes.
- Root scanning, a privileged GUI, or privilege handling inside Disk Lens.
- Continuous recursive indexing, filesystem watching, or persistent scan caches. The bounded navigation cache exists only for the lifetime of the loaded service.
- A complete explanation of Btrfs snapshots, reserved space, open-deleted files, sparse files, reflinks, shared extents, or compression.
- Remote, cloud, and network-share analytics or telemetry.
- Sandboxing, selecting, authenticating, or configuring the user's coding agent.

## Milestone success criterion

The development milestone succeeds when a user can type or browse to a synthetic scope, identify a dominant directory with hidden entries present, drill into it, return through the visible Back control without a new scan, narrow the view, ask the configured Omarchy agent about it through a verified non-destructive prompt, and deliberately move one exact synthetic entry to Trash; the same disposable-guest flow must retain data when confirmation is cancelled, Trash is unsupported, a scan is cancelled, or a directory is unreadable. Public-release criteria remain in [`RELEASE.md`](RELEASE.md).
