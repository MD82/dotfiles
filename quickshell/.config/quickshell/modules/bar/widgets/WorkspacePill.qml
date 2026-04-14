pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../common/" as Common
import "../../../services/" as Services

/**
 * Single workspace pill.
 * Active: colored background + rose accent border.
 * Shows up to 3 app icons for open windows in this workspace.
 */
Item {
    id: root

    property int workspaceId: 1
    property bool active: false
    property bool hovered: mouseArea.containsMouse

    property var windowsInWs: Services.HyprlandData.windowList.filter(
        w => w.workspace.id === root.workspaceId
    )

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Rectangle {
        id: pill
        radius: Common.Appearance.rounding.full
        color: {
            if (root.active) return Common.Appearance.m3colors.m3primaryContainer
            if (root.hovered) return Common.Appearance.m3colors.m3surfaceContainerHighest
            return Common.Appearance.m3colors.m3surfaceContainerHigh
        }
        border.color: root.active
            ? Common.Appearance.m3colors.m3primary
            : Common.Appearance.m3colors.m3outlineVariant
        border.width: root.active ? 1.5 : 1

        implicitWidth: innerRow.implicitWidth + 18
        implicitHeight: 34

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
        Behavior on scale {
            NumberAnimation { duration: 120 }
        }

        scale: root.active ? 1.0 : (root.hovered ? 1.04 : 1.0)

        Rectangle {
            visible: root.active
            width: 5
            height: 5
            radius: 3
            anchors {
                left: parent.left
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }
            color: Common.Appearance.m3colors.m3primary
        }

        RowLayout {
            id: innerRow
            anchors.centerIn: parent
            spacing: 5

            // Workspace number dot / label
            Text {
                text: root.workspaceId
                font.pixelSize: 11
                font.weight: root.active ? Font.DemiBold : Font.Medium
                font.family: Common.Appearance.font.family.main
                color: root.active
                    ? Common.Appearance.m3colors.m3onPrimaryContainer
                    : Common.Appearance.m3colors.m3onSurfaceVariant
                leftPadding: root.active ? 6 : 2
            }

            // App icons (max 3)
            Repeater {
                model: Math.min(root.windowsInWs.length, 3)

                delegate: Item {
                    required property int index
                    property var win: root.windowsInWs[index]

                    width: 18
                    height: 18

                    Image {
                        anchors.fill: parent
                        source: {
                            const cls = parent.win?.class ?? ""
                            return cls ? `image://icon/${cls}` : ""
                        }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        // Fallback: show nothing on error
                        onStatusChanged: {
                            if (status === Image.Error)
                                source = ""
                        }
                    }
                }
            }

            // "+N" overflow label
            Text {
                visible: root.windowsInWs.length > 3
                text: `+${root.windowsInWs.length - 3}`
                font.pixelSize: 10
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurfaceVariant
                rightPadding: 2
            }
        }
    }

    // Click to switch workspace
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            console.log("[WorkspacePill] clicked, id:", root.workspaceId, "active:", root.active)
            if (!root.active)
                Hyprland.dispatch(`workspace ${root.workspaceId}`)
        }
        onPressed: console.log("[WorkspacePill] pressed at", mouse.x, mouse.y, "size:", width, "x", height)
        cursorShape: Qt.PointingHandCursor
    }
}
