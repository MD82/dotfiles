pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../common/" as Common

/**
 * Airy calendar popup — Rosé Pine Dawn styled.
 */
Item {
    id: root
    signal closeRequested

    implicitWidth: 260
    implicitHeight: col.implicitHeight + 20

    property int displayYear: new Date().getFullYear()
    property int displayMonth: new Date().getMonth()  // 0-indexed

    property var today: new Date()

    // Background card
    Rectangle {
        anchors.fill: parent
        radius: Common.Appearance.rounding.large
        color: Common.Appearance.m3colors.m3surface
        border.color: Common.Appearance.m3colors.m3outlineVariant
        border.width: 1
        layer.enabled: true
        layer.effect: null
    }

    ColumnLayout {
        id: col
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        spacing: 6

        // ── Header: prev / month+year / next ──────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "‹"
                font.pixelSize: 18
                color: Common.Appearance.m3colors.m3onSurfaceVariant
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.displayMonth === 0) {
                            root.displayMonth = 11;
                            root.displayYear -= 1;
                        } else {
                            root.displayMonth -= 1;
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: `${root.displayYear}년 ${root.displayMonth + 1}월`
                font.pixelSize: Common.Appearance.font.pixelSize.normal
                font.family: Common.Appearance.font.family.expressive
                font.weight: Font.Medium
                color: Common.Appearance.m3colors.m3onSurface
            }

            Text {
                text: "›"
                font.pixelSize: 18
                color: Common.Appearance.m3colors.m3onSurfaceVariant
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.displayMonth === 11) {
                            root.displayMonth = 0;
                            root.displayYear += 1;
                        } else {
                            root.displayMonth += 1;
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // ── Day-of-week headers ───────────────────────────
        Grid {
            columns: 7
            Layout.fillWidth: true
            spacing: 2

            Repeater {
                model: ["일", "월", "화", "수", "목", "금", "토"]
                delegate: Text {
                    required property string modelData
                    required property int index
                    width: 32
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.pixelSize: 10
                    font.family: Common.Appearance.font.family.main
                    color: index === 0
                        ? Common.Appearance.m3colors.m3love ?? Common.Appearance.m3colors.m3primary
                        : Common.Appearance.m3colors.m3outline
                }
            }
        }

        // ── Calendar day cells ────────────────────────────
        Grid {
            id: calGrid
            columns: 7
            Layout.fillWidth: true
            spacing: 2

            property int firstDayOfWeek: new Date(root.displayYear, root.displayMonth, 1).getDay()
            property int daysInMonth: new Date(root.displayYear, root.displayMonth + 1, 0).getDate()
            property int totalCells: firstDayOfWeek + daysInMonth

            Repeater {
                model: Math.ceil(calGrid.totalCells / 7) * 7

                delegate: Item {
                    required property int index
                    width: 32
                    height: 28

                    property int dayNum: index - calGrid.firstDayOfWeek + 1
                    property bool isValid: dayNum >= 1 && dayNum <= calGrid.daysInMonth
                    property bool isToday: isValid
                        && dayNum === root.today.getDate()
                        && root.displayMonth === root.today.getMonth()
                        && root.displayYear === root.today.getFullYear()
                    property bool isSunday: (index % 7) === 0

                    Rectangle {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: Common.Appearance.rounding.full
                        color: isToday
                            ? Common.Appearance.m3colors.m3primaryContainer
                            : "transparent"
                        visible: parent.isValid
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.isValid ? parent.dayNum : ""
                        font.pixelSize: 11
                        font.family: Common.Appearance.font.family.main
                        font.weight: parent.isToday ? Font.Bold : Font.Normal
                        color: {
                            if (!parent.isValid) return "transparent"
                            if (parent.isToday) return Common.Appearance.m3colors.m3onPrimaryContainer
                            if (parent.isSunday) return Common.Appearance.m3colors.m3primary
                            return Common.Appearance.m3colors.m3onSurface
                        }
                    }
                }
            }
        }

        // ── Close hint ───────────────────────────────────
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "오늘: " + Qt.formatDate(root.today, "yyyy년 M월 d일")
            font.pixelSize: 10
            font.family: Common.Appearance.font.family.expressive
            color: Common.Appearance.m3colors.m3outline
            bottomPadding: 2
        }
    }

    // Close on outside click
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: mouse => mouse.accepted = false
    }
}
