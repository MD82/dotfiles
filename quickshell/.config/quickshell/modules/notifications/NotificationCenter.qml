pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../common/" as Common

/**
 * Notification center panel — slides in from the right.
 */
Item {
    id: root
    signal closeRequested

    implicitWidth: 300
    implicitHeight: Math.min(500, headerRow.height + 12 + listView.contentHeight + 24)

    Rectangle {
        anchors.fill: parent
        radius: Common.Appearance.rounding.large
        color: Common.Appearance.m3colors.m3surface
        border.color: Common.Appearance.m3colors.m3outlineVariant
        border.width: 1
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 8

        // Header
        RowLayout {
            id: headerRow
            Layout.fillWidth: true

            Text {
                text: "알림"
                font.pixelSize: Common.Appearance.font.pixelSize.normal
                font.family: Common.Appearance.font.family.title
                font.weight: Font.Medium
                color: Common.Appearance.m3colors.m3onSurface
                Layout.fillWidth: true
            }

            // Clear all
            Text {
                text: "모두 지우기"
                font.pixelSize: Common.Appearance.font.pixelSize.smaller
                font.family: Common.Appearance.font.family.main
                color: Common.Appearance.m3colors.m3primary
                visible: NotificationService.notifications.length > 0
                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationService.clearAll()
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Close button
            Text {
                text: "✕"
                font.pixelSize: 14
                color: Common.Appearance.m3colors.m3onSurfaceVariant
                leftPadding: 8
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeRequested()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Empty state
        Text {
            visible: NotificationService.notifications.length === 0
            text: "새 알림이 없습니다 🌸"
            font.pixelSize: Common.Appearance.font.pixelSize.small
            font.family: Common.Appearance.font.family.expressive
            color: Common.Appearance.m3colors.m3outline
            Layout.alignment: Qt.AlignHCenter
            topPadding: 16
            bottomPadding: 16
        }

        // Notification list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true
            model: NotificationService.notifications

            delegate: NotificationCard {
                required property var modelData
                notification: modelData
                width: listView.width
                onDismissed: NotificationService.dismiss(modelData.id)
            }
        }
    }
}
