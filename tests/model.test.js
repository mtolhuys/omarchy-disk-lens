const assert = require("node:assert/strict")
const Model = require("../src/Model.js")

function record(value) {
  return JSON.stringify({ protocol: 1, ...value })
}

const capacity = Model.parseCapacity(JSON.stringify({
  filesystems: [{
    source: "/dev/mapper/root[/@home]",
    target: "/home",
    fstype: "btrfs",
    size: 1000,
    used: 720,
    avail: 280,
    "use%": "72%"
  }]
}))
assert.equal(capacity.available, true)
assert.equal(capacity.percent, 72)
assert.equal(capacity.target, "/home")
assert.equal(Model.parseCapacity("not json").available, false)
assert.doesNotThrow(() => Model.parseCapacity(JSON.stringify({ filesystems: [null] })))
assert.equal(Model.parseCapacity(JSON.stringify({ filesystems: [null] })).available, false)

const scanOutput = [
  record({ type: "start", path: "/fixture" }),
  record({
    type: "entry",
    path: "/fixture/large folder",
    pathB64: "L2ZpeHR1cmUvbGFyZ2UgZm9sZGVy",
    name: "large folder",
    kind: "directory",
    allocatedBytes: 800,
    mtime: 1700000000,
    validUtf8: true,
    actionable: true
  }),
  record({
    type: "entry",
    path: "/fixture/.hidden\nname",
    pathB64: "L2ZpeHR1cmUvLmhpZGRlbgpuYW1l",
    name: ".hidden\nname",
    kind: "file",
    allocatedBytes: 200,
    mtime: 1600000000,
    validUtf8: true,
    actionable: true
  }),
  record({ type: "warning", message: "one path was unreadable" }),
  record({
    type: "complete",
    path: "/fixture",
    totalBytes: 1000,
    entries: 2,
    warnings: 1,
    partial: true
  })
].join("\n")

const scan = Model.parseScan(scanOutput)
assert.equal(scan.ok, true)
assert.equal(scan.entries.length, 2)
assert.equal(scan.entries[0].name, "large folder")
assert.equal(scan.partial, true)
assert.equal(scan.totalBytes, 1000)

assert.equal(Model.parseScan(scanOutput.replace('"protocol":1', '"protocol":2')).ok, false)
assert.equal(Model.parseScan(scanOutput.replace(/\n[^\n]+$/, "")).ok, false)
assert.equal(Model.parseScan(scanOutput + "\nnot-json").ok, false)
assert.equal(Model.parseScan(scanOutput.replace('"entries":2', '"entries":3')).ok, false)
assert.equal(Model.parseScan(scanOutput.replace('"validUtf8":true', '"validUtf8":"yes"')).ok, false)
assert.equal(Model.parseScan(scanOutput.replace('"allocatedBytes":800', '"allocatedBytes":"800"')).ok, false)
assert.equal(Model.parseScan(scanOutput.replace('"path":"/fixture/large folder"', '"path":"/outside"')).ok, false)
assert.equal(Model.parseScan(scanOutput.replace('"pathB64":"L2ZpeHR1cmUvbGFyZ2UgZm9sZGVy"', '"pathB64":"not base64"')).ok, false)
assert.equal(Model.parseScan(scanOutput + "\n" + record({ type: "warning", message: "too late" })).ok, false)
assert.equal(Model.parseScan(scanOutput.replace('"partial":true', '"partial":false')).ok, false)
assert.equal(Model.parseScan([
  record({ type: "warning", message: "too early" }),
  record({ type: "start", path: "/fixture" }),
  record({ type: "complete", path: "/fixture", totalBytes: 0, entries: 0, warnings: 1, partial: true })
].join("\n")).ok, false)

const boundedWarnings = [record({ type: "start", path: "/fixture" })]
for (let index = 0; index < Model.MAX_WARNINGS; index += 1)
  boundedWarnings.push(record({ type: "warning", message: `warning ${index}` }))
boundedWarnings.push(record({
  type: "complete",
  path: "/fixture",
  totalBytes: 0,
  entries: 0,
  warnings: Model.MAX_WARNINGS,
  partial: true
}))
assert.equal(Model.parseScan(boundedWarnings.join("\n")).ok, true)
boundedWarnings.splice(-1, 0, record({ type: "warning", message: "one warning too many" }))
assert.equal(Model.parseScan(boundedWarnings.join("\n")).ok, false)

const visibleDefault = Model.filterEntries(scan.entries, {})
assert.deepEqual(visibleDefault.map(entry => entry.name), ["large folder"])

const visibleHidden = Model.filterEntries(scan.entries, {
  includeHidden: true,
  kind: "files",
  query: "hidden",
  minimumBytes: 100
})
assert.deepEqual(visibleHidden.map(entry => entry.name), [".hidden\nname"])

assert.equal(Model.formatBytes(0), "0 B")
assert.equal(Model.formatBytes(1024), "1 KiB")
assert.equal(Model.formatBytes(1073741824), "1 GiB")
assert.equal(Model.safeLabel("line\nname\t"), "line�name�")

const mapEntries = [
  { path: "/a", name: "a", allocatedBytes: 600 },
  { path: "/b", name: "b", allocatedBytes: 300 },
  { path: "/c", name: "c", allocatedBytes: 100 }
]
const rectangles = Model.treemap(mapEntries, 600, 300, 48)
assert.equal(rectangles.length, 3)
assert.deepEqual(new Set(rectangles.map(rect => rect.path)), new Set(["/a", "/b", "/c"]))
for (const rect of rectangles) {
  assert.ok(rect.x >= 0 && rect.y >= 0)
  assert.ok(rect.width > 0 && rect.height > 0)
  assert.ok(rect.x + rect.width <= 600.000001)
  assert.ok(rect.y + rect.height <= 300.000001)
}
const mappedArea = rectangles.reduce((sum, rect) => sum + rect.width * rect.height, 0)
assert.ok(Math.abs(mappedArea - 180000) < 0.01)

console.log("ok - model, protocol, filters, formatting, and treemap")
