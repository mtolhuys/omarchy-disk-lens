# Screenshot and showcase contract

Repository media must come from the current Disk Lens runtime in a disposable Omarchy Plugin Lab guest. Captures use synthetic directories only and must contain no maintainer username, host path, personal filename, private mount label, prompt, agent transcript, credential, or host desktop content. The disposable guest's generic Home path may appear where the truthful first-use interface requires it.

## Required captures

- `disk-lens-first-use.png`: compact first-use panel in the maintained dark theme;
- `disk-lens-scanning.png`: active scan with the running activity ring and cancellable state;
- `disk-lens-treemap.png`: completed synthetic scan with proportional treemap;
- `disk-lens-agent.png`: selected synthetic directory with the visible **Ask Omarchy** action in the maintained light theme;
- `disk-lens-qdirstat.png`: Disk Lens and real QDirStat on the same synthetic scope;
- `disk-lens-showcase.gif`: deterministic widescreen product tour built from the captures above.

The GIF presents five truthful scenes: capacity at a glance, explicit scanning, visual analysis, read-only agent guidance, and QDirStat hand-off. It uses current-product screenshots as visual evidence, stays legible at GitHub README width, and does not imply automatic scans, cleanup, deletion, privileged analysis, embedded QDirStat, or a sandboxed agent.

Rebuild the deterministic derivative with:

```bash
make showcase
```

Screenshots prove visual composition only. Scanner, prompt, package, path, runtime-identity, and lifecycle claims require the machine assertions in [`TESTING.md`](TESTING.md).
