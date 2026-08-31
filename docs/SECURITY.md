# Security model

Disk Lens inspects filenames, metadata, and allocated sizes on local filesystems. It does not need file contents, network access, a privileged GUI, or user-derived command source.

## Trust boundaries

- Paths and filenames are untrusted data, including whitespace, newlines, control characters, leading dashes, and invalid UTF-8 bytes.
- Scanner and shallow-folder output are untrusted until every record matches protocol version `1`, its field rules, bounded counts, and exact completion accounting.
- **Ask Omarchy** delegates one selected path and measured size to the user's configured coding agent after an explicit user action. That agent may use a remote provider and follows Omarchy's own launch and approval policy.
- **Trash** changes one selected filesystem entry only after a modal confirmation. Desktop Trash support and recovery behavior belong to GLib/GIO and the underlying filesystem.
- The Omarchy shell is a long-lived user process, so recursive work and retained models are bounded.

## Enforced invariants

- Both bundled helpers refuse UID `0`, require exactly one absolute directory, resolve it with `realpath`, and terminate option parsing before the path.
- GNU `du` emits NUL-delimited records and stays on one filesystem. Filenames never become shell source.
- GNU `find` emits NUL-delimited immediate-directory records for the inline browser and never starts a size traversal.
- Display labels replace control characters. Invalid UTF-8 entries retain an encoded identity for accounting but are non-actionable in the UI.
- At most one recursive scan belongs to the service. Scan results and folder-browser results are separately bounded to 5,000 immediate entries, while rendered projections are smaller.
- Each helper forwards `TERM` to its owned `du`, `find`, or `gio` child, waits for it, removes private temporary state, and exits `130`.
- The last completed result is not replaced by a cancelled or protocol-invalid attempt.
- Navigation cache snapshots are accepted only after strict scan parsing, remain memory-only, and are bounded to eight scopes and 12,000 total entries.
- The file manager receives selected paths as individual process arguments.
- The Trash service accepts only an actionable exact entry in the current validated scan. The helper independently requires its resolved parent to equal that scope and passes the target as one `gio trash --` argument.
- `omarchy agent prompt` receives the complete fixed-format question as one process argument. Before a selected path enters that question, C0 and DEL control characters are removed and the value is capped at 4,096 characters. Selected paths never become shell source.
- Disk Lens exposes no permanent deletion, empty-Trash, bulk cleanup, permission changes, package management, snapshot actions, privileged helper, destructive IPC route, or generic command runner.
- Capacity and scan data remain local unless the user explicitly activates **Ask Omarchy**.

## Agent boundary

**Ask Omarchy** is available only for an actionable selected directory. The prompt places its read-only rules first, explicitly classifies filesystem-derived text as untrusted data, and then encloses the sanitized path in a labelled data block. It also includes allocated bytes and formatted size, the user's necessity and deletion-safety questions, instructions to distinguish findings from guesses, and a confirmation requirement before proposing any change.

This is an instruction boundary, not a hard sandbox. The maintained Omarchy launcher may start agents with their configured approval behavior, and the selected agent may contact a network provider. Disk Lens does not choose the agent, capture credentials, inspect responses, or claim that its prompt can override runtime policy.

## Trash boundary

The confirmation snapshot contains the selected path, displayed allocation, kind, and current scope. Control characters are repaired and markup delimiters are escaped before the path enters the shell-native message component. The modal always opens with **Cancel** selected. Confirmation is rejected if a scan or another Trash operation is active, if the active scope changed, if the entry disappeared from the current model, or if it is no longer actionable.

`scripts/disk-lens-trash` refuses root execution, the scanned scope itself, and the Home directory itself. It never resolves the selected item, so moving a symlink moves the link rather than its target. It resolves only the scope and target parent, requires them to match, and never evaluates path text. Unsupported mounts, missing targets, and `gio` failures return fixed user-facing errors and leave the scan model intact. Disk Lens never empties Trash, claims immediate capacity recovery, or substitutes `rm`.

## State and lifecycle

Version `0.5.1` keeps capacity, bounded navigation snapshots, folder-browser state, filters, selection, Trash status, and agent-dispatch bookkeeping in memory. It writes no scan-result cache or plugin settings. Disablement and plugin removal unload the service and widget without deleting scanned files or emptying desktop Trash. The opt-in development installer uses a dedicated XDG-cache snapshot and replaces only plugin id `io.github.mtolhuys.disk-lens`.

## Vulnerability reporting

Follow the private reporting instructions in the root [`SECURITY.md`](../SECURITY.md). Do not publish sensitive paths, screenshots, or proof-of-concept filenames from a real Home directory.
