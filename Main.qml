import QtQuick
import QtQuick.Controls
import MqttConnect 1.0

Window {
    width: 1280
    height: 720
    visible: true
    title: qsTr("Car Dashboard")

    property string currentTimeString: ""
    // property bool engineStarted: false
    property bool isDashboardActive: false

    function setIsDashboardActive(state) {
        isDashboardActive = state
        console.log("Dashboard active state updated to:", state)
    }

    function getCurrentTime() {
        var date = new Date()
        var hours = date.getHours()
        var minutes = date.getMinutes()
        var seconds = date.getSeconds()
        var ampm = hours >= 12 ? 'PM' : 'AM'
        hours = hours % 12
        hours = hours ? hours : 12 // the hour '0' should be '12'
        currentTimeString = "-9°C               " + hours.toString(
                    ).padStart(2, '0') + ":" + minutes.toString().padStart(
                    2, '0') + ":" + seconds.toString(
                    ).padStart(2, '0') + " " + ampm
    }

    Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: getCurrentTime()
    }

    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a" // Darker background color
        // color: "grey"

        // Top bar with temperature and time
        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            height: 40

            Text {
                id: timeDisplay
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 18
                text: currentTimeString
            }
        }

        // Speedometer
        Item {
            width: 400
            height: 400
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter

            Speedometer {
                id: speedometer
                value: 0
                maxValue: 270
                title: "km/h"
                // running: engineStarted
                isActive: isDashboardActive
            }

            Text {
                text: "482 km"
                color: "#00bfff" // Blue color for fuel range
                font.pixelSize: 18
                anchors.bottom: speedometer.bottom
                anchors.horizontalCenter: speedometer.horizontalCenter
                anchors.bottomMargin: 30
            }

            // Left Indicator
            Indicators {
                id: leftIndicator
                direction: "left"
                anchors.horizontalCenter: speedometer.horizontalCenter
                anchors.top: speedometer.bottom
                anchors.topMargin: 20
                onIndicatorClicked: {
                    if (rightIndicator.isActive) {
                        rightIndicator.deactivate()
                    }
                }
            }
        }

        // RPM Gauge
        Item {
            width: 400
            height: 400
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter

            RpmGauge {
                id: rpmGauge
                value: 0
                maxValue: 9000
                title: "rpm x1000"
                // isActive: engineStarted
                isActive: isDashboardActive
            }

            Text {
                text: "84°C"
                color: "#00bfff" // Blue color for temperature
                font.pixelSize: 18
                anchors.bottom: rpmGauge.bottom
                anchors.horizontalCenter: rpmGauge.horizontalCenter
                anchors.bottomMargin: 30
            }

            // Right Indicator
            Indicators {
                id: rightIndicator
                direction: "right"
                anchors.horizontalCenter: rpmGauge.horizontalCenter
                anchors.top: rpmGauge.bottom
                anchors.topMargin: 20
                onIndicatorClicked: {
                    if (leftIndicator.isActive) {
                        leftIndicator.deactivate()
                    }
                }
            }
        }

        // Middle section
        Item {
            width: 400
            height: 500
            anchors.centerIn: parent
            Canvas {
                id: canvas
                anchors.fill: parent
                onPaint: {
                    var ctx = canvas.getContext("2d")
                    ctx.clearRect(0, 0, canvas.width, canvas.height)

                    var centerX = canvas.width / 2
                    var longSegmentLength = 300 // Horizontal segment length
                    var angledSegmentLength = 40 // Shorter angled segments
                    var segments = 20 // More segments for smoother tapering and fading

                    // Calculate x-coordinates for the horizontal segment
                    var x1 = centerX - longSegmentLength / 2
                    var x2 = centerX + longSegmentLength / 2

                    var angleRadians = 125 * Math.PI / 180 // 125-degree angle in radiansr
                    var offsetX = angledSegmentLength * Math.cos(angleRadians)
                    var offsetY = angledSegmentLength * Math.sin(angleRadians)

                    // Top Shape: U-shape (open upward)
                    var yTop = 170 // Position for the top U-shape

                    // U-shape at the top (horizontal part)
                    ctx.beginPath()
                    ctx.moveTo(x1, yTop) // Left end
                    ctx.lineTo(x2, yTop) // Horizontal part of the U
                    ctx.strokeStyle = "rgb(228, 229, 231)"
                    ctx.lineWidth = 5
                    ctx.stroke()

                    // Function to draw tapering and fading lines
                    function drawTaperingLine(xStart, yStart, xEnd, yEnd, maxLineWidth, minLineWidth, startOpacity, endOpacity) {
                        var deltaX = (xEnd - xStart) / segments
                        var deltaY = (yEnd - yStart) / segments
                        var deltaLineWidth = (maxLineWidth - minLineWidth) / segments
                        var deltaOpacity = (startOpacity - endOpacity) / segments

                        for (var i = 0; i < segments; i++) {
                            ctx.beginPath()
                            ctx.moveTo(xStart + i * deltaX, yStart + i * deltaY)
                            ctx.lineTo(xStart + (i + 1) * deltaX,
                                       yStart + (i + 1) * deltaY)

                            ctx.lineWidth = maxLineWidth - i * deltaLineWidth
                            var opacity = startOpacity - i * deltaOpacity
                            ctx.strokeStyle = "rgba(228, 229, 231," + opacity + ")"
                            ctx.stroke()
                        }
                    }

                    // U-shape angled segments (thinning and fading)
                    drawTaperingLine(x1, yTop, x1 + offsetX, yTop - offsetY, 5,
                                     0.5, 1, 0) // Left angled segment
                    drawTaperingLine(x2, yTop, x2 - offsetX, yTop - offsetY, 5,
                                     0.5, 1, 0) // Right angled segment

                    // Bottom Shape: N-shape (open downward)
                    var yBottom = 330 // Position for the bottom N-shape

                    // N-shape at the bottom (horizontal part)
                    ctx.beginPath()
                    ctx.moveTo(x1, yBottom) // Left end
                    ctx.lineTo(x2, yBottom) // Horizontal part of the N
                    ctx.strokeStyle = "rgb(228, 229, 231)"
                    ctx.lineWidth = 5
                    ctx.stroke()

                    // N-shape angled segments (thinning and fading)
                    drawTaperingLine(x1, yBottom, x1 + offsetX,
                                     yBottom + offsetY, 5, 0.5, 1,
                                     0) // Left angled segment
                    drawTaperingLine(x2, yBottom, x2 - offsetX,
                                     yBottom + offsetY, 5, 0.5, 1,
                                     0) // Right angled segment
                }
            }

            // Start/Stop Button
            Rectangle {
                id: startButton
                width: 150
                height: 150
                radius: 75
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: isDashboardActive ? "red" : "blue"
                    }
                    GradientStop {
                        position: 1.0
                        color: isDashboardActive ? "darkred" : "lightblue"
                    }
                }

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                border.color: "lightgray"
                border.width: 2

                Text {
                    text: isDashboardActive ? "Stop" : "Start"
                    font.pixelSize: 16
                    anchors.centerIn: parent
                    color: "white"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        isDashboardActive = !isDashboardActive
                        mqttClient.publish("Controls",
                                           isDashboardActive ? "Start" : "Stop")
                        console.log(isDashboardActive ? "Dashboard started" : "Dashboard stopped")
                    }

                    // Hover effect
                    onEntered: startButton.border.color
                               = isDashboardActive ? "darkgreen" : "darkblue"
                    onExited: startButton.border.color = "lightgray"
                }
            }

            // Music Player inside the N shape
            MusicPlayer {
                id: musicPlayer
                width: parent.width * 0.7
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 80
                musicFolderPath: "file:///E:/SONGS/" // Make sure this path is correct
                onMusicChanged: {
                    console.log("Now playing:", musicFile)
                }
            }
        }
    }

    MqttConnect {
        id: mqttClient
        onMessageReceived: {
            if (message === "Start") {
                setIsDashboardActive(true)
            } else if (message === "Stop") {
                setIsDashboardActive(false)
            }
        }
    }

    Component.onCompleted: {
        getCurrentTime() // Set initial time
        mqttClient.connectToHost(
                    "8a32bd31bcd34ae888901f8f7608c539.s1.eu.hivemq.cloud",
                    8883, "Ram123", "Ram123456", "Controls")
    }
}
