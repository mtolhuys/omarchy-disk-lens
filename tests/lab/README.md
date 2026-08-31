# Plugin Lab scenarios

Product-owned host-driven scenarios belong here. They are executed by the maintained disposable Omarchy Plugin Lab and must never target the daily host.

- `acceptance.sh` covers the complete native journey: one-action first use, editable and browsed scopes, hidden-by-default visibility, cache-restored Back, explicit Refresh, selected-item Trash confirmation/cancellation/failure/success, themes, scan and cancellation states, filtering, agent guidance, runtime update, and lifecycle cleanup.
- `public-install.sh` proves the documented public GitHub clone, exact commit, enablement, loaded identities, removal, and cleanup.

The scenario creates only synthetic guest fixtures inside the run overlay. Its plugin, compositor, and process mutations disappear with that overlay.
