pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../../common/" as Common
import "../../../services/" as Services

Item {
    id: root
    required property var screen
    property bool hovered: mouseArea.containsMouse

    property var monitorData: {
        const monitors = Services.HyprlandData.monitors;
        for (let i = 0; i < monitors.length; i++) {
            if (root.screen !== null && monitors[i].name === root.screen.name)
                return monitors[i];
        }
        return null;
    }
    property var minimizedWindows: Services.HyprlandData.windowList.filter(w => {
        const name = w?.workspace?.name ?? "";
        const minimized = name === "special:minimized" || name === "minimized" || name.indexOf("minimized") !== -1;
        return minimized && root.monitorData !== null && w?.monitor === root.monitorData.id;
    })
    property int activeWorkspaceId: root.monitorData?.activeWorkspace?.id ?? Services.HyprlandData.activeWorkspace?.id ?? 1

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Process {
        id: restorePicker
        command: ["sh", "-lc", `bash ~/.config/hypr/scripts/minimized-restore-picker ${root.activeWorkspaceId} ${root.monitorData?.id ?? ""}`]
        onRunningChanged: {
            if (!running) {
                Services.HyprlandData.updateWindowList();
                Services.HyprlandData.updateWorkspaces();
            }
        }
    }

    function showRestorePicker() {
        if (root.minimizedWindows.length === 0 || restorePicker.running)
            return;

        restorePicker.running = true;
    }

    Rectangle {
        id: pill
        radius: Common.Appearance.rounding.full
        color: root.hovered
            ? Common.Appearance.m3colors.m3surfaceContainerHighest
            : Common.Appearance.m3colors.m3surfaceContainerHigh
        border.color: root.minimizedWindows.length > 0
            ? Common.Appearance.m3colors.m3secondary
            : Common.Appearance.m3colors.m3outlineVariant
        border.width: root.minimizedWindows.length > 0 ? 1.5 : 1

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

        scale: root.hovered ? 1.04 : 1.0

        RowLayout {
            id: innerRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: "M"
                font.pixelSize: 11
                font.family: Common.Appearance.font.family.main
                font.weight: Font.DemiBold
                color: root.minimizedWindows.length > 0
                    ? Common.Appearance.m3colors.m3secondary
                    : Common.Appearance.m3colors.m3onSurfaceVariant
                leftPadding: 2
            }

            Repeater {
                model: Math.min(root.minimizedWindows.length, 3)

                delegate: Item {
                    required property int index
                    property var win: root.minimizedWindows[index]

                    width: 18
                    height: 18

                    Image {
                        id: appIcon
                        anchors.fill: parent
                        source: {
                            const cls = parent.win?.class ?? "";
                            return cls ? `image://icon/${cls}` : "";
                        }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        onStatusChanged: {
                            if (status === Image.Error)
                                source = "";
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: appIcon.source === ""
                        text: (parent.win?.class ?? "?").slice(0, 1).toUpperCase()
                        font.pixelSize: 10
                        font.family: Common.Appearance.font.family.main
                        font.weight: Font.DemiBold
                        color: Common.Appearance.m3colors.m3onSurfaceVariant
                    }
                }
            }

            Text {
                visible: root.minimizedWindows.length > 3
                text: `+${root.minimizedWindows.length - 3}`
                font.pixelSize: 10
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurfaceVariant
                rightPadding: 2
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.minimizedWindows.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.minimizedWindows.length > 0)
                root.showRestorePicker();
        }
    }

}
