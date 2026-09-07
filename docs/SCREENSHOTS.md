# Screenshot and showcase contract

Repository media must come from the current Disk Lens runtime in a disposable Omarchy Plugin Lab guest. Captures use synthetic directories only and must contain no maintainer username, host path, personal filename, private mount label, prompt, agent transcript, credential, or host desktop content. The disposable guest's generic Home path may appear where the truthful first-use interface requires it.

## Required captures

- `disk-lens-first-use.png`: compact first-use panel with one contextual scan action;
- `disk-lens-folder-picker.png`: theme-native inline browser listing folders without measuring them;
- `disk-lens-scanning.png`: active scan with the bar activity ring and quiet vertical scan beam in the results pane;
- `disk-lens-treemap.png`: completed synthetic scan with hidden entries visible, proportional treemap, and selection actions (**Open · o** / **Ask Omarchy · a** / **Trash · x**);
- `disk-lens-trash.png`: exact synthetic target confirmation with **Cancel** selected;
- `disk-lens-agent.png`: selected synthetic directory with visible **Ask Omarchy** and **Trash** actions;
- `disk-lens-filtered-list.png`: ranked list with the same selection detail strip;
- `disk-lens-banner.png`: composed README / marketplace banner from Plugin Lab console frames;
- `disk-lens-showcase.gif`: deterministic widescreen product tour built from the captures above;
- `preview.png`: deterministic marketplace preview built from the opening visual-insight scene.

The GIF leads with visual analysis, then presents capacity, in-place folder choice, explicit scanning, focused filtering, read-only agent guidance, and recoverable selected-item removal. It stays legible at GitHub README width and does not imply automatic scans, permanent deletion, empty-Trash cleanup, privileged analysis, package installation, or a sandboxed agent.

## Current provenance

Banner source frames come from green `0.6.12` Plugin Lab run `20260907-191623`, which exercised the current working-tree candidate through `tests/lab/banner-capture.sh` in a disposable guest. Frames:

- `success-disk-lens-banner-01-scanning-beam.png` — quiet motion-relative beam over a live synthetic treemap;
- `success-disk-lens-banner-02-treemap-selection.png` — Archive selected with **Open · o** / **Ask Omarchy · a** / **Trash · x**;
- `success-disk-lens-banner-03-keys-sheet.png` — in-panel Keys sheet;
- `success-disk-lens-banner-04-list-selection.png` — ranked list with the same selection footer.

The composed `disk-lens-banner.png` is `1600x986`. Pointer parking kept the virtual cursor outside the panel before each publication capture. Paths are synthetic (`/tmp/disk-lens-fixture/...`) only.

`disk-lens-scanning.png`, `disk-lens-treemap.png`, and `disk-lens-filtered-list.png` were refreshed from the same `20260907-191623` frames. Older first-use, folder-picker, trash, and agent captures remain from green `0.5.2` Plugin Lab run `20260901-121313` until those scenes are re-shot.

The rebuilt `0.6.12` showcase is `1000x563`, 184 frames, 2820833 bytes, with SHA-256 `521d3f183b4586774c6e890a87fb1df3f034d2e00606b172cb7462a47cfc134c`. The 165658-byte marketplace preview has SHA-256 `e5bc209e98cce454959034d062ef0233445f7413b94384d4cb1b5cb5b0f7871e`.

Rebuild showcase derivatives with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, path, runtime-identity, cache, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
