# Omarchy Disk Lens engineering contract

Omarchy Disk Lens is a native Omarchy disk-usage dashboard with an optional QDirStat deep-dive path. Beauty, speed, and legibility are co-equal product requirements; a visually polished control that hides state, blocks the shell, or makes storage claims it cannot prove is not complete.

Read these files before changing product behavior:

1. `docs/PRODUCT.md`
2. `docs/UX.md`
3. `docs/ARCHITECTURE.md`
4. `docs/SECURITY.md`
5. `docs/DEPENDENCIES.md`
6. `docs/TESTING.md`
7. `docs/DECISIONS.md`
8. `docs/RELEASE.md`

For Omarchy integration work, also read the maintained Omarchy Plugin Lab `AGENTS.md`, `README.md`, and `TESTING.md`, then inspect the Omarchy source selected by the lab. Activate, install, update, remove, or visually test Disk Lens only in the disposable Plugin Lab, never on the daily host.

## Product invariants

- The bar indicator remains cheap: it may refresh filesystem capacity periodically, but it never starts a recursive directory scan by itself.
- Recursive work is explicit, cancellable, same-user, and asynchronous. Closing the panel must not leave an accidental scan farm behind.
- Distinguish filesystem capacity from directory totals. Never imply that `du`-style totals explain snapshots, reserved blocks, compression, deleted-open files, or every Btrfs allocation difference.
- QDirStat is optional. The native overview must remain useful without it.
- Installing QDirStat is always an explicit, visible user action in a terminal using `omarchy pkg aur add qdirstat`. Never install it from an enable hook or hidden background process.
- Never run QDirStat as root. Never add destructive cleanup actions to the native panel without a new product and threat review.
- Treat paths as data. Pass arguments structurally and never interpolate a selected path into shell code.
- Every state must have visible feedback and a deterministic recovery action: idle, scanning, ready, partial, cancelled, failed, dependency missing, installation launched, and dependency available.
- Theme colors, spacing, type, and motion come from current Omarchy contracts. The UI must work in both light and dark themes and under reduced motion.

## Repository rules

- Keep all tracked documentation, comments, diagnostics, fixtures, and user-facing text in English.
- Do not add private paths, VM images, generated evidence, package caches, credentials, or host diagnostics.
- Keep public claims aligned with the exact candidate proven in the Plugin Lab.
- Use semantic versions. Do not create `manifest.json` until every declared entry point exists and the repository validator can prove it.
- Keep commits atomic and do not push, publish, tag, or alter external repository settings without explicit authorization.

## Release gates

A release candidate requires source tests, manifest validation, light/dark visual review, cancellation and error recovery tests, and a disposable Plugin Lab scenario that drives the rendered bar control and panel through QMP pointer input. QDirStat installation and launch claims require a separate disposable-guest proof of the exact public command and resulting mapped window.
