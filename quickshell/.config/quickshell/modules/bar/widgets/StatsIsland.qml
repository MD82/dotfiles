pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../common/" as Common
import "../../../services/" as Services

/**
 * System stats island: CPU% · MEM GB · GPU% · GPU W
 */
IslandBase {
    id: root

    minHeight: 40
    padding: 7
    hPadding: 14
    implicitContentWidth: statsRow.implicitWidth
    implicitContentHeight: statsRow.implicitHeight

    RowLayout {
        id: statsRow
        spacing: 12

        // CPU
        RowLayout {
            spacing: 4
            Text {
                text: "󰍛"
                font.pixelSize: 13
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3outline
            }
            Text {
                text: `${Services.SystemStats.cpuUsage}%`
                font.pixelSize: Common.Appearance.font.pixelSize.small
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurface
                width: 34
            }
        }

        // Divider
        Rectangle {
            width: 1; height: 14
            color: Common.Appearance.m3colors.m3outlineVariant
            Layout.alignment: Qt.AlignVCenter
        }

        // MEM
        RowLayout {
            spacing: 4
            Text {
                text: "󰘚"
                font.pixelSize: 13
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3outline
            }
            Text {
                text: `${Services.SystemStats.memUsedGb}G`
                font.pixelSize: Common.Appearance.font.pixelSize.small
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurface
                width: 36
            }
        }

        // Divider
        Rectangle {
            width: 1; height: 14
            color: Common.Appearance.m3colors.m3outlineVariant
            Layout.alignment: Qt.AlignVCenter
        }

        // GPU usage
        RowLayout {
            spacing: 4
            Text {
                text: "󰢮"
                font.pixelSize: 13
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3outline
            }
            Text {
                text: `${Services.SystemStats.gpuUsage}%`
                font.pixelSize: Common.Appearance.font.pixelSize.small
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurface
                width: 34
            }
        }

        // Divider
        Rectangle {
            width: 1; height: 14
            color: Common.Appearance.m3colors.m3outlineVariant
            Layout.alignment: Qt.AlignVCenter
        }

        // GPU power
        RowLayout {
            spacing: 4
            Text {
                text: "󱐋"
                font.pixelSize: 13
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3outline
            }
            Text {
                text: `${Services.SystemStats.gpuPowerW}W`
                font.pixelSize: Common.Appearance.font.pixelSize.small
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3onSurface
                width: 34
            }
        }
    }
}
