# Plugin Lab scenarios

Product-owned host-driven scenarios belong here. They are executed by the maintained disposable Omarchy Plugin Lab and must never target the daily host.

- `acceptance.sh` covers the native public journey, themes, scan states, filtering, runtime update, and lifecycle cleanup.
- `qdirstat.sh` covers the visible install command, cancelled installation state, disposable AUR build, live detection, mapped selected-scope window, and ownership boundaries.

Both scenarios create only synthetic guest fixtures inside the run overlay. Their package, plugin, compositor, and process mutations disappear with that overlay.
