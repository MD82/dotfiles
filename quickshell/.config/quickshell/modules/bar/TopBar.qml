pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import "../../common/" as Common
import "../../services/" as Services
import "./widgets/"

/**
 * Top bar — Islands style, Rosé Pine Dawn
 * Layout: [Workspaces] ··· [Clock] ··· [Volume · Notifications · Tray]
 */
Scope {
    id: root

    IpcHandler {
        target: "topbar"

        function toggle(): void {
            Services.GlobalStates.topBarExpanded = !Services.GlobalStates.topBarExpanded;
        }

        function open(): void {
            Services.GlobalStates.topBarExpanded = true;
        }

        function close(): void {
            Services.GlobalStates.topBarExpanded = false;
        }
    }

    // Wrap both PanelWindows in a Scope so they share the same modelData
    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData
            readonly property bool expanded: Services.GlobalStates.topBarExpanded
            readonly property int miniBarHeight: 8
            readonly property int miniDotSize: 3
            readonly property int miniDotGap: 5
            readonly property int barHeight: 48
            readonly property int currentBarHeight: expanded ? barHeight : miniBarHeight

            PanelWindow {
                id: bar
                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                height: currentBarHeight
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.exclusiveZone: height

                Behavior on height {
                    NumberAnimation {
                        duration: Common.Config.options.appearance.animation.duration.elementMoveFast
                        easing.type: Easing.OutCubic
                    }
                }

                Item {
                    anchors.fill: parent

                    Row {
                        id: miniDots
                        visible: !expanded
                        anchors.centerIn: parent
                        spacing: miniDotGap

                        Repeater {
                            model: 3

                            Rectangle {
                                required property int index
                                width: miniDotSize
                                height: miniDotSize
                                radius: width / 2
                                color: index === 1
                                    ? Common.Appearance.m3colors.m3primary
                                    : Common.Appearance.m3colors.m3outlineVariant
                                opacity: index === 1 ? 0.95 : 0.55
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !expanded
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.GlobalStates.topBarExpanded = true
                    }

                    Item {
                        visible: expanded
                        anchors.fill: parent

                        // Left island: Workspaces
                        WorkspaceIsland {
                            id: leftIsland
                            anchors {
                                left: parent.left
                                leftMargin: 12
                                verticalCenter: parent.verticalCenter
                            }
                            screen: bar.screen
                        }

                        // Center group: clock/stats
                        Item {
                            anchors {
                                left: leftIsland.right
                                leftMargin: 12
                                right: rightIsland.left
                                rightMargin: 12
                                verticalCenter: parent.verticalCenter
                            }
                            height: 40

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                ClockIsland {
                                    id: centerIsland
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StatsIsland {
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Right island: Volume + Notifications
                        SystemIsland {
                            id: rightIsland
                            anchors {
                                right: parent.right
                                rightMargin: 12
                                verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
