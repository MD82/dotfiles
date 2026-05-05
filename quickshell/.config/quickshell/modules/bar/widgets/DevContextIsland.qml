pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io
import "../../../common/" as Common

/**
 * Development-focused center island: current repo, branch, and active window.
 */
IslandBase {
    id: root

    minHeight: 40
    padding: 7
    hPadding: 14
    implicitContentWidth: contentRow.implicitWidth
    implicitContentHeight: contentRow.implicitHeight

    property var activeToplevel: Hyprland.activeToplevel
    property var activeMeta: activeToplevel?.lastIpcObject ?? ({})
    property int activePid: Number(activeMeta.pid ?? 0)
    property string appClass: activeMeta.class ?? ""
    property string windowTitle: activeToplevel?.title ?? activeMeta.title ?? "No active window"
    property string repoName: ""
    property string branchName: ""

    function refreshGitContext() {
        if (activePid <= 0) {
            repoName = "";
            branchName = "";
            return;
        }

        if (!gitContext.running)
            gitContext.running = true;
    }

    onActivePidChanged: refreshGitContext()
    Component.onCompleted: refreshGitContext()

    Process {
        id: gitContext
        command: [
            "sh",
            "-lc",
            "pid=\"$1\"; cwd=\"\"; [ -n \"$pid\" ] && [ -e \"/proc/$pid/cwd\" ] && cwd=$(readlink -f \"/proc/$pid/cwd\" 2>/dev/null || true); [ -n \"$cwd\" ] || exit 0; repo=$(git -C \"$cwd\" rev-parse --show-toplevel 2>/dev/null) || exit 0; branch=$(git -C \"$repo\" branch --show-current 2>/dev/null); [ -n \"$branch\" ] || branch=$(git -C \"$repo\" rev-parse --short HEAD 2>/dev/null); dirty=\"\"; git -C \"$repo\" diff --quiet --ignore-submodules -- 2>/dev/null || dirty=\"*\"; printf '%s|%s%s' \"$(basename \"$repo\")\" \"$branch\" \"$dirty\"",
            "sh",
            String(root.activePid)
        ]
        stdout: StdioCollector {
            id: gitCollector
            onStreamFinished: {
                const text = gitCollector.text.trim();
                if (!text) {
                    root.repoName = "";
                    root.branchName = "";
                    return;
                }

                const parts = text.split("|");
                root.repoName = parts[0] ?? "";
                root.branchName = parts[1] ?? "";
            }
        }
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        spacing: 10

        Text {
            visible: root.repoName.length > 0
            text: root.repoName
            font.pixelSize: Common.Appearance.font.pixelSize.small
            font.family: Common.Appearance.font.family.main
            font.weight: Font.DemiBold
            color: Common.Appearance.m3colors.m3onSurface
            elide: Text.ElideRight
            Layout.maximumWidth: 150
        }

        Text {
            visible: root.branchName.length > 0
            text: root.branchName
            font.pixelSize: Common.Appearance.font.pixelSize.smaller
            font.family: Common.Appearance.font.family.main
            color: Common.Appearance.m3colors.m3primary
            elide: Text.ElideRight
            Layout.maximumWidth: 150
        }

        Rectangle {
            visible: root.repoName.length > 0 || root.branchName.length > 0
            width: 1
            height: 16
            color: Common.Appearance.m3colors.m3outlineVariant
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.appClass.length > 0
            text: root.appClass
            font.pixelSize: Common.Appearance.font.pixelSize.smaller
            font.family: Common.Appearance.font.family.main
            color: Common.Appearance.m3colors.m3onSurfaceVariant
            elide: Text.ElideRight
            Layout.maximumWidth: 120
        }

        Text {
            text: root.windowTitle
            font.pixelSize: Common.Appearance.font.pixelSize.small
            font.family: Common.Appearance.font.family.expressive
            color: Common.Appearance.m3colors.m3onSurface
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.minimumWidth: 80
        }
    }
}
