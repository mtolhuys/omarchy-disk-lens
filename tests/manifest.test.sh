#!/bin/bash

set -euo pipefail

readonly project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly manifest="$project_root/manifest.json"

jq -e '
  .schemaVersion == 1
  and .id == "io.github.mtolhuys.disk-lens"
  and (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
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

if find "$project_root" -path "$project_root/.git" -prune -o -type l -print -quit | grep -q .; then
  echo "plugin tree contains a symbolic link" >&2
  exit 1
fi

if rg -n '(^|[^A-Za-z])(sudo|pkexec|eval)([^A-Za-z]|$)|bash[[:space:]]+-c.*selected' \
    "$project_root/src" "$project_root/scripts"; then
  echo "forbidden runtime primitive found" >&2
  exit 1
fi

rg -F 'omarchy plugin add "$snapshot_dir" --yes' "$project_root/bin/dev-install" >/dev/null
rg -F 'wait_for_plugin_state known' "$project_root/bin/dev-install" >/dev/null
rg -F 'omarchy plugin enable "$plugin_id"' "$project_root/bin/dev-install" >/dev/null
if rg -F 'omarchy plugin add "$snapshot_dir" --enable' "$project_root/bin/dev-install" >/dev/null; then
  echo "development installer races add and enable in one command" >&2
  exit 1
fi

printf 'ok - manifest, entry points, tree shape, and forbidden primitives\n'
