# Security model

Disk Lens inspects filenames, metadata, and allocated sizes on local filesystems. It does not need file contents, network access, a privileged GUI, or user-derived command source.

## Trust boundaries

- Paths and filenames are untrusted data, including whitespace, newlines, control characters, leading dashes, and invalid UTF-8 bytes.
- Scanner output is untrusted until every record matches protocol version `1`, its field rules, bounded counts, and exact completion accounting.
- **Ask Omarchy** delegates one selected path and measured size to the user's configured coding agent after an explicit user action. That agent may use a remote provider and follows Omarchy's own launch and approval policy.
- The Omarchy shell is a long-lived user process, so recursive work and retained models are bounded.

## Enforced invariants

- The bundled helper refuses UID `0`, requires exactly one absolute directory, resolves it with `realpath`, and terminates option parsing before the path.
- GNU `du` emits NUL-delimited records and stays on one filesystem. Filenames never become shell source.
- Display labels replace control characters. Invalid UTF-8 entries retain an encoded identity for accounting but are non-actionable in the UI.
- At most one recursive scan belongs to the service and results contain at most 5,000 immediate children.
- The helper forwards `TERM` to its owned `du` child, waits for it, removes its private temporary directory, and exits `130`.
- The last completed result is not replaced by a cancelled or protocol-invalid attempt.
- The file manager receives selected paths as individual process arguments.
- `omarchy agent prompt` receives the complete fixed-format question as one process argument. Before a selected path enters that question, C0 and DEL control characters are removed and the value is capped at 4,096 characters. Selected paths never become shell source.
- Disk Lens does not expose deletion, cleanup, permission changes, package management, snapshot actions, or a generic command runner.
- Capacity and scan data remain local unless the user explicitly activates **Ask Omarchy**.

## Agent boundary

**Ask Omarchy** is available only for an actionable selected directory. The prompt places its read-only rules first, explicitly classifies filesystem-derived text as untrusted data, and then encloses the sanitized path in a labelled data block. It also includes allocated bytes and formatted size, the user's necessity and deletion-safety questions, instructions to distinguish findings from guesses, and a confirmation requirement before proposing any change.

This is an instruction boundary, not a hard sandbox. The maintained Omarchy launcher may start agents with their configured approval behavior, and the selected agent may contact a network provider. Disk Lens does not choose the agent, capture credentials, inspect responses, or claim that its prompt can override runtime policy.

## State and lifecycle

Version `0.4.1` keeps capacity, scan results, filters, selection, and agent-dispatch bookkeeping in memory. It writes no scan-result cache or plugin settings. Disablement and removal unload the service and widget; scanned user files stay untouched. The opt-in development installer uses a dedicated XDG-cache snapshot and replaces only plugin id `io.github.mtolhuys.disk-lens`.

## Vulnerability reporting

Follow the private reporting instructions in the root [`SECURITY.md`](../SECURITY.md). Do not publish sensitive paths, screenshots, or proof-of-concept filenames from a real Home directory.
