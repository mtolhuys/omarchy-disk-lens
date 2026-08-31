# Development milestone evidence

This record describes the strongest verified `0.4.0` development milestone. It is not a public release record and does not authorize a push, tag, release, or marketplace submission.

## Candidate identity

- Manifest: `io.github.mtolhuys.disk-lens` version `0.4.0`
- Service identity: `disk-lens-service-v0400`
- Widget identity: `disk-lens-widget-v0400`
- Accepted repository candidate: pending final Plugin Lab acceptance
- Omarchy base revision: `83881e979b35468c3e7d60b171e319ede61a88fd`
- Plugin Lab base revision: `259ef26e9909bd74323177d2d29e2007cf8c73db`
- Omarchy ISO harness revision: `268bac16d351a21d867e37565738f458b11cb06c`
- ISO/base identity: `omarchy-2026.08.27-x86_64-local`, verified official ISO checksum, reusable clean base plus a fresh per-run overlay
- README showcase: pending current native-only captures and deterministic rebuild

## Required commands

```bash
make test
make validate
make showcase

cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
```

## Current proof target

The final record must name one exact clean candidate and timestamped disposable-guest run proving public `make update`, loaded identities, real pointer routing, first use, scanning activity, exact synthetic totals, treemap, filtered list, agent hand-off, light/dark themes, cancellation, partial/long/empty states, same-path update, disable/re-enable/remove, preserved synthetic files, and clean teardown.

## Deliberate limitations

- No tag, release artifact, artifact SHA-256, public install URL, marketplace entry, or minimum supported Omarchy release exists yet.
- Automated activation, update, visual, and lifecycle work stays inside disposable guests.
- The agent prompt is an instruction boundary, not a hard sandbox. Provider, network behavior, approvals, and sandbox policy belong to the configured agent.
- Scan state is in memory and returns to Home after a shell reload.
- Idle, dense-model, representative-scan, and cancellation budgets are not quantified.
- Pressure-state fixtures, narrow and 5,000-entry layouts, complete keyboard navigation, contrast measurement, screen-reader announcements, and composed reduced-motion acceptance remain unverified.
- Btrfs snapshot, shared-extent, exclusive-allocation, and reclaimable-space accounting is not implemented.

## Historical milestones

Versions `0.1.0` through `0.3.0` established the initial native panel, selected-folder agent guidance, compact pie gauge, loading indicators, strict protocol hardening, and deterministic media pipeline. Their evidence is superseded by the current product boundary.
