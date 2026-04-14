pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import "../../../common/" as Common

/**
 * Right island: Volume control + Notification center toggle.
 */
IslandBase {
    id: root

    minHeight: 40
    padding: 7
    hPadding: 12
    implicitContentWidth: systemRow.implicitWidth
    implicitContentHeight: systemRow.implicitHeight

    property bool notifOpen: false
    property string inputLang: "EN"

    // fcitx5 상태 폴링 (1=영문, 2=한글)
    Process {
        id: fcitxProc
        command: ["fcitx5-remote"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim()
                root.inputLang = (v === "2") ? "KO" : "EN"
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { if (!fcitxProc.running) fcitxProc.running = true }
    }

    // Default audio sink — PwObjectTracker binds the node so it becomes ready
    property var sink: Pipewire.defaultAudioSink
    property bool sinkReady: Pipewire.ready && sink != null && sink.ready && sink.audio != null
    property var audio: sinkReady ? sink.audio : null
    property real volume: audio?.volume ?? 0
    property bool muted: audio?.muted ?? false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            console.log("[SystemIsland] defaultAudioSink changed:", Pipewire.defaultAudioSink)
        }
    }

    Connections {
        target: Pipewire.defaultAudioSink
        enabled: Pipewire.defaultAudioSink != null
        function onReadyChanged() {
            console.log("[SystemIsland] sink ready changed:", Pipewire.defaultAudioSink?.ready)
        }
    }

    RowLayout {
        id: systemRow
        spacing: 10

        // ── Volume ──────────────────────────────────────────
        RowLayout {
            spacing: 7

            // Mute/icon button
            Text {
                text: {
                    if (root.muted || root.volume === 0) return "󰝟"
                    if (root.volume < 0.33) return "󰕿"
                    if (root.volume < 0.66) return "󰖀"
                    return "󰕾"
                }
                font.pixelSize: 18
                font.family: Common.Appearance.font.family.main
                color: root.muted
                    ? Common.Appearance.m3colors.m3outline
                    : Common.Appearance.m3colors.m3onSurface

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("[SystemIsland] mute icon clicked, muted:", root.muted, "audio:", root.audio)
                        if (root.audio)
                            root.audio.muted = !root.audio.muted
                    }
                    onPressed: console.log("[SystemIsland] mute icon pressed at", mouse.x, mouse.y)
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Volume slider
            Rectangle {
                id: sliderTrack
                width: 72
                height: 5
                radius: 2
                color: Common.Appearance.m3colors.m3surfaceContainerHighest
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    width: Math.max(0, Math.min(parent.width, parent.width * root.volume))
                    height: parent.height
                    radius: parent.radius
                    color: root.muted
                        ? Common.Appearance.m3colors.m3outline
                        : Common.Appearance.m3colors.m3primary

                    Behavior on width {
                        NumberAnimation { duration: 80 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse => console.log("[SystemIsland] slider pressed at", mouse.x, mouse.y, "track width:", sliderTrack.width)
                    onClicked: mouse => {
                        const v = Math.max(0, Math.min(1, mouse.x / sliderTrack.width));
                        if (root.audio) {
                            root.audio.volume = v;
                            root.audio.muted = false;
                        }
                    }
                    onWheel: wheel => {
                        if (root.audio) {
                            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                            root.audio.volume = Math.max(0, Math.min(1, root.volume + delta));
                            root.audio.muted = false;
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Volume percentage
            Text {
                text: `${Math.round(root.volume * 100)}%`
                font.pixelSize: Common.Appearance.font.pixelSize.small
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurfaceVariant
                width: 34
            }
        }

        // Divider
        Rectangle {
            width: 1
            height: 20
            color: Common.Appearance.m3colors.m3outlineVariant
            Layout.alignment: Qt.AlignVCenter
        }

        // ── Input language ──────────────────────────────────
        Text {
            text: root.inputLang
            font.pixelSize: Common.Appearance.font.pixelSize.small
            font.family: Common.Appearance.font.family.main
            font.weight: Font.Medium
            color: root.inputLang === "KO"
                ? Common.Appearance.m3colors.m3primary
                : Common.Appearance.m3colors.m3onSurfaceVariant
        }

        // Divider
        Rectangle {
            width: 1
            height: 20
            color: Common.Appearance.m3colors.m3outlineVariant
            Layout.alignment: Qt.AlignVCenter
        }

        // ── Notification bell ───────────────────────────────
        NotifBell {
            onToggle: root.notifOpen = !root.notifOpen
        }
    }

}
