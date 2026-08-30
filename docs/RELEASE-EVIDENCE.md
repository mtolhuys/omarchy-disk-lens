# Development milestone evidence

This record describes the strongest verified `0.1.0` development milestone. It is not a public release record and does not authorize a push, tag, release, or marketplace submission.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.1.0`
- Service identity: `disk-lens-service-v0100`
- Widget identity: `disk-lens-widget-v0100`
- Runtime candidate commit: `d5d914486f0a718138167bf26cb3a66293f27287`
- Omarchy source revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab revision: `12f8120056e23dc17e454afe35f15dc45e2f986a`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus fresh per-run overlay
- Optional dependency: QDirStat `2.0-1` from the AUR, built and installed only in the disposable guest

## Commands

```bash
make test
make validate

cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab fast
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/qdirstat.sh
```

`OMARCHY_PLUGIN_LAB_ROOT` and the plugin path are task-local absolute paths and are intentionally not committed with maintainer-specific values.

## Timestamped disposable-guest evidence

| Run id | Result | Scope |
| --- | --- | --- |
| `20260830-235755` | green | generic Plugin Lab fast gate: all 207 maintained Omarchy test files passed in a fresh guest |
| `20260831-000146` | green | exact committed native candidate: real pointer, synthetic scans, treemap/list/filter controls, dark/light themes, cancellation, partial/long/empty states, same-path update, disable/re-enable/remove |
| `20260831-000341` | green | exact committed optional bridge: visible exact install command, cancelled terminal state, QDirStat `2.0-1`, live detection, selected synthetic scope mapped in QDirStat, removal ownership boundary |

Run directories and VM overlays remain outside the repository under the Plugin Lab's timestamped evidence root. No VM image, package cache, or generated screenshot is committed.

## Machine assertions passed

- Source tests and Omarchy manifest validation run before the guest development install.
- Plugin registry, service IPC, and widget IPC agree on enabled state and loaded build identities.
- Real bar geometry meets the tested host minimum and a QMP pointer opens the panel through the public route.
- Synthetic fixture state exposes the expected scope, entry count, allocated total, shared view/filter model, and selection.
- Cancelling a scan preserves four last-good entries and leaves no `disk-lens-scan` process.
- Permission denial yields a non-empty explicit partial result.
- A public same-path update changes service and widget identities and the runtime snapshot path.
- Disable unloads both entry points; re-enable restores exactly one of each; removal preserves synthetic files and leaves no scanner.
- The public QDirStat action exposes exactly `omarchy pkg aur add qdirstat` in a visible terminal. Cancelling leaves the dependency absent and the UI does not claim success.
- After guest-only installation, executable detection becomes available and QDirStat maps on `/tmp/disk-lens-qdir-fixture` as the desktop user.
- Removing Disk Lens while QDirStat is open leaves the package, process, and fixture untouched.

## Visual review

The following synthetic checkpoints were inspected at original resolution:

- first use and capacity rail;
- ready squarified treemap;
- filtered ranked list;
- Catppuccin Latte light theme and Tokyo Night dark theme;
- cancelled, partial, long-scope, and empty states;
- missing-QDirStat card and visible Omarchy install terminal;
- real QDirStat window and Disk Lens side by side on the same synthetic scope;
- removed-plugin desktop state.

The panel showed calm hierarchy, readable exact values, bounded scope elision, reachable actions, a useful area encoding, and no private filesystem content.

## Deliberate limitations

- No tag, release artifact, artifact SHA-256, public install URL, marketplace entry, or minimum supported Omarchy release exists yet.
- The daily Omarchy host was not used for activation, visual testing, package installation, update, or lifecycle tests. `make dev-install` was invoked only inside disposable guests.
- Scan state is in memory and returns to Home after a shell reload.
- Performance budgets are structurally bounded but not yet quantified.
- Warning, critical, and unavailable capacity fixtures; narrow and dense layouts; full keyboard item navigation; focus/contrast measurement; screen-reader announcements; and composed reduced-motion acceptance remain unverified.
- QDirStat package, unpackaged-file, and cache-file integrations are not implemented or claimed.
- Btrfs snapshot/shared-extent/reclaimable-space accounting is not implemented or claimed.
