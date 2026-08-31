#!/bin/bash

# Optional-dependency acceptance for Omarchy Disk Lens. The AUR build, package
# installation, visible terminal, and QDirStat window exist only in the
# disposable Omarchy Plugin Lab guest.

omarchy_host_test() {
  local project_dir lab_root plugin_dir geometry icon_x icon_y widget_width widget_height
  local screen_width screen_height qdir_x qdir_y terminal_address terminal_pid terminal_sid
  local package_file qdir_version

  project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
  lab_root="${OMARCHY_PLUGIN_LAB_ROOT:?Set OMARCHY_PLUGIN_LAB_ROOT to the disposable Plugin Lab checkout}"
  # Expands only inside guest commands.
  # shellcheck disable=SC2016
  plugin_dir='${HOME}/.config/omarchy/plugins/io.github.mtolhuys.disk-lens'

  # shellcheck disable=SC1091
  source "$lab_root/host-tests/helpers/pointer.sh"

  log "Staging the exact Disk Lens candidate and QDirStat hand-off fixture"
  tar -C "$project_dir" --exclude .git --exclude test-results -cf - . | ssh_guest \
    "rm -rf /tmp/disk-lens-candidate && mkdir -p /tmp/disk-lens-candidate && tar -C /tmp/disk-lens-candidate -xf -"
  ssh_guest "git -C /tmp/disk-lens-candidate init -q && \
    git -C /tmp/disk-lens-candidate add . && \
    git -C /tmp/disk-lens-candidate -c user.name=DiskLensLab -c user.email=lab@invalid commit -qm candidate"
  ssh_session "rm -rf /tmp/disk-lens-qdir-fixture && \
    mkdir -p '/tmp/disk-lens-qdir-fixture/Archive' '/tmp/disk-lens-qdir-fixture/Projects' && \
    dd if=/dev/zero of='/tmp/disk-lens-qdir-fixture/Archive/media.bin' bs=1M count=6 status=none && \
    dd if=/dev/zero of='/tmp/disk-lens-qdir-fixture/Projects/source.bin' bs=1M count=2 status=none"

  ssh_session "cd /tmp/disk-lens-candidate && make update"
  wait_for_guest_state "QDirStat scenario loads the exact service and widget identity" 25 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e '.buildIdentity == \"disk-lens-service-v0300\" and .qdirStatAvailable == false' && \
     omarchy-shell disk-lens state | jq -e '.buildIdentity == \"disk-lens-widget-v0300\"'" || return 1

  geometry="$(ssh_session "omarchy-shell shell debugBarGeometry | jq -r \
    '.[] | select(.id == \"io.github.mtolhuys.disk-lens\" and .visible) | [.x,.y,.width,.height] | @tsv' | head -n1")"
  read -r icon_x icon_y widget_width widget_height <<<"$geometry"
  [[ -n $icon_x && $widget_width -ge 26 && $widget_height -ge 24 ]] || return 1
  icon_x=$((icon_x + widget_width / 2))
  icon_y=$((icon_y + widget_height / 2))
  read -r screen_width screen_height < <(ssh_session \
    "hyprctl -j monitors | jq -r 'map(select(.focused))[0] // .[0] | [.width,.height] | @tsv'")
  qdir_x=$((screen_width - 50))
  qdir_y=572

  qmp_pointer_tap "$screen_width" "$screen_height" "$icon_x" "$icon_y" left
  wait_for_guest_state "real bar pointer opens the missing-dependency state" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .qdirStatAvailable == false'" || return 1
  ssh_session "test \"\$(omarchy-shell disk-lens scan /tmp/disk-lens-qdir-fixture)\" = started"
  wait_for_guest_state "synthetic hand-off scope is rendered before installation" 20 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
      '.scanState == \"ready\" and .scope == \"/tmp/disk-lens-qdir-fixture\" and .entryCount == 2'" || return 1
  capture_console "success-disk-lens-qdir-01-missing"

  qmp_pointer_tap "$screen_width" "$screen_height" "$qdir_x" "$qdir_y" left
  wait_for_guest_state "public Install control opens the exact visible terminal command" 15 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.installLaunched == true and .qdirStatAvailable == false' && \
     pgrep -af '[o]marchy pkg aur add qdirstat' >/dev/null && \
     hyprctl -j clients | jq -e 'any(.[]; .class == \"org.omarchy.terminal\" and .title == \"Omarchy\")'" || {
    ssh_session "omarchy-shell disk-lens state; pgrep -af 'qdirstat|omarchy-pkg-aur-add|omarchy pkg aur add' || true; \
      hyprctl -j clients | jq '[.[] | {address,class,title,mapped}]'" || true
    return 1
  }
  capture_console "success-disk-lens-qdir-02-visible-install"

  terminal_address=$(ssh_session "hyprctl -j clients | jq -r \
    '[.[] | select(.class == \"org.omarchy.terminal\" and .title == \"Omarchy\")][0].address // empty'")
  [[ -n $terminal_address ]] || return 1
  terminal_pid=$(ssh_session "hyprctl -j clients | jq -r --arg address '$terminal_address' \
    '.[] | select(.address == \$address) | .pid'")
  [[ $terminal_pid =~ ^[0-9]+$ && $terminal_pid -gt 1 ]] || return 1
  terminal_sid=$(ssh_session "ps -o sid= -p '$terminal_pid' | tr -d ' '")
  [[ $terminal_sid =~ ^[0-9]+$ && $terminal_sid -gt 1 ]] || return 1

  # Closing a terminal while an AUR compiler owns its foreground process group
  # can leave that systemd scope alive. Terminate only the exact terminal
  # session created by the public action, then keep its build tree out of the
  # deterministic harness-owned installation below.
  ssh_session "pkill -TERM -s '$terminal_sid' || true"
  wait_for_guest_state "closing the visible terminal leaves Disk Lens explicitly uninstalled" 15 ssh_session \
    "! pgrep -af '[o]marchy pkg aur add qdirstat' >/dev/null && \
     ! pacman -Q qdirstat >/dev/null 2>&1 && \
     omarchy-shell disk-lens state | jq -e '.installLaunched == true and .qdirStatAvailable == false'" || return 1
  ssh_session "if [[ -d \"\$HOME/.cache/yay/qdirstat\" ]]; then \
    rm -rf /tmp/disk-lens-public-aur-attempt && \
    mv \"\$HOME/.cache/yay/qdirstat\" /tmp/disk-lens-public-aur-attempt; \
  fi"

  log "Installing the stable QDirStat AUR package inside the disposable guest"
  ssh_session "MAKEFLAGS=-j4 yay -S --noconfirm --needed qdirstat || \
    find \"\$HOME/.cache/yay/qdirstat\" -maxdepth 1 -name 'qdirstat-[0-9]*.pkg.tar.zst' -print -quit | grep -q ."
  package_file=$(ssh_session "find \"\$HOME/.cache/yay/qdirstat\" -maxdepth 1 \
    -name 'qdirstat-[0-9]*.pkg.tar.zst' -printf '%T@ %p\\n' | sort -nr | head -n1 | cut -d' ' -f2-")
  [[ -n $package_file ]] || return 1
  ssh_session "printf '%s\\n' omarchy | sudo -S pacman -U --noconfirm '$package_file'"
  qdir_version=$(ssh_session "pacman -Q qdirstat | awk '{print \$2}'")
  [[ -n $qdir_version ]] || return 1
  printf 'QDirStat guest package: %s\n' "$qdir_version"

  ssh_session "omarchy-shell disk-lens-service refreshQDirStat >/dev/null || true"
  wait_for_guest_state "Disk Lens re-detects the installed optional dependency" 15 ssh_session \
    "omarchy-shell disk-lens-service state | jq -e '.qdirStatChecked == true and .qdirStatAvailable == true'" || return 1

  if ! ssh_session "omarchy-shell disk-lens state | jq -e '.opened == true'" >/dev/null 2>&1; then
    qmp_pointer_tap "$screen_width" "$screen_height" "$icon_x" "$icon_y" left
  fi
  wait_for_guest_state "available-dependency panel is open after package hooks settle" 12 ssh_session \
    "omarchy-shell disk-lens state | jq -e '.opened == true and .qdirStatAvailable == true'" || return 1

  # The package transaction may reload the long-lived shell and therefore its
  # deliberately in-memory scan result. Re-select the synthetic scope through
  # the public scan contract before testing the hand-off.
  if ! ssh_session "omarchy-shell disk-lens state | jq -e \
      '.scope == \"/tmp/disk-lens-qdir-fixture\" and .scanState == \"ready\"'" >/dev/null 2>&1; then
    ssh_session "test \"\$(omarchy-shell disk-lens scan /tmp/disk-lens-qdir-fixture)\" = started"
  fi
  wait_for_guest_state "available QDirStat keeps the exact hand-off scope selectable" 20 ssh_session \
    "omarchy-shell disk-lens state | jq -e \
      '.opened == true and .qdirStatAvailable == true and \
       .scope == \"/tmp/disk-lens-qdir-fixture\" and .scanState == \"ready\"'" || return 1

  qdir_x=$((screen_width - 40))
  qdir_y=177
  qmp_pointer_tap "$screen_width" "$screen_height" "$qdir_x" "$qdir_y" left
  wait_for_guest_state "public Open control maps QDirStat on the selected scope as the desktop user" 30 ssh_session \
    "pgrep -u \"\$(id -u)\" -af '[q]dirstat /tmp/disk-lens-qdir-fixture' >/dev/null && \
     hyprctl -j clients | jq -e \
       'any(.[]; ((((.class // \"\") | ascii_downcase | contains(\"qdirstat\")) or ((.title // \"\") | contains(\"QDirStat\"))) and .mapped == true))'" || {
    ssh_session "pgrep -af qdirstat || true; hyprctl -j clients | jq '[.[] | {class,title,mapped}]'" || true
    return 1
  }
  capture_console "success-disk-lens-qdir-03-opened-scope"

  ssh_session "omarchy-plugin-remove io.github.mtolhuys.disk-lens --yes"
  wait_for_guest_state "plugin removal leaves QDirStat and the user fixture untouched" 20 ssh_session \
    "test ! -e \"$plugin_dir\" && test -f '/tmp/disk-lens-qdir-fixture/Archive/media.bin' && \
     pacman -Q qdirstat >/dev/null && pgrep -u \"\$(id -u)\" -x qdirstat >/dev/null && \
     ! omarchy-shell disk-lens state >/dev/null 2>&1 && ! omarchy-shell disk-lens-service state >/dev/null 2>&1" || return 1

  ssh_session "pkill -x qdirstat && test -z \"\$(hyprctl configerrors)\""
  printf 'ok - visible install, QDirStat %s detection, scoped launch, and ownership boundaries passed\n' "$qdir_version"
}
