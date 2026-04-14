pragma ComponentBehavior: Bound

import QtQuick
import "../../../common/" as Common
import "../../notifications/" as Notifs

/**
 * Notification bell icon with unread badge.
 */
Item {
    id: root
    signal toggle

    implicitWidth: 24
    implicitHeight: 24
    property bool hovered: mouseArea.containsMouse

    property int unreadCount: Notifs.NotificationService.unreadCount

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.unreadCount > 0
            ? Common.Appearance.m3colors.m3primaryContainer
            : (root.hovered
                ? Common.Appearance.m3colors.m3surfaceContainerHighest
                : "transparent")
        border.color: root.unreadCount > 0
            ? Common.Appearance.m3colors.m3primary
            : (root.hovered
                ? Common.Appearance.m3colors.m3outlineVariant
                : "transparent")
        border.width: 1

        Text {
            id: bellIcon
            anchors.centerIn: parent
            text: root.unreadCount > 0 ? "󰂚" : "󰂜"
            font.pixelSize: 15
            font.family: Common.Appearance.font.family.main
            color: root.unreadCount > 0
                ? Common.Appearance.m3colors.m3primary
                : Common.Appearance.m3colors.m3onSurfaceVariant
        }
    }

    // Unread count badge
    Rectangle {
        visible: root.unreadCount > 0
        anchors {
            top: parent.top
            right: parent.right
            topMargin: -2
            rightMargin: -2
        }
        width: 14
        height: 14
        radius: 7
        color: Common.Appearance.m3colors.m3primary

        Text {
            anchors.centerIn: parent
            text: root.unreadCount > 9 ? "9+" : root.unreadCount
            font.pixelSize: 8
            font.family: Common.Appearance.font.family.main
            color: Common.Appearance.m3colors.m3onPrimary
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggle()
        cursorShape: Qt.PointingHandCursor
    }
}
