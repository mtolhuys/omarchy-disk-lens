# Omarchy Disk Lens

> A calm, visual answer to “what is eating my disk?” for Omarchy.

Omarchy Disk Lens is a native bar widget and disk-usage panel for Omarchy. It keeps filesystem pressure glanceable, turns an explicit directory scan into a ranked list and squarified treemap, asks the configured Omarchy agent to explain suspicious folders, and hands a scope to QDirStat when deeper desktop analysis is useful.

Version `0.2.0` is a working development preview. Its vertical slice has passed real-session acceptance in the disposable Omarchy Plugin Lab; it has not been tagged, published, or submitted to a marketplace.

## What works today

- A compact pie gauge shows used capacity for the filesystem backing Home without spending bar width on a percentage label or starting a recursive scan.
- The panel shows exact used and available capacity and keeps scan freshness separate from capacity refreshes.
- Scans are explicit, cancellable, same-user, same-filesystem, and limited to the immediate children of one absolute scope.
- Treemap and ranked-list views share selection, totals, name search, type, hidden-entry, minimum-size, and modification-age filters.
- First-use, scanning, ready, partial, cancelled, failed, empty, filtered-empty, and optional-QDirStat states have distinct recovery paths.
- Selected entries can be drilled into or opened in the file manager. Selected directories expose **Ask Omarchy**, which launches the configured default agent with the exact path, measured size, and an explicit read-only investigation prompt.
- QDirStat opens the current scope or selected directory as the desktop user.
- If QDirStat is missing, **Install** opens a visible terminal with the fixed command `omarchy pkg aur add qdirstat`; Disk Lens never claims that merely opening the terminal installed it.

Disk Lens never scans on panel open, silently installs packages, runs a privileged GUI, or offers destructive cleanup actions. The agent hand-off is explicit and follows the configured agent's own provider and Omarchy launch policy; Disk Lens supplies a non-destructive prompt but does not claim to sandbox that agent.

## Install the current development tree

From this checkout, run:

```bash
make dev-install
```

This is an explicit, host-mutating development command. It first runs the complete source suite and Omarchy manifest validation, snapshots the exact current working tree—including uncommitted edits—then replaces only the installed `io.github.mtolhuys.disk-lens` development copy, enables it, and waits for both loaded runtime identities. Run it again after any local change to guarantee that the active Omarchy session uses the newest code in this checkout.

Do not use `sudo`. The snapshot lives under `${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-disk-lens/development-source`; it is stable across repeated same-path plugin updates. The development installer itself was accepted inside the disposable Plugin Lab before being documented here, but was not invoked on the maintainer's daily host during development.

To remove the development copy:

```bash
omarchy plugin remove io.github.mtolhuys.disk-lens --yes
```

Removal does not uninstall QDirStat or touch scanned files.

## Develop and verify

```bash
make test
make validate
```

Runtime, visual, update, and lifecycle verification belongs in the disposable Omarchy Plugin Lab:

```bash
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/qdirstat.sh
```

Here `./bin/lab` refers to the maintained Plugin Lab checkout. See [`docs/TESTING.md`](docs/TESTING.md) and [`docs/RELEASE-EVIDENCE.md`](docs/RELEASE-EVIDENCE.md) for the exact evidence boundary.

## Why QDirStat is optional

Disk Lens is the quick Omarchy-native overview. QDirStat is the specialist tool for a complete filesystem tree, advanced statistics, package views, and deliberate cleanup workflows. Disk Lens launches QDirStat with a structurally passed directory argument instead of embedding or imitating its Qt interface.

## Project map

| Document | Purpose |
| --- | --- |
| [`docs/PRODUCT.md`](docs/PRODUCT.md) | Implemented promise, scope, and boundaries |
| [`docs/UX.md`](docs/UX.md) | Visual system, interaction model, states, and remaining accessibility work |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Runtime boundaries, data flow, scanner protocol, and QDirStat hand-off |
| [`docs/SECURITY.md`](docs/SECURITY.md) | Path, privilege, installation, and cleanup safety |
| [`docs/DEPENDENCIES.md`](docs/DEPENDENCIES.md) | Required and optional runtime contracts |
| [`docs/TESTING.md`](docs/TESTING.md) | Source and disposable-guest test contract |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Durable architectural decisions |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Proven milestones and release-hardening gaps |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Publishable-release checklist |
| [`docs/RELEASE-EVIDENCE.md`](docs/RELEASE-EVIDENCE.md) | Current verified milestone and deliberate limitations |

## Contributing

Start with [`CONTRIBUTING.md`](CONTRIBUTING.md) and the repository contract in [`AGENTS.md`](AGENTS.md). Never activate development code on a daily Omarchy host as part of automated tests.

## License

MIT. See [`LICENSE`](LICENSE).
