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

All six source captures come from green `0.5.0` Plugin Lab run `20260831-224131`, which exercised repository candidate `54973b88185ddd017672776b31c972c0259ef90c` through installed development snapshot `fe65d927d937`. The synthetic `1280x800` captures cover first use, the inline browser, the single-indicator scan state, hidden-by-default storage visibility, the selected-folder agent action, and filtering.

The regenerated showcase is `1000x563`, 161 frames, 2,375,757 bytes, with SHA-256 `a624529a06f406796a54ab429113b0f96029d4bdc2ca887083d052876289fbc2`. The 165,875-byte marketplace preview has SHA-256 `4cda620dc14791af79fe958c48d2b68e90f9bfac9c6197f16b92d77f392d096f`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
