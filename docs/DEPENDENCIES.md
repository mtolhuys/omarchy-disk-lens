# Dependency contract

## Runtime platform

Disk Lens currently targets the maintained Omarchy development plugin contract used by its disposable Plugin Lab base:

- third-party `schemaVersion: 1` plugins;
- `service` and `bar-widget` entry points plus runtime snapshots;
- the Omarchy `BarWidget`, `KeyboardPanel`, UI tokens, and plugin service registry;
- Quickshell and the QML modules shipped by Omarchy.

A public minimum supported Omarchy release has not yet been declared; clean-clone acceptance against that version is a release gate.

## Required commands

Runtime code uses commands supplied by the tested Omarchy/Arch environment:

- `findmnt` from util-linux for byte-oriented Home-filesystem capacity;
- GNU `du`, `stat`, `realpath`, `base64`, and `mktemp` for the bundled scanner;
- `jq` and `iconv` for strict NDJSON records and UTF-8 classification;
- `omarchy-cmd-present`, `uwsm-app`, `xdg-open`, `omarchy agent prompt`, and `omarchy-launch-floating-terminal-with-presentation` for desktop integration.

The opt-in development installer additionally requires `git`, `tar`, `jq`, `omarchy`, and `omarchy-shell`. It refuses UID `0`.

Node.js is used only by source tests. `qmllint` plus a selected Omarchy source tree can provide an additional development lint pass; neither is a plugin runtime dependency.

`dua` remains a useful Omarchy terminal application, but Disk Lens does not parse its presentation-oriented output as an API.

## Optional QDirStat dependency

QDirStat unlocks deep inspection and remains optional:

- package: `qdirstat` from the AUR;
- explicit install command: `omarchy pkg aur add qdirstat`;
- runtime executable: `qdirstat`;
- supported Disk Lens input: one selected directory path.

Disk Lens does not vendor QDirStat, copy its treemap code, own its UI, or remove it. Package, unpackaged-file, and cache-file inputs are not part of `0.2.0`.

## Optional agent dependency

**Ask Omarchy** requires a default coding agent already selected and installed through Omarchy. Disk Lens calls only the maintained `omarchy agent prompt` entry point and does not install, configure, authenticate, or choose an agent. Core capacity, scanning, filtering, navigation, file-manager, and QDirStat behavior remain available without a working agent.

## Dependency policy

- Prefer contracts already shipped by Omarchy.
- Do not add a runtime compiler, language package manager, daemon, systemd unit, or network service.
- Do not download or install code during plugin enablement or ordinary use.
- Treat QDirStat installation as a terminal-owned user workflow.
- Review architecture, security, artifact size, license, and update behavior before adding any dependency.
