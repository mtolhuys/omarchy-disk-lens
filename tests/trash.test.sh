#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root
readonly trash_helper="$project_root/scripts/disk-lens-trash"
readonly fake_bin="$project_root/tests/fixtures/trash-bin"

fixture=$(mktemp -d -t omarchy-disk-lens-trash-test.XXXXXX)
readonly fixture
trap 'rm -rf -- "$fixture"' EXIT

scope="$fixture/scope"
trash="$fixture/trash"
mkdir -p "$scope" "$trash" "$fixture/outside"

hostile_name=$'-cache\n$(touch disk-lens-must-not-run)'
hostile_path="$scope/$hostile_name"
mkdir -p -- "$hostile_path"
printf 'fixture' >"$hostile_path/data.bin"

PATH="$fake_bin:$PATH" DISK_LENS_TEST_TRASH="$trash" \
  "$trash_helper" --scope "$scope" --path "$hostile_path"
[[ ! -e $hostile_path ]]
[[ -f "$trash/$hostile_name/data.bin" ]]
[[ ! -e "$scope/disk-lens-must-not-run" ]]

outside="$fixture/outside/keep.bin"
printf 'keep' >"$outside"
if PATH="$fake_bin:$PATH" DISK_LENS_TEST_TRASH="$trash" \
    "$trash_helper" --scope "$scope" --path "$outside" >/dev/null 2>&1; then
  echo "trash helper accepted an item outside the scanned scope" >&2
  exit 1
fi
[[ -f $outside ]]

link_target="$fixture/outside/link-target.bin"
link_path="$scope/link.bin"
printf 'target' >"$link_target"
ln -s -- "$link_target" "$link_path"
PATH="$fake_bin:$PATH" DISK_LENS_TEST_TRASH="$trash" \
  "$trash_helper" --scope "$scope" --path "$link_path"
[[ ! -L $link_path ]]
[[ -f $link_target ]]
[[ -L $trash/link.bin ]]

if PATH="$fake_bin:$PATH" DISK_LENS_TEST_TRASH="$trash" \
    "$trash_helper" --scope "$scope" --path "$scope" >/dev/null 2>&1; then
  echo "trash helper accepted the scanned scope itself" >&2
  exit 1
fi
[[ -d $scope ]]

protected_home="$scope/home"
mkdir -p "$protected_home"
if HOME="$protected_home" PATH="$fake_bin:$PATH" DISK_LENS_TEST_TRASH="$trash" \
    "$trash_helper" --scope "$scope" --path "$protected_home" >/dev/null 2>&1; then
  echo "trash helper accepted the Home directory itself" >&2
  exit 1
fi
[[ -d $protected_home ]]

if "$trash_helper" --path "$scope" >/dev/null 2>&1; then
  echo "trash helper accepted an incomplete argument set" >&2
  exit 1
fi

printf 'ok - exact selected entries move through a guarded Trash boundary\n'
