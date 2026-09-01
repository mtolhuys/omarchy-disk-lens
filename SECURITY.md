# Security policy

## Reporting a vulnerability

Please report security issues privately to the repository owner through GitHub's private vulnerability reporting feature when it becomes available. Do not open a public issue containing private filesystem paths, directory listings, screenshots of a real home directory, or a working command-injection payload.

Include the affected version, expected and observed behavior, a minimal synthetic fixture, and whether the issue can cross a privilege, path, process, or plugin-lifecycle boundary.

## Supported versions

| Version | Supported |
| --- | --- |
| `0.5.2` | Yes |
| `0.5.0` | Yes |
| `0.4.1` | Yes |
| `0.4.0` and earlier | No |

## Security boundary

Disk Lens is designed as a same-user, local-only inspection tool. It does not need network access, file contents, automatic package installation, root execution, or destructive cleanup. The detailed engineering invariants live in [`docs/SECURITY.md`](docs/SECURITY.md).
