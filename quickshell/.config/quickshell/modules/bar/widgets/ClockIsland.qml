pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../common/" as Common
import "../../calendar/"

/**
 * Center island: time + date. Click opens calendar popup.
 */
IslandBase {
    id: root

    minHeight: 40
    padding: 7
    hPadding: 18
    implicitContentWidth: clockRow.implicitWidth
    implicitContentHeight: clockRow.implicitHeight

    property bool calendarOpen: false

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    RowLayout {
        id: clockRow
        spacing: 10

        // Time
        Text {
            id: timeText
            text: Qt.formatTime(clock.date, "hh:mm")
            font.pixelSize: Common.Appearance.font.pixelSize.larger
            font.family: Common.Appearance.font.family.main
            font.weight: Font.Medium
            color: Common.Appearance.m3colors.m3onSurface
        }

        // Separator dot
        Rectangle {
            width: 3
            height: 3
            radius: 2
            color: Common.Appearance.m3colors.m3outline
            Layout.alignment: Qt.AlignVCenter
        }

        // Date
        Text {
            id: dateText
            text: Qt.formatDate(clock.date, "M월 d일 (ddd)")
            font.pixelSize: Common.Appearance.font.pixelSize.normal
            font.family: Common.Appearance.font.family.expressive
            color: Common.Appearance.m3colors.m3onSurfaceVariant
        }
    }

    // Click area to toggle calendar
    MouseArea {
        parent: root
        anchors.fill: parent
        onClicked: {
            console.log("[ClockIsland] clicked, calendarOpen:", !root.calendarOpen)
            root.calendarOpen = !root.calendarOpen
        }
        onPressed: console.log("[ClockIsland] pressed at", mouse.x, mouse.y)
        cursorShape: Qt.PointingHandCursor
    }

    // Calendar popup
    CalendarPopup {
        id: calendarPopup
        visible: root.calendarOpen
        // Position below the clock island
        x: -(width / 2) + (root.width / 2)
        y: root.height + 6
        onCloseRequested: root.calendarOpen = false
    }
}
