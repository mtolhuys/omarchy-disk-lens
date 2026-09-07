#!/bin/bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly project_root
readonly open_helper="$project_root/scripts/disk-lens-open"
readonly fake_bin="$project_root/tests/fixtures/open-bin"

fixture=$(mktemp -d -t omarchy-disk-lens-open-test.XXXXXX)
readonly fixture
trap 'rm -rf -- "$fixture"' EXIT

log="$fixture/open.log"
scope="$fixture/scope"
mkdir -p "$scope"

# Real ELF binary copy (executable / pie).
cp -f -- /bin/true "$scope/tool.bin"
chmod +x -- "$scope/tool.bin"

printf 'hello\n' >"$scope/notes.txt"
printf 'PNG' >"$scope/photo.png"
printf '\0\1\2\3' >"$scope/blob.bin"
mkdir -p "$scope/folder"
ln -s -- "$scope/folder" "$scope/folder-link"
ln -s -- "$scope/tool.bin" "$scope/tool-link"

run_open() {
  local path=$1
  shift || true
  : >"$log"
  env -i \
    PATH="$fake_bin:/usr/bin:/bin" \
    HOME="$fixture/home" \
    DISK_LENS_TEST_OPEN_LOG="$log" \
    DISK_LENS_TEST_DIR_HANDLER="${DISK_LENS_TEST_DIR_HANDLER:-com.thisisgm.flea.desktop}" \
    DISK_LENS_TEST_MIME_BY_NAME="${DISK_LENS_TEST_MIME_BY_NAME:-}" \
    "$open_helper" -- "$path" "$@"
}

assert_log_contains() {
  local needle=$1
  if ! grep -F -- "$needle" "$log" >/dev/null; then
    echo "expected log to contain: $needle" >&2
    echo "--- log ---" >&2
    cat "$log" >&2 || true
    exit 1
  fi
}

assert_log_lacks() {
  local needle=$1
  if grep -F -- "$needle" "$log" >/dev/null; then
    echo "expected log NOT to contain: $needle" >&2
    echo "--- log ---" >&2
    cat "$log" >&2 || true
    exit 1
  fi
}

# Directories open via xdg-open (through uwsm-app).
run_open "$scope/folder"
assert_log_contains $'uwsm-app\txdg-open\t'"$scope/folder"
assert_log_contains $'xdg-open\t'"$scope/folder"
assert_log_lacks 'flea'

# Ordinary documents still use xdg-open on the file itself.
run_open "$scope/notes.txt"
assert_log_contains $'xdg-open\t'"$scope/notes.txt"
assert_log_lacks 'flea'
assert_log_lacks 'gdbus'

# Executables must NEVER be passed to xdg-open — reveal via flea --select.
run_open "$scope/tool.bin"
assert_log_contains $'flea\t--gui\t--select\t'"$scope/tool.bin"
assert_log_lacks $'xdg-open\t'"$scope/tool.bin"

# application/octet-stream also reveals.
run_open "$scope/blob.bin"
assert_log_contains $'flea\t--gui\t--select\t'"$scope/blob.bin"
assert_log_lacks $'xdg-open\t'"$scope/blob.bin"

# Symlink to executable: treated by MIME as executable → reveal the link path.
run_open "$scope/tool-link"
assert_log_contains $'flea\t--gui\t--select\t'"$scope/tool-link"
assert_log_lacks $'xdg-open\t'"$scope/tool-link"

# Without Flea as directory handler, fall back to FileManager1 ShowItems.
DISK_LENS_TEST_DIR_HANDLER='org.gnome.Nautilus.desktop' \
  run_open "$scope/tool.bin"
assert_log_contains 'org.freedesktop.FileManager1.ShowItems'
assert_log_lacks $'xdg-open\t'"$scope/tool.bin"
assert_log_lacks $'flea\t'

# Images remain normal xdg-open targets.
run_open "$scope/photo.png"
assert_log_contains $'xdg-open\t'"$scope/photo.png"

# Reject relative paths and incomplete argv.
if "$open_helper" -- relative/path >/dev/null 2>&1; then
  echo "open helper accepted a relative path" >&2
  exit 1
fi
if "$open_helper" "$scope/notes.txt" >/dev/null 2>&1; then
  echo "open helper accepted a path without --" >&2
  exit 1
fi

# Widget must route Open through the helper and debounce repeats.
rg -F 'Quickshell.execDetached([openHelperPath, "--", path])' \
  "$project_root/src/BarWidget.qml" >/dev/null
rg -F 'if (now - lastOpenAtMs < 500) return' \
  "$project_root/src/BarWidget.qml" >/dev/null
if rg -n 'uwsm-app", "--", "xdg-open"' "$project_root/src/BarWidget.qml"; then
  echo "widget still hands bare paths to xdg-open" >&2
  exit 1
fi

printf 'ok - open helper reveals binaries and debounces widget Open\n'
