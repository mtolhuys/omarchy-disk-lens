# Architecture

```text
Omarchy shell
  ├─ Disk Lens service (kept loaded)
  │    ├─ findmnt disk discovery + capacity process, on mount events and every 60 seconds
  │    ├─ one long-lived findmnt --poll mount watcher
  │    ├─ selected disk persisted to XDG state
  │    ├─ one disk-lens-scan process
  │    ├─ at most one guarded disk-lens-trash process
  │    └─ bounded in-memory result cache with Home retention
  └─ Disk Lens bar widget + KeyboardPanel
       ├─ pie gauge, one activity ring, stacked disk cards, and editable scope controls
       ├─ one shallow disk-lens-folders process while browsing
       ├─ shared filters and selection
       ├─ treemap or ranked list
       └─ structural launches: file manager and Omarchy agent

disk-lens-scan
  └─ immediate children via shell glob
       ├─ real directories: bounded parallel GNU du -s --one-file-system --null
       └─ files/symlinks/other: batched st_blocks accounting
            └─ strict NDJSON protocol version 1

disk-lens-folders
  └─ GNU find -mindepth 1 -maxdepth 1 with NUL output
       └─ strict shallow-folder NDJSON protocol version 1

disk-lens-trash
  └─ gio trash -- EXACT_CURRENT_CHILD
       └─ same-user, exact-scope, recoverable removal boundary
```

## Plugin contract

`manifest.json` uses Omarchy `schemaVersion: 1`, declares `service` and `bar-widget`, and keeps the service loaded. `src/Service.qml` owns capacity and scan process state. `src/BarWidget.qml` follows the host `open()`, `close()`, and `opened` contract and renders a host-owned `KeyboardPanel` anchored to the real bar widget.

Service and widget expose stable IPC state plus independent build identities. Plugin Lab acceptance compares source installation and loaded behavior, and a same-path public update must change both loaded identities.

## Capacity adapter

The service runs locale-independent `findmnt --json --bytes --list` with explicit fields for source, target, filesystem type, size, used, available, and use percentage. `Model.parseDisks` keeps local block filesystems only: FUSE (including rclone), network, tmpfs, squashfs, overlay, and pseudo filesystems are dropped, as are mounts under `/boot`, `/efi`, `/proc`, `/sys`, `/dev`, `/snap`, `/var/lib/docker`, and `/run` except `/run/media`, where udisks mounts removable media (`/media` and `/mnt` are kept too). Loop-backed filesystems are kept when their type is a regular local filesystem; snap images are dropped as squashfs. Btrfs subvolume sources such as `/dev/mapper/root[/@home]` are stripped of their bracketed suffix and collapsed into one disk that keeps every mount target. At most 16 disks are listed. The disk holding `$HOME` comes first and uses `$HOME` as its scan root; every other disk uses its shortest mount target.

The selected disk drives the bar pie, tooltip, and panel analysis scope. Selecting a disk restores its cached result when one exists and otherwise returns the analysis area to first use at that disk's scan root; it never starts a recursive scan. Scanning or restoring a path keeps the selection on the disk whose mount target is the longest prefix of that path. The choice is stored as `{"source", "target"}` in `${XDG_STATE_HOME:-~/.local/state}/omarchy-disk-lens/selected-disk.json` through a Quickshell `FileView` after a structural `mkdir -p`. At service start the saved disk is matched by source and target, then by source alone, then falls back to the Home disk; a fallback does not overwrite the saved choice, so a temporarily unplugged disk is selected again when it returns. A long-lived `findmnt --poll --list --noheadings --output ACTION,TARGET` process reports mount table changes. Each event line restarts a 400 ms debounce that runs one discovery, so a plugged-in or removed disk updates within about half a second; the 60-second timer remains a fallback. If the watcher exits unexpectedly it restarts with exponential backoff (1 s doubling to 60 s, reset after 30 s of uptime) and triggers a discovery for missed events. The service stops it on destruction, so plugin disablement and shell restarts leave no watcher behind.

When a disk disappears, cached results under its mount targets are dropped because the remounted contents may differ, and a scan running on it is cancelled. If it was selected, the panel falls back to the Home disk, shows a one-line notice, and keeps the saved selection; when the saved disk is mounted again it is selected automatically. Explicitly choosing a disk, or scanning a path on another disk, replaces the saved selection. Disks that appear after start are marked **NEW** for eight seconds.

Omarchy's per-widget settings API was not used because it rewrites the user's `shell.json` for what is runtime state owned by the service.

Capacity refreshes at service start, panel open, middle-click, explicit IPC request, and every 60 seconds. None of these paths starts a recursive directory scan.

## Scan adapter

`scripts/disk-lens-scan` accepts exactly `--path ABSOLUTE_DIRECTORY`, refuses UID `0`, resolves the directory, and measures each immediate child independently on the same filesystem. Real directories are sized with a bounded parallel pool of GNU `du -s` jobs (override with `DISK_LENS_SCAN_JOBS`, capped at 32). Non-directory children use batched `stat` block accounting. Records stay NUL-delimited so tabs and newlines cannot split them. Noise directories such as `.git`, `node_modules`, and caches are intentionally measured—they are common disk consumers the product must surface.

The helper emits protocol-versioned NDJSON. The parser requires one start record, no more than 5,000 valid entry records, no more than 20 bounded warnings, and one matching completion record whose path, entry count, warning floor, totals, and completeness flag agree with the parsed stream. Paths, names, encoded paths, flags, warnings, and numeric fields have explicit type or length bounds. Unknown versions, types, malformed JSON, invalid fields, truncation, or missing completion fail the attempt without replacing the last good result.

The QML process collector promotes a complete parsed result atomically. Permission and I/O messages become a bounded, control-free warning set, while the completion record retains the total warning count. Starting or cancelling a replacement scan leaves every last-good result field intact. Cancellation stops the helper, which terminates its owned `du` child and cleans temporary state.

Recursive work is confined to the owned `du -s` workers for real directories. Post-processing classifies UTF-8 once for the common case, then resolves locale-independent file type and modification metadata in groups of 256 with associative path lookups and emits JSON in groups of 256. Valid pre-epoch timestamps normalize to the protocol's unknown-date value instead of invalidating the scan. A source regression proves that 1,024 normal file entries require no more than 10 `stat` processes, 8 `jq` processes, two `iconv` processes, and no standalone `base64` process; invalid UTF-8 uses a deliberately slower isolated fallback. Cancellation terminates every owned measurement child before cleaning temporary state.

## Folder browser adapter

`scripts/disk-lens-folders` resolves one absolute path and lists only its immediate directories through NUL-delimited GNU `find` output. It never computes sizes and never starts the recursive scanner. Its separate strict parser bounds the result to 5,000 folders, rejects protocol inconsistencies, marks invalid UTF-8 entries non-actionable, and renders at most 80 rows.

The browser stays inside the Omarchy panel. A native `QtQuick.Dialogs`/GTK folder dialog was evaluated in the disposable lab and rejected after reproducibly aborting Quickshell inside GLib/GIO's GVFS directory-monitor path despite available memory. The inline adapter avoids mixing that native dialog lifecycle into the long-lived shell process.

## Model and navigation

One active in-memory entry array drives both projections. Filters are pure projections over name, kind, hidden status, minimum allocated bytes, and maximum modification age. Hidden entries are included by default. Filtered bytes are labelled independently from scanned totals. Treemap geometry is bounded to the 48 largest visible entries; the ranked view renders at most 80 and directs the user to filters for further narrowing.

Drilling into an actionable directory pushes the prior scope into a 16-step widget history and starts a new immediate-child scan only when that target has no cache entry. The service retains at most eight completed scopes and 12,000 total entries, with the Home result retained when it fits alongside the active result. Back promotes the cached snapshot atomically and preserves its original timestamp; explicit Refresh always starts a new scan. Scopes and results are not persisted, so a shell reload returns to the selected disk's scan root in first-use state.

`src/ActivityRing.qml` paints the single theme-derived scan ring around the bar gauge, exists visually only while its `running` property is true, and exposes progress semantics. Panel status and Cancel remain literal and static, so scan state stays available when motion cannot be perceived.

## Omarchy agent adapter

The selected-directory action constructs one explanatory prompt containing a control-free, 4,096-character-bounded path value, allocated byte count, and a fixed non-destructive investigation contract. Read-only and untrusted-data instructions precede the explicitly delimited filesystem path. QML launches `omarchy agent prompt` as four process arguments; neither the path nor the complete prompt becomes shell source. The maintained Omarchy launcher starts the user's default agent. Disk Lens neither selects a provider nor overrides authentication, network, approval, or sandbox policy.

## Trash adapter

The widget snapshots one actionable selected entry and its current scope, then opens the shell-native confirmation with **Cancel** selected. The service revalidates that the snapshot is still an exact entry in the current scan and a lexical immediate child of that scope before it starts `scripts/disk-lens-trash`. No destructive IPC method exists.

The helper refuses UID `0`, relative or unresolved scopes, the scope itself, the Home directory itself, missing targets, non-UTF-8 values, and targets whose resolved parent differs from the current scope. It launches `gio trash -- "$target_path"` with the path as one argument, forwards termination to its owned child, and emits only fixed control-free failures. It does not call `rm`, empty Trash, or fall back to permanent deletion.

After success, the service clears its navigation cache, refreshes capacity, and starts one explicit remeasurement of the affected scope. The selection disappears only when that fresh model no longer contains the entry. If the platform refuses Trash—for example on an internal system mount—the old model and item remain intact and the UI exposes a dismissible error. Moving within one filesystem does not itself reclaim capacity; the confirmation and success notice both say that Trash must be emptied separately.

## Btrfs accounting

Filesystem free space and per-path allocation answer different questions. Snapshots, compression, and shared extents can explain a gap. Version `0.5.2` does not calculate exclusive/shared extents, snapshot ownership, or reclaimable bytes.

## Lifecycle and development snapshots

Disablement unloads both entry points and stops their processes and timers. Plugin removal uses Omarchy's normal lifecycle and does not remove scanned data or empty desktop Trash. A selected filesystem entry changes only through its own confirmed Trash action.

`make update` validates the current checkout, copies its exact committed and uncommitted working tree into a dedicated Git snapshot under XDG cache, and removes only an existing Disk Lens plugin. Add, asynchronous catalog discovery, and enable are separate bounded phases. The installer preserves the previous bar position when available and verifies the installed snapshot commit plus both source-derived loaded identities. `make dev-install` and `make install` are equivalent aliases.
