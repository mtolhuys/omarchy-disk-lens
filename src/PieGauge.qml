import QtQuick

Item {
  id: root

  property real value: 0
  property bool available: true
  property color fillColor: "white"
  property color trackColor: "#3fffffff"
  property color outlineColor: "#8fffffff"

  implicitWidth: 18
  implicitHeight: 18

  onValueChanged: gauge.requestPaint()
  onAvailableChanged: gauge.requestPaint()
  onFillColorChanged: gauge.requestPaint()
  onTrackColorChanged: gauge.requestPaint()
  onOutlineColorChanged: gauge.requestPaint()

  Canvas {
    id: gauge
    anchors.fill: parent

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    onPaint: {
      var context = getContext("2d")
      var size = Math.min(width, height)
      var lineWidth = Math.max(1, size * 0.075)
      var radius = Math.max(0, size / 2 - lineWidth)
      var centerX = width / 2
      var centerY = height / 2
      var start = -Math.PI / 2
      var percent = Math.max(0, Math.min(100, Number(root.value || 0)))

      context.clearRect(0, 0, width, height)
      context.beginPath()
      context.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
      context.fillStyle = String(root.trackColor)
      context.fill()

      if (root.available && percent > 0) {
        context.beginPath()
        context.moveTo(centerX, centerY)
        context.arc(centerX, centerY, radius, start, start + Math.PI * 2 * percent / 100, false)
        context.closePath()
        context.fillStyle = String(root.fillColor)
        context.fill()
      }

      context.beginPath()
      context.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
      context.lineWidth = lineWidth
      context.strokeStyle = String(root.outlineColor)
      context.stroke()
    }
  }
}
