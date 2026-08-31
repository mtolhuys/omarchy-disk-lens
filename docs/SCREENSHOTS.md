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

All seven source captures come from green `0.5.0` Plugin Lab run `20260831-231750`, which exercised clean repository candidate `0fd5be3121d77db522294e7264be8de26fbf5b8a` through installed development snapshot `fcf8b5a5370f`. The synthetic `1280x800` captures cover first use, the inline browser, the single-indicator scan state, hidden-by-default storage visibility, exact-target Trash confirmation, the selected-folder agent action, and filtering.

The regenerated showcase is `1000x563`, 184 frames, 3,039,973 bytes, with SHA-256 `1d07822b55bf2ce9b97a3a700c5567b22e4f66d3f2a40998d943211a7fba994b`. The 191,208-byte marketplace preview has SHA-256 `7393c330bf981e9bfcfb6708cb35097dca4229cbcfca7878b65a7351e946bcf3`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
