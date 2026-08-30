# Changelog

All notable changes to Omarchy Disk Lens are documented here. The format follows Keep a Changelog and the project uses Semantic Versioning.

## Unreleased

### Changed

- Reserved for changes after the `0.1.0` development milestone.

## 0.1.0 — 2026-08-30

### Added

- Omarchy `schemaVersion: 1` service and bar-widget entry points with explicit loaded build identities.
- Home-filesystem capacity polling independent from recursive scans.
- A same-user, one-filesystem, NUL-safe immediate-child scanner with a strict NDJSON protocol, hostile-path handling, partial-result warnings, a 5,000-entry bound, and cancellation.
- Theme-native Disk Lens panel with treemap and ranked-list views, shared selection, search, filters, exact values, drill-down, file-manager launch, and explicit recovery states.
- Optional QDirStat detection, visible AUR installation terminal, live re-detection, and structured selected-directory launch.
- Source tests plus disposable Plugin Lab scenarios for pointer routing, visual states, themes, scanning, cancellation, partial traversal, same-path runtime update, lifecycle cleanup, and the real QDirStat bridge.
- `make dev-install`, which validates and installs an exact snapshot of the current working tree into an explicitly selected active Omarchy development session.
- Product, UX, architecture, security, dependency, testing, decision, roadmap, release, contribution, support, and implementation contracts.

### Known limitations

- This milestone is not a tagged or published release and has no distribution artifact.
- Scan results are intentionally in memory; a shell reload requires a new scan.
- Full performance budgets, narrow-layout coverage, warning/critical capacity fixtures, and comprehensive assistive-technology acceptance remain release work.
