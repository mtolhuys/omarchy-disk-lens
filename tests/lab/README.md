# Plugin Lab scenarios

Product-owned host-driven scenarios belong here. They are executed by the maintained disposable Omarchy Plugin Lab and must never target the daily host.

- `acceptance.sh` covers the complete native public journey, themes, scan states, filtering, agent guidance, runtime update, and lifecycle cleanup.

The scenario creates only synthetic guest fixtures inside the run overlay. Its plugin, compositor, and process mutations disappear with that overlay.
