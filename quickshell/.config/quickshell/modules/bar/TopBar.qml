pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import "../../common/" as Common
import "../../services/" as Services
import "./widgets/"
import "../notifications/"

/**
 * Top bar — Islands style, Rosé Pine Dawn
 * Layout: [Workspaces] ··· [Clock] ··· [Volume · Notifications · Tray]
 */
Variants {
    id: root
    model: Quickshell.screens

    // Wrap both PanelWindows in a Scope so they share the same modelData
    Scope {
        required property var modelData
        readonly property int barHeight: 48

        PanelWindow {
            id: bar
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            height: barHeight
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: height

            // ── Row holding three islands ──────────────────────────────────
            Item {
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onPressed: mouse => {
                        console.log("[TopBar] RAW press at", mouse.x, mouse.y, "bar size:", parent.width, "x", parent.height)
                        mouse.accepted = false
                    }
                }

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

                // Center group: normal clock/stats or development context
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
                        visible: !Common.Config.options.bar.devMode
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

                    RowLayout {
                        visible: Common.Config.options.bar.devMode
                        anchors.fill: parent
                        spacing: 8

                        DevContextIsland {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 720
                            Layout.alignment: Qt.AlignVCenter
                        }

                        StatsIsland {
                            Layout.alignment: Qt.AlignVCenter
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

        // Notification center — separate PanelWindow so it can extend below the bar
        PanelWindow {
            id: notifPanel
            screen: bar.screen
            visible: rightIsland.notifOpen

            anchors { top: true; right: true }
            margins.top: barHeight + 6
            margins.right: 12

            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay

            implicitWidth: notifCenter.implicitWidth
            implicitHeight: notifCenter.implicitHeight

            NotificationCenter {
                id: notifCenter
                onCloseRequested: rightIsland.notifOpen = false
            }
        }
    }
}
