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

Until the `0.5.2` candidate completes its exact-candidate visual run, all seven source captures remain the synthetic `1280x800` images from green `0.5.1` Plugin Lab run `20260831-234322`. The candidate does not claim those historical captures as new runtime evidence; they temporarily preserve truthful first-use, inline-browser, single-indicator, treemap, Trash, agent, and filter compositions while the release media is prepared.

The current `0.5.2` candidate showcase is `1000x563`, 184 frames, 2,745,006 bytes, with SHA-256 `a1f8a43f518f816451004af0b69f11a26ded0da0c883173bb3ae9a1088e6f2fd`. The 194,661-byte visual-insight marketplace preview has SHA-256 `da9087ebf782b371363c90c0926480e41863c3d5312d5e49bac939618a34c164`. Two consecutive deterministic builds produced those exact hashes.

Rebuild both derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
