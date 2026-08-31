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

All six source captures come from green `0.5.0` Plugin Lab run `20260831-221753`, which exercised exact worktree snapshot `7a69c5c7892d` based on repository revision `93fe75e5e60e950a2cfaf9043c54144669abadc8`. The synthetic `1280x800` captures cover first use, the inline browser, the single-indicator scan state, hidden-by-default storage visibility, the selected-folder agent action, and filtering.

The regenerated showcase is `1000x563`, 161 frames, 2,370,393 bytes, with SHA-256 `3dcb9f139ce13c86d8329483b9086a49505f237de5a0446feebe95854829db44`. The 165,961-byte marketplace preview has SHA-256 `9f4640dca8fdf6cf9e135fc2ac4e7bc4f6eb72635dcd63b5892a5d37f51c63fd`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
