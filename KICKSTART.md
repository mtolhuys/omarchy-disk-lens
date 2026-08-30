# Implementation kickstart

Paste the prompt below into a new Codex task from the repository root.

---

We are building **Omarchy Disk Lens** in the current repository root.

Take this project from its documentation scaffold through the strongest coherent implementation milestone you can genuinely verify, with the first priority being a beautiful, highly usable vertical slice rather than a broad mock-up.

Before changing anything:

1. Read `AGENTS.md` and every Markdown file it lists, completely.
2. Use the `omarchy-plugin-lab` skill and read its maintained `AGENTS.md`, `README.md`, and `TESTING.md` completely.
3. Inspect the current Omarchy source selected by the lab, especially the third-party manifest contract, bar-widget host pointer/open/close API, theme tokens/components, process APIs, runtime snapshot behavior, and current tests. Do not copy an older plugin blindly.
4. Locate the maintained disposable lab through the skill/current workspace and run `./bin/lab doctor` from its root before activating anything.

Then implement Milestone M1 from `docs/ROADMAP.md` and continue into M2 only where the vertical slice remains polished and fully testable:

- create `manifest.json` only together with working `service` and `bar-widget` entry points;
- expose a build identity from every independently loaded entry point;
- implement cheap, machine-readable capacity discovery separately from recursive scans;
- define and test a strict versioned NDJSON scan protocol with a bundled same-user, NUL-safe helper;
- render a truly polished Omarchy-native bar indicator and panel using current theme contracts;
- make scanning explicit, asynchronous, single-job, cancellable, and preserve the last completed result;
- build one canonical result/selection model for both ranked list and treemap;
- include literal first-use, scanning, ready, partial, cancelled, and failed states;
- keep QDirStat optional; if you reach M3, use an explicit visible terminal action with exactly `omarchy pkg aur add qdirstat`, never an install hook or hidden elevation;
- pass selected paths as structured arguments and never launch QDirStat as root;
- do not add delete or cleanup actions.

Create focused source tests and a product-owned Plugin Lab scenario under `tests/lab/`. Drive the rendered bar control with QMP pointer input and pair every meaningful action with a machine assertion. Prove source, installed, and loaded runtime identity. Test light and dark themes, long paths, permission failures, cancellation, reduced motion, and dependency states. Never install or activate the plugin on the daily host.

Iterate on the actual rendered result until it is visually excellent: calm hierarchy, balanced density, readable exact values, a useful—not decorative—treemap, first-class ranked list, excellent empty/error states, and no unreachable controls. Screenshots support visual review but do not replace state assertions.

Keep all documentation and public claims aligned with what the exact candidate proves. Run the smallest sufficient source and Plugin Lab gates, inspect the timestamped evidence and shell logs, and report:

- what is now implemented;
- exact validation/test commands;
- timestamped evidence directories and machine assertions;
- screenshots reviewed;
- remaining roadmap items and unverified boundaries.

Do not push, publish, tag, install packages on the host, or modify the daily Omarchy configuration.

---
