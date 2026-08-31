# Architecture

```text
Omarchy shell
  ├─ Disk Lens service (kept loaded)
  │    ├─ findmnt capacity process, every 60 seconds
  │    ├─ qdirstat executable detection
  │    ├─ one disk-lens-scan process
  │    └─ last completed in-memory result
  └─ Disk Lens bar widget + KeyboardPanel
       ├─ proportional pie gauge, capacity rail, and scope controls
       ├─ shared filters and selection
       ├─ treemap or ranked list
       └─ structural launches: file manager, Omarchy agent, QDirStat, install terminal

disk-lens-scan
  └─ GNU du --all --one-file-system --max-depth=1 --null
       └─ strict NDJSON protocol version 1
```

## Plugin contract

`manifest.json` uses Omarchy `schemaVersion: 1`, declares `service` and `bar-widget`, and keeps the service loaded. `src/Service.qml` owns capacity, dependency, and scan process state. `src/BarWidget.qml` follows the host `open()`, `close()`, and `opened` contract and renders a host-owned `KeyboardPanel` anchored to the real bar widget.

Service and widget expose stable IPC state plus independent build identities. Plugin Lab acceptance compares source installation and loaded behavior, and a same-path public update must change both loaded identities.

## Capacity adapter

The service runs locale-independent `findmnt --json --bytes --target "$HOME"` with explicit fields for source, target, filesystem type, size, used, available, and use percentage. `Model.parseCapacity` accepts exactly one usable filesystem object and normalizes numbers before UI use.

Capacity refreshes at service start, panel open, middle-click, explicit IPC request, and every 60 seconds. None of these paths starts a recursive directory scan.

## Scan adapter

`scripts/disk-lens-scan` accepts exactly `--path ABSOLUTE_DIRECTORY`, refuses root, resolves the directory, and runs one same-filesystem GNU `du` traversal. It reads NUL-delimited byte/path pairs so tabs and newlines cannot split records.

The helper emits protocol-versioned NDJSON records:

```json
{"protocol":1,"type":"entry","path":"/tmp/example/Archive","pathB64":"L3RtcC9leGFtcGxlL0FyY2hpdmU=","name":"Archive","kind":"directory","allocatedBytes":123456,"mtime":1760000000,"validUtf8":true,"actionable":true}
```

The parser requires one start record, no more than 5,000 valid entry records, optional warnings, and one matching completion record. Unknown versions, types, malformed JSON, invalid fields, truncation, or missing completion fail the attempt without replacing the last good result.

The QML process collector promotes a complete parsed result atomically; it does not stream partial rows into the visible model. Permission and I/O messages become a bounded warning set and mark the completed result partial. Cancellation stops the helper, which terminates its owned `du` child and cleans temporary state.

## Model and navigation

One in-memory entry array drives both projections. Filters are pure projections over name, kind, hidden status, minimum allocated bytes, and maximum modification age. Filtered bytes are labelled independently from scanned totals. Treemap geometry is bounded to the 48 largest visible entries; the ranked view renders at most 80 and directs the user to filters for further narrowing.

Drilling into an actionable directory starts a new immediate-child scan. Parent navigation derives one structural absolute path. Version `0.2.0` does not persist scopes or results, so a shell reload returns to Home and first-use state.

## Omarchy agent adapter

The selected-directory action constructs one explanatory prompt containing the exact path, allocated byte count, and a fixed non-destructive investigation contract. QML launches `omarchy agent prompt` as four process arguments; the path never becomes shell source. The prompt asks the configured default agent to investigate read-only, distinguish verified findings from guesses, explain necessity and reclaim options, and request confirmation before proposing any filesystem-changing command.

The maintained Omarchy launcher chooses and starts the user's default agent. Disk Lens neither selects a provider nor overrides that agent's authentication, network, approval, or sandbox policy. Dispatch count and selected path are exposed only through local widget IPC for lifecycle and acceptance assertions.

## QDirStat adapter

The service detects QDirStat with `omarchy-cmd-present qdirstat`. The widget supports two fixed operations:

- launch `qdirstat` through `uwsm-app` with the selected directory as a separate argument;
- launch the Omarchy floating presentation terminal with the fixed command `omarchy pkg aur add qdirstat`.

After the terminal is launched, a three-second timer rechecks executable availability while the panel remains relevant. “Installation launched” and “available” are distinct states. Package views, unpackaged-file views, and QDirStat cache exchange are not implemented.

## Btrfs accounting

Filesystem free space and per-path allocation answer different questions. Snapshots, compression, and shared extents can explain a gap. Version `0.2.0` does not calculate exclusive/shared extents, snapshot ownership, or reclaimable bytes.

## Lifecycle and development snapshots

Disablement unloads both entry points and stops their processes and timers. Removal uses Omarchy's normal lifecycle and does not remove user data or QDirStat.

`make update` first validates the current checkout, copies its exact committed and uncommitted working tree into a dedicated Git snapshot under XDG cache, and removes only an existing Disk Lens plugin. Add, asynchronous catalog discovery, and enable are separate bounded phases; this avoids the shell discovery race in a combined add-and-enable call and lets a rerun recover a disabled checkout left by an interrupted installation. The installer preserves the previous bar section/index when available, verifies the installed snapshot commit, and checks both source-derived loaded identities before success. `make dev-install` and `make install` are equivalent aliases.
