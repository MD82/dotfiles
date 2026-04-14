pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../common/" as Common

/**
 * Single notification card inside the center panel.
 */
Item {
    id: root
    required property var notification
    signal dismissed

    implicitHeight: card.implicitHeight
    implicitWidth: card.implicitWidth

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Common.Appearance.rounding.normal
        color: Common.Appearance.m3colors.m3surfaceContainerLow
        border.color: Common.Appearance.m3colors.m3outlineVariant
        border.width: 1

        implicitHeight: cardRow.implicitHeight + 16

        RowLayout {
            id: cardRow
            anchors {
                fill: parent
                margins: 10
            }
            spacing: 8

            // App icon
            Image {
                source: root.notification?.appIcon
                    ? `image://icon/${root.notification.appIcon}`
                    : ""
                width: 28
                height: 28
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignTop
                onStatusChanged: {
                    if (status === Image.Error) source = ""
                }
            }

            // Text area
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.notification?.summary ?? ""
                        font.pixelSize: Common.Appearance.font.pixelSize.small
                        font.family: Common.Appearance.font.family.main
                        font.weight: Font.Medium
                        color: Common.Appearance.m3colors.m3onSurface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.notification?.appName ?? ""
                        font.pixelSize: 10
                        font.family: Common.Appearance.font.family.main
                        color: Common.Appearance.m3colors.m3outline
                    }
                }

                Text {
                    text: root.notification?.body ?? ""
                    font.pixelSize: Common.Appearance.font.pixelSize.smaller
                    font.family: Common.Appearance.font.family.main
                    color: Common.Appearance.m3colors.m3onSurfaceVariant
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            // Dismiss button
            Text {
                text: "✕"
                font.pixelSize: 11
                color: Common.Appearance.m3colors.m3outline
                Layout.alignment: Qt.AlignTop
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.dismissed()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
