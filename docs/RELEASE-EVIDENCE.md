# Development milestone evidence

This record describes the strongest verified `0.2.0` development milestone. It is not a public release record and does not authorize a push, tag, release, or marketplace submission.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.2.0`
- Service identity: `disk-lens-service-v0200`
- Widget identity: `disk-lens-widget-v0200`
- Current candidate commit: `dd0cdef259aaa5481e5e649c697864580510b76d`
- Runtime feature commit: `2b2c7b86b1a803db0a330359cd4e8e88ca32717b`
- Omarchy source revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab revision: `12f8120056e23dc17e454afe35f15dc45e2f986a`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus a fresh per-run overlay
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
| `20260830-235755` | green | generic Plugin Lab fast gate: all 207 maintained Omarchy test files passed in a fresh guest; this platform gate predates the `0.2.0` runtime candidate |
| `20260831-004011` | green | exact committed `0.2.0` runtime candidate: compact pie indicator and panel, scan and selection, guarded Omarchy-agent hand-off, list/map/filter controls, dark/light themes, cancellation, partial/long/empty states, same-path update, disable/re-enable/remove |
| `20260831-004241` | green | exact committed `0.2.0` optional bridge: public install control, visible exact command, cancelled terminal state, QDirStat `2.0-1`, live detection, scoped launch, and removal ownership boundary |
| `20260831-072400` | green | exact current candidate installed through public `make update`: source validation, installed snapshot commit, source-derived loaded identities, public behavior, same-path update, disable/re-enable/remove |

Run directories and VM overlays remain outside the repository under the Plugin Lab's timestamped evidence root. No VM image, package cache, generated prompt capture, or screenshot is committed.

## Machine assertions passed

- Source tests and Omarchy manifest validation run before the guest development install.
- The public `make update` target snapshots committed and uncommitted working-tree files, verifies the installed checkout has the same Git commit and origin, and compares both loaded identities with values read from the current source tree.
- Plugin registry, service IPC, and widget IPC agree on enabled state and the `v0200` build identities.
- Real bar geometry meets the tested host minimum; the bar exposes one square, proportional capacity pie without percentage text, and a QMP pointer opens the panel through the public route.
- The opened panel remains within the tested `520` pixel width and compact height envelope.
- Synthetic fixture state exposes the expected scope, entry count, allocated total, shared view/filter model, and selection.
- The selected-directory action dispatches one prompt through `omarchy agent prompt` with the exact path and allocated size.
- The captured prompt asks why the directory is large, whether it is necessary, and whether deletion is safe. It instructs the agent to begin read-only, distinguish findings from guesses, avoid filesystem changes, and request explicit confirmation before proposing a changing command.
- The configured agent opens visibly under `org.omarchy.agent`; the guest fixture remains byte-for-byte present after the inert test provider receives the prompt.
- Cancelling a scan preserves four last-good entries and leaves no `disk-lens-scan` process.
- Permission denial yields a non-empty explicit partial result.
- A public same-path update changes service and widget identities and the runtime snapshot path.
- Disable unloads both entry points; re-enable restores exactly one of each; removal preserves synthetic files and leaves no scanner.
- The public QDirStat action exposes exactly `omarchy pkg aur add qdirstat` in a visible terminal. Cancelling leaves the dependency absent and the UI does not claim success.
- After guest-only installation, executable detection becomes available and QDirStat maps on `/tmp/disk-lens-qdir-fixture` as the desktop user.
- Removing Disk Lens while QDirStat is open leaves the package, process, and fixture untouched.

## Visual review

The following synthetic checkpoints were inspected at original resolution:

- the square proportional bar pie and compact first-use state;
- ready squarified treemap and ranked list;
- selected-directory inspector with `Drill in`, `Open`, and `Ask Omarchy` actions;
- Catppuccin Latte light theme and Tokyo Night dark theme;
- cancelled, partial, long-scope, and empty states;
- missing-QDirStat row and visible Omarchy install terminal;
- real QDirStat and Disk Lens side by side on the same synthetic scope;
- removed-plugin desktop state.

The panel showed calm hierarchy, readable exact values, bounded scope elision, reachable actions, useful area encoding, and no private daily-host filesystem content.

## Deliberate limitations

- No tag, release artifact, artifact SHA-256, public install URL, marketplace entry, or minimum supported Omarchy release exists yet.
- The daily Omarchy host was not used for activation, visual testing, package installation, agent dispatch, update, or lifecycle tests. `make dev-install` was invoked only inside disposable guests.
- The agent prompt is an instruction boundary, not a hard sandbox. The selected Omarchy agent provider, its network behavior, approval policy, and sandbox remain outside Disk Lens.
- Scan state is in memory and returns to Home after a shell reload.
- Performance budgets are structurally bounded but not yet quantified.
- Warning, critical, and unavailable capacity fixtures; narrow and dense layouts; full keyboard item navigation; focus/contrast measurement; screen-reader announcements; and composed reduced-motion acceptance remain unverified.
- QDirStat package, unpackaged-file, and cache-file integrations are not implemented or claimed.
- Btrfs snapshot/shared-extent/reclaimable-space accounting is not implemented or claimed.

## Historical milestone

The preceding `0.1.0` runtime candidate was commit `d5d914486f0a718138167bf26cb3a66293f27287`, with service/widget identities `disk-lens-service-v0100` and `disk-lens-widget-v0100`. Its exact disposable-guest acceptance runs were `20260831-000146` and `20260831-000341`. Those results remain historical evidence only and are superseded by the `0.2.0` candidate above.
