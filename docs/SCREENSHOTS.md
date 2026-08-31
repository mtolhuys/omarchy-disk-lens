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
- `preview.png`: deterministic marketplace preview extracted from the safe-removal scene.

The GIF presents seven truthful native scenes: one clear starting action, in-place folder choice, explicit scanning, visual analysis, recoverable selected-item removal, read-only agent guidance, and focused filtering. It stays legible at GitHub README width and does not imply automatic scans, permanent deletion, empty-Trash cleanup, privileged analysis, package installation, or a sandboxed agent.

## Current provenance

All seven source captures come from green `0.5.1` Plugin Lab run `20260831-234322`, which exercised clean repository candidate `671be6091a981f651e6cedd13a77a9000512375a` through installed development snapshot `489839281f1f`. The synthetic `1280x800` captures cover first use without a duplicate header close action, the inline browser, the single-indicator scan state, hidden-by-default storage visibility, exact-target Trash confirmation, the selected-folder agent action, and filtering.

The regenerated showcase is `1000x563`, 184 frames, 3,039,740 bytes, with SHA-256 `8c7c4e95c82cd59fbcc8e22190d25d912a1d9e682c681eb097611041cb93fa13`. The 190,996-byte marketplace preview has SHA-256 `bdd0b2488c62e48727a9b81fc38774135f762b18f19afb60106fb8f44cb2786a`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
