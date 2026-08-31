# Test contract

Disk Lens runtime tests never activate the plugin, install packages, or mutate configuration on a daily Omarchy host. Those operations run only in a fresh overlay of the disposable Omarchy Plugin Lab.

## Source gate

Run from the repository root:

```bash
make test
make validate
```

`make test` currently proves:

- the manifest schema, identifiers, kinds, entry points, and executable helper;
- strict capacity parsing and strict version `1` NDJSON scan parsing;
- deterministic formatting, filtering, totals, and treemap bounds;
- paths containing spaces, tabs, newlines, a leading dash, and invalid UTF-8 bytes;
- invalid UTF-8 entries remain displayable but non-actionable;
- permission errors produce a usable partial result;
- scanner `TERM` cancellation exits with status `130` and leaves no child process;
- relative paths and unknown helper arguments are rejected;
- tracked source and documentation remain English.

The helper fixtures use temporary synthetic directories only. They never traverse the developer's Home directory.

## Product-owned Plugin Lab scenarios

With a task-specific variable pointing at the maintained lab checkout:

```bash
cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/qdirstat.sh
```

`acceptance.sh` installs through the public `make update` target inside the guest and proves:

1. recovery from a checkout left by an interrupted add, source tests, manifest validation, bounded catalog discovery, plugin registration, and loaded service/widget identities;
2. real bar geometry and QMP pointer routing into the real panel;
3. exact synthetic scan scope, entry count, allocated total, and explicit refresh;
4. treemap selection plus rendered list/search/clear interaction;
5. the visible **Ask Omarchy** action closing the panel and launching an `org.omarchy.agent` terminal with the exact selected path, size, read-only constraint, and confirmation boundary captured by a guest-only default-agent shim;
6. Catppuccin Latte and Tokyo Night rendering without state loss or compositor errors;
7. cancellation with the last completed result preserved and no scanner left behind;
8. explicit partial, long-scope, empty, and missing-QDirStat states;
9. a same-path public plugin update replacing both loaded runtime identities;
10. disable, re-enable, removal, user-data preservation, and post-run log cleanliness.

`qdirstat.sh` separately proves:

1. the public **Install** action opens a visible terminal running exactly `omarchy pkg aur add qdirstat`;
2. cancelling that terminal is not presented as installation success;
3. the stable AUR package can be built and installed only inside the disposable guest;
4. Disk Lens re-detects the executable;
5. the public **Open** action maps QDirStat on the exact synthetic directory as the desktop user;
6. removing Disk Lens leaves QDirStat, the QDirStat process, and the synthetic user data untouched.

## Visual review boundary

The current vertical-slice matrix covers first use, compact treemap ready, selected-folder agent hand-off, filtered list, light theme, cancelled, partial, long scope, empty, missing dependency, visible installation terminal, mapped QDirStat, and removed states. Every screenshot uses synthetic guest data and is paired with a machine assertion. The agent prompt is captured by an inert guest-only executable; no maintainer credentials, host agent, or real user path enters the VM.

Before a public release, add quantified warning/critical/unknown-capacity fixtures, narrow and dense layouts, composed-panel reduced-motion acceptance, complete keyboard focus order, contrast measurement, and assistive-technology review. Disk Lens itself adds no custom looping or geometry animation.

## Performance boundary

The implementation already bounds recursive process count to one, retained entries to 5,000, treemap items to 48, and rendered list items to 80. Panel opening and capacity display do not wait for a recursive scan.

No public performance claim is made yet. A release candidate still needs recorded idle CPU/memory, representative scan responsiveness, dense-model interaction, and maximum cancellation teardown measurements with VM context.

## Evidence records

Every milestone records the candidate identity, manifest version, Omarchy base identity, QDirStat version when relevant, exact commands, timestamped run directories, screenshots reviewed, and deliberate gaps in [`RELEASE-EVIDENCE.md`](RELEASE-EVIDENCE.md). README and changelog claims may not exceed that record.
