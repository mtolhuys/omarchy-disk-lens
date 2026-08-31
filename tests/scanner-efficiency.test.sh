#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root
readonly scanner="$project_root/scripts/disk-lens-scan"
readonly counting_bin="$project_root/tests/fixtures/counting-bin"
fixture=$(mktemp -d -t disk-lens-efficiency-test.XXXXXX)
counter=$(mktemp -d -t disk-lens-process-counter.XXXXXX)

cleanup() {
  rm -rf -- "$fixture" "$counter"
}
trap cleanup EXIT

for index in {0001..1024}; do
  printf x >"$fixture/file-$index"
done

DISK_LENS_PROCESS_COUNTER="$counter" PATH="$counting_bin:$PATH" \
  "$scanner" --path "$fixture" >"$counter/result.ndjson"

jq -e -s '.[-1].type == "complete" and .[-1].entries == 1024' \
  "$counter/result.ndjson" >/dev/null

jq_calls=$(find "$counter" -mindepth 1 -maxdepth 1 -type d -name 'jq.*' | wc -l)
stat_calls=$(find "$counter" -mindepth 1 -maxdepth 1 -type d -name 'stat.*' | wc -l)
iconv_calls=$(find "$counter" -mindepth 1 -maxdepth 1 -type d -name 'iconv.*' | wc -l)
base64_calls=$(find "$counter" -mindepth 1 -maxdepth 1 -type d -name 'base64.*' | wc -l)

(( jq_calls <= 18 ))
(( stat_calls <= 16 ))
(( iconv_calls <= 2 ))
(( base64_calls == 0 ))

printf 'ok - 1,024 entries use bounded metadata and JSON batches\n'
