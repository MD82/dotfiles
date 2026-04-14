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

/**
 * Bottom bar — center island with Overview trigger button.
 */
Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        anchors {
            bottom: true
            left: true
            right: true
        }

        height: 56
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: height

        Item {
            anchors.fill: parent
        }
    }
}
