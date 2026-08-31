# Architecture

```text
Omarchy shell
  ├─ Disk Lens service (kept loaded)
  │    ├─ findmnt capacity process, every 60 seconds
  │    ├─ one disk-lens-scan process
  │    └─ last completed in-memory result
  └─ Disk Lens bar widget + KeyboardPanel
       ├─ pie gauge, bounded activity rings, capacity rail, and scope controls
       ├─ shared filters and selection
       ├─ treemap or ranked list
       └─ structural launches: file manager and Omarchy agent

disk-lens-scan
  └─ GNU du --all --one-file-system --max-depth=1 --null
       └─ strict NDJSON protocol version 1
```

## Plugin contract

`manifest.json` uses Omarchy `schemaVersion: 1`, declares `service` and `bar-widget`, and keeps the service loaded. `src/Service.qml` owns capacity and scan process state. `src/BarWidget.qml` follows the host `open()`, `close()`, and `opened` contract and renders a host-owned `KeyboardPanel` anchored to the real bar widget.

Service and widget expose stable IPC state plus independent build identities. Plugin Lab acceptance compares source installation and loaded behavior, and a same-path public update must change both loaded identities.

## Capacity adapter

The service runs locale-independent `findmnt --json --bytes --target "$HOME"` with explicit fields for source, target, filesystem type, size, used, available, and use percentage. `Model.parseCapacity` accepts exactly one usable filesystem object and normalizes numbers before UI use.

Capacity refreshes at service start, panel open, middle-click, explicit IPC request, and every 60 seconds. None of these paths starts a recursive directory scan.

## Scan adapter

`scripts/disk-lens-scan` accepts exactly `--path ABSOLUTE_DIRECTORY`, refuses root, resolves the directory, and runs one same-filesystem GNU `du` traversal. It reads NUL-delimited byte/path pairs so tabs and newlines cannot split records.

The helper emits protocol-versioned NDJSON. The parser requires one start record, no more than 5,000 valid entry records, no more than 20 bounded warnings, and one matching completion record whose path, entry count, warning floor, totals, and completeness flag agree with the parsed stream. Paths, names, encoded paths, flags, warnings, and numeric fields have explicit type or length bounds. Unknown versions, types, malformed JSON, invalid fields, truncation, or missing completion fail the attempt without replacing the last good result.

The QML process collector promotes a complete parsed result atomically. Permission and I/O messages become a bounded warning set and mark the completed result partial. Cancellation stops the helper, which terminates its owned `du` child and cleans temporary state.

## Model and navigation

One in-memory entry array drives both projections. Filters are pure projections over name, kind, hidden status, minimum allocated bytes, and maximum modification age. Filtered bytes are labelled independently from scanned totals. Treemap geometry is bounded to the 48 largest visible entries; the ranked view renders at most 80 and directs the user to filters for further narrowing.

Drilling into an actionable directory starts a new immediate-child scan. Parent navigation derives one structural absolute path. Version `0.4.1` does not persist scopes or results, so a shell reload returns to Home and first-use state.

`src/ActivityRing.qml` is the shared scan-ring primitive. It paints a theme-derived bounded arc, exists visually only while its `running` property is true, and exposes progress semantics. Scan status remains available as text when motion cannot be perceived.

## Omarchy agent adapter

The selected-directory action constructs one explanatory prompt containing a control-free, 4,096-character-bounded path value, allocated byte count, and a fixed non-destructive investigation contract. Read-only and untrusted-data instructions precede the explicitly delimited filesystem path. QML launches `omarchy agent prompt` as four process arguments; neither the path nor the complete prompt becomes shell source. The maintained Omarchy launcher starts the user's default agent. Disk Lens neither selects a provider nor overrides authentication, network, approval, or sandbox policy.

## Btrfs accounting

Filesystem free space and per-path allocation answer different questions. Snapshots, compression, and shared extents can explain a gap. Version `0.4.1` does not calculate exclusive/shared extents, snapshot ownership, or reclaimable bytes.

## Lifecycle and development snapshots

Disablement unloads both entry points and stops their processes and timers. Removal uses Omarchy's normal lifecycle and does not remove user data.

`make update` validates the current checkout, copies its exact committed and uncommitted working tree into a dedicated Git snapshot under XDG cache, and removes only an existing Disk Lens plugin. Add, asynchronous catalog discovery, and enable are separate bounded phases. The installer preserves the previous bar position when available and verifies the installed snapshot commit plus both source-derived loaded identities. `make dev-install` and `make install` are equivalent aliases.
