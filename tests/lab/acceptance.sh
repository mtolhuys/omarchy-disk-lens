#!/bin/bash

# Focused real-session acceptance for Omarchy Disk Lens. All plugin activation,
# fixtures, pointer input, and lifecycle mutations stay inside the disposable
# Omarchy Plugin Lab guest.

omarchy_host_test() {
  local project_dir lab_root plugin_dir geometry icon_x icon_y widget_width widget_height
  local screen_width screen_height scan_total runtime_before runtime_after
  local scan_button_x scan_button_y view_button_x search_x filter_y clear_x agent_x agent_y
  local agent_pid agent_sid scanned_before long_scope
  project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
  lab_root="${OMARCHY_PLUGIN_LAB_ROOT:?Set OMARCHY_PLUGIN_LAB_ROOT to the disposable Plugin Lab checkout}"
  plugin_dir='${HOME}/.config/omarchy/plugins/io.github.mtolhuys.disk-lens'

  source "$lab_root/host-tests/helpers/pointer.sh"

  log "Staging the exact Disk Lens candidate and synthetic fixture"
  tar -C "$project_dir" --exclude .git --exclude test-results -cf - . | ssh_guest \
    "rm -rf /tmp/disk-lens-candidate && mkdir -p /tmp/disk-lens-candidate && tar -C /tmp/disk-lens-candidate -xf -"
  ssh_guest "git -C /tmp/disk-lens-candidate init -q && \
    git -C /tmp/disk-lens-candidate add . && \
    git -C /tmp/disk-lens-candidate -c user.name=DiskLensLab -c user.email=lab@invalid commit -qm candidate"
  ssh_session "rm -rf /tmp/disk-lens-fixture && \
    mkdir -p '/tmp/disk-lens-fixture/Archive' '/tmp/disk-lens-fixture/Projects' '/tmp/disk-lens-fixture/.cache' && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/Archive/video.bin' bs=1M count=12 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/Projects/source.bin' bs=1M count=5 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/.cache/data.bin' bs=1M count=2 status=none && \
    printf notes >'/tmp/disk-lens-fixture/read me.txt'"
  long_scope='/tmp/disk-lens-long-scope/clients/acme-space-research/production-archives/2026-08-30'
  ssh_session "rm -rf /tmp/disk-lens-permission /tmp/disk-lens-empty /tmp/disk-lens-long-scope && \
    mkdir -p '/tmp/disk-lens-permission/readable' '/tmp/disk-lens-permission/restricted' \
      '/tmp/disk-lens-empty' '$long_scope' && \
    dd if=/dev/zero of='/tmp/disk-lens-permission/readable/visible.bin' bs=1M count=1 status=none && \
    printf private >'/tmp/disk-lens-permission/restricted/secret.bin' && \
    chmod 000 '/tmp/disk-lens-permission/restricted' && \
    dd if=/dev/zero of='$long_scope/long-path.bin' bs=1M count=1 status=none"

  log "Staging a checkout left behind by an interrupted add"
  ssh_session "mkdir -p \"\$HOME/.config/omarchy/plugins\" && \
    rm -rf '$plugin_dir' && git clone -q /tmp/disk-lens-candidate '$plugin_dir'"

  ssh_session "cd /tmp/disk-lens-candidate && make update"

  wait_for_guest_state "service and widget load with matching candidate identity" 25 ssh_session \
    "omarchy-plugin-list --json | jq -e 'any(.[]; .id == \"io.github.mtolhuys.disk-lens\" and .enabled == true)' && \
     omarchy-shell disk-lens-service state | jq -e '.buildIdentity == \"disk-lens-service-v0200\" and (.capacityState == \"ready\" or .capacityState == \"loading\")' && \
     omarchy-shell disk-lens state | jq -e '.buildIdentity == \"disk-lens-widget-v0200\" and .opened == false'" || {
    ssh_session "omarchy-shell shell listPlugins; journalctl --user --since '-3 minutes' --no-pager | tail -n 220" || true
    return 1
  }

  runtime_before=$(ssh_session "find \"\$XDG_RUNTIME_DIR/omarchy/plugin-runtime\" -path '*/src/BarWidget.qml' -print -quit")
  [[ -n $runtime_before ]] || return 1
  ssh_session "test -z \"\$(find \"\$XDG_RUNTIME_DIR/omarchy/plugin-runtime\" -name .git -print -quit)\""

  geometry="$(ssh_session "omarchy-shell shell debugBarGeometry | jq -r \
    '.[] | select(.id == \"io.github.mtolhuys.disk-lens\" and .visible) | [.x,.y,.width,.height] | @tsv' | head -n1")"
  read -r icon_x icon_y widget_width widget_height <<<"$geometry"
  [[ -n $icon_x && $widget_width -ge 26 && $widget_height -ge 24 ]] || return 1
  icon_x=$((icon_x + widget_width / 2))
  icon_y=$((icon_y + widget_height / 2))
  read -r screen_width screen_height < <(ssh_session \
    "hyprctl -j monitors | jq -r 'map(select(.focused))[0] // .[0] | [.width,.height] | @tsv'")
  scan_button_x=$((screen_width - 67))
  scan_button_y=177
  view_button_x=$((screen_width - 55))
  search_x=$((screen_width - 360))
  filter_y=218
  clear_x=$((screen_width - 36))
  agent_x=$((screen_width - 265))
  agent_y=612

  qmp_pointer_tap "$screen_width" "$screen_height" "$icon_x" "$icon_y" left
  wait_for_guest_state "real bar pointer opens the first-use panel" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .scanState == \"idle\" and .capacityPercent >= 0'" || return 1
  capture_console "success-disk-lens-01-first-use"

  ssh_session "test \"\$(omarchy-shell disk-lens scan /tmp/disk-lens-fixture)\" = started"
  wait_for_guest_state "synthetic scan publishes exact completed data" 25 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e \
      '.scanState == \"ready\" and .lastScanPath == \"/tmp/disk-lens-fixture\" and .entryCount == 4 and .totalBytes > 19000000' && \
     omarchy-shell disk-lens state | jq -e '.entryCount == 4 and .visibleCount == 3 and .viewMode == \"treemap\"'" || {
    ssh_session "omarchy-shell disk-lens-service state; journalctl --user --since '-2 minutes' --no-pager | tail -n 160" || true
    return 1
  }
  scan_total=$(ssh_session "omarchy-shell disk-lens-service state | jq -r .totalBytes")
  [[ $scan_total -gt 19000000 ]] || return 1

  scanned_before=$(ssh_session "omarchy-shell disk-lens-service state | jq -r .scannedAt")
  qmp_pointer_tap "$screen_width" "$screen_height" "$scan_button_x" "$scan_button_y" left
  wait_for_guest_state "rendered Refresh control starts and completes a newer scan" 15 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e \
      '.scanState == \"ready\" and .lastScanPath == \"/tmp/disk-lens-fixture\" and .scannedAt > $scanned_before'" || return 1
  capture_console "success-disk-lens-02-treemap"

  qmp_pointer_tap "$screen_width" "$screen_height" $((screen_width - 400)) 400 left
  wait_for_guest_state "treemap pointer selection reaches the canonical model" 10 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.selectedPath == \"/tmp/disk-lens-fixture/Archive\"'" || return 1

  log "Proving the selected-folder hand-off through Omarchy's maintained agent prompt"
  ssh_session "mkdir -p \"\$HOME/.config/omarchy/defaults\" && \
    codex_path=\$(command -v codex) && test -n \"\$codex_path\" && rm -f \"\$codex_path\" && \
    printf '%s' 'IyEvYmluL2Jhc2gKcHJpbnRmICclc1xuJyAiJEAiID4gL3RtcC9kaXNrLWxlbnMtYWdlbnQtYXJndgpzbGVlcCAzMAo=' \
      | base64 -d >\"\$codex_path\" && \
    chmod 755 \"\$codex_path\" && printf 'codex\n' >\"\$HOME/.config/omarchy/defaults/agent\" && \
    rm -f /tmp/disk-lens-agent-argv"
  qmp_pointer_tap "$screen_width" "$screen_height" "$agent_x" "$agent_y" left
  wait_for_guest_state "public Ask Omarchy action launches the default agent with a constrained selected-folder prompt" 20 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
       '.opened == false and .agentLaunchCount == 1 and .lastAgentPath == \"/tmp/disk-lens-fixture/Archive\"' && \
     grep -F 'Path: /tmp/disk-lens-fixture/Archive' /tmp/disk-lens-agent-argv >/dev/null && \
     grep -F 'Begin with read-only inspection.' /tmp/disk-lens-agent-argv >/dev/null && \
     grep -F 'Ask for explicit confirmation' /tmp/disk-lens-agent-argv >/dev/null && \
     hyprctl -j clients | jq -e 'any(.[]; .class == \"org.omarchy.agent\" and .mapped == true)'" || {
    ssh_session "omarchy-shell disk-lens state; test -f /tmp/disk-lens-agent-argv && sed -n '1,80p' /tmp/disk-lens-agent-argv; \
      hyprctl -j clients | jq '[.[] | {class,title,mapped}]'; journalctl --user --since '-2 minutes' --no-pager | tail -n 160" || true
    return 1
  }
  capture_console "success-disk-lens-03-agent-handoff"
  agent_pid=$(ssh_session "hyprctl -j clients | jq -r \
    '[.[] | select(.class == \"org.omarchy.agent\" and .mapped == true)][0].pid // empty'")
  [[ $agent_pid =~ ^[0-9]+$ && $agent_pid -gt 1 ]] || return 1
  agent_sid=$(ssh_session "ps -o sid= -p '$agent_pid' | tr -d ' '")
  [[ $agent_sid =~ ^[0-9]+$ && $agent_sid -gt 1 ]] || return 1
  ssh_session "pkill -TERM -s '$agent_sid' || true"
  wait_for_guest_state "agent hand-off terminal closes without changing the selected fixture" 15 ssh_session \
    "test -f '/tmp/disk-lens-fixture/Archive/video.bin' && \
     ! hyprctl -j clients | jq -e 'any(.[]; .class == \"org.omarchy.agent\" and .mapped == true)'" || return 1

  qmp_pointer_tap "$screen_width" "$screen_height" "$icon_x" "$icon_y" left
  wait_for_guest_state "compact panel reopens with the selected directory intact" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .selectedPath == \"/tmp/disk-lens-fixture/Archive\"'" || return 1

  qmp_pointer_tap "$screen_width" "$screen_height" "$view_button_x" "$filter_y" left
  qmp_pointer_tap "$screen_width" "$screen_height" "$search_x" "$filter_y" left
  type_text "Archive"
  wait_for_guest_state "rendered view and search controls drive one filtered list model" 10 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.query == \"Archive\" and .visibleCount == 1 and .viewMode == \"list\"'" || return 1
  capture_console "success-disk-lens-04-filtered-list"

  qmp_pointer_tap "$screen_width" "$screen_height" "$clear_x" "$filter_y" left
  wait_for_guest_state "rendered clear control restores the complete result" 10 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.query == \"\" and .visibleCount == 3'" || return 1

  log "Reviewing the same loaded candidate against a maintained light theme"
  ssh_session "omarchy-theme-set 'Catppuccin Latte'"
  wait_for_guest_state "light theme applies without losing plugin state" 20 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .entryCount == 4' && \
     test -z \"\$(hyprctl configerrors)\"" || return 1
  capture_console "success-disk-lens-05-light-theme"
  ssh_session "omarchy-theme-set 'Tokyo Night'"
  wait_for_guest_state "dark theme reapplies without losing plugin state" 20 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .entryCount == 4'" || return 1

  log "Exercising cancellation with compositor motion disabled"
  ssh_session "hyprctl keyword animations:enabled false >/dev/null"
  ssh_session "test \"\$(omarchy-shell disk-lens-service scan /)\" = started"
  qmp_pointer_tap "$screen_width" "$screen_height" "$scan_button_x" "$scan_button_y" left
  wait_for_guest_state "rendered Cancel control preserves the last completed result" 12 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e \
      '.scanState == \"cancelled\" and .lastScanPath == \"/tmp/disk-lens-fixture\" and .entryCount == 4' && \
     ! pgrep -f '[d]isk-lens-scan' >/dev/null" || return 1
  capture_console "success-disk-lens-06-cancelled"
  ssh_session "hyprctl keyword animations:enabled true >/dev/null"

  ssh_session "test \"\$(omarchy-shell disk-lens scan /tmp/disk-lens-permission)\" = started"
  wait_for_guest_state "permission failure produces an explicit usable partial result" 20 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e \
      '.scanState == \"partial\" and .partial == true and .warningCount > 0 and .entryCount > 0'" || return 1
  capture_console "success-disk-lens-07-partial"
  ssh_session "chmod 700 '/tmp/disk-lens-permission/restricted'"

  ssh_session "test \"\$(omarchy-shell disk-lens scan '$long_scope')\" = started"
  wait_for_guest_state "long scopes remain exact in state and bounded in the rendered control" 15 ssh_session \
    "omarchy-shell disk-lens state | jq -e --arg scope '$long_scope' \
      '.scanState == \"ready\" and .scope == \$scope and .entryCount == 1'" || return 1
  capture_console "success-disk-lens-08-long-scope"

  ssh_session "test \"\$(omarchy-shell disk-lens scan /tmp/disk-lens-empty)\" = started"
  wait_for_guest_state "empty scope has a distinct complete state" 15 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
      '.scanState == \"ready\" and .scope == \"/tmp/disk-lens-empty\" and .entryCount == 0'" || return 1
  capture_console "success-disk-lens-09-empty"

  wait_for_guest_state "missing QDirStat remains an explicit optional state" 10 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e '.qdirStatChecked == true and .qdirStatAvailable == false'" || return 1

  log "Applying a same-path runtime edit through the public update flow"
  ssh_guest "sed -i 's/disk-lens-service-v0200/disk-lens-service-v0200-labupdate/' \
      /home/omarchy/.cache/omarchy-disk-lens/development-source/src/Service.qml && \
    sed -i 's/disk-lens-widget-v0200/disk-lens-widget-v0200-labupdate/' \
      /home/omarchy/.cache/omarchy-disk-lens/development-source/src/BarWidget.qml && \
    git -C /home/omarchy/.cache/omarchy-disk-lens/development-source add src/Service.qml src/BarWidget.qml && \
    git -C /home/omarchy/.cache/omarchy-disk-lens/development-source \
      -c user.name=DiskLensLab -c user.email=lab@invalid commit -qm runtime-update"
  ssh_session "omarchy-plugin-update io.github.mtolhuys.disk-lens --yes"
  wait_for_guest_state "same-path update replaces service and widget runtime identities" 30 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e '.buildIdentity == \"disk-lens-service-v0200-labupdate\"' && \
     omarchy-shell disk-lens state | jq -e '.buildIdentity == \"disk-lens-widget-v0200-labupdate\"'" || {
    ssh_session "omarchy-shell disk-lens-service state; omarchy-shell disk-lens state; journalctl --user --since '-3 minutes' --no-pager | tail -n 220" || true
    return 1
  }
  runtime_after=$(ssh_session "find \"\$XDG_RUNTIME_DIR/omarchy/plugin-runtime\" -path '*/src/BarWidget.qml' -print -quit")
  [[ -n $runtime_after && $runtime_after != "$runtime_before" ]] || return 1

  ssh_session "omarchy-plugin-disable io.github.mtolhuys.disk-lens"
  wait_for_guest_state "disable unloads both runtime entry points" 20 ssh_session \
    "omarchy-plugin-list --json | jq -e 'any(.[]; .id == \"io.github.mtolhuys.disk-lens\" and .enabled == false)' && \
     ! omarchy-shell disk-lens-service state >/dev/null 2>&1 && ! omarchy-shell disk-lens state >/dev/null 2>&1" || return 1

  ssh_session "omarchy-plugin-enable io.github.mtolhuys.disk-lens"
  wait_for_guest_state "re-enable restores one service and one widget" 25 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e '.buildIdentity == \"disk-lens-service-v0200-labupdate\"' && \
     omarchy-shell disk-lens state | jq -e '.buildIdentity == \"disk-lens-widget-v0200-labupdate\"'" || return 1

  ssh_session "omarchy-plugin-remove io.github.mtolhuys.disk-lens --yes"
  wait_for_guest_state "remove unloads Disk Lens without touching user data or QDirStat" 25 ssh_session \
    "test ! -e \"$plugin_dir\" && test -f '/tmp/disk-lens-fixture/Archive/video.bin' && \
     omarchy-plugin-list --json | jq -e 'all(.[]; .id != \"io.github.mtolhuys.disk-lens\")' && \
     ! pgrep -f '[d]isk-lens-scan' >/dev/null" || return 1

  ssh_session "test -z \"\$(hyprctl configerrors)\" && \
    ! journalctl --user --since '-8 minutes' --no-pager | grep -E \
      'Disk Lens.*(failed to load|Error)|io.github.mtolhuys.disk-lens.*(failed|Error)'"
  capture_console "success-disk-lens-10-removed"

  printf 'ok - Disk Lens pointer, compact UI, agent prompt, themes, scan states, filters, runtime update, lifecycle, and cleanup passed\n'
}
