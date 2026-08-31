import QtQuick
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root

  moduleName: "io.github.mtolhuys.disk-lens"

  readonly property string buildIdentity: "disk-lens-widget-v0500"
  readonly property var diskService: bar && bar.shell
    ? bar.shell.serviceFor("io.github.mtolhuys.disk-lens") : null
  readonly property var capacity: diskService ? diskService.capacity : Model.parseCapacity("")
  readonly property bool capacityReady: capacity && capacity.available === true
  readonly property bool scanRunning: diskService
    && (diskService.scanState === "scanning" || diskService.scanState === "cancelling")
  readonly property string currentScope: diskService
    ? String(diskService.lastScanPath || diskService.scanPath || Quickshell.env("HOME"))
    : Quickshell.env("HOME")
  readonly property var visibleEntries: Model.filterEntries(
    diskService ? diskService.entries : [],
    {
      query: query,
      kind: kindFilter,
      includeHidden: includeHidden,
      minimumBytes: minimumBytes,
      maximumAgeSeconds: maximumAgeSeconds
    })
  readonly property double visibleBytes: Model.sumBytes(visibleEntries)
  readonly property var selectedEntry: entryForPath(selectedPath)
  readonly property var treemapRects: Model.treemap(
    visibleEntries,
    Math.max(1, treemapCanvas.width - Style.space(4)),
    Math.max(1, treemapCanvas.height - Style.space(4)),
    48)
  readonly property bool opened: popupOpen
  readonly property bool popoutSwitchClosing: false
  readonly property real openPanelIndicatorWidth: button.labelWidth
  readonly property string scopeDraftPath: Model.normalizeScopeInput(scopeDraft, Quickshell.env("HOME"))
  readonly property bool scopeDraftChanged: scopeDraftPath !== "" && scopeDraftPath !== currentScope
  readonly property string folderListerPath: diskService && diskService.sourceDir
    ? diskService.sourceDir + "/scripts/disk-lens-folders" : ""

  property bool popupOpen: false
  property bool includeHidden: true
  property string kindFilter: "all"
  property string query: ""
  property double minimumBytes: 0
  property double maximumAgeSeconds: 0
  property string viewMode: "treemap"
  property string selectedPath: ""
  property int agentLaunchCount: 0
  property string lastAgentPath: ""
  property string scopeDraft: Quickshell.env("HOME")
  property string scopeInputError: ""
  property var navigationHistory: []
  property bool folderPickerOpen: false
  property string folderPickerPath: Quickshell.env("HOME")
  property string folderPickerState: "idle"
  property var folderPickerEntries: []
  property string folderPickerError: ""
  property string folderPickerWarning: ""

  function entryForPath(path) {
    var value = String(path || "")
    var entries = diskService && Array.isArray(diskService.entries) ? diskService.entries : []
    for (var i = 0; i < entries.length; i++) {
      if (entries[i] && entries[i].path === value) return entries[i]
    }
    return null
  }

  function stateColor() {
    if (!capacityReady) return Color.muted
    if (capacity.percent >= 90) return Color.urgent
    if (capacity.percent >= 75) return Color.accent
    return Color.foreground
  }

  function pressureLabel() {
    if (!capacityReady) return "Capacity unavailable"
    if (capacity.percent >= 90) return "Critical pressure"
    if (capacity.percent >= 75) return "Storage pressure"
    return "Healthy capacity"
  }

  function capacityTooltip() {
    if (!capacityReady) return "Disk Lens — capacity unavailable"
    return "Disk Lens — " + capacity.percent + "% used on " + capacity.target
      + ", " + Model.formatBytes(capacity.avail) + " available"
  }

  function scanStateLabel() {
    if (!diskService) return "Service unavailable"
    if (diskService.scanState === "scanning") return "Scanning…"
    if (diskService.scanState === "cancelling") return "Cancelling…"
    if (diskService.scanState === "partial") return "Partial result"
    if (diskService.scanState === "ready") return "Scan complete"
    if (diskService.scanState === "cancelled") return "Scan cancelled"
    if (diskService.scanState === "failed") return "Scan failed"
    return "Ready to scan"
  }

  function scanFreshness() {
    if (!diskService || !diskService.scannedAt) return "NOT SCANNED"
    return Qt.formatDateTime(new Date(diskService.scannedAt), "MMM d · HH:mm").toUpperCase()
  }

  function open() {
    popupOpen = true
    if (diskService) diskService.refreshCapacity()
  }

  function close() { popupOpen = false }
  function closeForPopoutSwitch() { close() }
  function toggle() { popupOpen ? close() : open() }

  function requestScan(path) {
    if (!diskService) return false
    var target = Model.normalizeScopeInput(String(path || currentScope), Quickshell.env("HOME"))
    if (!target) return false
    selectedPath = ""
    scopeDraft = target
    scopeInputError = ""
    return diskService.startScan(target)
  }

  function pushHistory(path) {
    var value = String(path || "")
    if (!value) return
    var next = navigationHistory.slice()
    if (next.length === 0 || next[next.length - 1] !== value) next.push(value)
    while (next.length > 16) next.shift()
    navigationHistory = next
  }

  function navigateTo(path) {
    if (!diskService || scanRunning) return false
    var target = Model.normalizeScopeInput(path, Quickshell.env("HOME"))
    if (!target) {
      scopeInputError = "Enter an absolute folder path, or start with ~/."
      return false
    }
    if (target === currentScope && diskService.lastScanPath) {
      scopeDraft = target
      scopeInputError = ""
      return true
    }

    var previous = diskService.lastScanPath ? currentScope : ""
    if (previous && previous !== target) pushHistory(previous)
    selectedPath = ""
    scopeDraft = target
    scopeInputError = ""
    if (diskService.restoreCachedScan(target)) return true
    if (diskService.startScan(target)) return true

    if (previous && navigationHistory.length > 0) {
      var rollback = navigationHistory.slice()
      rollback.pop()
      navigationHistory = rollback
    }
    return false
  }

  function goBack() {
    if (!diskService || scanRunning || navigationHistory.length === 0) return false
    var next = navigationHistory.slice()
    var target = next.pop()
    navigationHistory = next
    selectedPath = ""
    scopeDraft = target
    scopeInputError = ""
    if (diskService.restoreCachedScan(target)) return true
    if (diskService.startScan(target)) return true
    next.push(target)
    navigationHistory = next
    return false
  }

  function submitScopeInput() {
    var target = Model.normalizeScopeInput(scopeDraft, Quickshell.env("HOME"))
    if (!target) {
      scopeInputError = "Enter an absolute folder path, or start with ~/."
      return false
    }
    scopeField.focus = false
    if (!diskService || !diskService.lastScanPath) return requestScan(target)
    if (target !== currentScope) return navigateTo(target)
    return requestScan(target)
  }

  function chooseFolder() {
    if (scanRunning || folderListProcess.running) return false
    folderPickerOpen = true
    return browseFolder(scopeDraftPath || currentScope)
  }

  function browseFolder(path) {
    if (!folderListerPath || folderListProcess.running) return false
    var target = Model.normalizeScopeInput(path, Quickshell.env("HOME"))
    if (!target) {
      folderPickerError = "Enter an absolute folder path, or start with ~/."
      return false
    }
    folderPickerPath = target
    folderPickerEntries = []
    folderPickerError = ""
    folderPickerWarning = ""
    folderPickerState = "loading"
    folderListProcess.command = [folderListerPath, "--path", target]
    folderListProcess.running = true
    return true
  }

  function closeFolderPicker() {
    if (folderListProcess.running) folderListProcess.running = false
    folderPickerOpen = false
    folderPickerState = "idle"
    folderPickerError = ""
  }

  function acceptFolderPicker() {
    if (folderPickerState !== "ready" && folderPickerState !== "partial") return false
    var target = folderPickerPath
    folderPickerOpen = false
    scopeDraft = target
    return navigateTo(target)
  }

  function scanOrCancel() {
    if (!diskService) return
    if (scanRunning) diskService.cancelScan()
    else if (scopeDraftChanged) navigateTo(scopeDraftPath)
    else requestScan(currentScope)
  }

  function drillInto(entry) {
    if (!entry || entry.kind !== "directory" || entry.actionable !== true || scanRunning) return
    navigateTo(entry.path)
  }

  function selectedActionPath() {
    return selectedEntry && selectedEntry.actionable === true
      ? selectedEntry.path : currentScope
  }

  function openInFileManager() {
    Quickshell.execDetached(["uwsm-app", "--", "xdg-open", selectedActionPath()])
  }

  function askOmarchyAboutSelected() {
    if (!selectedEntry || selectedEntry.actionable !== true || selectedEntry.kind !== "directory") return false

    var path = String(selectedEntry.path)
    var allocatedBytes = Number(selectedEntry.allocatedBytes || 0)
    var prompt = Model.buildAgentPrompt(path, allocatedBytes)

    Quickshell.execDetached(["omarchy", "agent", "prompt", prompt])
    agentLaunchCount += 1
    lastAgentPath = path
    close()
    return true
  }

  function cycleKindFilter() {
    kindFilter = kindFilter === "all" ? "directories"
      : (kindFilter === "directories" ? "files" : "all")
  }

  function kindFilterLabel() {
    return kindFilter === "directories" ? "Folders"
      : (kindFilter === "files" ? "Files" : "All types")
  }

  function minimumLabel() {
    if (minimumBytes >= 1073741824) return "≥ 1 GiB"
    if (minimumBytes >= 104857600) return "≥ 100 MiB"
    return "Any size"
  }

  function cycleMinimum() {
    minimumBytes = minimumBytes === 0 ? 104857600
      : (minimumBytes === 104857600 ? 1073741824 : 0)
  }

  function ageLabel() {
    if (maximumAgeSeconds === 604800) return "Last 7 days"
    if (maximumAgeSeconds === 2592000) return "Last 30 days"
    if (maximumAgeSeconds === 31536000) return "Last year"
    return "Any age"
  }

  function cycleAge() {
    maximumAgeSeconds = maximumAgeSeconds === 0 ? 604800
      : (maximumAgeSeconds === 604800 ? 2592000
      : (maximumAgeSeconds === 2592000 ? 31536000 : 0))
  }

  function clearFilters() {
    query = ""
    includeHidden = true
    kindFilter = "all"
    minimumBytes = 0
    maximumAgeSeconds = 0
  }

  function hasFilters() {
    return query !== "" || !includeHidden || kindFilter !== "all"
      || minimumBytes > 0 || maximumAgeSeconds > 0
  }

  function stateSnapshot() {
    return {
      buildIdentity: buildIdentity,
      opened: opened,
      capacityPercent: capacityReady ? capacity.percent : -1,
      pressure: pressureLabel(),
      scanState: diskService ? diskService.scanState : "unavailable",
      scope: currentScope,
      entryCount: diskService ? diskService.entries.length : 0,
      visibleCount: visibleEntries.length,
      selectedPath: selectedPath,
      viewMode: viewMode,
      query: query,
      includeHidden: includeHidden,
      kindFilter: kindFilter,
      agentLaunchCount: agentLaunchCount,
      lastAgentPath: lastAgentPath,
      scopeDraft: scopeDraft,
      scopeInputError: scopeInputError,
      historyDepth: navigationHistory.length,
      folderPickerOpen: folderPickerOpen,
      folderPickerPath: folderPickerPath,
      folderPickerState: folderPickerState,
      folderPickerCount: folderPickerEntries.length,
      scanActionCount: (scanButton.visible ? 1 : 0) + (firstUseSurface.visible ? 1 : 0),
      closeButtonWidth: closeButton.width,
      closeButtonHeight: closeButton.height,
      closeButtonFocused: closeButton.activeFocus,
      scanIndicatorRunning: scanRunning,
      activityIndicatorCount: scanRunning ? 1 : 0
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onVisibleEntriesChanged: {
    if (selectedPath && !entryForPath(selectedPath)) selectedPath = ""
  }

  onCurrentScopeChanged: {
    if (!scopeField.activeFocus) scopeDraft = currentScope
  }

  Process {
    id: folderListProcess
    command: []
    stdout: StdioCollector {
      id: folderListStdout
      waitForEnd: true
    }
    stderr: StdioCollector {
      id: folderListStderr
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (!root.folderPickerOpen) return
      var output = String(folderListStdout.text || "")
      if (exitCode !== 0 && !output) {
        root.folderPickerState = "failed"
        root.folderPickerError = String(folderListStderr.text || "Folder browsing failed").trim()
        return
      }
      var result = Model.parseFolderList(output)
      if (!result.ok) {
        root.folderPickerState = "failed"
        root.folderPickerError = result.error
        return
      }
      root.folderPickerPath = result.path
      root.folderPickerEntries = result.entries
      root.folderPickerWarning = result.warning
      root.folderPickerState = result.partial ? "partial" : "ready"
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    labelVisible: false
    hasVisualContent: true
    tooltipText: root.capacityTooltip()
    active: root.capacityReady && root.capacity.percent >= 90
    activeColor: root.stateColor()
    fixedWidth: root.barSize
    Accessible.name: root.capacityTooltip()
    Accessible.role: Accessible.Button

    onPressed: function(button) {
      if (button === Qt.MiddleButton && root.diskService) root.diskService.refreshCapacity()
      else root.toggle()
    }

    PieGauge {
      width: Math.min(parent.width, parent.height) * 0.48
      height: width
      anchors.centerIn: parent
      value: root.capacityReady ? root.capacity.percent : 0
      available: root.capacityReady
      fillColor: root.stateColor()
      trackColor: Util.alpha(button.foreground, 0.18)
      outlineColor: button.foreground
    }

    ActivityRing {
      width: Math.min(parent.width, parent.height) * 0.68
      height: width
      anchors.centerIn: parent
      running: root.scanRunning
      foreground: root.stateColor()
      track: Util.alpha(button.foreground, 0.12)
      strokeWidth: Math.max(1, width * 0.07)
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    focusTarget: root.folderPickerOpen ? folderPickerField
      : (searchField.enabled ? searchField : scopeField)
    contentWidth: popup.fittedContentWidth(Style.space(520))
    contentHeight: popup.fittedContentHeight(Math.min(panelColumn.implicitHeight, Style.space(640)))

    Flickable {
      id: panelScroll
      anchors.fill: parent
      contentWidth: width
      contentHeight: panelColumn.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      interactive: contentHeight > height
      QQC.ScrollBar.vertical: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

      Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        onActivated: root.folderPickerOpen ? root.closeFolderPicker() : root.close()
      }

      Column {
        id: panelColumn
        width: panelScroll.width
        spacing: Style.space(9)

        Row {
          width: parent.width
          spacing: Style.space(10)

          BorderSurface {
            width: Style.space(36)
            height: width
            color: Style.selectedFillFor(root.stateColor(), Color.accent)
            borderSpec: Border.controlSpec("normal", root.stateColor(), Color.accent)
            radius: Style.cornerRadius

            PieGauge {
              width: parent.width * 0.5
              height: width
              anchors.centerIn: parent
              value: root.capacityReady ? root.capacity.percent : 0
              available: root.capacityReady
              fillColor: root.stateColor()
              trackColor: Util.alpha(Color.popups.text, 0.14)
              outlineColor: root.stateColor()
            }

          }

          Column {
            width: parent.width - Style.space(36) - Style.space(10) - closeButton.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: "Disk Lens"
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              textFormat: Text.PlainText
            }

            Text {
              width: parent.width
              text: root.pressureLabel() + " · " + root.scanStateLabel()
              color: root.stateColor()
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              elide: Text.ElideRight
              textFormat: Text.PlainText
            }
          }

          Button {
            id: closeButton
            width: Style.space(32)
            height: width
            anchors.verticalCenter: parent.verticalCenter
            iconText: "×"
            iconSize: Style.font.body
            horizontalPadding: 0
            verticalPadding: 0
            tooltipText: "Close Disk Lens"
            focusable: true
            Accessible.name: "Close Disk Lens"
            Accessible.role: Accessible.Button
            onClicked: root.close()
          }
        }

        BorderSurface {
          width: parent.width
          implicitHeight: capacityColumn.implicitHeight + Style.space(18)
          color: Style.normalFillFor(Color.popups.text, Color.accent)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Column {
            id: capacityColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.space(9)
            spacing: Style.space(6)

            Row {
              width: parent.width

              Column {
                width: parent.width - capacityValue.width
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: root.capacityReady
                    ? Model.safeLabel(root.capacity.target) + "  ·  " + String(root.capacity.fstype).toUpperCase()
                    : "Home filesystem"
                  color: Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: true
                  elide: Text.ElideMiddle
                  textFormat: Text.PlainText
                }

                Text {
                  width: parent.width
                  text: root.capacityReady
                    ? Model.formatBytes(root.capacity.used) + " used  ·  " + Model.formatBytes(root.capacity.avail) + " free"
                    : (root.diskService ? root.diskService.capacityError : "Waiting for the Disk Lens service")
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                  textFormat: Text.PlainText
                }
              }

              Text {
                id: capacityValue
                text: root.capacityReady ? root.capacity.percent + "%" : "—"
                color: root.stateColor()
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
                textFormat: Text.PlainText
              }
            }

            Rectangle {
              width: parent.width
              height: Style.space(4)
              radius: height / 2
              color: Util.alpha(Color.popups.text, 0.1)

              Rectangle {
                width: root.capacityReady ? parent.width * root.capacity.percent / 100 : 0
                height: parent.height
                radius: height / 2
                color: root.stateColor()
              }
            }
          }
        }

        BorderSurface {
          visible: root.folderPickerOpen
          width: parent.width
          height: Style.space(300)
          color: Style.normalFillFor(Color.popups.text, Color.accent)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Column {
            anchors.fill: parent
            anchors.margins: Style.space(10)
            spacing: Style.space(8)

            Row {
              width: parent.width

              Column {
                width: parent.width - folderPickerCancel.width
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: "Choose a folder"
                  color: Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.subtitle
                  font.bold: true
                  textFormat: Text.PlainText
                }

                Text {
                  width: parent.width
                  text: "Browse without measuring disk usage, then open the selected scope."
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                  textFormat: Text.PlainText
                }
              }

              Button {
                id: folderPickerCancel
                text: "Cancel"
                focusable: true
                onClicked: root.closeFolderPicker()
              }
            }

            Row {
              width: parent.width
              spacing: Style.space(8)

              Button {
                iconText: "‹"
                tooltipText: "Browse parent folder"
                focusable: true
                enabled: !folderListProcess.running && root.folderPickerPath !== "/"
                opacity: enabled ? 1 : 0.35
                onClicked: root.browseFolder(Model.parentPath(root.folderPickerPath))
              }

              TextField {
                id: folderPickerField
                width: parent.width - parent.children[0].width - useFolderButton.width - Style.space(16)
                text: root.folderPickerPath
                selectByMouse: true
                enabled: !folderListProcess.running
                Accessible.name: "Folder browser path"
                onAccepted: root.browseFolder(text)

                TapHandler { onTapped: folderPickerField.forceActiveFocus() }
              }

              Button {
                id: useFolderButton
                text: "Use folder"
                iconText: "→"
                bordered: true
                selected: true
                focusable: true
                enabled: root.folderPickerState === "ready" || root.folderPickerState === "partial"
                opacity: enabled ? 1 : 0.35
                onClicked: root.acceptFolderPicker()
              }
            }

            Text {
              visible: root.folderPickerState === "loading" || root.folderPickerError !== "" || root.folderPickerWarning !== ""
              width: parent.width
              text: root.folderPickerState === "loading" ? "Opening folder…"
                : (root.folderPickerError || root.folderPickerWarning)
              color: root.folderPickerError ? Color.urgent : Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              elide: Text.ElideMiddle
              textFormat: Text.PlainText
            }

            Flickable {
              width: parent.width
              height: parent.height - y
              contentWidth: width
              contentHeight: folderPickerColumn.implicitHeight
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              interactive: contentHeight > height
              QQC.ScrollBar.vertical: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

              Column {
                id: folderPickerColumn
                width: parent.width
                spacing: Style.space(2)

                Repeater {
                  model: root.folderPickerEntries.slice(0, 80)

                  delegate: BorderSurface {
                    required property var modelData
                    width: folderPickerColumn.width
                    height: Style.space(32)
                    color: folderHover.hovered
                      ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"
                    borderSpec: Border.none()
                    radius: Style.cornerRadius

                    Row {
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      anchors.margins: Style.space(9)
                      spacing: Style.space(8)

                      Text {
                        text: "▸"
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        textFormat: Text.PlainText
                      }

                      Text {
                        width: parent.width - parent.children[0].width - Style.space(8)
                        text: Model.safeLabel(modelData.name)
                        color: Color.popups.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                        elide: Text.ElideMiddle
                        textFormat: Text.PlainText
                      }
                    }

                    HoverHandler { id: folderHover }
                    MouseArea {
                      anchors.fill: parent
                      enabled: modelData.actionable && !folderListProcess.running
                      cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                      onClicked: root.browseFolder(modelData.path)
                    }

                    Accessible.name: "Open folder " + Model.safeLabel(modelData.name)
                    Accessible.role: Accessible.ListItem
                  }
                }

                Text {
                  visible: root.folderPickerState !== "loading" && root.folderPickerEntries.length === 0
                  width: parent.width
                  text: root.folderPickerError ? "This folder could not be opened" : "No subfolders here"
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  horizontalAlignment: Text.AlignHCenter
                  textFormat: Text.PlainText
                }

                Text {
                  visible: root.folderPickerEntries.length > 80
                  width: parent.width
                  text: "Showing the first 80 folders"
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  horizontalAlignment: Text.AlignHCenter
                  textFormat: Text.PlainText
                }
              }
            }
          }
        }

        Column {
          visible: !root.folderPickerOpen
          width: parent.width
          spacing: Style.space(8)

          Row {
            width: parent.width
            spacing: Style.space(8)

            Button {
              id: parentButton
              iconText: "‹"
              tooltipText: "Go back without rescanning"
              focusable: true
              enabled: !root.scanRunning && root.navigationHistory.length > 0
              opacity: enabled ? 1 : 0.35
              onClicked: root.goBack()
            }

            TextField {
              id: scopeField
              width: parent.width - parentButton.width - folderPickerButton.width - Style.space(16)
                - (scanButton.visible ? scanButton.width + Style.space(8) : 0)
              height: scanButton.height
              text: root.scopeDraft
              placeholderText: "/home/you or ~/Projects"
              selectByMouse: true
              enabled: !root.scanRunning
              Accessible.name: "Folder path to inspect"
              onTextEdited: {
                root.scopeDraft = text
                root.scopeInputError = ""
              }
              onAccepted: root.submitScopeInput()

              TapHandler { onTapped: scopeField.forceActiveFocus() }
            }

            Button {
              id: folderPickerButton
              iconText: "…"
              tooltipText: "Choose a folder"
              focusable: true
              enabled: !root.scanRunning
              opacity: enabled ? 1 : 0.35
              Accessible.name: "Choose a folder"
              onClicked: root.chooseFolder()
            }

            Button {
              id: scanButton
              visible: root.scanRunning || (root.diskService && root.diskService.lastScanPath !== "")
              text: root.scanRunning
                ? (root.diskService && root.diskService.scanState === "cancelling" ? "Cancelling…" : "Cancel")
                : (root.scopeDraftChanged ? "Open" : "Refresh")
              iconText: root.scanRunning ? "■" : (root.scopeDraftChanged ? "→" : "↻")
              bordered: true
              focusable: true
              active: root.scanRunning
              onClicked: root.scanOrCancel()
            }

          }

          Text {
            visible: root.scopeInputError !== ""
            width: parent.width
            text: root.scopeInputError
            color: Color.urgent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }

          Row {
            width: parent.width
            spacing: Style.space(8)

            TextField {
              id: searchField
              width: parent.width - viewButton.width
                - (clearFilterButton.visible ? clearFilterButton.width + Style.space(8) : 0) - Style.space(8)
              placeholderText: "Filter this scan…"
              text: root.query
              enabled: root.diskService && root.diskService.entries.length > 0
              onTextChanged: if (root.query !== text) root.query = text
              Accessible.name: "Filter scanned entries"

              TapHandler {
                onTapped: searchField.forceActiveFocus()
              }
            }

            Button {
              id: viewButton
              text: root.viewMode === "treemap" ? "List" : "Map"
              iconText: root.viewMode === "treemap" ? "☷" : "▦"
              selected: true
              focusable: true
              tooltipText: root.viewMode === "treemap" ? "Show ranked list" : "Show treemap"
              onClicked: root.viewMode = root.viewMode === "treemap" ? "list" : "treemap"
            }

            Button {
              id: clearFilterButton
              iconText: "×"
              tooltipText: "Clear all filters"
              focusable: true
              visible: root.hasFilters()
              onClicked: root.clearFilters()
            }
          }

          Row {
            width: parent.width
            spacing: Style.space(6)

            Button {
              text: root.kindFilterLabel()
              selected: root.kindFilter !== "all"
              focusable: true
              onClicked: root.cycleKindFilter()
            }

            Button {
              text: root.includeHidden ? "Hidden shown" : "Hidden off"
              selected: !root.includeHidden
              focusable: true
              onClicked: root.includeHidden = !root.includeHidden
            }

            Button {
              text: root.minimumLabel()
              selected: root.minimumBytes > 0
              focusable: true
              onClicked: root.cycleMinimum()
            }

            Button {
              text: root.ageLabel()
              selected: root.maximumAgeSeconds > 0
              focusable: true
              onClicked: root.cycleAge()
            }
          }
        }

        BorderSurface {
          id: firstUseSurface
          visible: !root.folderPickerOpen && (!root.diskService || root.diskService.scanState === "idle")
          width: parent.width
          implicitHeight: firstUseColumn.implicitHeight + Style.space(34)
          color: Util.alpha(Color.accent, 0.08)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Column {
            id: firstUseColumn
            anchors.centerIn: parent
            width: parent.width - Style.space(40)
            spacing: Style.space(8)

            Text {
              width: parent.width
              text: "Find the heavy branch"
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              horizontalAlignment: Text.AlignHCenter
              textFormat: Text.PlainText
            }

            Text {
              width: parent.width
              text: "Type a folder path or choose one, then follow its largest branch. Disk Lens scans only when you ask."
              color: Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              wrapMode: Text.WordWrap
              horizontalAlignment: Text.AlignHCenter
              textFormat: Text.PlainText
            }

            Button {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.scopeDraftPath === Quickshell.env("HOME") ? "Scan Home" : "Scan folder"
              iconText: "↻"
              bordered: true
              focusable: true
              onClicked: root.submitScopeInput()
            }
          }
        }

        BorderSurface {
          visible: !root.folderPickerOpen && root.diskService && root.scanRunning
          width: parent.width
          implicitHeight: scanProgressRow.implicitHeight + Style.space(24)
          color: Util.alpha(Color.accent, 0.08)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Column {
            id: scanProgressRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.space(12)
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: root.diskService && root.diskService.scanState === "cancelling"
                ? "Stopping the scan safely…" : "Measuring allocated space…"
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              textFormat: Text.PlainText
            }

            Text {
              width: parent.width
              text: "The last complete result stays intact until this scan finishes."
              color: Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
              textFormat: Text.PlainText
            }
          }
        }

        BorderSurface {
          visible: !root.folderPickerOpen && root.diskService && root.diskService.scanState === "failed"
          width: parent.width
          implicitHeight: scanErrorColumn.implicitHeight + Style.space(24)
          color: Util.alpha(Color.urgent, 0.09)
          borderSpec: Border.controlSpec("normal", Color.urgent, Color.urgent)
          radius: Style.cornerRadius

          Column {
            id: scanErrorColumn
            anchors.fill: parent
            anchors.margins: Style.space(12)
            spacing: Style.space(4)

            Text {
              width: parent.width
              text: "Scan failed"
              color: Color.urgent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              textFormat: Text.PlainText
            }

            Text {
              width: parent.width
              text: root.diskService ? root.diskService.scanError : "Disk Lens service is unavailable"
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
              textFormat: Text.PlainText
            }
          }
        }

        BorderSurface {
          visible: !root.folderPickerOpen && root.diskService && root.diskService.scanState === "cancelled"
          width: parent.width
          implicitHeight: cancelledRow.implicitHeight + Style.space(24)
          color: Util.alpha(Color.accent, 0.08)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Row {
            id: cancelledRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.space(12)
            spacing: Style.space(10)

            Text {
              text: "■"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.icon
              textFormat: Text.PlainText
            }

            Column {
              width: parent.width - parent.children[0].width - Style.space(10)
              spacing: Style.space(2)

              Text {
                width: parent.width
                text: "Scan cancelled"
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                textFormat: Text.PlainText
              }

              Text {
                width: parent.width
                text: root.diskService && root.diskService.entries.length > 0
                  ? "The last complete result is still shown. Refresh whenever you are ready."
                  : "Nothing was replaced. Start a new scan whenever you are ready."
                color: Color.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
              }
            }
          }
        }

        BorderSurface {
          visible: !root.folderPickerOpen && root.diskService && root.diskService.scanState === "partial"
          width: parent.width
          implicitHeight: partialRow.implicitHeight + Style.space(16)
          color: Util.alpha(Color.accent, 0.08)
          borderSpec: Border.controlSpec("normal", Color.accent, Color.accent)
          radius: Style.cornerRadius

          Row {
            id: partialRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.space(8)
            spacing: Style.space(9)

            Text {
              text: "Partial scan · " + (root.diskService ? root.diskService.warnings.length : 0)
                + ((root.diskService && root.diskService.warnings.length === 1) ? " warning" : " warnings")
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              textFormat: Text.PlainText
            }

            Text {
              width: parent.width - parent.children[0].width - Style.space(9)
              text: root.diskService && root.diskService.warnings.length > 0
                ? String(root.diskService.warnings[0])
                : "Some paths could not be measured; the available results remain useful."
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              elide: Text.ElideMiddle
              textFormat: Text.PlainText
            }
          }
        }

        BorderSurface {
          visible: !root.folderPickerOpen && root.diskService
            && (root.diskService.scanState === "ready" || root.diskService.scanState === "partial")
            && root.diskService.entries.length === 0
          width: parent.width
          implicitHeight: emptyColumn.implicitHeight + Style.space(34)
          color: Style.normalFillFor(Color.popups.text, Color.accent)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Column {
            id: emptyColumn
            anchors.centerIn: parent
            width: parent.width - Style.space(40)
            spacing: Style.space(5)

            Text {
              width: parent.width
              text: "Nothing is taking space here"
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.subtitle
              font.bold: true
              horizontalAlignment: Text.AlignHCenter
              textFormat: Text.PlainText
            }

            Text {
              width: parent.width
              text: "This scope has no immediate entries to show. Try its parent directory."
              color: Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
              horizontalAlignment: Text.AlignHCenter
              textFormat: Text.PlainText
            }
          }
        }

        Column {
          visible: !root.folderPickerOpen && root.diskService && root.diskService.entries.length > 0
          width: parent.width
          spacing: Style.space(8)

          Row {
            width: parent.width

            Column {
              width: parent.width - resultSummary.width
              spacing: Style.space(2)

              Text {
                width: parent.width
                text: root.diskService && root.diskService.partial
                  ? "Largest entries · partial scan" : "Largest entries"
                color: root.diskService && root.diskService.partial ? Color.accent : Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.subtitle
                font.bold: true
                textFormat: Text.PlainText
              }

              Text {
                width: parent.width
                text: root.scanFreshness() + "  ·  " + root.visibleEntries.length + " OF " + root.diskService.entries.length + " SHOWN"
                color: Color.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 0.7
                textFormat: Text.PlainText
              }
            }

            Text {
              id: resultSummary
              text: Model.formatBytes(root.visibleBytes)
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              textFormat: Text.PlainText
            }
          }

          BorderSurface {
            id: treemapFrame
            visible: root.viewMode === "treemap"
            width: parent.width
            height: Style.space(215)
            color: Util.alpha(Color.popups.text, 0.035)
            borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
            radius: Style.cornerRadius
            clip: true

            Item {
              id: treemapCanvas
              anchors.fill: parent
              anchors.margins: Style.space(2)

              Repeater {
                model: root.treemapRects

                delegate: Rectangle {
                  required property var modelData
                  required property int index

                  x: modelData.x
                  y: modelData.y
                  width: Math.max(0, modelData.width - Style.space(2))
                  height: Math.max(0, modelData.height - Style.space(2))
                  radius: Math.min(Style.cornerRadius, Style.space(5))
                  color: {
                    var palette = [Color.accent, Color.foreground, Color.muted, Color.urgent]
                    var base = palette[index % palette.length]
                    var alpha = index === 0 ? 0.42 : Math.max(0.13, 0.32 - index * 0.006)
                    return Util.alpha(base, alpha)
                  }
                  border.width: root.selectedPath === modelData.path ? Math.max(1, Style.space(2)) : 0
                  border.color: Color.accent

                  Column {
                    anchors.fill: parent
                    anchors.margins: Style.space(8)
                    visible: parent.width >= Style.space(72) && parent.height >= Style.space(42)
                    spacing: Style.space(2)

                    Text {
                      width: parent.width
                      text: Model.safeLabel(modelData.entry.name)
                      color: Color.popups.text
                      font.family: Style.font.family
                      font.pixelSize: parent.parent.width > Style.space(150) ? Style.font.body : Style.font.caption
                      font.bold: index < 3
                      elide: Text.ElideRight
                      textFormat: Text.PlainText
                    }

                    Text {
                      width: parent.width
                      text: Model.formatBytes(modelData.entry.allocatedBytes)
                      color: Color.popups.text
                      opacity: 0.72
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      elide: Text.ElideRight
                      textFormat: Text.PlainText
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedPath = modelData.path
                    onDoubleClicked: root.drillInto(modelData.entry)
                  }

                  Accessible.name: Model.safeLabel(modelData.entry.name) + ", " + Model.formatBytes(modelData.entry.allocatedBytes)
                  Accessible.role: Accessible.ListItem
                }
              }

              Text {
                anchors.centerIn: parent
                visible: root.visibleEntries.length === 0
                text: "No entries match these filters"
                color: Color.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                textFormat: Text.PlainText
              }
            }
          }

          Column {
            visible: root.viewMode === "list"
            width: parent.width
            spacing: Style.space(3)

            Repeater {
              model: root.visibleEntries.slice(0, 80)

              delegate: BorderSurface {
                required property var modelData
                required property int index
                width: parent.width
                height: Style.space(36)
                color: root.selectedPath === modelData.path
                  ? Style.selectedFillFor(Color.popups.text, Color.accent)
                  : (rowHover.hovered ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent")
                borderSpec: root.selectedPath === modelData.path
                  ? Border.controlSpec("focus", Color.popups.text, Color.accent)
                  : Border.none()
                radius: Style.cornerRadius

                Rectangle {
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: Style.space(8)
                  width: Math.max(Style.space(3), (parent.width - Style.space(16))
                    * modelData.allocatedBytes / Math.max(1, root.visibleEntries[0].allocatedBytes))
                  height: parent.height - Style.space(10)
                  radius: Style.cornerRadius
                  color: Util.alpha(index === 0 ? Color.accent : Color.foreground, index === 0 ? 0.15 : 0.06)
                }

                Row {
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.margins: Style.space(10)
                  spacing: Style.space(10)

                  Text {
                    width: Style.space(18)
                    text: modelData.kind === "directory" ? "▸" : "·"
                    color: modelData.kind === "directory" ? Color.accent : Color.muted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    textFormat: Text.PlainText
                  }

                  Text {
                    width: parent.width - parent.children[0].width - rowBytes.width - Style.space(20)
                    text: Model.safeLabel(modelData.name)
                    color: Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    font.bold: index < 3
                    elide: Text.ElideMiddle
                    textFormat: Text.PlainText
                  }

                  Text {
                    id: rowBytes
                    text: Model.formatBytes(modelData.allocatedBytes)
                    color: Color.popups.text
                    opacity: 0.74
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    textFormat: Text.PlainText
                  }
                }

                HoverHandler { id: rowHover }
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.selectedPath = modelData.path
                  onDoubleClicked: root.drillInto(modelData)
                }

                Accessible.name: Model.safeLabel(modelData.name) + ", " + Model.formatBytes(modelData.allocatedBytes)
                Accessible.role: Accessible.ListItem
              }
            }

            Text {
              visible: root.visibleEntries.length > 80
              width: parent.width
              text: "Showing the largest 80 entries · refine the filters to narrow the list"
              color: Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              horizontalAlignment: Text.AlignHCenter
              textFormat: Text.PlainText
            }

            Text {
              visible: root.visibleEntries.length === 0
              width: parent.width
              text: "No entries match these filters"
              color: Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              horizontalAlignment: Text.AlignHCenter
              textFormat: Text.PlainText
            }
          }
        }

        BorderSurface {
          visible: !root.folderPickerOpen && root.selectedEntry !== null
          width: parent.width
          implicitHeight: inspectorColumn.implicitHeight + Style.space(18)
          color: Style.selectedFillFor(Color.popups.text, Color.accent)
          borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
          radius: Style.cornerRadius

          Column {
            id: inspectorColumn
            anchors.fill: parent
            anchors.margins: Style.space(9)
            spacing: Style.space(6)

            Row {
              width: parent.width

              Column {
                width: parent.width - inspectorBytes.width
                spacing: Style.space(2)

                Text {
                  width: parent.width
                  text: root.selectedEntry ? Model.safeLabel(root.selectedEntry.name) : ""
                  color: Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: true
                  elide: Text.ElideMiddle
                  textFormat: Text.PlainText
                }

                Text {
                  width: parent.width
                  text: root.selectedEntry
                    ? String(root.selectedEntry.kind).toUpperCase() + "  ·  "
                      + (root.selectedEntry.mtime > 0
                        ? Qt.formatDateTime(new Date(root.selectedEntry.mtime * 1000), "MMM d, yyyy")
                        : "DATE UNKNOWN")
                    : ""
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  textFormat: Text.PlainText
                }
              }

              Text {
                id: inspectorBytes
                text: root.selectedEntry ? Model.formatBytes(root.selectedEntry.allocatedBytes) : ""
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.subtitle
                font.bold: true
                textFormat: Text.PlainText
              }
            }

            Row {
              width: parent.width
              spacing: Style.space(6)

              Button {
                visible: root.selectedEntry && root.selectedEntry.kind === "directory" && root.selectedEntry.actionable
                text: "Drill in"
                iconText: "→"
                bordered: true
                focusable: true
                onClicked: root.drillInto(root.selectedEntry)
              }

              Button {
                text: "Open"
                iconText: "↗"
                focusable: true
                enabled: root.selectedEntry && root.selectedEntry.actionable
                opacity: enabled ? 1 : 0.35
                onClicked: root.openInFileManager()
              }

              Button {
                visible: root.selectedEntry && root.selectedEntry.kind === "directory" && root.selectedEntry.actionable
                text: "Ask Omarchy"
                iconText: "✦"
                bordered: true
                selected: true
                focusable: true
                tooltipText: "Ask your default Omarchy agent to inspect this folder read-only"
                Accessible.name: "Ask Omarchy about the selected folder"
                onClicked: root.askOmarchyAboutSelected()
              }

            }
          }
        }
      }
    }
  }

  IpcHandler {
    target: "disk-lens"

    function state(): string { return JSON.stringify(root.stateSnapshot()) }
    function open(): string { root.open(); return "opened" }
    function close(): string { root.close(); return "closed" }
    function toggle(): string { root.toggle(); return root.opened ? "opened" : "closed" }
    function scan(path: string): string { return root.requestScan(path) ? "started" : "rejected" }
    function navigate(path: string): string { return root.navigateTo(path) ? "opened" : "rejected" }
    function back(): string { return root.goBack() ? "opened" : "unavailable" }
    function cancel(): string { return root.diskService && root.diskService.cancelScan() ? "cancelling" : "idle" }
    function setFilter(query: string): string { root.query = query; return String(root.visibleEntries.length) }
    function setView(mode: string): string {
      root.viewMode = mode === "list" ? "list" : "treemap"
      return root.viewMode
    }
    function select(path: string): string {
      root.selectedPath = root.entryForPath(path) ? path : ""
      return root.selectedPath ? "selected" : "unknown"
    }
  }
}
