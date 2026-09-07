import QtQuick

// One vertical scanner stripe that ping-pongs left↔right.
// Soft horizontal glow falloff via LinearGradient only — never a horizontal
// pill/blob, never discrete vertical strip banding.
Item {
  id: root

  property bool running: false
  property color accent: "#f5a524"
  property color track: "#24ffffff"
  // 1.0 = hero empty pane; ~0.55–0.8 = translucent overlay on live results
  property real intensity: 1.0
  // 0 = stripe near left edge, 1 = stripe near right edge
  property real sweep: 0

  implicitWidth: 240
  implicitHeight: 160
  visible: running
  clip: true

  Accessible.name: running ? "Scan beam active" : "Scan beam"
  Accessible.role: Accessible.ProgressBar

  function rgba(c, a) {
    return "rgba(" + Math.round(c.r * 255) + ", " + Math.round(c.g * 255) + ", "
      + Math.round(c.b * 255) + ", " + a + ")"
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
    antialiasing: true

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    onPaint: {
      var ctx = getContext("2d")
      var w = width
      var h = height
      var gain = Math.max(0.18, Math.min(1.25, root.intensity))

      ctx.clearRect(0, 0, w, h)
      if (w < 4 || h < 4)
        return

      // Quiet field so the beam reads against dark UI (not a full wash)
      var field = ctx.createLinearGradient(0, 0, w, 0)
      field.addColorStop(0, root.rgba(root.accent, 0.015 * gain))
      field.addColorStop(0.5, root.rgba(root.accent, 0.04 * gain))
      field.addColorStop(1, root.rgba(root.accent, 0.015 * gain))
      ctx.fillStyle = field
      ctx.fillRect(0, 0, w, h)

      ctx.fillStyle = String(root.track)
      ctx.globalAlpha = 0.12 * gain
      ctx.fillRect(0, 0, w, h)
      ctx.globalAlpha = 1

      // Vertical stripe geometry: tall beam, modest width, soft horizontal falloff
      var beamW = Math.max(36, Math.min(72, w * 0.14))
      var travel = w + beamW
      var cx = -beamW * 0.5 + root.sweep * travel
      var left = cx - beamW * 0.5
      // Slight inset so the beam feels instrumented, not edge-flush debug fill
      var top = h * 0.04
      var bodyH = h * 0.92

      // Outer soft halo (wider, fainter) — single LinearGradient, no strips
      var haloW = beamW * 2.1
      var halo = ctx.createLinearGradient(cx - haloW * 0.5, 0, cx + haloW * 0.5, 0)
      halo.addColorStop(0.0, root.rgba(root.accent, 0))
      halo.addColorStop(0.18, root.rgba(root.accent, 0.03 * gain))
      halo.addColorStop(0.35, root.rgba(root.accent, 0.08 * gain))
      halo.addColorStop(0.5, root.rgba(root.accent, 0.12 * gain))
      halo.addColorStop(0.65, root.rgba(root.accent, 0.08 * gain))
      halo.addColorStop(0.82, root.rgba(root.accent, 0.03 * gain))
      halo.addColorStop(1.0, root.rgba(root.accent, 0))
      ctx.fillStyle = halo
      ctx.fillRect(cx - haloW * 0.5, top, haloW, bodyH)

      // Main vertical beam body
      var body = ctx.createLinearGradient(left, 0, left + beamW, 0)
      body.addColorStop(0.0, root.rgba(root.accent, 0))
      body.addColorStop(0.15, root.rgba(root.accent, 0.08 * gain))
      body.addColorStop(0.32, root.rgba(root.accent, 0.22 * gain))
      body.addColorStop(0.5, root.rgba(root.accent, 0.36 * gain))
      body.addColorStop(0.68, root.rgba(root.accent, 0.22 * gain))
      body.addColorStop(0.85, root.rgba(root.accent, 0.08 * gain))
      body.addColorStop(1.0, root.rgba(root.accent, 0))
      ctx.fillStyle = body
      ctx.fillRect(left, top, beamW, bodyH)

      // Hot vertical core (still a line, not a blob)
      var coreHalf = Math.max(2.5, beamW * 0.07)
      var core = ctx.createLinearGradient(cx - coreHalf * 3.2, 0, cx + coreHalf * 3.2, 0)
      core.addColorStop(0.0, root.rgba(root.accent, 0))
      core.addColorStop(0.30, root.rgba(root.accent, 0.28 * gain))
      core.addColorStop(0.5, "rgba(255, 255, 255, " + (0.38 * gain) + ")")
      core.addColorStop(0.70, root.rgba(root.accent, 0.32 * gain))
      core.addColorStop(1.0, root.rgba(root.accent, 0))
      ctx.fillStyle = core
      ctx.fillRect(cx - coreHalf * 3.2, top + bodyH * 0.02, coreHalf * 6.4, bodyH * 0.96)

      // Crisp leading hairline — reads as a scanner, not a flare
      ctx.fillStyle = root.rgba(root.accent, 0.50 * gain)
      ctx.fillRect(cx - 0.75, top + bodyH * 0.05, 1.5, bodyH * 0.90)

      // Soft top/bottom fade so the stripe eases into the pane
      var vig = ctx.createLinearGradient(0, top, 0, top + bodyH)
      vig.addColorStop(0.0, "rgba(0, 0, 0, " + (0.22 * gain) + ")")
      vig.addColorStop(0.12, "rgba(0, 0, 0, 0)")
      vig.addColorStop(0.88, "rgba(0, 0, 0, 0)")
      vig.addColorStop(1.0, "rgba(0, 0, 0, " + (0.22 * gain) + ")")
      ctx.fillStyle = vig
      ctx.fillRect(cx - haloW * 0.5, top, haloW, bodyH)
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
