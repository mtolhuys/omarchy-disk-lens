#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root

if rg -n --ignore-case \
  '\b(annuleren|bestanden|bestand|beschikbaar|foutmelding|gebruikte|mappen|opnieuw|schijf|verwijderen|waarschuwing)\b' \
  "$project_root" \
  --glob '!tests/english.test.sh' \
  --glob '!.git/**'; then
  echo "tracked project text contains Dutch product copy" >&2
  exit 1
fi

printf 'ok - tracked product text is English\n'
