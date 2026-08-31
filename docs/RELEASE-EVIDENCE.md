# Development milestone evidence

This record describes the strongest verified `0.5.1` pre-1.0 development milestone and preserves the public-install boundary of the preceding `0.5.0` release.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.5.1`
- Service identity: `disk-lens-service-v0501`
- Widget identity: `disk-lens-widget-v0501`
- Accepted repository candidate: `671be6091a981f651e6cedd13a77a9000512375a`, installed as exact development snapshot `489839281f1f`
- Last public clean-clone candidate: `0e21ef7dd5068b29bb009acbb78e36645b88a0b6` (`0.5.0`)
- Omarchy base revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab base revision: `259ef26e9909bd74323177d2d29e2007cf8c73db`
- Omarchy ISO harness revision: `268bac16d351a21d867e37565738f458b11cb06c`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus a fresh per-run overlay
- README showcase: `1000x563`, 184 frames, 3,039,740 bytes, SHA-256 `8c7c4e95c82cd59fbcc8e22190d25d912a1d9e682c681eb097611041cb93fa13`
- Marketplace preview: `1000x563`, 190,996 bytes, SHA-256 `bdd0b2488c62e48727a9b81fc38774135f762b18f19afb60106fb8f44cb2786a`

## Required commands

```bash
make test
make validate
make showcase

cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab fast
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
```

After `0.5.1` is published, its distribution gate additionally requires:

```bash
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/public-install.sh
```

## Timestamped disposable-guest evidence

| Run id | Result | Scope |
| --- | --- | --- |
| `20260831-234322` | green | clean repository candidate `671be60`, installed as snapshot `489839281f1f`: loaded `v0501` identities, no duplicate header close action, real bar-pointer close and reopen toggles, one first-use scan action, hidden entries shown, inline folder browser, typed scope, explicit refresh, cached Back without a scanner process, selected-folder agent hand-off, exact-target Trash confirmation on Cancel, cancellation without change, unsupported-mount preservation with a visible error, user-home Trash move plus automatic remeasurement, filters, themes, one activity indicator, scan cancellation, hostile paths, partial/long/empty states, same-path update, retained Trash contents, and full lifecycle cleanup |
| `20260831-234159` | rejected | the host scenario was invoked without its required `OMARCHY_PLUGIN_LAB_ROOT`; the harness stopped before staging or activating the plugin. The accepted rerun supplied the explicit lab root and exercised the unchanged clean candidate |
| `20260831-233807` | green | complete Omarchy source suite in a disposable guest: all 207 test files passed before focused product acceptance |
| `20260831-232623` | green | public HTTPS clone of exact `0.5.0` tag commit `0e21ef7`, Omarchy validation, enablement, loaded `v0500` identities, documented removal, unload, checkout cleanup, and clean compositor/log state |
| `20260831-232241` | green | public HTTPS clone of exact `0.5.0` release-preparation commit `f4563ca`, Omarchy validation, enablement, loaded `v0500` identities, documented removal, unload, checkout cleanup, and clean compositor/log state |
| `20260831-231750` | green | clean repository candidate `0fd5be3`, installed as snapshot `fcf8b5a5370f`: loaded `v0500` identities, exact 32-pixel square close geometry, real pointer dismissal and bar reopening, one first-use scan action, hidden entries shown, inline folder browser, typed scope, explicit refresh, cached Back without a scanner process, selected-folder agent hand-off, exact-target Trash confirmation on Cancel, cancellation without change, unsupported-mount preservation with a visible error, user-home Trash move plus automatic remeasurement, filters, themes, one activity indicator, scan cancellation, hostile paths, partial/long/empty states, same-path update, retained Trash contents, and full lifecycle cleanup |
| `20260831-230121` | rejected | the initial success fixture attempted desktop Trash from the guest's internal `/tmp` mount; GIO correctly refused that mount, exposing a missing explicit platform-failure assertion. The accepted candidate adds a fixed inline error, proves the item remains intact, and separately proves success from a normal user-home scope |
| `20260831-224131` | green | clean repository candidate `54973b8`, installed as snapshot `fe65d927d937`: loaded `v0500` identities, exact 32-pixel square close geometry, real pointer dismissal and bar reopening, one first-use scan action, hidden entries shown, inline folder browser, typed scope, explicit refresh, cached Back without a scanner process, agent hand-off, filters, themes, one activity indicator, cancellation, hostile paths, partial/long/empty states, same-path update, and full lifecycle cleanup |
| `20260831-223912` | rejected | the first square-only close candidate passed geometry and focus assertions, but the real pointer dismissal failed; its screenshot exposed a second missing header gap that placed part of the control outside the available row width, which the accepted candidate corrects and guards with an exact content-width assertion |
| `20260831-221223` | rejected | native `QtQuick.Dialogs` folder-picker experiment reproducibly aborted Quickshell; coredump and logs located the abort in the GLib/GIO GTK/GVFS directory-monitor path despite available memory, so the candidate was replaced by the accepted inline browser |
| `20260831-215559` | green | mandatory disposable-lab baseline source suite for the current session |
| `20260831-145042` | green | last public proof: clean HTTPS clone of `0.4.1` commit `5d84d58`, Omarchy validation, enablement, loaded `v0401` identities, documented removal, unload, checkout cleanup, and clean compositor/log state |

Run artifacts remain under the Plugin Lab evidence root. Selected synthetic screenshots were copied into `docs/media` under [`SCREENSHOTS.md`](SCREENSHOTS.md).

## Machine assertions passed

- Source tests, scanner process-budget checks, and Omarchy manifest validation ran before guest installation; ShellCheck ran because it was available.
- Registry, service IPC, and widget IPC agreed on enabled state and `v0501` identities.
- Real bar geometry exposed one square proportional capacity pie; a QMP pointer opened the host-owned panel.
- The header contained no duplicate close action. A second pointer click on the same active bar widget closed the panel through the host forwarding route, and a third reopened it.
- Opening the panel did not scan. First use presented one scan action, while the scope field remained directly editable and the inline browser listed folders with a shallow, NUL-safe helper only.
- Hidden entries were enabled by default. An explicit scan published the exact synthetic scope, four stored and visible entries, and more than 19 MB of allocated data.
- Drill in measured a new scope. Back restored the preceding bounded cache entry with its original `scannedAt` value and did not launch a scanner process. Refresh remained the explicit remeasurement action.
- Treemap selection, ranked-list switching, typed search, and clear controls updated one canonical model.
- Normal and hostile scanner-derived paths passed through the selected-directory agent boundary without becoming shell source or standalone injected prompt instructions; the inert guest agent opened and fixtures remained unchanged.
- The rendered Trash action snapshotted one exact current entry, showed its path and measured allocation, selected Cancel by default, and left the fixture unchanged when cancelled.
- Explicit keyboard confirmation on an unsupported internal mount produced a fixed visible failure and retained the item. The same guarded action moved a user-home directory through `gio trash`, cleared stale cached scopes, remeasured to an empty result, retained the Trash entry through plugin removal, and never exposed permanent-delete or empty-Trash behavior.
- A live scan exposed exactly one machine-visible activity indicator around the bar gauge. Static status and Cancel remained usable; cancellation preserved the last completed result and left no scanner process.
- Permission denial yielded an explicit usable partial result; long, empty, and hostile scopes remained distinct and recoverable.
- Maintained light and dark themes preserved state without compositor errors.
- A same-path update replaced both runtime identities. Disable unloaded both entry points, re-enable restored one of each, and removal preserved synthetic files.
- Final compositor configuration and targeted shell logs were clean.

## Scanner efficiency evidence

The filesystem traversal remains one GNU `du --all --one-file-system --block-size=1 --max-depth=1 --null` process, preserving exact allocated-byte and mount-boundary semantics. Post-processing now classifies common UTF-8 input once and batches metadata and JSON work instead of spawning processes per entry.

On the development host, the same synthetic 600-entry fixture improved from approximately 2.2 seconds to a five-run median of 0.140 seconds. The enforced 1,024-entry regression permits at most 18 `jq`, 16 `stat`, two `iconv`, and zero `base64` invocations for ordinary UTF-8 names. These figures prove removal of process-spawn amplification; they are not a general end-to-end scan-time promise because storage, cache state, directory depth, and filesystem behavior dominate `du` traversal time.

## Visual and media review

Eighteen Disk Lens checkpoints from the final 22-capture run were reviewed, including the close-free first-use header, inline browsing, typed scope, active scan, ready treemap, cached Back, filtered list, selected-folder agent action, Trash confirmation, unsupported Trash, successful Trash, maintained light/dark themes, cancelled, partial, long, empty, hostile-path, update, and removed states. All visible filesystem data was synthetic.

The README product tour was built twice from the current seven captures. Both builds produced the recorded 184-frame hash. The opening frame and marketplace preview were inspected at original `1000x563` resolution; hierarchy, screenshot crops, progress markers, browser scene, Cancel-first Trash confirmation, native filter finale, and agent action remained legible without implying automatic scanning, permanent deletion, empty-Trash cleanup, privilege, package installation, or hard agent sandboxing.

## Deliberate limitations

- The supported runtime contract is current Omarchy Quattro; no older minimum Omarchy release is claimed.
- Public clean-clone proof for `0.5.1` cannot exist until the candidate is pushed. The exact `0.5.0` tag commit passed public HTTPS clone, load, and removal in run `20260831-232623`, but that historical proof does not establish the unpublished version.
- Marketplace review state is external and is not asserted by this repository evidence record.
- Automated activation, update, visual, and lifecycle work stays inside disposable guests.
- The agent prompt is an instruction boundary, not a hard sandbox. Provider, network behavior, approvals, and sandbox policy belong to the configured agent.
- Desktop Trash availability depends on GLib/GIO and the selected filesystem or mount. Disk Lens reports refusal without changing the item, never falls back to permanent deletion, and does not empty Trash; moving an item to Trash does not itself reclaim capacity.
- Scan state and navigation cache are bounded and in memory; a shell reload requires a new scan.
- Representative cold-disk, dense-model, cancellation-latency, and end-to-end performance budgets are not quantified.
- Pressure-state fixtures, narrow and 5,000-entry layouts, complete keyboard navigation, contrast measurement, screen-reader announcements, and composed reduced-motion acceptance remain unverified.
- Btrfs snapshot, shared-extent, exclusive-allocation, and reclaimable-space accounting is not implemented.

## Historical milestones

Versions `0.1.0` through `0.5.0` established the initial native panel, selected-folder agent guidance, compact pie gauge, strict protocol hardening, self-contained product boundary, deterministic media pipeline, hardened prompt boundary, editable scope navigation, and guarded Trash workflow. Their runtime evidence is superseded by the current candidate except where explicitly retained as historical distribution proof.
