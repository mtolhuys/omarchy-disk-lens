import QtQuick

// Soft full-width accent shimmer while a scan is active.
// Sweeps left→right→left; accent/track colors come from the host theme.
Item {
  id: root

  property bool running: false
  property color accent: "#f5a524"
  property color track: "#24ffffff"
  // 0 = band anchored left, 1 = band anchored right
  property real sweep: 0

  implicitWidth: 240
  implicitHeight: 8
  visible: running
  clip: true

  Accessible.name: running ? "Scan shimmer active" : "Scan shimmer"
  Accessible.role: Accessible.ProgressBar

  function rgba(c, a) {
    return "rgba(" + Math.round(c.r * 255) + ", " + Math.round(c.g * 255) + ", "
      + Math.round(c.b * 255) + ", " + a + ")"
  }

  onAccentChanged: canvas.requestPaint()
  onTrackChanged: canvas.requestPaint()
  onSweepChanged: canvas.requestPaint()
  onRunningChanged: {
    if (!running)
      sweep = 0
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
      var w = width
      var h = height
      var radius = h / 2
      var bandW = Math.max(h * 2.5, w * 0.32)
      var travel = Math.max(0, w - bandW)
      var x = root.sweep * travel
      var i
      var stops = 24

      ctx.clearRect(0, 0, w, h)

      // Soft track pill
      ctx.beginPath()
      ctx.moveTo(radius, 0)
      ctx.lineTo(w - radius, 0)
      ctx.arc(w - radius, radius, radius, -Math.PI / 2, Math.PI / 2, false)
      ctx.lineTo(radius, h)
      ctx.arc(radius, radius, radius, Math.PI / 2, -Math.PI / 2, false)
      ctx.closePath()
      ctx.fillStyle = String(root.track)
      ctx.fill()

      // Soft accent sheen across the track
      var sheen = ctx.createLinearGradient(0, 0, w, 0)
      sheen.addColorStop(0, root.rgba(root.accent, 0.04))
      sheen.addColorStop(0.5, root.rgba(root.accent, 0.10))
      sheen.addColorStop(1, root.rgba(root.accent, 0.04))
      ctx.fillStyle = sheen
      ctx.fill()

      // Sweeping band: fade in / hot core / fade out
      for (i = 0; i < stops; i++) {
        var t0 = i / stops
        var t1 = (i + 1) / stops
        var mid = (t0 + t1) / 2
        var edge = mid < 0.5 ? mid * 2 : (1 - mid) * 2
        var alpha = 0.05 + edge * edge * 0.42
        var x0 = x + bandW * t0
        var x1 = x + bandW * t1
        ctx.fillStyle = root.rgba(root.accent, alpha)
        ctx.fillRect(x0, 0, Math.max(1, x1 - x0), h)
      }

      // Round the band ends by re-clipping to the pill (already clipped by Item)
      // Highlight core line for a subtle instrument feel
      var coreX = x + bandW * 0.5
      var core = ctx.createLinearGradient(coreX - bandW * 0.08, 0, coreX + bandW * 0.08, 0)
      core.addColorStop(0, root.rgba(root.accent, 0))
      core.addColorStop(0.5, root.rgba(root.accent, 0.55))
      core.addColorStop(1, root.rgba(root.accent, 0))
      ctx.fillStyle = core
      ctx.fillRect(coreX - bandW * 0.08, h * 0.15, bandW * 0.16, h * 0.7)
    }
  }

  SequentialAnimation on sweep {
    loops: Animation.Infinite
    running: root.running && root.visible
    NumberAnimation {
      from: 0
      to: 1
      duration: 1800
      easing.type: Easing.InOutSine
    }
    NumberAnimation {
      from: 1
      to: 0
      duration: 1800
      easing.type: Easing.InOutSine
    }
  }
}
