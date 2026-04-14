pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import "../../common/" as Common

/**
 * Toast notification popup — slides in from top-right, auto-dismiss.
 */
Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: toastWindow
        required property var modelData
        screen: modelData

        anchors { top: true; right: true }
        margins.top: 52
        margins.right: 8

        width: 320
        height: toastCol.implicitHeight + 16
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay

        // Show only the latest notification
        property var latestNotif: NotificationService.notifications.length > 0
            ? NotificationService.notifications[0]
            : null

        visible: latestNotif !== null && toastTimer.running

        Timer {
            id: toastTimer
            interval: 4000
            running: toastWindow.latestNotif !== null
            repeat: false
            onRunningChanged: {
                if (running) NotificationService.markAllRead()
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Common.Appearance.rounding.large
            color: Common.Appearance.m3colors.m3surface
            border.color: Common.Appearance.m3colors.m3outlineVariant
            border.width: 1

            RowLayout {
                id: toastCol
                anchors { fill: parent; margins: 10 }
                spacing: 8

                Image {
                    source: toastWindow.latestNotif?.appIcon
                        ? `image://icon/${toastWindow.latestNotif.appIcon}`
                        : ""
                    width: 28; height: 28
                    fillMode: Image.PreserveAspectFit
                    Layout.alignment: Qt.AlignTop
                    onStatusChanged: if (status === Image.Error) source = ""
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: toastWindow.latestNotif?.summary ?? ""
                        font.pixelSize: Common.Appearance.font.pixelSize.small
                        font.family: Common.Appearance.font.family.main
                        font.weight: Font.Medium
                        color: Common.Appearance.m3colors.m3onSurface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: toastWindow.latestNotif?.body ?? ""
                        font.pixelSize: Common.Appearance.font.pixelSize.smaller
                        font.family: Common.Appearance.font.family.main
                        color: Common.Appearance.m3colors.m3onSurfaceVariant
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }
        }

        // Progress bar (timeout indicator)
        Rectangle {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 4
            }
            height: 2
            radius: 1
            color: Common.Appearance.m3colors.m3surfaceContainerHighest

            Rectangle {
                id: progressBar
                height: parent.height
                radius: parent.radius
                color: Common.Appearance.m3colors.m3primary
                width: parent.width

                NumberAnimation on width {
                    running: toastTimer.running
                    from: toastWindow.width - 8
                    to: 0
                    duration: 4000
                }
            }
        }
    }
}
