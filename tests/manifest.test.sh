#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root
readonly manifest="$project_root/manifest.json"

jq -e '
  .schemaVersion == 1
  and .id == "io.github.mtolhuys.disk-lens"
  and .version == "0.5.0"
  and (.kinds | sort == ["bar-widget", "service"])
  and .entryPoints.service == "src/Service.qml"
  and .entryPoints.barWidget == "src/BarWidget.qml"
  and .barWidget.allowMultiple == false
  and .barWidget.defaultSection == "right"
' "$manifest" >/dev/null

while IFS= read -r entry_point; do
  [[ $entry_point != /* ]]
  [[ $entry_point != *..* ]]
  [[ -f $project_root/$entry_point ]]
done < <(jq -r '.entryPoints[]' "$manifest")

rg -F 'disk-lens-service-v0500' "$project_root/src/Service.qml" >/dev/null
rg -F 'disk-lens-widget-v0500' "$project_root/src/BarWidget.qml" >/dev/null
[[ -x $project_root/scripts/disk-lens-trash ]]

if find "$project_root" -path "$project_root/.git" -prune -o -type l -print -quit | grep -q .; then
  echo "plugin tree contains a symbolic link" >&2
  exit 1
fi

if rg -n '(^|[^A-Za-z])(sudo|pkexec|eval)([^A-Za-z]|$)|bash[[:space:]]+-c.*selected' \
    "$project_root/src" "$project_root/scripts"; then
  echo "forbidden runtime primitive found" >&2
  exit 1
fi

if rg -n 'omarchy pkg aur add|omarchy-launch-floating-terminal-with-presentation' \
    "$project_root/src" "$project_root/scripts"; then
  echo "runtime must not install or launch optional desktop analyzers" >&2
  exit 1
fi

rg -F 'var prompt = Model.buildAgentPrompt(path, allocatedBytes)' \
  "$project_root/src/BarWidget.qml" >/dev/null
if rg -F '"Path: " + path' "$project_root/src/BarWidget.qml" >/dev/null; then
  echo "selected path bypasses the bounded agent prompt adapter" >&2
  exit 1
fi

rg -F 'trashProcess.command = [trashHelperPath, "--scope", trashTargetScope, "--path", trashTargetPath]' \
  "$project_root/src/Service.qml" >/dev/null
rg -F 'gio trash -- "$target_path"' "$project_root/scripts/disk-lens-trash" >/dev/null
rg -F 'selectedIndex: 0' "$project_root/src/BarWidget.qml" >/dev/null
if rg -n '(^|[^A-Za-z])(rm|unlink)[[:space:]].*target_path' \
    "$project_root/src" "$project_root/scripts/disk-lens-trash"; then
  echo "selected items must move through the desktop Trash boundary" >&2
  exit 1
fi

rg -F 'omarchy plugin add "$snapshot_dir" --yes' "$project_root/bin/dev-sync" >/dev/null
rg -F 'wait_for_plugin_state known' "$project_root/bin/dev-sync" >/dev/null
rg -F 'omarchy plugin enable "$plugin_id"' "$project_root/bin/dev-sync" >/dev/null
if rg -F 'omarchy plugin add "$snapshot_dir" --enable' "$project_root/bin/dev-sync" >/dev/null; then
  echo "development installer races add and enable in one command" >&2
  exit 1
fi

printf 'ok - manifest, entry points, tree shape, and forbidden primitives\n'
