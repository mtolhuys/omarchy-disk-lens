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

  readonly property string buildIdentity: "disk-lens-service-v0502"
  readonly property string homePath: Quickshell.env("HOME")
  readonly property string sourceDir: manifest ? String(manifest.__sourceDir || "") : ""
  readonly property string scannerPath: sourceDir ? sourceDir + "/scripts/disk-lens-scan" : ""
  readonly property string trashHelperPath: sourceDir ? sourceDir + "/scripts/disk-lens-trash" : ""

  property var capacity: Model.parseCapacity("")
  property string capacityState: "loading"
  property string capacityError: ""
  property double capacityUpdatedAt: 0

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

  function validScanPath(path) {
    var value = String(path || "")
    return value.length > 0 && value.length <= 4096 && value.charAt(0) === "/" && value.indexOf("\u0000") < 0
  }

  function startScan(path) {
    var selectedPath = String(path || scanPath || homePath)
    if (scanProcess.running || trashProcess.running || !validScanPath(selectedPath) || !scannerPath) return false

    scanPath = selectedPath
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
    command: ["findmnt", "--json", "--bytes", "--target", root.homePath,
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
      var parsed = Model.parseCapacity(capacityStdout.text)
      root.capacity = parsed
      root.capacityState = parsed.available ? "ready" : "failed"
      root.capacityError = parsed.error
      root.capacityUpdatedAt = Date.now()
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
    function scan(path: string): string { return root.startScan(path) ? "started" : "rejected" }
    function restore(path: string): string { return root.restoreCachedScan(path) ? "restored" : "missing" }
    function cancel(): string { return root.cancelScan() ? "cancelling" : "idle" }
    function clearTrashStatus(): string { return root.clearTrashStatus() ? "cleared" : "busy" }
  }

  Component.onCompleted: {
    refreshCapacity()
  }

  Component.onDestruction: {
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
