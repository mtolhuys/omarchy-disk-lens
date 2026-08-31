# Development milestone evidence

This record describes the strongest verified `0.4.0` pre-1.0 release milestone and its disposable desktop evidence.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.4.0`
- Service identity: `disk-lens-service-v0400`
- Widget identity: `disk-lens-widget-v0400`
- Accepted repository candidate: `d0737689b795e1d7c6db819cd01cb13e961121a3`
- Omarchy base revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab base revision: `259ef26e9909bd74323177d2d29e2007cf8c73db`
- Omarchy ISO harness revision: `268bac16d351a21d867e37565738f458b11cb06c`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus a fresh per-run overlay
- README showcase: `1000×563`, 147 frames, 2,167,480 bytes, SHA-256 `b3a67e0283e6ba46f9565307ae334911665814e20865d76add55d8bb335b8089`
- Marketplace preview: `1000×563`, 152,685 bytes, SHA-256 `fa7f53692eca1f79690c89f05eef271f3b42d9c71b7f5b65b9ea46e5f0ddf5de`

## Required commands

```bash
make test
make validate
make showcase

cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/public-install.sh
```

## Timestamped disposable-guest evidence

| Run id | Result | Scope |
| --- | --- | --- |
| `20260831-085831` | green | public GitHub commit `2c1debf`: documented HTTPS clone, Omarchy validation, enablement, exact remote and commit, loaded `v0400` identities, documented removal, unload, checkout cleanup, and clean compositor/log state |
| `20260831-085530` | green | exact clean publication candidate `d073768`: public `make update` through `bin/dev-sync`, interrupted-add recovery, loaded `v0400` identities, real pointer-opened compact UI, synthetic scanning and filtering, visible activity indicator, agent hand-off, light/dark themes, cancellation, partial/long/empty states, same-path update, disable/re-enable/remove, preserved fixture, and clean teardown |
| `20260831-084135` | green | preceding native-only runtime candidate `dfabca9`; superseded by the publication-candidate run above |

Run artifacts remain under the Plugin Lab evidence root. Selected synthetic screenshots were copied into `docs/media` under [`SCREENSHOTS.md`](SCREENSHOTS.md).

## Machine assertions passed

- Source tests and Omarchy manifest validation ran before the guest development install; ShellCheck ran because it was available.
- The public `make update` target recovered a valid checkout left disabled by an interrupted add, then verified the installed snapshot and source-derived identities.
- Registry, service IPC, and widget IPC agreed on enabled state and `v0400` identities.
- Real bar geometry exposed one square proportional capacity pie; a QMP pointer opened the host-owned panel.
- Opening the panel did not scan. Explicit scan and rendered refresh published the exact synthetic scope, four stored entries, three visible entries, and more than 19 MB of allocated data.
- Treemap selection, ranked-list switching, typed search, and clear controls updated one canonical model.
- The selected-directory action dispatched the exact synthetic path and measured allocation through `omarchy agent prompt`; the captured argument required read-only inspection and confirmation before change.
- A live scan exposed literal and machine-visible activity, then rendered cancellation preserved the last completed result and left no scanner process.
- Permission denial yielded an explicit usable partial result; long and empty scopes remained distinct and recoverable.
- Maintained light and dark themes preserved state without compositor errors.
- A public same-path update replaced both runtime identities. Disable unloaded both entry points, re-enable restored one of each, and removal preserved synthetic files.
- The documented public GitHub URL cloned the expected shared commit in a fresh guest, passed Omarchy validation, enabled and loaded both entry points, then removed and unloaded cleanly through the documented plugin id.
- Final compositor configuration and targeted shell logs were clean.

## Visual and media review

The first-use, active-scan, ready-treemap, filtered-list, selected-folder agent, light-theme, cancelled, partial, long-scope, empty, and removed checkpoints were reviewed from synthetic `1280×800` captures. The native panel is visibly shorter without a dependency row or secondary-app action.

The README product tour was built twice from the current five captures. Both builds produced the recorded 147-frame hash. Five representative frames were inspected at original `1000×563` resolution; hierarchy, screenshot crops, progress markers, native filter finale, and agent action remained legible without implying automatic scanning, cleanup, privilege, package installation, or hard agent sandboxing.

## Deliberate limitations

- The supported runtime contract is current Omarchy Quattro; no older minimum Omarchy release is claimed.
- Marketplace listing approval is external to this repository and may still be pending.
- Automated activation, update, visual, and lifecycle work stays inside disposable guests.
- The agent prompt is an instruction boundary, not a hard sandbox. Provider, network behavior, approvals, and sandbox policy belong to the configured agent.
- Scan state is in memory and returns to Home after a shell reload.
- Idle, dense-model, representative-scan, and cancellation budgets are not quantified.
- Pressure-state fixtures, narrow and 5,000-entry layouts, complete keyboard navigation, contrast measurement, screen-reader announcements, and composed reduced-motion acceptance remain unverified.
- Btrfs snapshot, shared-extent, exclusive-allocation, and reclaimable-space accounting is not implemented.

## Historical milestones

Versions `0.1.0` through `0.3.0` established the initial native panel, selected-folder agent guidance, compact pie gauge, loading indicators, strict protocol hardening, and deterministic media pipeline. Their evidence is superseded by the current product boundary.
