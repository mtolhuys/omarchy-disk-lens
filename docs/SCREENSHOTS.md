# Screenshot and showcase contract

Repository media must come from the current Disk Lens runtime in a disposable Omarchy Plugin Lab guest. Captures use synthetic directories only and must contain no maintainer username, host path, personal filename, private mount label, prompt, agent transcript, credential, or host desktop content. The disposable guest's generic Home path may appear where the truthful first-use interface requires it.

## Required captures

- `disk-lens-first-use.png`: compact first-use panel with one contextual scan action;
- `disk-lens-folder-picker.png`: theme-native inline browser listing folders without measuring them;
- `disk-lens-scanning.png`: active scan with the single bar activity ring and cancellable panel state;
- `disk-lens-treemap.png`: completed synthetic scan with hidden entries visible and proportional treemap;
- `disk-lens-agent.png`: selected synthetic directory with visible **Ask Omarchy** in the maintained light theme;
- `disk-lens-filtered-list.png`: one-result ranked list after rendered search and view controls;
- `disk-lens-showcase.gif`: deterministic widescreen product tour built from the captures above;
- `preview.png`: deterministic marketplace preview extracted from the visual-analysis scene.

The GIF presents six truthful native scenes: one clear starting action, in-place folder choice, explicit scanning, visual analysis, read-only agent guidance, and focused filtering. It stays legible at GitHub README width and does not imply automatic scans, cleanup, deletion, privileged analysis, package installation, or a sandboxed agent.

## Current provenance

All six source captures come from green `0.5.0` Plugin Lab run `20260831-223300`, which exercised repository candidate `90b1f6865dd3ed0119ddb63d5b269757b0014557` through installed development snapshot `f2ab87b65dc4`. The synthetic `1280x800` captures cover first use, the inline browser, the single-indicator scan state, hidden-by-default storage visibility, the selected-folder agent action, and filtering.

The regenerated showcase is `1000x563`, 161 frames, 2,375,497 bytes, with SHA-256 `dfccab9f3b26b0bb009d25eae61963032b97b4439edef42a56fc00b9c5baba9a`. The 166,009-byte marketplace preview has SHA-256 `21d440e1e26b3fcf4e4b50499ac2e948b734048e48d49abadccf8a74062b40a9`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
