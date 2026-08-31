#!/bin/bash

# Public clean-clone acceptance for the marketplace installation instructions.
# Every plugin, shell, and configuration mutation stays in the disposable guest.

omarchy_host_test() {
  local project_dir expected_commit plugin_id plugin_dir repository_url
  project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
  expected_commit=$(git -C "$project_dir" rev-parse HEAD)
  plugin_id="io.github.mtolhuys.disk-lens"
  plugin_dir="\$HOME/.config/omarchy/plugins/$plugin_id"
  repository_url="https://github.com/mtolhuys/omarchy-disk-lens.git"

  log "Installing the exact public Disk Lens repository and enabling it"
  ssh_session "if omarchy-plugin-list --json | jq -e --arg id '$plugin_id' 'any(.[]; .id == \$id)' >/dev/null; then \
      omarchy plugin remove '$plugin_id' --yes; \
    fi; \
    omarchy plugin add '$repository_url' --enable --yes"

  wait_for_guest_state "public clean clone is installed, enabled, and loaded at the expected commit" 30 ssh_session \
    "test -d \"$plugin_dir/.git\" && \
     test \"\$(git -C \"$plugin_dir\" remote get-url origin)\" = '$repository_url' && \
     test \"\$(git -C \"$plugin_dir\" rev-parse HEAD)\" = '$expected_commit' && \
     omarchy-plugin-list --json | jq -e --arg id '$plugin_id' \
       'any(.[]; .id == \$id and .enabled == true)' && \
     omarchy-shell disk-lens-service state | jq -e '.buildIdentity == \"disk-lens-service-v0400\"' && \
     omarchy-shell disk-lens state | jq -e '.buildIdentity == \"disk-lens-widget-v0400\"'" || {
    ssh_session "omarchy-plugin-list --json; omarchy-shell shell listPlugins; \
      journalctl --user --since '-3 minutes' --no-pager | tail -n 220" || true
    return 1
  }
  capture_console "success-disk-lens-public-install"

  ssh_session "omarchy plugin remove '$plugin_id' --yes"
  wait_for_guest_state "public removal unloads both entry points and removes the checkout" 25 ssh_session \
    "test ! -e \"$plugin_dir\" && \
     omarchy-plugin-list --json | jq -e --arg id '$plugin_id' 'all(.[]; .id != \$id)' && \
     ! omarchy-shell disk-lens-service state >/dev/null 2>&1 && \
     ! omarchy-shell disk-lens state >/dev/null 2>&1" || return 1

  ssh_session "test -z \"\$(hyprctl configerrors)\" && \
    ! journalctl --user --since '-5 minutes' --no-pager | grep -E \
      'Disk Lens.*(failed to load|Error)|io.github.mtolhuys.disk-lens.*(failed|Error)'"
  capture_console "success-disk-lens-public-remove"

  printf 'ok - public GitHub clone, enable, loaded identities, removal, and cleanup passed\n'
}
