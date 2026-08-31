# Development milestone evidence

This record describes the strongest verified `0.5.0` pre-1.0 development milestone and preserves the public-install boundary of the preceding `0.4.1` release.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.5.0`
- Service identity: `disk-lens-service-v0500`
- Widget identity: `disk-lens-widget-v0500`
- Accepted repository candidate: `54973b88185ddd017672776b31c972c0259ef90c`, installed as exact development snapshot `fe65d927d937`
- Last public clean-clone candidate: `5d84d58563f577136ce9c517979bafbfeb157889` (`0.4.1`)
- Omarchy base revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab base revision: `259ef26e9909bd74323177d2d29e2007cf8c73db`
- Omarchy ISO harness revision: `268bac16d351a21d867e37565738f458b11cb06c`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus a fresh per-run overlay
- README showcase: `1000x563`, 161 frames, 2,375,757 bytes, SHA-256 `a624529a06f406796a54ab429113b0f96029d4bdc2ca887083d052876289fbc2`
- Marketplace preview: `1000x563`, 165,875 bytes, SHA-256 `4cda620dc14791af79fe958c48d2b68e90f9bfac9c6197f16b92d77f392d096f`

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

After `0.5.0` is published, its distribution gate additionally requires:

```bash
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/public-install.sh
```

## Timestamped disposable-guest evidence

| Run id | Result | Scope |
| --- | --- | --- |
| `20260831-224131` | green | clean repository candidate `54973b8`, installed as snapshot `fe65d927d937`: loaded `v0500` identities, exact 32-pixel square close geometry, real pointer dismissal and bar reopening, one first-use scan action, hidden entries shown, inline folder browser, typed scope, explicit refresh, cached Back without a scanner process, agent hand-off, filters, themes, one activity indicator, cancellation, hostile paths, partial/long/empty states, same-path update, and full lifecycle cleanup |
| `20260831-223912` | rejected | the first square-only close candidate passed geometry and focus assertions, but the real pointer dismissal failed; its screenshot exposed a second missing header gap that placed part of the control outside the available row width, which the accepted candidate corrects and guards with an exact content-width assertion |
| `20260831-221223` | rejected | native `QtQuick.Dialogs` folder-picker experiment reproducibly aborted Quickshell; coredump and logs located the abort in the GLib/GIO GTK/GVFS directory-monitor path despite available memory, so the candidate was replaced by the accepted inline browser |
| `20260831-215559` | green | mandatory disposable-lab baseline source suite for the current session |
| `20260831-145042` | green | last public proof: clean HTTPS clone of `0.4.1` commit `5d84d58`, Omarchy validation, enablement, loaded `v0401` identities, documented removal, unload, checkout cleanup, and clean compositor/log state |

Run artifacts remain under the Plugin Lab evidence root. Selected synthetic screenshots were copied into `docs/media` under [`SCREENSHOTS.md`](SCREENSHOTS.md).

## Machine assertions passed

- Source tests, scanner process-budget checks, and Omarchy manifest validation ran before guest installation; ShellCheck ran because it was available.
- Registry, service IPC, and widget IPC agreed on enabled state and `v0500` identities.
- Real bar geometry exposed one square proportional capacity pie; a QMP pointer opened the host-owned panel.
- Opening the panel did not scan. First use presented one scan action, while the scope field remained directly editable and the inline browser listed folders with a shallow, NUL-safe helper only.
- Hidden entries were enabled by default. An explicit scan published the exact synthetic scope, four stored and visible entries, and more than 19 MB of allocated data.
- Drill in measured a new scope. Back restored the preceding bounded cache entry with its original `scannedAt` value and did not launch a scanner process. Refresh remained the explicit remeasurement action.
- Treemap selection, ranked-list switching, typed search, and clear controls updated one canonical model.
- Normal and hostile scanner-derived paths passed through the selected-directory agent boundary without becoming shell source or standalone injected prompt instructions; the inert guest agent opened and fixtures remained unchanged.
- A live scan exposed exactly one machine-visible activity indicator around the bar gauge. Static status and Cancel remained usable; cancellation preserved the last completed result and left no scanner process.
- Permission denial yielded an explicit usable partial result; long, empty, and hostile scopes remained distinct and recoverable.
- Maintained light and dark themes preserved state without compositor errors.
- A same-path update replaced both runtime identities. Disable unloaded both entry points, re-enable restored one of each, and removal preserved synthetic files.
- Final compositor configuration and targeted shell logs were clean.

## Scanner efficiency evidence

The filesystem traversal remains one GNU `du --all --one-file-system --block-size=1 --max-depth=1 --null` process, preserving exact allocated-byte and mount-boundary semantics. Post-processing now classifies common UTF-8 input once and batches metadata and JSON work instead of spawning processes per entry.

On the development host, the same synthetic 600-entry fixture improved from approximately 2.2 seconds to a five-run median of 0.140 seconds. The enforced 1,024-entry regression permits at most 18 `jq`, 16 `stat`, two `iconv`, and zero `base64` invocations for ordinary UTF-8 names. These figures prove removal of process-spawn amplification; they are not a general end-to-end scan-time promise because storage, cache state, directory depth, and filesystem behavior dominate `du` traversal time.

## Visual and media review

Fourteen Disk Lens checkpoints from the final 18-capture run were reviewed, including first use, inline browsing, typed scope, active scan, ready treemap, cached Back, filtered list, selected-folder agent action, maintained light/dark themes, cancelled, partial, long, empty, hostile-path, update, and removed states. All visible filesystem data was synthetic.

The README product tour was built twice from the current six captures. Both builds produced the recorded 161-frame hash. The opening frame and marketplace preview were inspected at original `1000x563` resolution; hierarchy, screenshot crops, progress markers, browser scene, native filter finale, and agent action remained legible without implying automatic scanning, cleanup, privilege, package installation, or hard agent sandboxing.

## Deliberate limitations

- The supported runtime contract is current Omarchy Quattro; no older minimum Omarchy release is claimed.
- Public clean-clone proof for `0.5.0` cannot exist until the candidate is pushed. The `0.4.1` public proof remains valid historical distribution evidence but does not prove the unpublished version.
- Marketplace review state is external and is not asserted by this repository evidence record.
- Automated activation, update, visual, and lifecycle work stays inside disposable guests.
- The agent prompt is an instruction boundary, not a hard sandbox. Provider, network behavior, approvals, and sandbox policy belong to the configured agent.
- Scan state and navigation cache are bounded and in memory; a shell reload requires a new scan.
- Representative cold-disk, dense-model, cancellation-latency, and end-to-end performance budgets are not quantified.
- Pressure-state fixtures, narrow and 5,000-entry layouts, complete keyboard navigation, contrast measurement, screen-reader announcements, and composed reduced-motion acceptance remain unverified.
- Btrfs snapshot, shared-extent, exclusive-allocation, and reclaimable-space accounting is not implemented.

## Historical milestones

Versions `0.1.0` through `0.4.1` established the initial native panel, selected-folder agent guidance, compact pie gauge, strict protocol hardening, self-contained product boundary, deterministic media pipeline, and hardened prompt boundary. Their runtime evidence is superseded by the current candidate except where explicitly retained as public distribution proof.
