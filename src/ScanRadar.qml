import QtQuick

// One vertical scanner stripe — GPU-animated x (no Canvas, no layered FBO).
// Motion-relative radar glow: bright leading edge in the travel direction,
// soft trail fading behind. Trail/lead flip with ping-pong via direction (±1).
// Host is fully transparent; only stacked horizontal accent gradients paint.
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

  readonly property real gain: Math.max(0.18, Math.min(1.25, intensity))
  // Wider traveler so the comet trail has room to fade
  readonly property real beamWidth: {
    if (width < 2)
      return 110
    return Math.max(88, Math.min(168, width * 0.34))
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
    }
  }

  // Moving beam traveler — x transform only; scale.x mirrors trail/lead
  Item {
    id: beam
    width: root.beamWidth
    height: parent.height
    x: -width + root.sweep * (parent.width + width)
    transform: Scale {
      origin.x: beam.width * 0.5
      origin.y: beam.height * 0.5
      xScale: root.direction
    }

    // Painted for direction=+1 (moving right): long trail ← left, hot lead → right

    // Outermost trail wash (longest, faintest)
    Rectangle {
      anchors.right: parent.right
      anchors.rightMargin: parent.width * 0.04
      width: parent.width * 1.05
      height: parent.height
      opacity: root.gain
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
          position: 0.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
        GradientStop {
          position: 0.22
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.025)
        }
        GradientStop {
          position: 0.55
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.07)
        }
        GradientStop {
          position: 0.82
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.06)
        }
      }
    }

    // Mid trail → body ramp
    Rectangle {
      anchors.right: parent.right
      width: parent.width * 0.78
      height: parent.height
      opacity: root.gain
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
          position: 0.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
        GradientStop {
          position: 0.28
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.08)
        }
        GradientStop {
          position: 0.58
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.20)
        }
        GradientStop {
          position: 0.84
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.36)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
        }
      }
    }

    // Hot leading core — sharp toward the travel direction, soft behind
    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: Math.max(28, parent.width * 0.34)
      height: parent.height * 0.96
      opacity: root.gain
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
          position: 0.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
        GradientStop {
          position: 0.30
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.22)
        }
        GradientStop {
          position: 0.62
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.52)
        }
        GradientStop {
          position: 0.86
          color: Qt.rgba(1, 1, 1, 0.68)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
        }
      }
    }

    // Crisp leading hairline at the leading edge
    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: 2
      height: parent.height * 0.90
      radius: 1
      color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.78 * root.gain)
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
      duration: 2200
      easing.type: Easing.InOutSine
    }
    ScriptAction {
      script: root.direction = -1
    }
    NumberAnimation {
      from: 1
      to: 0
      duration: 2200
      easing.type: Easing.InOutSine
    }
  }
}
