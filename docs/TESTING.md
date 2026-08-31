# Test contract

Disk Lens runtime tests never activate the plugin or mutate configuration on a daily Omarchy host. Those operations run only in a fresh overlay of the disposable Omarchy Plugin Lab.

## Source gate

Run from the repository root:

```bash
make test
make validate
```

`make test` proves the manifest and entry points; strict capacity, scan, and shallow-folder parsing; bounded paths, warnings, totals, completion accounting, and post-processing process counts; deterministic formatting, scope normalization, navigation helpers, filtering, totals, and treemap geometry; hidden and hostile filenames plus invalid UTF-8 handling; guarded Trash arguments, parent-scope enforcement, symlink treatment, no-shell hostile paths, and no permanent-delete fallback; usable partial results; cancellation cleanup; rejected invalid arguments; English tracked text; and ShellCheck when available. Fixtures use temporary synthetic directories only and never traverse the developer's Home directory or modify the host desktop Trash.

## Product-owned Plugin Lab scenario

```bash
cd "$OMARCHY_PLUGIN_LAB_ROOT"
./bin/lab doctor
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/acceptance.sh
./bin/lab plugin /absolute/path/to/omarchy-disk-lens/tests/lab/public-install.sh
```

`acceptance.sh` installs through public `make update` inside the guest and proves:

1. interrupted-add recovery, source tests, manifest validation, catalog discovery, registration, and loaded identities;
2. real bar geometry and QMP pointer routing into the real panel, including square close-control geometry, rendered dismissal, and bar-pointer reopening;
3. exactly one first-use scan action, hidden entries shown by default, the rendered inline folder browser, Escape recovery, typed scope entry, exact synthetic count and total, and explicit refresh;
4. treemap selection, rendered Drill in, Back restoring the exact prior timestamp without a scanner process, plus rendered list, search, and clear interaction;
5. visible **Ask Omarchy** closing the panel and launching an `org.omarchy.agent` terminal with the bounded path value, size, read-only constraint, untrusted-data boundary, and confirmation boundary captured by a guest-only shim, including a scanner-derived newline-injection fixture;
6. rendered **Trash** opening an exact-target modal on Cancel, cancel preserving data, explicit keyboard confirmation, an unsupported internal mount retaining its item with a visible error, and a user-home entry moving to desktop Trash before an automatic fresh scan;
7. maintained light and dark themes without state loss or compositor errors;
8. exactly one machine-visible activity indicator, cancellation with the last result preserved, and no scanner left behind;
9. explicit partial, long-scope, and empty states;
10. a same-path public plugin update replacing both loaded identities;
11. disable, re-enable, removal, ordinary user-data preservation, retained desktop Trash contents, and clean logs.

`public-install.sh` separately proves that the README's public GitHub URL clones the expected repository commit, passes Omarchy validation, enables and loads both `v0500` entry points, and removes cleanly through the documented plugin id. It must be rerun after the candidate is published; the local development acceptance does not substitute for public-clone evidence.

## Visual review boundary

The current matrix covers first use, inline folder browsing, typed scope, cache-restored Back navigation, active scanning, compact treemap, selected-folder agent hand-off, Trash confirmation, unsupported Trash, successful Trash, filtered list, light theme, cancelled, partial, long scope, empty, and removed states. Every screenshot uses synthetic guest data and is paired with a machine assertion. The agent prompt is captured by an inert guest-only executable; no credentials, host agent, real user path, or host Trash state enters the VM.

Before public release, add quantified warning/critical/unknown-capacity fixtures, narrow and dense layouts, composed reduced-motion acceptance, complete keyboard focus order, contrast measurement, and assistive-technology review.

## Performance boundary

The implementation bounds recursive process count to one, one scan result to 5,000 entries, the navigation cache to eight scopes and 12,000 entries, folder results to 5,000 entries, treemap items to 48, and rendered lists to 80. The 1,024-entry source fixture enforces at most 16 metadata batches, 18 JSON batches, two UTF-8 checks, and zero standalone Base64 processes for normal UTF-8 names. Panel opening, capacity display, and folder browsing do not wait for a recursive scan. No end-to-end public performance claim is made until idle CPU/memory, representative scan responsiveness, dense-model interaction, and cancellation teardown are measured in a recorded VM context.

## Evidence records

Every milestone records the candidate identity, manifest version, Omarchy base identity, exact commands, timestamped run directories, screenshots reviewed, and deliberate gaps in [`RELEASE-EVIDENCE.md`](RELEASE-EVIDENCE.md). README and changelog claims may not exceed that record.
