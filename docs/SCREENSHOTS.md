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

All five source captures come from green `0.4.0` Plugin Lab run `20260831-084135`, which exercised repository candidate `dfabca91e702d01c51bd5c009e52ce6606548b40`. Source captures are `1280×800`; the showcase is `1000×563`, 147 frames, 2,167,480 bytes, with SHA-256 `b3a67e0283e6ba46f9565307ae334911665814e20865d76add55d8bb335b8089`. Two consecutive final builds produced that exact hash.

Rebuild the deterministic derivative with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
