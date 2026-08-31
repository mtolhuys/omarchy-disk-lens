# Development milestone evidence

This record describes the strongest verified `0.3.0` development milestone. It is not a public release record and does not authorize a push, tag, release, or marketplace submission.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.3.0`
- Service identity: `disk-lens-service-v0300`
- Widget identity: `disk-lens-widget-v0300`
- Accepted repository candidate: `49757b0918d37250f5e29ca4ca42ca18cbe83187`
- Runtime and protocol feature commit: `677d5a7e2648c41b748f6e3f22b51ea13656f4eb`
- Omarchy base revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab base revision: `259ef26e9909bd74323177d2d29e2007cf8c73db`
- Omarchy ISO harness revision: `268bac16d351a21d867e37565738f458b11cb06c`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus a fresh per-run overlay
- Optional dependency: QDirStat `2.0-1` from the AUR, built and installed only in the disposable guest
- README showcase: `1000×563`, 147 frames, 2,167,553 bytes, SHA-256 `ef56268b5ba662192b8e9072de8033d998a3c65964d07a94cf7b1e6a2c812dd9`

## Commands

```bash
make test
make validate
make showcase

cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/qdirstat.sh
```

The lab root and plugin path are task-local absolute paths and are intentionally not committed with maintainer-specific values.

## Timestamped disposable-guest evidence

| Run id | Result | Scope |
| --- | --- | --- |
| `20260831-081952` | green | exact repository candidate `49757b0`: public `make update`, discovery-race recovery, loaded `v0300` identities, pointer-opened compact UI, synthetic scanning and filtering, visible activity indicator, agent hand-off, light/dark themes, cancellation, partial/long/empty states, same-path update, disable/re-enable/remove, and clean teardown |
| `20260831-081243` | green | exact runtime candidate `677d5a7`: missing-dependency UI, exact visible install command, cancelled terminal state, guest-only QDirStat `2.0-1` AUR build, live detection, same-scope mapped window, and plugin/QDirStat ownership boundary |
| `20260831-073627` | green | development-installer discovery-race repair: interrupted-add fixture, bounded catalog absence/discovery, explicit enablement, loaded identity checks, public behavior, and lifecycle acceptance |
| `20260830-235755` | green | historical generic Plugin Lab fast gate: all 207 maintained Omarchy test files passed in a fresh guest; this platform gate predates the `0.3.0` runtime candidate |

Run directories, logs, and disposable overlays remain under the Plugin Lab evidence root. The selected synthetic screenshots are copied into `docs/media` under the separate provenance contract in [`SCREENSHOTS.md`](SCREENSHOTS.md).

An earlier `20260831-081030` product scenario completed every Disk Lens assertion and saved its evidence, but the concurrently edited lab launcher produced a parse error after VM teardown. It is not treated as a green command and was superseded by the clean `20260831-081952` run.

## Machine assertions passed

- Source tests and Omarchy manifest validation run before every guest development install; ShellCheck runs when available.
- The public `make update` target snapshots committed and uncommitted working-tree files, verifies the installed checkout commit and origin, and compares both loaded identities with values read from current source.
- Add, asynchronous catalog discovery, and enablement are separate bounded phases. Rerunning repairs a valid checkout left disabled by an interrupted or discovery-raced add.
- Plugin registry, service IPC, and widget IPC agree on enabled state and the `v0300` build identities.
- Real bar geometry exposes one square proportional capacity pie without percentage text; a QMP pointer opens the panel through the public bar route.
- A live scan exposes `scanIndicatorRunning`, literal `Scanning…` and `Measuring allocated space…` status, a cancellable control, and the last complete result. Cancellation preserves four last-good entries and leaves no scanner process.
- Synthetic fixture state exposes the exact scope, entry count, allocated total, shared view/filter model, selection, and proportional treemap.
- The selected-directory action dispatches one exact path and measured allocation through `omarchy agent prompt`. The captured prompt requires read-only investigation, distinguishes findings from guesses, forbids changes, and requires confirmation before a change-oriented command is proposed.
- Protocol regression tests reject null capacity objects, malformed JSON, unsupported versions, trailing records, non-integer values, invalid flags/base64, non-child paths, warning overflow, mismatched completion counts, and inconsistent partial state.
- The scanner uses NUL-delimited traversal, caps retained entries at 5,000 and emitted warnings at 20, reserves the truncation warning within that bound, handles hostile filenames and partial traversal, and terminates its owned `du` child on cancellation.
- Permission denial yields a non-empty explicit partial result; long and empty scopes retain distinct recoverable states.
- A public same-path update changes both loaded runtime identities. Disable unloads both entry points; re-enable restores exactly one of each; removal preserves synthetic files and leaves no scanner.
- The public QDirStat action exposes exactly `omarchy pkg aur add qdirstat` in a visible terminal. Cancelling leaves the dependency absent and the UI does not claim success.
- After guest-only installation, executable detection becomes available and QDirStat maps on `/tmp/disk-lens-qdir-fixture` as the desktop user. Removing Disk Lens leaves the package, process, and fixture untouched.

## Visual and media review

The following synthetic checkpoints were inspected at original `1280×800` resolution:

- square capacity pie and compact first-use panel;
- active scan with visible bar/header/status activity rings and static text equivalents;
- ready treemap and ranked list, selection inspector, filters, and clear action;
- selected-directory **Ask Omarchy** action in Catppuccin Latte and the primary flow in Tokyo Night;
- cancelled, partial, long-scope, empty, missing-dependency, and visible-install states;
- real QDirStat and Disk Lens side by side on the exact same synthetic scope;
- unloaded and removed-plugin desktop states.

The README product tour was rebuilt twice from the current captures. Both builds produced the same 147-frame SHA-256 recorded above. Five representative frames were inspected at original resolution; text, screenshot crops, progress markers, and the final QDirStat composition remained legible without implying automatic scanning, cleanup, privilege, embedding, or upstream endorsement.

## Deliberate limitations

- No tag, release artifact, artifact SHA-256, public install URL, marketplace entry, or minimum supported Omarchy release exists yet.
- Automated activation, package installation, agent dispatch, update, visual, and lifecycle work stayed inside disposable guests. A user-initiated daily-host update exposed the catalog-discovery race; subsequent automated repair tests stayed in Plugin Lab.
- The accepted Omarchy source checkout and Plugin Lab checkout contained unrelated in-progress worktree changes. The final lab launcher and pointer helper matched Plugin Lab revision `259ef26`, but this is not the clean-clone/minimum-version release gate.
- The agent prompt is an instruction boundary, not a hard sandbox. Provider, network behavior, approvals, and sandbox policy belong to the configured agent.
- Scan state is in memory and returns to Home after a shell reload.
- Performance is structurally bounded but idle, dense-model, representative-scan, and cancellation budgets are not quantified.
- Warning, critical, and unavailable capacity fixtures; narrow and 5,000-entry layouts; complete keyboard item navigation; contrast measurement; screen-reader announcements; and composed reduced-motion acceptance remain unverified.
- QDirStat package, unpackaged-file, and cache-file integrations are not implemented. QDirStat remains separately installed GPL-2.0 software; Disk Lens contains no QDirStat code and implies no upstream endorsement.
- Btrfs snapshot, shared-extent, exclusive-allocation, and reclaimable-space accounting is not implemented.

## Historical milestones

The preceding `0.2.0` candidate used service/widget identities `disk-lens-service-v0200` and `disk-lens-widget-v0200`; its final exact runtime and optional-bridge runs were `20260831-072400` and `20260831-004241`. The `0.1.0` candidate used `v0100` identities with runs `20260831-000146` and `20260831-000341`. Those results remain historical evidence only and are superseded by the `0.3.0` milestone above.
