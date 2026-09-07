import QtQuick

// One vertical scanner stripe — GPU-animated x (no Canvas, no layered FBO).
// Host is fully transparent; only stacked horizontal accent gradients paint.
Item {
  id: root

  property bool running: false
  property color accent: "#f5a524"
  property color track: "#24ffffff" // call-site compat; unused (no pane wash)
  property real intensity: 1.0
  // 0 = off the left edge, 1 = off the right edge
  property real sweep: 0

  readonly property real gain: Math.max(0.18, Math.min(1.25, intensity))
  readonly property real beamWidth: {
    if (width < 2)
      return 56
    return Math.max(48, Math.min(92, width * 0.17))
  }

  implicitWidth: 240
  implicitHeight: 160
  visible: running
  clip: true

  Accessible.name: running ? "Scan beam active" : "Scan beam"
  Accessible.role: Accessible.ProgressBar

  onRunningChanged: {
    if (!running)
      sweep = 0
  }

  // Moving beam traveler — x transform only
  Item {
    id: beam
    width: root.beamWidth
    height: parent.height
    x: -width + root.sweep * (parent.width + width)

    // Outermost faint bloom
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 2.4
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
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.05)
        }
        GradientStop {
          position: 0.5
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.11)
        }
        GradientStop {
          position: 0.72
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.05)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
      }
    }

    // Mid bloom
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 1.45
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
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.10)
        }
        GradientStop {
          position: 0.5
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.24)
        }
        GradientStop {
          position: 0.78
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.10)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
      }
    }

    // Main beam body
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      height: parent.height
      opacity: root.gain
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
          position: 0.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
        GradientStop {
          position: 0.16
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
        }
        GradientStop {
          position: 0.5
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.42)
        }
        GradientStop {
          position: 0.84
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
      }
    }

    // Hot core
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      width: Math.max(14, parent.width * 0.32)
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
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.40)
        }
        GradientStop {
          position: 0.5
          color: Qt.rgba(1, 1, 1, 0.62)
        }
        GradientStop {
          position: 0.70
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.46)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0)
        }
      }
    }

    // Leading hairline
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      width: 2
      height: parent.height * 0.90
      radius: 1
      color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.62 * root.gain)
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
