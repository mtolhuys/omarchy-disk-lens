#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root
readonly scanner="$project_root/scripts/disk-lens-scan"
readonly slow_bin="$project_root/tests/fixtures/slow-bin"
fixture=$(mktemp -d -t disk-lens-scan-test.XXXXXX)

cleanup() {
  chmod -R u+rwx "$fixture" 2>/dev/null || true
  rm -rf -- "$fixture"
}
trap cleanup EXIT

mkdir -p "$fixture/large folder" "$fixture/.hidden"
dd if=/dev/zero of="$fixture/large folder/payload.bin" bs=4096 count=8 status=none
dd if=/dev/zero of="$fixture/.hidden/cache.bin" bs=4096 count=2 status=none
printf 'small' >"$fixture/-leading-dash"
printf 'tab' >"$fixture/tab"$'\t'"name"
printf 'line' >"$fixture/line"$'\n'"name"
invalid_name=$(printf 'invalid-\377')
printf 'invalid' >"$fixture/$invalid_name"

output=$($scanner --path "$fixture")
printf '%s\n' "$output" | jq -e -s '
  length >= 8
  and all(.[]; .protocol == 1)
  and .[0].type == "start"
  and .[-1].type == "complete"
  and .[-1].path == $path
  and .[-1].entries >= 6
  and .[-1].totalBytes > 0
' --arg path "$fixture" >/dev/null

printf '%s\n' "$output" | jq -e -s --arg path "$fixture/large folder" \
  'any(.[]; .type == "entry" and .path == $path and .kind == "directory" and .allocatedBytes > 0)' >/dev/null

printf '%s\n' "$output" | jq -e -s --arg path "$fixture/line"$'\n'"name" \
  'any(.[]; .type == "entry" and .path == $path and .actionable == true)' >/dev/null

invalid_b64=$(printf '%s' "$fixture/$invalid_name" | base64 -w0)
printf '%s\n' "$output" | jq -e -s --arg pathB64 "$invalid_b64" \
  'any(.[]; .type == "entry" and .pathB64 == $pathB64 and .validUtf8 == false and .actionable == false)' >/dev/null

mkdir -p "$fixture/permission-fixture/restricted"
printf 'private' >"$fixture/permission-fixture/restricted/payload"
chmod 000 "$fixture/permission-fixture/restricted"
partial_output=$($scanner --path "$fixture/permission-fixture")
printf '%s\n' "$partial_output" | jq -e -s '
  any(.[]; .type == "warning" and (.message | contains("Permission denied")))
  and .[-1].type == "complete"
  and .[-1].partial == true
  and .[-1].warnings > 0
' >/dev/null
chmod 700 "$fixture/permission-fixture/restricted"

cancel_output="$fixture/cancel.ndjson"
set +e
PATH="$slow_bin:$PATH" "$scanner" --path "$fixture" >"$cancel_output" &
scanner_pid=$!
for _ in {1..50}; do
  pgrep -P "$scanner_pid" -f "$slow_bin/du" >/dev/null && break
  sleep 0.02
done
kill -TERM "$scanner_pid"
wait "$scanner_pid"
cancel_status=$?
set -e
[[ $cancel_status -eq 130 ]]
sleep 0.05
if pgrep -P "$scanner_pid" >/dev/null 2>&1; then
  echo "scanner cancellation left a child process running" >&2
  exit 1
fi
jq -e -s 'length == 1 and .[0].type == "start"' "$cancel_output" >/dev/null

if $scanner --path relative >/dev/null 2>&1; then
  echo "relative scan path was unexpectedly accepted" >&2
  exit 1
fi

if $scanner --unknown "$fixture" >/dev/null 2>&1; then
  echo "unknown scanner arguments were unexpectedly accepted" >&2
  exit 1
fi

printf 'ok - NUL-safe scan protocol, hostile paths, partial traversal, and cancellation\n'
