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

  readonly property string buildIdentity: "disk-lens-service-v0400"
  readonly property string homePath: Quickshell.env("HOME")
  readonly property string sourceDir: manifest ? String(manifest.__sourceDir || "") : ""
  readonly property string scannerPath: sourceDir ? sourceDir + "/scripts/disk-lens-scan" : ""

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
  property string scanError: ""
  property double scannedAt: 0
  property bool expectedStop: false
  property string scanOutput: ""
  property string scanStderr: ""

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
    if (scanProcess.running || !validScanPath(selectedPath) || !scannerPath) return false

    scanPath = selectedPath
    scanError = ""
    warnings = []
    expectedStop = false
    scanOutput = ""
    scanStderr = ""
    scanState = "scanning"
    scanProcess.command = [scannerPath, "--path", selectedPath]
    scanProcess.running = true
    return true
  }

  function cancelScan() {
    if (!scanProcess.running) return false
    expectedStop = true
    scanState = "cancelling"
    scanProcess.running = false
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
    partial = result.partial
    lastScanPath = result.path
    scanPath = result.path
    scannedAt = Date.now()
    scanState = partial ? "partial" : "ready"
    scanError = ""
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
      warningCount: warnings.length,
      scanError: scanError,
      scannedAt: scannedAt
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
        root.capacityError = String(capacityStderr.text || "Could not read filesystem capacity").trim()
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
        root.scanError = String(scanStderrCollector.text || root.scanStderr || "Disk scan failed").trim()
        return
      }
      root.applyScanOutput(output)
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
    function cancel(): string { return root.cancelScan() ? "cancelling" : "idle" }
  }

  Component.onCompleted: {
    refreshCapacity()
  }

  Component.onDestruction: {
    if (scanProcess.running) {
      expectedStop = true
      scanProcess.running = false
    }
  }
}
