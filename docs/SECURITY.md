# Security model

Disk Lens inspects filenames, metadata, and allocated sizes on local filesystems. It does not need file contents, network access, a privileged GUI, or user-derived command source.

## Trust boundaries

- Paths and filenames are untrusted data, including whitespace, newlines, control characters, leading dashes, and invalid UTF-8 bytes.
- Scanner output is untrusted until every record matches protocol version `1`, its record type, path rules, numeric bounds, and the 5,000-entry limit.
- QDirStat is third-party optional software installed from the AUR only after an explicit user action.
- The Omarchy shell is a long-lived user process, so recursive work and retained models are bounded.

## Enforced invariants

- The bundled helper refuses UID `0`, requires exactly one absolute directory, resolves it with `realpath`, and terminates option parsing before the path.
- GNU `du` emits NUL-delimited records and stays on one filesystem. Filenames never become shell source.
- Display labels replace control characters. Invalid UTF-8 entries retain an encoded identity for accounting but are non-actionable in the UI.
- At most one recursive scan belongs to the service and results contain at most 5,000 immediate children.
- The helper forwards `TERM` to its owned `du` child, waits for it, removes its private temporary directory, and exits `130`. Service destruction stops its owned helper process.
- The last completed result is not replaced by a cancelled or protocol-invalid attempt.
- QDirStat and the file manager receive selected paths as individual process arguments.
- Disk Lens does not expose deletion, cleanup, permission changes, package removal, snapshot actions, or a generic command runner.
- No scan result, path, mount data, or analytics leave the machine.

## Installation boundary

The **Install QDirStat** control opens a visible terminal with one fixed command:

```bash
omarchy pkg aur add qdirstat
```

No path or UI text is interpolated into that command. The terminal owns AUR review, prompts, privilege entry, success, failure, and cancellation. Disk Lens sets only an “installation launched” state, keeps the missing-dependency copy visible until executable detection succeeds, and polls availability while that state is relevant.

## State and lifecycle

Version `0.1.0` keeps capacity, scan results, filters, and selection in memory. It writes no scan-result cache or plugin settings. A shell reload therefore requires a new scan.

Disablement and removal unload the service and widget. The accepted lifecycle leaves scanned user files and QDirStat untouched; only Omarchy-owned plugin installation/runtime data follow the normal plugin lifecycle. The opt-in development installer uses a dedicated snapshot under the user's XDG cache and replaces only plugin id `io.github.mtolhuys.disk-lens`.

## Vulnerability reporting

Follow the private reporting instructions in the root [`SECURITY.md`](../SECURITY.md). Do not publish sensitive paths, screenshots, or proof-of-concept filenames from a real Home directory.
