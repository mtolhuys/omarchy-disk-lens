# Screenshot and showcase contract

Repository media must come from the current Disk Lens runtime in a disposable Omarchy Plugin Lab guest. Captures use synthetic directories only and must contain no maintainer username, host path, personal filename, private mount label, prompt, agent transcript, credential, or host desktop content. The disposable guest's generic Home path may appear where the truthful first-use interface requires it.

## Required captures

- `disk-lens-first-use.png`: compact first-use panel in the maintained dark theme;
- `disk-lens-scanning.png`: active scan with running activity ring and cancellable state;
- `disk-lens-treemap.png`: completed synthetic scan with proportional treemap;
- `disk-lens-agent.png`: selected synthetic directory with visible **Ask Omarchy** in the maintained light theme;
- `disk-lens-filtered-list.png`: one-result ranked list after rendered search and view controls;
- `disk-lens-showcase.gif`: deterministic widescreen product tour built from the captures above.

The GIF presents five truthful native scenes: capacity at a glance, explicit scanning, visual analysis, read-only agent guidance, and focused filtering. It stays legible at GitHub README width and does not imply automatic scans, cleanup, deletion, privileged analysis, package installation, or a sandboxed agent.

## Current provenance

The source captures come from the latest green `0.4.0` Plugin Lab product scenario recorded in [`RELEASE-EVIDENCE.md`](RELEASE-EVIDENCE.md). Source captures are `1280×800`; exact showcase dimensions, frames, bytes, hash, and consecutive-build check are recorded there after generation.

Rebuild the deterministic derivative with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
