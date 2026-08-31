# Test contract

Disk Lens runtime tests never activate the plugin or mutate configuration on a daily Omarchy host. Those operations run only in a fresh overlay of the disposable Omarchy Plugin Lab.

## Source gate

Run from the repository root:

```bash
make test
make validate
```

`make test` proves the manifest and entry points; strict capacity and scan parsing; bounded paths, warnings, totals, and completion accounting; deterministic formatting, filtering, totals, and treemap geometry; hostile filenames and invalid UTF-8 handling; usable partial results; cancellation cleanup; rejected invalid arguments; English tracked text; and ShellCheck when available. Fixtures use temporary synthetic directories only and never traverse the developer's Home directory.

## Product-owned Plugin Lab scenario

```bash
cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/public-install.sh
```

`acceptance.sh` installs through public `make update` inside the guest and proves:

1. interrupted-add recovery, source tests, manifest validation, catalog discovery, registration, and loaded identities;
2. real bar geometry and QMP pointer routing into the real panel;
3. exact synthetic scan scope, count, total, and explicit refresh;
4. treemap selection plus rendered list, search, and clear interaction;
5. visible **Ask Omarchy** closing the panel and launching an `org.omarchy.agent` terminal with the bounded path value, size, read-only constraint, untrusted-data boundary, and confirmation boundary captured by a guest-only shim, including a scanner-derived newline-injection fixture;
6. maintained light and dark themes without state loss or compositor errors;
7. a machine-visible activity indicator, cancellation with the last result preserved, and no scanner left behind;
8. explicit partial, long-scope, and empty states;
9. a same-path public plugin update replacing both loaded identities;
10. disable, re-enable, removal, user-data preservation, and clean logs.

`public-install.sh` separately proves that the README's public GitHub URL clones the expected repository commit, passes Omarchy validation, enables and loads both `v0401` entry points, and removes cleanly through the documented plugin id.

## Visual review boundary

The current matrix covers first use, active scanning, compact treemap, selected-folder agent hand-off, filtered list, light theme, cancelled, partial, long scope, empty, and removed states. Every screenshot uses synthetic guest data and is paired with a machine assertion. The agent prompt is captured by an inert guest-only executable; no credentials, host agent, or real user path enters the VM.

Before public release, add quantified warning/critical/unknown-capacity fixtures, narrow and dense layouts, composed reduced-motion acceptance, complete keyboard focus order, contrast measurement, and assistive-technology review.

## Performance boundary

The implementation bounds recursive process count to one, retained entries to 5,000, treemap items to 48, and rendered list items to 80. Panel opening and capacity display do not wait for a recursive scan. No public performance claim is made until idle CPU/memory, representative scan responsiveness, dense-model interaction, and cancellation teardown are measured in a recorded VM context.

## Evidence records

Every milestone records the candidate identity, manifest version, Omarchy base identity, exact commands, timestamped run directories, screenshots reviewed, and deliberate gaps in [`RELEASE-EVIDENCE.md`](RELEASE-EVIDENCE.md). README and changelog claims may not exceed that record.
