# Release contract

The current development milestone is recorded in [`RELEASE-EVIDENCE.md`](RELEASE-EVIDENCE.md). A green vertical slice is not, by itself, a public release.

## Candidate identity

Record one clean candidate:

- Git commit and tag;
- manifest version and loaded runtime identity;
- distribution artifact SHA-256;
- Omarchy source revision and supported release;
- Plugin Lab ISO/base identity;
- QDirStat package/version used for optional-dependency acceptance.

## Publishable checklist

### Product

- README describes implemented behavior in present tense and future work as future work.
- Every visible control has a documented outcome, failure state, and recovery action.
- Capacity and directory totals use accurate language, including Btrfs limitations.
- Core value remains available with QDirStat absent.

### Visual and accessibility

- Bar hit target, cross-axis sizing, and panel placement match the live host contract.
- Light and dark themes, warning/critical states, narrow layouts, long paths, empty/dense results, partial scans, and dependency states are reviewed.
- Treemap information is equivalently available through list and inspector.
- Keyboard traversal, focus visibility, accessible labels/status, contrast, and reduced motion pass.
- Current screenshots use synthetic fixtures and disclose no private filesystem data.

### Runtime and safety

- Manifest validation and every declared entry point pass.
- Source, installed, and loaded runtime identities match after update/rescan.
- Scanner protocol handles hostile filenames, malformed output, disappearing files, permissions, overflow, cancellation, and process cleanup.
- No recursive scan starts from bar polling, plugin enablement, or panel opening.
- Paths are passed structurally; no shell evaluation or privileged GUI exists.
- QDirStat installation is explicit, terminal-owned, optional, and never inferred successful from launch.
- Disable/remove terminates owned work and removes only plugin-owned state; user files and QDirStat remain untouched.

### Evidence

- Source/component suite is green from a clean checkout.
- Idle, scan, large-model, and cancellation performance budgets are green.
- Generic Plugin Lab lifecycle is green.
- Product-owned QMP scenario is green with exact timestamped evidence.
- Optional AUR installation and mapped QDirStat window scenario is green when those claims ship.
- Shell logs contain no entry-point, binding, protocol, or dependency errors after the reload boundary.
- Known unverified boundaries are written literally in release notes.

### Publication

- Version, changelog, manifest, README, artifact, screenshots, and release notes agree.
- License and third-party attribution review is complete.
- Repository contains no VM state, caches, generated evidence, machine-local paths, or real home-directory metadata.
- Installation/removal instructions are tested from a clean clone.
- No push, tag, release, marketplace submission, or external setting change occurs without owner authorization.

## Evidence record template

```text
Release:
Commit:
Artifact SHA-256:
Omarchy revision / ISO:
QDirStat version:

Commands:
- source:
- performance:
- lifecycle:
- product scenario:
- optional dependency:

Timestamped evidence directories:
-

Machine assertions:
-

Visual review:
-

Deliberate limitations / unverified boundaries:
-
```
