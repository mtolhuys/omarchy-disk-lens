# Screenshot and showcase contract

Repository media must come from the current Disk Lens runtime in a disposable Omarchy Plugin Lab guest. Captures use synthetic directories only and must contain no maintainer username, host path, personal filename, private mount label, prompt, agent transcript, credential, or host desktop content. The disposable guest's generic Home path may appear where the truthful first-use interface requires it.

## Required captures

- `disk-lens-first-use.png`: compact first-use panel in the maintained dark theme;
- `disk-lens-scanning.png`: active scan with running activity ring and cancellable state;
- `disk-lens-treemap.png`: completed synthetic scan with proportional treemap;
- `disk-lens-agent.png`: selected synthetic directory with visible **Ask Omarchy** in the maintained light theme;
- `disk-lens-filtered-list.png`: one-result ranked list after rendered search and view controls;
- `disk-lens-showcase.gif`: deterministic widescreen product tour built from the captures above.
- `preview.png`: deterministic marketplace preview extracted from the visual-analysis scene.

The GIF presents five truthful native scenes: capacity at a glance, explicit scanning, visual analysis, read-only agent guidance, and focused filtering. It stays legible at GitHub README width and does not imply automatic scans, cleanup, deletion, privileged analysis, package installation, or a sandboxed agent.

## Current provenance

All five source captures come from green `0.4.0` Plugin Lab run `20260831-084135`, which exercised repository candidate `dfabca91e702d01c51bd5c009e52ce6606548b40`. The `0.4.1` security patch changes only the non-visible agent prompt boundary, so those `1280×800` visual sources remain current. The regenerated showcase is `1000×563`, 147 frames, 2,167,422 bytes, with SHA-256 `dbe8cc97764dd57dbb23d70bbcacc5906cb9050e6bf440b98f36af0edf49ed5c`; the `152,640`-byte marketplace preview has SHA-256 `f8597f1a64abff7f55822100a855eead90b949ad639a51a63c533eb359e848e0`. Two consecutive `0.4.1` builds produced those exact hashes.

Rebuild both deterministic derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
