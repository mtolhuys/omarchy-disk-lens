#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root
readonly folder_browser="$project_root/scripts/disk-lens-folders"
readonly slow_bin="$project_root/tests/fixtures/slow-bin"
fixture=$(mktemp -d -t disk-lens-folders-test.XXXXXX)

cleanup() {
  rm -rf -- "$fixture"
}
trap cleanup EXIT

mkdir -p "$fixture/Projects" "$fixture/.steam" "$fixture/folder with spaces" "$fixture/line"$'\n'"name"
printf file >"$fixture/not-a-folder"
invalid_name=$(printf 'invalid-\377')
mkdir "$fixture/$invalid_name"

output=$($folder_browser --path "$fixture")
printf '%s\n' "$output" | jq -e -s --arg path "$fixture" '
  .[0] == {protocol: 1, type: "folder-start", path: $path}
  and .[-1].type == "folder-complete"
  and .[-1].entries == 5
  and any(.[]; .type == "folder" and .name == ".steam" and .actionable == true)
  and any(.[]; .type == "folder" and .name == "line\nname" and .actionable == true)
  and all(.[]; .type != "folder" or .name != "not-a-folder")
' >/dev/null

printf '%s\n' "$output" | jq -e -s '
  any(.[]; .type == "folder" and .validUtf8 == false and .actionable == false)
' >/dev/null

if $folder_browser --path relative >/dev/null 2>&1; then
  echo "relative folder browser path was unexpectedly accepted" >&2
  exit 1
fi

cancel_output="$fixture/cancel.ndjson"
set +e
PATH="$slow_bin:$PATH" "$folder_browser" --path "$fixture" >"$cancel_output" &
browser_pid=$!
for _ in {1..50}; do
  pgrep -P "$browser_pid" -f "$slow_bin/find" >/dev/null && break
  sleep 0.02
done
kill -TERM "$browser_pid"
wait "$browser_pid"
cancel_status=$?
set -e
[[ $cancel_status -eq 130 ]]
sleep 0.05
if pgrep -P "$browser_pid" >/dev/null 2>&1; then
  echo "folder browser cancellation left a child process running" >&2
  exit 1
fi
jq -e -s 'length == 1 and .[0].type == "folder-start"' "$cancel_output" >/dev/null

printf 'ok - shallow folder browser handles hostile names and cancellation\n'
