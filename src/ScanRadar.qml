import QtQuick

// Soft radar sweep for the results pane while a scan is active.
// Accent/track colors come from the host theme; motion stops with `running`.
Item {
  id: root

  property bool running: false
  property color accent: "#f5a524"
  property color track: "#24ffffff"
  property real sweepAngle: 0
  property real pulse: 0.55

  implicitWidth: 160
  implicitHeight: 160
  visible: running

  Accessible.name: running ? "Scan radar active" : "Scan radar"
  Accessible.role: Accessible.ProgressBar

  function rgba(c, a) {
    return "rgba(" + Math.round(c.r * 255) + ", " + Math.round(c.g * 255) + ", "
      + Math.round(c.b * 255) + ", " + a + ")"
  }

  onAccentChanged: canvas.requestPaint()
  onTrackChanged: canvas.requestPaint()
  onSweepAngleChanged: canvas.requestPaint()
  onPulseChanged: canvas.requestPaint()
  onRunningChanged: {
    if (!running) {
      sweepAngle = 0
      pulse = 0.55
    }
    canvas.requestPaint()
  }

  Canvas {
    id: canvas
    anchors.fill: parent

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    onPaint: {
      var ctx = getContext("2d")
      var size = Math.min(width, height)
      var cx = width / 2
      var cy = height / 2
      var radius = size * 0.42
      var i
      var rings = 4

      ctx.clearRect(0, 0, width, height)

      var core = ctx.createRadialGradient(cx, cy, 0, cx, cy, radius * 0.55)
      core.addColorStop(0, root.rgba(root.accent, 0.22 * root.pulse))
      core.addColorStop(0.55, root.rgba(root.accent, 0.08 * root.pulse))
      core.addColorStop(1, root.rgba(root.accent, 0))
      ctx.fillStyle = core
      ctx.beginPath()
      ctx.arc(cx, cy, radius * 0.55, 0, Math.PI * 2)
      ctx.fill()

      ctx.lineWidth = Math.max(1, size * 0.008)
      for (i = 1; i <= rings; i++) {
        var r = radius * (i / rings)
        var ringAlpha = 0.12 + (i / rings) * 0.16 * root.pulse
        ctx.beginPath()
        ctx.arc(cx, cy, r, 0, Math.PI * 2)
        ctx.strokeStyle = root.rgba(root.accent, ringAlpha * 0.55)
        ctx.stroke()
        ctx.beginPath()
        ctx.arc(cx, cy, r, 0, Math.PI * 2)
        ctx.strokeStyle = String(root.track)
        ctx.globalAlpha = 0.35 + 0.15 * (i / rings)
        ctx.stroke()
        ctx.globalAlpha = 1
      }

      ctx.strokeStyle = root.rgba(root.accent, 0.22)
      ctx.lineWidth = Math.max(1, size * 0.006)
      var tick = radius * 0.08
      ctx.beginPath()
      ctx.moveTo(cx - radius - tick * 0.2, cy)
      ctx.lineTo(cx - radius + tick, cy)
      ctx.moveTo(cx + radius - tick, cy)
      ctx.lineTo(cx + radius + tick * 0.2, cy)
      ctx.moveTo(cx, cy - radius - tick * 0.2)
      ctx.lineTo(cx, cy - radius + tick)
      ctx.moveTo(cx, cy + radius - tick)
      ctx.lineTo(cx, cy + radius + tick * 0.2)
      ctx.stroke()

      var start = root.sweepAngle - Math.PI / 2
      var span = Math.PI * 0.55
      var steps = 28
      for (i = 0; i < steps; i++) {
        var t0 = start - span * ((i + 1) / steps)
        var t1 = start - span * (i / steps)
        var a = (1 - i / steps)
        a = a * a * (0.08 + 0.42 * root.pulse)
        ctx.beginPath()
        ctx.moveTo(cx, cy)
        ctx.arc(cx, cy, radius, t0, t1, false)
        ctx.closePath()
        ctx.fillStyle = root.rgba(root.accent, a)
        ctx.fill()
      }

      ctx.beginPath()
      ctx.moveTo(cx, cy)
      ctx.lineTo(cx + Math.cos(start) * radius, cy + Math.sin(start) * radius)
      ctx.strokeStyle = root.rgba(root.accent, 0.85)
      ctx.lineWidth = Math.max(1.5, size * 0.012)
      ctx.lineCap = "round"
      ctx.stroke()

      var tipX = cx + Math.cos(start) * radius
      var tipY = cy + Math.sin(start) * radius
      var tip = ctx.createRadialGradient(tipX, tipY, 0, tipX, tipY, size * 0.045)
      tip.addColorStop(0, "rgba(255, 255, 255, 0.75)")
      tip.addColorStop(0.35, root.rgba(root.accent, 0.7))
      tip.addColorStop(1, root.rgba(root.accent, 0))
      ctx.fillStyle = tip
      ctx.beginPath()
      ctx.arc(tipX, tipY, size * 0.045, 0, Math.PI * 2)
      ctx.fill()

      ctx.beginPath()
      ctx.arc(cx, cy, Math.max(2, size * 0.018), 0, Math.PI * 2)
      ctx.fillStyle = root.rgba(root.accent, 0.9)
      ctx.fill()
    }
  }

  NumberAnimation on sweepAngle {
    from: 0
    to: Math.PI * 2
    duration: 2400
    loops: Animation.Infinite
    running: root.running && root.visible
  }

  SequentialAnimation on pulse {
    loops: Animation.Infinite
    running: root.running && root.visible
    NumberAnimation { from: 0.42; to: 1.0; duration: 1100; easing.type: Easing.InOutSine }
    NumberAnimation { from: 1.0; to: 0.42; duration: 1100; easing.type: Easing.InOutSine }
  }
}
