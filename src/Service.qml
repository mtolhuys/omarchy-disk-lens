import QtQuick
import Quickshell
import Quickshell.Io
import "Model.js" as Model

Item {
  id: root

  property var shell: null
  property var manifest: null
  property var pluginRegistry: null
  property var barWidgetRegistry: null
  property string omarchyPath: ""

  readonly property string buildIdentity: "disk-lens-service-v0700"
  readonly property string homePath: Quickshell.env("HOME")
  // Newer Omarchy hosts strip __sourceDir from third-party manifests, so fall
  // back to the plugin root resolved relative to this file.
  readonly property string sourceDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir)
    : decodeURIComponent(String(Qt.resolvedUrl("..")).replace(/^file:\/\//, "").replace(/\/$/, ""))
  readonly property string scannerPath: sourceDir ? sourceDir + "/scripts/disk-lens-scan" : ""
  readonly property string trashHelperPath: sourceDir ? sourceDir + "/scripts/disk-lens-trash" : ""
  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || homePath + "/.local/state")
    + "/omarchy-disk-lens"
  readonly property string selectionPath: stateDir + "/selected-disk.json"

  property var capacity: Model.parseCapacity("")
  property string capacityState: "loading"
  property string capacityError: ""
  property double capacityUpdatedAt: 0
  property var disks: []
  property string selectedDiskKey: ""
  property bool diskSelectionRestored: false
  property string pendingSelectionText: ""
  property var savedSelection: null
  property bool selectionFallback: false
  property bool fallbackAfterCancel: false
  property string diskNotice: ""
  property var freshDiskKeys: []
  property bool refreshPending: false
  property bool mountWatcherStopping: false
  property int mountWatcherRestarts: 0
  property double mountWatcherStartedAt: 0

  property string scanState: "idle"
  property string scanPath: homePath
  property string lastScanPath: ""
  property var entries: []
  property double totalBytes: 0
  property bool partial: false
  property var warnings: []
  property double warningCount: 0
  property string scanError: ""
  property double scannedAt: 0
  property bool expectedStop: false
  property string scanOutput: ""
  property string scanStderr: ""
  property var scanCache: []
  property int cacheHitCount: 0
  property bool resultFromCache: false

  property string trashState: "idle"
  property string trashTargetPath: ""
  property string trashTargetName: ""
  property string trashTargetScope: ""
  property string trashCompletedPath: ""
  property string trashCompletedName: ""
  property string trashError: ""
  property int trashMoveCount: 0
  property bool expectedTrashStop: false
  property string trashRescanScope: ""

  readonly property int maxCachedScopes: 8
  readonly property int maxCachedEntries: 12000

  function refreshCapacity() {
    if (capacityProcess.running) return false
    capacityState = capacity.available ? "ready" : "loading"
    capacityError = ""
    capacityProcess.running = true
    return true
  }

  function selectedDisk() {
    return Model.findDisk(disks, selectedDiskKey)
  }

  function applyDisks(raw) {
    var result = Model.parseDisks(raw, homePath)
    if (!result.ok) {
      disks = result.disks
      capacity = Model.parseCapacity("")
      capacityState = "failed"
      capacityError = result.error
      return
    }

    var previous = disks
    disks = result.disks
    capacityState = "ready"
    capacityError = ""

    if (!diskSelectionRestored) {
      diskSelectionRestored = true
      try {
        savedSelection = Model.parseDiskSelection(selectionFile.text())
      } catch (error) {
        savedSelection = null
      }
      var initialKey = Model.chooseDisk(disks, savedSelection)
      // A saved disk that is not mounted yet is selected once it appears.
      selectionFallback = savedSelection !== null
        && Model.findDisk(disks, initialKey).source !== savedSelection.source
      setSelectedDisk(initialKey, false, false)
      return
    }

    var added = Model.addedDiskKeys(previous, disks)
    if (added.length > 0) {
      freshDiskKeys = added
      freshDiskTimer.restart()
    }
    var removed = Model.removedDisks(previous, disks)
    var scopeRemoved = removed.length > 0 && Model.diskForPath(removed, lastScanPath || scanPath) !== ""
    if (removed.length > 0) forgetRemovedDisks(removed)

    if (!selectedDisk()) {
      // The selected disk disappeared (for example, unplugged). Fall back
      // without overwriting the saved choice so it returns when remounted.
      selectionFallback = true
      if (!diskNotice) diskNotice = "Disk " + Model.safeLabel(removed.length ? removed[0].target : "")
        + " was removed."
      setSelectedDisk(Model.chooseDisk(disks, savedSelection), false, true)
      return
    }

    var savedKey = savedSelection ? Model.chooseDisk(disks, savedSelection) : ""
    var savedDisk = Model.findDisk(disks, savedKey)
    if (selectionFallback && savedDisk && savedDisk.source === savedSelection.source
        && savedKey !== selectedDiskKey && !scanProcess.running && !trashProcess.running) {
      // The saved disk returned: select it again without rewriting the file.
      selectionFallback = false
      diskNotice = ""
      setSelectedDisk(savedKey, false, false)
      return
    }
    capacity = selectedDisk()
    if (scopeRemoved) setSelectedDisk(selectedDiskKey, false, true)
  }

  // Drops cached results that belong to unmounted disks (their contents may
  // differ when remounted) and cancels a scan running on one of them.
  function forgetRemovedDisks(removed) {
    var kept = []
    for (var index = 0; index < scanCache.length; index++) {
      var snapshot = scanCache[index]
      if (snapshot && !Model.diskForPath(removed, snapshot.path)) kept.push(snapshot)
    }
    scanCache = kept

    if (scanProcess.running && Model.diskForPath(removed, scanPath)) {
      fallbackAfterCancel = true
      cancelScan()
      diskNotice = "Disk " + Model.safeLabel(removed[0].target) + " was removed; its scan was cancelled."
    }
  }

  // Selects a disk and points the analysis scope at its scan root. A cached
  // result is restored; otherwise the analysis returns to first-use state.
  // Selection never starts a recursive scan.
  // force resets the analysis even when the current scope still resolves to
  // this disk, which happens when the scope belonged to an unmounted disk.
  function setSelectedDisk(key, persist, force) {
    var disk = Model.findDisk(disks, key)
    if (!disk) return false
    selectedDiskKey = disk.key
    capacity = disk
    if (persist) saveDiskSelection(disk)
    if (scanProcess.running || trashProcess.running) return true
    if (!force && Model.diskForPath(disks, lastScanPath || scanPath) === disk.key) return true
    if (restoreCachedScan(disk.scanRoot)) return true
    entries = []
    totalBytes = 0
    warnings = []
    warningCount = 0
    partial = false
    lastScanPath = ""
    scanPath = disk.scanRoot
    scannedAt = 0
    scanState = "idle"
    scanError = ""
    resultFromCache = false
    return true
  }

  function selectDisk(key) {
    if (scanProcess.running || trashProcess.running) return false
    if (!Model.findDisk(disks, String(key || ""))) return false
    selectionFallback = false
    diskNotice = ""
    return setSelectedDisk(String(key || ""), true, false)
  }

  function cycleDisk(delta) {
    if (disks.length < 2) return false
    var index = 0
    for (var i = 0; i < disks.length; i++) {
      if (disks[i].key === selectedDiskKey) index = i
    }
    var next = (index + delta + disks.length) % disks.length
    return selectDisk(disks[next].key)
  }

  // Keeps the capacity view on the disk that holds the analysed scope.
  function syncDiskForPath(path) {
    var key = Model.diskForPath(disks, path)
    if (!key || key === selectedDiskKey) return
    selectedDiskKey = key
    capacity = selectedDisk()
    selectionFallback = false
    diskNotice = ""
    saveDiskSelection(capacity)
  }

  function saveDiskSelection(disk) {
    savedSelection = { source: disk.source, target: disk.target }
    pendingSelectionText = JSON.stringify({ source: disk.source, target: disk.target }) + "\n"
    if (!selectionDirProcess.running) selectionDirProcess.running = true
  }

  function validScanPath(path) {
    var value = String(path || "")
    return value.length > 0 && value.length <= 4096 && value.charAt(0) === "/" && value.indexOf("\u0000") < 0
  }

  function startScan(path) {
    var selectedPath = String(path || scanPath || homePath)
    if (scanProcess.running || trashProcess.running || !validScanPath(selectedPath) || !scannerPath) return false

    scanPath = selectedPath
    syncDiskForPath(selectedPath)
    scanError = ""
    expectedStop = false
    scanOutput = ""
    scanStderr = ""
    scanState = "scanning"
    scanProcess.command = [scannerPath, "--path", selectedPath]
    scanProcess.running = true
    return true
  }

  function cacheResult(snapshot) {
    if (!snapshot || !validScanPath(snapshot.path) || !Array.isArray(snapshot.entries)) return

    var next = [snapshot]
    var cachedEntries = snapshot.entries.length
    var pinnedHome = null
    if (snapshot.path !== homePath) {
      for (var homeIndex = 0; homeIndex < scanCache.length; homeIndex++) {
        if (scanCache[homeIndex] && scanCache[homeIndex].path === homePath) {
          pinnedHome = scanCache[homeIndex]
          break
        }
      }
    }
    var reserveHome = pinnedHome
      && cachedEntries + pinnedHome.entries.length <= maxCachedEntries
    var lruLimit = reserveHome ? maxCachedScopes - 1 : maxCachedScopes
    for (var index = 0; index < scanCache.length; index++) {
      var candidate = scanCache[index]
      if (!candidate || candidate.path === snapshot.path || candidate.path === homePath) continue
      if (next.length >= lruLimit) break
      if (cachedEntries + candidate.entries.length > maxCachedEntries) continue
      next.push(candidate)
      cachedEntries += candidate.entries.length
    }
    if (reserveHome) next.push(pinnedHome)
    scanCache = next
  }

  function restoreCachedScan(path) {
    var selectedPath = String(path || "")
    if (scanProcess.running || trashProcess.running || !validScanPath(selectedPath)) return false

    for (var index = 0; index < scanCache.length; index++) {
      var snapshot = scanCache[index]
      if (!snapshot || snapshot.path !== selectedPath) continue

      entries = snapshot.entries.slice()
      totalBytes = snapshot.totalBytes
      warnings = snapshot.warnings.slice()
      warningCount = snapshot.warningCount
      partial = snapshot.partial
      lastScanPath = snapshot.path
      scanPath = snapshot.path
      scannedAt = snapshot.scannedAt
      scanState = snapshot.partial ? "partial" : "ready"
      scanError = ""
      resultFromCache = true
      cacheHitCount += 1
      syncDiskForPath(snapshot.path)

      var refreshedCache = [snapshot]
      for (var cacheIndex = 0; cacheIndex < scanCache.length; cacheIndex++) {
        if (cacheIndex !== index) refreshedCache.push(scanCache[cacheIndex])
      }
      scanCache = refreshedCache
      return true
    }
    return false
  }

  function cancelScan() {
    if (!scanProcess.running) return false
    expectedStop = true
    scanState = "cancelling"
    scanProcess.running = false
    return true
  }

  function trashEntry(scope, path) {
    var selectedScope = String(scope || "")
    var selectedPath = String(path || "")
    if (scanProcess.running || trashProcess.running || !trashHelperPath
        || selectedScope !== lastScanPath || !validScanPath(selectedScope)
        || !validScanPath(selectedPath) || !Model.isImmediateChild(selectedPath, selectedScope))
      return null

    for (var index = 0; index < entries.length; index++) {
      var entry = entries[index]
      if (entry && entry.path === selectedPath && entry.actionable === true) return entry
    }
    return null
  }

  function moveToTrash(scope, path) {
    var entry = trashEntry(scope, path)
    if (!entry) {
      trashState = "failed"
      trashError = "The selected item is no longer an actionable entry in this scan."
      return false
    }

    trashTargetPath = String(entry.path)
    trashTargetName = String(entry.name)
    trashTargetScope = String(scope)
    trashCompletedPath = ""
    trashCompletedName = ""
    trashError = ""
    trashState = "moving"
    expectedTrashStop = false
    trashProcess.command = [trashHelperPath, "--scope", trashTargetScope, "--path", trashTargetPath]
    trashProcess.running = true
    return true
  }

  function clearTrashStatus() {
    if (trashProcess.running) return false
    trashState = "idle"
    trashError = ""
    trashCompletedPath = ""
    trashCompletedName = ""
    trashTargetPath = ""
    trashTargetName = ""
    trashTargetScope = ""
    return true
  }

  function applyScanOutput(raw) {
    var result = Model.parseScan(raw)
    if (!result.ok) {
      scanError = result.error
      scanState = "failed"
      return false
    }

    entries = result.entries
    totalBytes = result.totalBytes
    warnings = result.warnings
    warningCount = result.warningCount
    partial = result.partial
    lastScanPath = result.path
    scanPath = result.path
    scannedAt = Date.now()
    scanState = partial ? "partial" : "ready"
    scanError = ""
    resultFromCache = false
    syncDiskForPath(lastScanPath)
    cacheResult({
      path: lastScanPath,
      entries: entries.slice(),
      totalBytes: totalBytes,
      warnings: warnings.slice(),
      warningCount: warningCount,
      partial: partial,
      scannedAt: scannedAt
    })
    return true
  }

  function stateSnapshot() {
    return {
      buildIdentity: buildIdentity,
      capacityState: capacityState,
      capacity: capacity,
      disks: disks,
      selectedDiskKey: selectedDiskKey,
      savedSelection: savedSelection,
      selectionFallback: selectionFallback,
      diskNotice: diskNotice,
      freshDiskKeys: freshDiskKeys,
      mountWatcherRunning: mountWatcher.running,
      selectionPath: selectionPath,
      scanState: scanState,
      scanPath: scanPath,
      lastScanPath: lastScanPath,
      entryCount: entries.length,
      totalBytes: totalBytes,
      partial: partial,
      warningCount: warningCount,
      scanError: scanError,
      scannedAt: scannedAt,
      cacheCount: scanCache.length,
      cacheHitCount: cacheHitCount,
      resultFromCache: resultFromCache,
      trashState: trashState,
      trashTargetPath: trashTargetPath,
      trashCompletedPath: trashCompletedPath,
      trashCompletedName: trashCompletedName,
      trashError: trashError,
      trashMoveCount: trashMoveCount
    }
  }

  Process {
    id: capacityProcess
    command: ["findmnt", "--json", "--bytes", "--list",
      "--output", "SOURCE,TARGET,FSTYPE,SIZE,USED,AVAIL,USE%"]
    stdout: StdioCollector {
      id: capacityStdout
      waitForEnd: true
    }
    stderr: StdioCollector {
      id: capacityStderr
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.capacityState = "failed"
        root.capacityError = Model.diagnosticText(capacityStderr.text, "Could not read filesystem capacity")
        return
      }
      root.applyDisks(capacityStdout.text)
      root.capacityUpdatedAt = Date.now()
    }
    onRunningChanged: {
      if (!running && root.refreshPending) {
        root.refreshPending = false
        Qt.callLater(root.refreshCapacity)
      }
    }
  }

  // Mount table watcher: each event line schedules one debounced discovery,
  // so newly mounted or removed disks appear without waiting for the timer.
  Process {
    id: mountWatcher
    command: ["findmnt", "--poll", "--list", "--noheadings", "--output", "ACTION,TARGET"]
    stdout: SplitParser {
      onRead: function(line) { mountEventTimer.restart() }
    }
    onRunningChanged: if (running) root.mountWatcherStartedAt = Date.now()
    onExited: function(exitCode) {
      if (root.mountWatcherStopping) return
      if (Date.now() - root.mountWatcherStartedAt > 30000) root.mountWatcherRestarts = 0
      mountWatcherRestartTimer.interval = Math.min(60000, 1000 * Math.pow(2, root.mountWatcherRestarts))
      root.mountWatcherRestarts += 1
      mountWatcherRestartTimer.restart()
    }
  }

  Timer {
    id: mountEventTimer
    interval: 400
    repeat: false
    onTriggered: if (!root.refreshCapacity()) root.refreshPending = true
  }

  Timer {
    id: mountWatcherRestartTimer
    repeat: false
    onTriggered: {
      if (root.mountWatcherStopping) return
      mountWatcher.running = true
      // Events may have been missed while the watcher was down.
      if (!root.refreshCapacity()) root.refreshPending = true
    }
  }

  Timer {
    id: freshDiskTimer
    interval: 8000
    repeat: false
    onTriggered: root.freshDiskKeys = []
  }

  FileView {
    id: selectionFile
    path: root.selectionPath
    blockLoading: true
    watchChanges: false
    printErrors: false
  }

  Process {
    id: selectionDirProcess
    command: ["mkdir", "-p", "--", root.stateDir]
    onExited: function(exitCode) {
      if (exitCode === 0 && root.pendingSelectionText) selectionFile.setText(root.pendingSelectionText)
    }
  }

  Process {
    id: trashProcess
    command: []
    stdout: StdioCollector {
      id: trashStdout
      waitForEnd: true
    }
    stderr: StdioCollector {
      id: trashStderr
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (root.expectedTrashStop) {
        root.expectedTrashStop = false
        root.trashState = "idle"
        root.trashError = ""
        return
      }

      if (exitCode !== 0) {
        root.trashState = "failed"
        root.trashError = Model.diagnosticText(trashStderr.text,
          "The selected item could not be moved to Trash")
        return
      }

      var completedScope = root.trashTargetScope
      root.trashCompletedPath = root.trashTargetPath
      root.trashCompletedName = root.trashTargetName
      root.trashMoveCount += 1
      root.trashState = "moved"
      root.trashError = ""
      root.scanCache = []
      root.trashTargetPath = ""
      root.trashTargetName = ""
      root.trashTargetScope = ""
      root.refreshCapacity()
      root.trashRescanScope = completedScope
      trashRescanTimer.restart()
    }
  }

  Process {
    id: scanProcess
    command: []
    stdout: StdioCollector {
      id: scanStdout
      waitForEnd: true
      onStreamFinished: root.scanOutput = String(text || "")
    }
    stderr: StdioCollector {
      id: scanStderrCollector
      waitForEnd: true
      onStreamFinished: root.scanStderr = String(text || "")
    }
    onExited: function(exitCode) {
      if (root.expectedStop) {
        root.expectedStop = false
        root.scanState = "cancelled"
        root.scanError = ""
        if (root.fallbackAfterCancel) {
          root.fallbackAfterCancel = false
          root.setSelectedDisk(root.selectedDiskKey, false, true)
        }
        return
      }

      var output = String(scanStdout.text || root.scanOutput || "")
      if (exitCode !== 0 && !output) {
        root.scanState = "failed"
        root.scanError = Model.diagnosticText(scanStderrCollector.text || root.scanStderr,
          "Disk scan failed")
        return
      }
      root.applyScanOutput(output)
    }
  }

  Timer {
    id: trashRescanTimer
    interval: 0
    repeat: false
    onTriggered: {
      var scope = root.trashRescanScope
      root.trashRescanScope = ""
      if (scope) root.startScan(scope)
    }
  }

  Timer {
    interval: 60000
    repeat: true
    running: true
    onTriggered: root.refreshCapacity()
  }

  IpcHandler {
    target: "disk-lens-service"

    function state(): string { return JSON.stringify(root.stateSnapshot()) }
    function refreshCapacity(): string { return root.refreshCapacity() ? "started" : "busy" }
    function selectDisk(key: string): string { return root.selectDisk(key) ? "selected" : "rejected" }
    function cycleDisk(delta: int): string { return root.cycleDisk(delta) ? root.selectedDiskKey : "rejected" }
    function scan(path: string): string { return root.startScan(path) ? "started" : "rejected" }
    function restore(path: string): string { return root.restoreCachedScan(path) ? "restored" : "missing" }
    function cancel(): string { return root.cancelScan() ? "cancelling" : "idle" }
    function clearTrashStatus(): string { return root.clearTrashStatus() ? "cleared" : "busy" }
  }

  Component.onCompleted: {
    refreshCapacity()
    mountWatcher.running = true
  }

  Component.onDestruction: {
    mountWatcherStopping = true
    if (mountWatcher.running) mountWatcher.running = false
    if (scanProcess.running) {
      expectedStop = true
      scanProcess.running = false
    }
    if (trashProcess.running) {
      expectedTrashStop = true
      trashProcess.running = false
    }
  }
}
