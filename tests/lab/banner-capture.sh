#!/bin/bash

# README / marketplace banner capture for Omarchy Disk Lens.
# Runs only in the disposable Omarchy Plugin Lab guest — never on the daily host.
# Captures the quiet premium scan beam, selection detail actions, Keys sheet,
# and list view from the CURRENT working-tree candidate (0.6.12+).

park_pointer_outside_panel() {
  local response
  response=$(qmp '"input-send-event", "arguments": {"events": [
    {"type":"abs","data":{"axis":"x","value":0}},
    {"type":"abs","data":{"axis":"y","value":32767}}
  ]}')
  if grep -q '"error"' <<<"$response"; then
    printf 'QMP pointer parking failed: %s\n' "$response" >&2
    return 1
  fi
  sleep 0.4
}

omarchy_host_test() {
  local project_dir lab_root plugin_dir geometry icon_x icon_y widget_width widget_height
  local screen_width screen_height start_epoch
  local scan_button_x scan_button_y scope_field_x folder_picker_x
  local keys_x keys_y view_button_x filter_y
  project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
  lab_root="${OMARCHY_PLUGIN_LAB_ROOT:-}"
  if [[ -z $lab_root ]]; then
    for candidate in \
      "${LAB_ROOT:-}" \
      "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../omarchy/plugin-lab" 2>/dev/null && pwd)" \
      ""; do
      [[ -n $candidate && -f $candidate/host-tests/helpers/pointer.sh ]] || continue
      lab_root=$candidate
      break
    done
  fi
  [[ -n $lab_root && -f $lab_root/host-tests/helpers/pointer.sh ]] || {
    printf 'Set OMARCHY_PLUGIN_LAB_ROOT to the Plugin Lab checkout before running banner-capture\n' >&2
    return 1
  }
  # shellcheck disable=SC1091
  source "$lab_root/host-tests/helpers/pointer.sh"
  # Expands only inside guest commands.
  # shellcheck disable=SC2016
  plugin_dir='${HOME}/.config/omarchy/plugins/io.github.mtolhuys.disk-lens'
  start_epoch="$(date +%s)"

  log "Staging Disk Lens candidate for banner capture"
  tar -C "$project_dir" --exclude .git --exclude test-results --exclude .preview -cf - . | ssh_guest \
    "rm -rf /tmp/disk-lens-candidate && mkdir -p /tmp/disk-lens-candidate && tar -C /tmp/disk-lens-candidate -xf -"
  ssh_guest "git -C /tmp/disk-lens-candidate init -q && \
    git -C /tmp/disk-lens-candidate add . && \
    git -C /tmp/disk-lens-candidate -c user.name=DiskLensLab -c user.email=lab@invalid commit -qm candidate"

  log "Building a richer synthetic fixture (no personal paths)"
  ssh_session "rm -rf /tmp/disk-lens-fixture && \
    mkdir -p \
      '/tmp/disk-lens-fixture/Archive' \
      '/tmp/disk-lens-fixture/Projects' \
      '/tmp/disk-lens-fixture/Media' \
      '/tmp/disk-lens-fixture/Downloads' \
      '/tmp/disk-lens-fixture/.cache' \
      '/tmp/disk-lens-fixture/.local/share' && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/Archive/video.bin' bs=1M count=14 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/Projects/source.bin' bs=1M count=8 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/Media/photos.bin' bs=1M count=6 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/Downloads/package.bin' bs=1M count=4 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/.cache/data.bin' bs=1M count=3 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-fixture/.local/share/state.bin' bs=1M count=2 status=none && \
    printf 'notes for the lab fixture\n' >'/tmp/disk-lens-fixture/readme.txt'"

  ssh_session "mkdir -p \"\$HOME/.config/omarchy/plugins\" && \
    rm -rf \"$plugin_dir\" && git clone -q /tmp/disk-lens-candidate \"$plugin_dir\""
  ssh_session "cd /tmp/disk-lens-candidate && make update"

  wait_for_guest_state "Disk Lens 0.6.12 is installed and loaded" 25 ssh_session \
    "omarchy-plugin-list --json | jq -e 'any(.[]; .id == \"io.github.mtolhuys.disk-lens\" and .enabled == true)' && \
     jq -e '.version == \"0.6.12\"' \"$plugin_dir/manifest.json\" && \
     omarchy-shell disk-lens-service state | jq -e \
       '.buildIdentity == \"disk-lens-service-v0612\" and (.capacityState == \"ready\" or .capacityState == \"loading\")' && \
     omarchy-shell disk-lens state | jq -e '.buildIdentity == \"disk-lens-widget-v0612\" and .opened == false'" || {
    ssh_session "omarchy-shell shell listPlugins || true; \
      jq . \"$plugin_dir/manifest.json\" || true; \
      omarchy-shell disk-lens-service state || true; \
      omarchy-shell disk-lens state || true; \
      journalctl --user --since '-3 minutes' --no-pager \
        | grep -Ei 'quickshell|qml|disk-lens|segmentation|fatal|core dumped' | tail -n 240" || true
    return 1
  }

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
  scope_field_x=$((screen_width - 290))
  folder_picker_x=$((screen_width - 36))
  # Keys · ? sits in the panel header actions; List/Map toggle shares the filter row.
  view_button_x=$((screen_width - 55))
  filter_y=218
  printf '%s\n' "{\"viewport\":[${screen_width},${screen_height}],\"version\":\"0.6.12\",\"theme\":\"tokyo-night\"}" \
    >"$RUN_DIR/disk-lens-banner-geometry.json"

  qmp_pointer_tap "$screen_width" "$screen_height" "$icon_x" "$icon_y" left
  wait_for_guest_state "bar pointer opens Disk Lens panel" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
      '.opened == true and .scanState == \"idle\" and .includeHidden == true'" || return 1

  # --- Active scan with quiet premium beam over live results ---
  qmp_pointer_tap "$screen_width" "$screen_height" "$scope_field_x" "$scan_button_y" left
  press ctrl-a
  type_text "/tmp/disk-lens-fixture"
  press ret
  wait_for_guest_state "synthetic fixture scan completes" 25 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e \
      '.scanState == \"ready\" and .lastScanPath == \"/tmp/disk-lens-fixture\" and .entryCount >= 6 and .totalBytes > 35000000' && \
     omarchy-shell disk-lens state | jq -e \
      '.entryCount >= 6 and .visibleCount >= 6 and .viewMode == \"treemap\"'" || {
    ssh_session "omarchy-shell disk-lens-service state; omarchy-shell disk-lens state; \
      journalctl --user --since '-2 minutes' --no-pager | tail -n 160" || true
    return 1
  }

  # Start a slow refresh so the motion-relative beam is visible over the treemap.
  ssh_session "test \"\$(omarchy-shell disk-lens-service scan /usr)\" = started"
  wait_for_guest_state "slow refresh exposes the scan beam" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
      '.opened == true and .scanState == \"scanning\" and .scanIndicatorRunning == true and .activityIndicatorCount == 2'" || return 1
  # Mid-sweep (~1.4s into a 2.8s half-cycle) so the quiet beam sits in-pane.
  sleep 1.4
  park_pointer_outside_panel || return 1
  capture_console "success-disk-lens-banner-01-scanning-beam"
  # /usr may finish before Cancel; stop whatever is running, then restore the fixture.
  ssh_session "omarchy-shell disk-lens-service cancel >/dev/null || true"
  wait_for_guest_state "refresh is no longer running" 20 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e '.scanState != \"scanning\"' && \
     ! pgrep -f '[d]isk-lens-scan' >/dev/null" || return 1

  ssh_session "test \"\$(omarchy-shell disk-lens scan /tmp/disk-lens-fixture)\" = started"
  wait_for_guest_state "fixture returns to a ready treemap" 25 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e \
      '.scanState == \"ready\" and .lastScanPath == \"/tmp/disk-lens-fixture\" and .entryCount >= 6' && \
     omarchy-shell disk-lens state | jq -e '.viewMode == \"treemap\" and .opened == true'" || return 1

  # --- Treemap + selection detail strip (Open · o / Ask Omarchy · a / Trash · x) ---
  qmp_pointer_tap "$screen_width" "$screen_height" $((screen_width - 400)) 400 left
  wait_for_guest_state "treemap selection reaches Archive" 10 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
      '.selectedPath == \"/tmp/disk-lens-fixture/Archive\" and .openButtonCenterX > 0 and .askButtonCenterX > 0'" || {
    qmp_pointer_tap "$screen_width" "$screen_height" "$view_button_x" "$filter_y" left
    wait_for_guest_state "list view for selection fallback" 8 ssh_session \
      "omarchy-shell disk-lens state | jq -e '.viewMode == \"list\"'" || return 1
    press down
    press down
    wait_for_guest_state "list selection is a directory" 8 ssh_session \
      "omarchy-shell disk-lens state | jq -e '.selectedPath != \"\" and .askButtonCenterX > 0'" || return 1
    qmp_pointer_tap "$screen_width" "$screen_height" "$view_button_x" "$filter_y" left
    wait_for_guest_state "back to treemap after list select" 8 ssh_session \
      "omarchy-shell disk-lens state | jq -e '.viewMode == \"treemap\"'" || return 1
  }
  sleep 0.5
  park_pointer_outside_panel || return 1
  capture_console "success-disk-lens-banner-02-treemap-selection"

  # --- Keys sheet ---
  # QMP shift-slash does not reliably populate Qt event.text ("?"), so click Keys · ?.
  read -r keys_x keys_y < <(ssh_session "omarchy-shell disk-lens state | jq -r '[.keysButtonCenterX,.keysButtonCenterY] | @tsv'")
  [[ $keys_x -gt 0 && $keys_y -gt 0 ]] || return 1
  qmp_pointer_tap "$screen_width" "$screen_height" "$keys_x" "$keys_y" left
  wait_for_guest_state "Keys sheet opens" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .keysHelpOpen == true'" || return 1
  sleep 0.45
  park_pointer_outside_panel || return 1
  capture_console "success-disk-lens-banner-03-keys-sheet"
  press esc
  wait_for_guest_state "Keys sheet closes" 8 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .keysHelpOpen == false'" || return 1

  # --- Ranked list with the same selection footer ---
  qmp_pointer_tap "$screen_width" "$screen_height" "$view_button_x" "$filter_y" left
  wait_for_guest_state "list view is active" 10 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.viewMode == \"list\" and .visibleCount >= 6'" || return 1
  ssh_session "omarchy-shell disk-lens state | jq -e '.selectedPath != \"\" and .askButtonCenterX > 0'" || {
    press down
    wait_for_guest_state "list row selected" 8 ssh_session \
      "omarchy-shell disk-lens state | jq -e '.selectedPath != \"\"'" || return 1
  }
  sleep 0.45
  park_pointer_outside_panel || return 1
  capture_console "success-disk-lens-banner-04-list-selection"

  ssh_session "omarchy-plugin-remove io.github.mtolhuys.disk-lens --yes" >/dev/null || true
  wait_for_guest_state "banner candidate removes cleanly" 20 ssh_session \
    "test ! -e \"$plugin_dir\" && \
     omarchy-plugin-list --json | jq -e 'all(.[]; .id != \"io.github.mtolhuys.disk-lens\")'" || true

  ssh_session "journalctl --user --since '@$start_epoch' --no-pager" \
    >"$RUN_DIR/disk-lens-banner-journal.log" || true

  printf 'ok - Disk Lens banner frames captured (beam, treemap selection, Keys, list)\n'
}
