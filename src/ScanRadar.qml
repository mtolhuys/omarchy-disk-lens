import QtQuick

// Full-pane horizontal scan wash: a soft vertical accent beam sweeps
// left→right→left across the entire clipped host surface (hero or overlay).
// Status copy sits above; accent/track colors come from the host theme.
Item {
  id: root

  property bool running: false
  property color accent: "#f5a524"
  property color track: "#24ffffff"
  // 1.0 = hero empty pane; ~0.55–0.7 = translucent overlay on live results
  property real intensity: 1.0
  // 0 = beam at left edge, 1 = beam at right edge
  property real sweep: 0

  implicitWidth: 240
  implicitHeight: 160
  visible: running
  clip: true

  Accessible.name: running ? "Scan wash active" : "Scan wash"
  Accessible.role: Accessible.ProgressBar

  function rgba(c, a) {
    return "rgba(" + Math.round(c.r * 255) + ", " + Math.round(c.g * 255) + ", "
      + Math.round(c.b * 255) + ", " + a + ")"
  }

  function clamp01(v) {
    return Math.max(0, Math.min(1, v))
  }

  onAccentChanged: canvas.requestPaint()
  onTrackChanged: canvas.requestPaint()
  onIntensityChanged: canvas.requestPaint()
  onSweepChanged: canvas.requestPaint()
  onWidthChanged: canvas.requestPaint()
  onHeightChanged: canvas.requestPaint()
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
      var i
      var stops
      var gain = Math.max(0.15, Math.min(1.35, root.intensity))

      ctx.clearRect(0, 0, w, h)
      if (w < 2 || h < 2)
        return

      // Quiet full-pane veil so the wash reads as an instrument field
      var veil = ctx.createLinearGradient(0, 0, w, 0)
      veil.addColorStop(0, root.rgba(root.accent, 0.02 * gain))
      veil.addColorStop(0.5, root.rgba(root.accent, 0.055 * gain))
      veil.addColorStop(1, root.rgba(root.accent, 0.02 * gain))
      ctx.fillStyle = veil
      ctx.fillRect(0, 0, w, h)

      // Soft track sheen (theme-derived, barely there)
      ctx.fillStyle = String(root.track)
      ctx.globalAlpha = 0.22 * gain
      ctx.fillRect(0, 0, w, h)
      ctx.globalAlpha = 1

      // Beam geometry: wide translucent column with a hot vertical core
      var beamW = Math.max(48, Math.min(w * 0.42, h * 1.15))
      var travel = w + beamW
      var cx = -beamW * 0.5 + root.sweep * travel
      var left = cx - beamW * 0.5
      var right = cx + beamW * 0.5

      // Outer bloom / glow trail — taller soft body across full height
      var bloomW = beamW * 1.55
      var bloomLeft = cx - bloomW * 0.5
      stops = 36
      for (i = 0; i < stops; i++) {
        var t0 = i / stops
        var t1 = (i + 1) / stops
        var mid = (t0 + t1) / 2
        // Smooth raised-cosine falloff from center
        var edge = 0.5 + 0.5 * Math.cos((mid - 0.5) * Math.PI * 2)
        edge = root.clamp01(edge)
        var alpha = edge * edge * 0.10 * gain
        if (alpha < 0.002)
          continue
        var x0 = bloomLeft + bloomW * t0
        var x1 = bloomLeft + bloomW * t1
        ctx.fillStyle = root.rgba(root.accent, alpha)
        ctx.fillRect(x0, 0, Math.max(0.5, x1 - x0), h)
      }

      // Main wash column — translucent accent body
      stops = 40
      for (i = 0; i < stops; i++) {
        var u0 = i / stops
        var u1 = (i + 1) / stops
        var umid = (u0 + u1) / 2
        var lobe = Math.cos((umid - 0.5) * Math.PI)
        lobe = Math.max(0, lobe)
        lobe = lobe * lobe
        var a = (0.04 + lobe * 0.28) * gain
        var bx0 = left + beamW * u0
        var bx1 = left + beamW * u1
        ctx.fillStyle = root.rgba(root.accent, a)
        ctx.fillRect(bx0, 0, Math.max(0.5, bx1 - bx0), h)
      }

      // Hot vertical core with a soft white tip for instrument drama
      var coreHalf = Math.max(3, beamW * 0.045)
      var core = ctx.createLinearGradient(cx - coreHalf * 3, 0, cx + coreHalf * 3, 0)
      core.addColorStop(0, root.rgba(root.accent, 0))
      core.addColorStop(0.35, root.rgba(root.accent, 0.35 * gain))
      core.addColorStop(0.5, "rgba(255, 255, 255, " + (0.42 * gain) + ")")
      core.addColorStop(0.65, root.rgba(root.accent, 0.45 * gain))
      core.addColorStop(1, root.rgba(root.accent, 0))
      ctx.fillStyle = core
      ctx.fillRect(cx - coreHalf * 3, 0, coreHalf * 6, h)

      // Hairline leading edge — crisp but never loud
      ctx.fillStyle = root.rgba(root.accent, 0.55 * gain)
      ctx.fillRect(cx - 0.75, h * 0.06, 1.5, h * 0.88)

      // Top/bottom vignette so the beam feels clipped to the pane
      var vig = ctx.createLinearGradient(0, 0, 0, h)
      vig.addColorStop(0, "rgba(0, 0, 0, " + (0.10 * gain) + ")")
      vig.addColorStop(0.18, "rgba(0, 0, 0, 0)")
      vig.addColorStop(0.82, "rgba(0, 0, 0, 0)")
      vig.addColorStop(1, "rgba(0, 0, 0, " + (0.10 * gain) + ")")
      ctx.fillStyle = vig
      ctx.fillRect(Math.min(left, bloomLeft), 0, Math.max(beamW, bloomW), h)
    }
  }

  SequentialAnimation on sweep {
    loops: Animation.Infinite
    running: root.running && root.visible
    NumberAnimation {
      from: 0
      to: 1
      duration: 2200
      easing.type: Easing.InOutSine
    }
    NumberAnimation {
      from: 1
      to: 0
      duration: 2200
      easing.type: Easing.InOutSine
    }
  }
}
