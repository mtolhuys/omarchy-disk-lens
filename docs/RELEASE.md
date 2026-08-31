# Release contract

The current pre-1.0 milestone is recorded in [`RELEASE-EVIDENCE.md`](RELEASE-EVIDENCE.md). Marketplace publication does not turn automated validation into a security review or remove the remaining 1.0 hardening gates.

## Candidate identity

Record one clean Git commit and tag, manifest version and loaded identities, distribution artifact SHA-256, Omarchy source revision and supported release, and Plugin Lab ISO/base identity.

## Publishable checklist

### Product

- README describes implemented behavior in present tense and future work as future work.
- Every visible control has a documented outcome, failure state, and recovery action.
- Capacity and directory totals use accurate language, including Btrfs limitations.
- The full visual analysis flow requires no secondary graphical package.

### Visual and accessibility

- Bar hit target, cross-axis sizing, and panel placement match the live host contract.
- Light and dark themes, pressure states, narrow layouts, long paths, empty/dense results, and partial scans are reviewed.
- Treemap information is equivalently available through list and inspector.
- Keyboard traversal, focus visibility, accessible labels/status, contrast, and reduced motion pass.
- Screenshots use synthetic fixtures and disclose no private filesystem data.

### Runtime and safety

- Manifest validation and every declared entry point pass.
- Source, installed, and loaded runtime identities match after update and rescan.
- Scanner protocol handles hostile filenames, malformed output, disappearing files, permissions, overflow, cancellation, and cleanup.
- No recursive scan starts from bar polling, plugin enablement, or panel opening.
- Paths are passed structurally; no shell evaluation, package manager, generic command runner, or privileged GUI exists.
- Disable/remove terminates owned work and removes only plugin-owned state.

### Evidence and publication

- Source/component, lifecycle, product scenario, performance, and accessibility gates are green.
- Shell logs contain no entry-point, binding, or protocol errors after the reload boundary.
- Version, changelog, manifest, README, artifact, screenshots, and release notes agree.
- License review is complete and the repository contains no VM state, caches, generated evidence, machine-local paths, or real Home metadata.
- No push, tag, release, marketplace submission, or external setting change occurs without owner authorization.

## Evidence record template

```text
Release:
Commit:
Artifact SHA-256:
Omarchy revision / ISO:

Commands:
- source:
- performance:
- lifecycle:
- product scenario:

Timestamped evidence directories:
-

Machine assertions:
-

Visual review:
-

Deliberate limitations / unverified boundaries:
-
```
