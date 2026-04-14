pragma ComponentBehavior: Bound

import QtQuick
import "../../../common/" as Common

/**
 * Reusable island background: rounded pill, Rosé Pine Dawn surface color.
 * Set implicitContentWidth / implicitContentHeight from the child component.
 */
Item {
    id: root

    default property alias content: contentItem.data
    property int padding: 8
    property int hPadding: 12
    property int minHeight: 38
    property real implicitContentWidth: 0
    property real implicitContentHeight: 0

    implicitWidth: implicitContentWidth + hPadding * 2
    implicitHeight: Math.max(minHeight, implicitContentHeight + padding * 2)

    // Background pill
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Common.Appearance.rounding.full
        color: Common.Appearance.m3colors.m3surface
        border.color: Common.Appearance.m3colors.m3outlineVariant
        border.width: 1
    }

    // Content slot
    Item {
        id: contentItem
        anchors {
            fill: parent
            leftMargin: root.hPadding
            rightMargin: root.hPadding
            topMargin: root.padding
            bottomMargin: root.padding
        }
    }
}
