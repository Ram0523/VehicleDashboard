import QtQuick
import QtMultimedia
import Qt.labs.folderlistmodel

Item {
    id: root

    property string musicFolderPath: ""
    property string currentMusicFile: ""
    property bool isPlaying: false

    signal musicChanged(string musicFile)

    width: 300
    height: 80

    Rectangle {
        id: playerRect
        anchors.fill: parent
        color: "transparent"
        border.color: "blue"
        border.width: 2
        radius: 10

        property int currentTrackIndex: -1

        FolderListModel {
            id: folderModel
            folder: root.musicFolderPath
            nameFilters: ["*.mp3"]
            showDirs: false
            onStatusChanged: {
                if (status === FolderListModel.Ready) {
                    console.log("FolderListModel ready")
                    console.log("Folder path:", folder)
                    console.log("Number of files:", count)
                    for (var i = 0; i < count; i++) {
                        console.log("File", i, ":", get(i, "fileName"))
                    }
                    if (count > 0) {
                        playerRect.currentTrackIndex = 0
                        loadCurrentTrack()
                    } else {
                        console.log("No music files found in folder")
                    }
                }
            }
        }

        MediaPlayer {
            id: mediaPlayer
            audioOutput: AudioOutput {}
            onSourceChanged: {
                console.log("MediaPlayer source set to:", source)
            }
            onErrorOccurred: (error, errorString) => {
                console.log("MediaPlayer error:", errorString)
            }
            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.PlayingState) {
                    root.currentMusicFile = folderModel.get(playerRect.currentTrackIndex, "fileName")
                    root.musicChanged(root.currentMusicFile)
                    root.isPlaying = true
                } else if (playbackState === MediaPlayer.PausedState) {
                    root.isPlaying = false
                }
                controlsCanvas.requestPaint()
            }
        }

        Text {
            id: displayText
            text: root.isPlaying ? root.currentMusicFile : "Music Player"
            font.pixelSize: 18
            color: "blue"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            width: parent.width - 20
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Canvas {
            id: controlsCanvas
            width: parent.width
            height: 50
            anchors.bottom: parent.bottom
            onPaint: {
                var ctx = controlsCanvas.getContext("2d")
                ctx.clearRect(0, 0, controlsCanvas.width, controlsCanvas.height)
                var centerX = controlsCanvas.width / 2
                var iconSize = 20

                // Draw Play/Pause icon
                if (root.isPlaying) {
                    // Draw Pause icon
                    ctx.beginPath()
                    ctx.rect(centerX - 15, 10, 5, 20)
                    ctx.rect(centerX - 5, 10, 5, 20)
                    ctx.fillStyle = "red"
                    ctx.fill()
                } else {
                    // Draw Play icon
                    ctx.beginPath()
                    ctx.moveTo(centerX - 10, 10)
                    ctx.lineTo(centerX + 10, 20)
                    ctx.lineTo(centerX - 10, 30)
                    ctx.closePath()
                    ctx.fillStyle = "green"
                    ctx.fill()
                }

                // Draw Next icon
                ctx.beginPath()
                ctx.moveTo(centerX + 40, 10)
                ctx.lineTo(centerX + 50, 20)
                ctx.lineTo(centerX + 40, 30)
                ctx.closePath()
                ctx.fillStyle = "blue"
                ctx.fill()

                // Draw Previous icon
                ctx.beginPath()
                ctx.moveTo(centerX - 55, 10)
                ctx.lineTo(centerX - 65, 20)
                ctx.lineTo(centerX - 55, 30)
                ctx.closePath()
                ctx.fillStyle = "blue"
                ctx.fill()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {
                    console.log("Control clicked at x:", mouse.x)
                    var centerX = controlsCanvas.width / 2
                    if (mouse.x < centerX - 20) {
                        previousTrack()
                    } else if (mouse.x > centerX - 20 && mouse.x < centerX + 20) {
                        togglePlayPause()
                    } else {
                        nextTrack()
                    }
                }
            }
        }
    }

    function loadCurrentTrack() {
        if (folderModel.count > 0 && playerRect.currentTrackIndex >= 0) {
            console.log("Loading track at index:", playerRect.currentTrackIndex)
            mediaPlayer.source = folderModel.get(playerRect.currentTrackIndex, "fileUrl")
            root.currentMusicFile = folderModel.get(playerRect.currentTrackIndex, "fileName")
        } else {
            console.log("No music to load or invalid index")
        }
    }

    function togglePlayPause() {
        if (root.isPlaying) {
            pauseMusic()
        } else {
            playMusic()
        }
    }

    function playMusic() {
        console.log("playMusic called")
        if (folderModel.count > 0 && playerRect.currentTrackIndex >= 0) {
            mediaPlayer.play()
        } else {
            console.log("No music to play or invalid index")
        }
    }

    function pauseMusic() {
        console.log("pauseMusic called")
        mediaPlayer.pause()
    }

    function nextTrack() {
        console.log("nextTrack called")
        if (playerRect.currentTrackIndex < folderModel.count - 1) {
            playerRect.currentTrackIndex++
            loadCurrentTrack()
            if (root.isPlaying) {
                playMusic()
            }
        }
    }

    function previousTrack() {
        console.log("previousTrack called")
        if (playerRect.currentTrackIndex > 0) {
            playerRect.currentTrackIndex--
            loadCurrentTrack()
            if (root.isPlaying) {
                playMusic()
            }
        }
    }
}
