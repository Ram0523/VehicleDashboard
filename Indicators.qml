import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: indicator

    property bool isActive: false
    property string direction: "left" // Either "left" or "right"
    property color inactiveColor: "lightgray"
    property color activeColor: "yellow"
    property int blinkInterval: 500

    width: 100
    height: 50

    Canvas {
        id: indicatorCanvas
        width: parent.width
        height: parent.height
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()

            if (indicator.direction === "left") {
                ctx.moveTo(70, 10)
                ctx.lineTo(30, 25)
                ctx.lineTo(70, 40)
            } else if (indicator.direction === "right") {
                ctx.moveTo(30, 10)
                ctx.lineTo(70, 25)
                ctx.lineTo(30, 40)
            }

            ctx.closePath()
            ctx.fillStyle = indicator.isActive ? indicator.activeColor : indicator.inactiveColor
            ctx.fill()
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggleIndicator()
        }
    }

    Timer {
        id: blinkTimer
        interval: indicator.blinkInterval
        running: false
        repeat: true
        onTriggered: {
            indicatorCanvas.visible = !indicatorCanvas.visible
        }
    }

    SequentialAnimation {
        id: animation
        running: isActive
        loops: Animation.Infinite

        OpacityAnimator {
            target: indicatorCanvas
            from: 1.0
            to: 0.5
            duration: 250
            easing.type: Easing.InOutQuad
        }

        OpacityAnimator {
            target: indicatorCanvas
            from: 0.5
            to: 1.0
            duration: 250
            easing.type: Easing.InOutQuad
        }

        ScaleAnimator {
            target: indicatorCanvas
            from: 1.0
            to: 1.2
            duration: 250
            easing.type: Easing.InOutQuad
        }

        ScaleAnimator {
            target: indicatorCanvas
            from: 1.2
            to: 1.0
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    function toggleIndicator() {
        isActive = !isActive
        if (isActive) {
            blinkTimer.start()
            animation.start()
        } else {
            deactivate()
        }
        indicatorClicked(indicator.direction)
    }

    function deactivate() {
        isActive = false
        blinkTimer.stop()
        animation.stop()
        indicatorCanvas.visible = true
    }

    signal indicatorClicked(string direction)
}
