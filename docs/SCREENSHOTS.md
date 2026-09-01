# Screenshot and showcase contract

Repository media must come from the current Disk Lens runtime in a disposable Omarchy Plugin Lab guest. Captures use synthetic directories only and must contain no maintainer username, host path, personal filename, private mount label, prompt, agent transcript, credential, or host desktop content. The disposable guest's generic Home path may appear where the truthful first-use interface requires it.

## Required captures

- `disk-lens-first-use.png`: compact first-use panel with one contextual scan action;
- `disk-lens-folder-picker.png`: theme-native inline browser listing folders without measuring them;
- `disk-lens-scanning.png`: active scan with the single bar activity ring and cancellable panel state;
- `disk-lens-treemap.png`: completed synthetic scan with hidden entries visible and proportional treemap;
- `disk-lens-trash.png`: exact synthetic target confirmation with **Cancel** selected;
- `disk-lens-agent.png`: selected synthetic directory with visible **Ask Omarchy** and **Trash** actions;
- `disk-lens-filtered-list.png`: one-result ranked list after rendered search and view controls;
- `disk-lens-showcase.gif`: deterministic widescreen product tour built from the captures above;
- `preview.png`: deterministic marketplace preview built from the opening visual-insight scene.

The GIF leads with visual analysis, then presents capacity, in-place folder choice, explicit scanning, focused filtering, read-only agent guidance, and recoverable selected-item removal. It stays legible at GitHub README width and does not imply automatic scans, permanent deletion, empty-Trash cleanup, privileged analysis, package installation, or a sandboxed agent.

## Current provenance

All seven source captures come from green `0.5.2` Plugin Lab run `20260901-121313`, which exercised clean repository candidate `e563eb4b7bf166e5241996fe0cef4566b283c5d7` through installed development snapshot `1806ccbfec0e`. The synthetic `1280x800` captures cover first use, inline browsing, the single-indicator scan state, hidden-by-default treemap insight, exact-target Trash confirmation, the selected-folder agent action, and filtering. The scenario parks the virtual pointer outside the panel before each publication capture, avoiding accidental hover emphasis or cursor obstruction.

The `0.5.2` showcase is `1000x563`, 184 frames, 2,707,264 bytes, with SHA-256 `8e1795b72735b02ac9dcd4228321a6db46af4b63378be2c0c8f80d0ba541281d`. The 194,028-byte visual-insight marketplace preview has SHA-256 `8f3f2810c29ba5a3993e4a4403acf340de78b7e33df55aced9f3e5f79c98e4f9`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
