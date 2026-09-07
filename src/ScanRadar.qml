import QtQuick

// One vertical scanner stripe — GPU-animated x (no Canvas, no layered FBO).
// Quiet motion-relative radar: soft trail behind, slightly brighter lead ahead.
// Trail/lead flip with ping-pong via direction (±1). Transparent host only.
// Single coherent gradient (no stacked-rect seams / banding / hard hairline).
Item {
  id: root

  property bool running: false
  property color accent: "#f5a524"
  property color track: "#24ffffff" // call-site compat; unused (no pane wash)
  property real intensity: 1.0
  // 0 = off the left edge, 1 = off the right edge
  property real sweep: 0
  // +1 = sweeping right (trail left, lead right); -1 = sweeping left
  property int direction: 1
  // Subtle opacity breathe — organic radar, not a static sliding stripe
  property real breathe: 1.0

  readonly property real gain: Math.max(0.16, Math.min(1.1, intensity)) * breathe
  // Narrower traveler — whisper core with room for a soft trail
  readonly property real beamWidth: {
    if (width < 2)
      return 72
    return Math.max(56, Math.min(112, width * 0.22))
  }

  implicitWidth: 240
  implicitHeight: 160
  visible: running
  clip: true

  Accessible.name: running ? "Scan beam active" : "Scan beam"
  Accessible.role: Accessible.ProgressBar

  onRunningChanged: {
    if (!running) {
      sweep = 0
      direction = 1
      breathe = 1.0
    }
  }

  // Moving beam traveler — x transform only; scale.x mirrors trail/lead
  Item {
    id: beam
    width: root.beamWidth
    height: parent.height
    x: -width + root.sweep * (parent.width + width)
    opacity: root.gain
    transform: Scale {
      origin.x: beam.width * 0.5
      origin.y: beam.height * 0.5
      xScale: root.direction
    }

    // Painted for direction=+1 (moving right): long trail ← left, soft lead → right
    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
          position: 0.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
        GradientStop {
          position: 0.22
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.015)
        }
        GradientStop {
          position: 0.48
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.04)
        }
        GradientStop {
          position: 0.72
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.09)
        }
        // Soft body peak just behind the lead — never white-hot / neon
        GradientStop {
          position: 0.88
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
        }
        // Quiet leading edge (motion cue without a hard hairline)
        GradientStop {
          position: 0.96
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.24)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.03)
        }
      }
    }
  }

  SequentialAnimation on sweep {
    loops: Animation.Infinite
    running: root.running && root.visible
    ScriptAction {
      script: root.direction = 1
    }
    NumberAnimation {
      from: 0
      to: 1
      duration: 2800
      easing.type: Easing.InOutCubic
    }
    ScriptAction {
      script: root.direction = -1
    }
    NumberAnimation {
      from: 1
      to: 0
      duration: 2800
      easing.type: Easing.InOutCubic
    }
  }

  SequentialAnimation on breathe {
    loops: Animation.Infinite
    running: root.running && root.visible
    NumberAnimation {
      from: 0.78
      to: 1.0
      duration: 1700
      easing.type: Easing.InOutSine
    }
    NumberAnimation {
      from: 1.0
      to: 0.78
      duration: 1700
      easing.type: Easing.InOutSine
    }
  }
}
