import QtQuick

Item {
  id: root

  property bool running: false
  property color foreground: "white"
  property color track: "#24ffffff"
  property real strokeWidth: Math.max(1.5, Math.min(width, height) * 0.1)

  implicitWidth: 24
  implicitHeight: 24
  visible: running

  Accessible.name: running ? "Scan in progress" : "Scan activity"
  Accessible.role: Accessible.ProgressBar

  onForegroundChanged: ring.requestPaint()
  onTrackChanged: ring.requestPaint()
  onStrokeWidthChanged: ring.requestPaint()
  onRunningChanged: {
    if (!running) rotation = 0
    ring.requestPaint()
  }

  Canvas {
    id: ring
    anchors.fill: parent

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    onPaint: {
      var context = getContext("2d")
      var size = Math.min(width, height)
      var centerX = width / 2
      var centerY = height / 2
      var radius = Math.max(0, size / 2 - root.strokeWidth)
      var start = -Math.PI / 2

      context.clearRect(0, 0, width, height)
      context.lineWidth = root.strokeWidth
      context.lineCap = "round"

      context.beginPath()
      context.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
      context.strokeStyle = String(root.track)
      context.stroke()

      context.beginPath()
      context.arc(centerX, centerY, radius, start, start + Math.PI * 0.72, false)
      context.strokeStyle = String(root.foreground)
      context.stroke()
    }
  }

  RotationAnimation on rotation {
    from: 0
    to: 360
    duration: 820
    loops: Animation.Infinite
    running: root.running && root.visible
  }
}
