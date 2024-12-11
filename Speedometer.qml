import QtQuick
import QtQuick.Controls

Item {
    id: speedometer
    property int value: 0
    property int maxValue: 270
    property string title: "km/h"
    // property bool running: false
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
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI,
                    false) // Draw a full circle
            ctx.lineWidth = 15
            var gradient = ctx.createRadialGradient(centerX, centerY,
                                                    radius - 40, centerX,
                                                    centerY, radius + 10)
            gradient.addColorStop(
                        0, 'rgba(0, 170, 255, 0.3)') // Semi-transparent blue
            gradient.addColorStop(
                        1, 'rgba(255, 255, 255, 0.1)') // Slight gloss effect
            ctx.strokeStyle = gradient
            ctx.stroke()

            // Draw speed labels
            ctx.font = 'bold 14px sans-serif'
            ctx.fillStyle = '#ffffff'
            ctx.textAlign = 'center'
            ctx.textBaseline = 'middle'
            var speedMarks = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270]
            for (var i = 0; i < speedMarks.length; i++) {
                var angle = (Math.PI * 0.75) + (i * (Math.PI / 6))
                var x = centerX + (radius - 30) * Math.cos(angle)
                var y = centerY + (radius - 30) * Math.sin(angle)
                ctx.fillText(speedMarks[i], x, y)
            }

            // Draw pointy needle with a rounded base
            var speed = speedometer.value
            var needleAngle = (Math.PI * 0.75) + ((speed / 270) * (Math.PI * 1.5))

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

            // Draw current speed text
            ctx.font = 'bold 20px sans-serif'
            ctx.fillStyle = '#00aaff'
            ctx.fillText(speed + ' km/h', centerX, centerY + 60)
        }
    }

    Timer {
        id: speedTimer
        interval: 50
        running: speedometer.isActive
        repeat: true
        // onTriggered: {
        //     speedometer.value = (speedometer.value + 1) % (speedometer.maxValue + 1)
        //     canvas.requestPaint()
        // }
        onTriggered: {
            if (speedometer.isActive) {
                speedometer.value = (speedometer.value + 1) % (speedometer.maxValue + 1)
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
            if (speedometer.value > 0) {
                speedometer.value = Math.max(0, speedometer.value - 2)
                canvas.requestPaint()
            } else {
                resetTimer.stop()
            }
        }
    }

    onIsActiveChanged: {
        if (!isActive) {
            speedTimer.stop()
            resetTimer.start()
        }
    }

    function reset() {
        speedometer.value = 0
        canvas.requestPaint()
    }
}
