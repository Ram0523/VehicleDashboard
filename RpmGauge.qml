import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: rpmGauge
    property int value: 0
    property int maxValue: 9000
    property string title: "rpm x1000"
    property bool isActive: false
    width: 400
    height: 400

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = canvas.getContext('2d')
            ctx.clearRect(0, 0, canvas.width, canvas.height)

            var centerX = canvas.width / 2
            var centerY = canvas.height / 2
            var radius = Math.min(centerX, centerY) - 20

            // Draw outer circle with a glossy, partial transparent edge (Full Circle)
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false)
            ctx.lineWidth = 15
            var gradient = ctx.createRadialGradient(centerX, centerY,
                                                    radius - 40, centerX,
                                                    centerY, radius + 10)
            gradient.addColorStop(0, 'rgba(0, 170, 255, 0.3)')
            gradient.addColorStop(1, 'rgba(255, 255, 255, 0.1)')
            ctx.strokeStyle = gradient
            ctx.stroke()

            // Draw RPM labels
            ctx.font = 'bold 14px sans-serif'
            ctx.fillStyle = '#ffffff'
            ctx.textAlign = 'center'
            ctx.textBaseline = 'middle'
            var rpmMarks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            for (var i = 0; i < rpmMarks.length; i++) {
                var angle = (Math.PI * 0.75) + (i * (Math.PI / 6))
                var x = centerX + (radius - 30) * Math.cos(angle)
                var y = centerY + (radius - 30) * Math.sin(angle)
                ctx.fillText(rpmMarks[i], x, y)
            }

            // Draw pointy needle with a rounded base
            var rpmValue = rpmGauge.value
            var needleAngle = (Math.PI * 0.75) + ((rpmValue / maxValue) * (Math.PI * 1.5))
            var needleBaseWidth = 10
            var needleLength = radius - 40
            var baseRadius = 10

            var x1 = centerX + needleBaseWidth * Math.cos(
                        needleAngle - Math.PI / 2)
            var y1 = centerY + needleBaseWidth * Math.sin(
                        needleAngle - Math.PI / 2)
            var x2 = centerX + needleBaseWidth * Math.cos(
                        needleAngle + Math.PI / 2)
            var y2 = centerY + needleBaseWidth * Math.sin(
                        needleAngle + Math.PI / 2)
            var tipX = centerX + needleLength * Math.cos(needleAngle)
            var tipY = centerY + needleLength * Math.sin(needleAngle)

            var needleGradient = ctx.createLinearGradient(centerX, centerY,
                                                          tipX, tipY)
            needleGradient.addColorStop(0, '#00aaff')
            needleGradient.addColorStop(1, '#0077cc')

            ctx.beginPath()
            ctx.moveTo(x1, y1)
            ctx.lineTo(x2, y2)
            ctx.lineTo(tipX, tipY)
            ctx.closePath()
            ctx.fillStyle = needleGradient
            ctx.fill()

            ctx.beginPath()
            ctx.arc(centerX, centerY, baseRadius, 0, 2 * Math.PI, false)
            ctx.fillStyle = '#00aaff'
            ctx.fill()

            // Draw current RPM text
            ctx.font = 'bold 20px sans-serif'
            ctx.fillStyle = '#00aaff'
            ctx.fillText((rpmValue / 1000).toFixed(1) + 'k rpm', centerX,
                         centerY + 60)
        }
    }

    Timer {
        id: rpmTimer
        interval: 50
        running: rpmGauge.isActive
        repeat: true

        onTriggered: {
            if (rpmGauge.isActive) {
                rpmGauge.value = (rpmGauge.value + 100) % (rpmGauge.maxValue + 1)
                canvas.requestPaint()
            }
        }
    }

    Timer {
        id: resetTimer
        interval: 50
        repeat: true
        running: false
        onTriggered: {
            if (rpmGauge.value > 0) {
                rpmGauge.value = Math.max(0, rpmGauge.value - 50)
                canvas.requestPaint()
            } else {
                resetTimer.stop()
            }
        }
    }

    onIsActiveChanged: {
        if (!isActive) {
            rpmTimer.stop()
            resetTimer.start()
        }
    }

    function reset() {
        rpmGauge.value = 0
        canvas.requestPaint()
    }
}
