pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../common/" as Common
import "../../../services/" as Services

/**
 * Left island: workspace pills with open app icons inside each.
 */
IslandBase {
    id: root
    required property var screen

    padding: 5
    hPadding: 6
    implicitContentWidth: wsRow.implicitWidth
    implicitContentHeight: wsRow.implicitHeight

    // Pull monitor info to show only workspaces for this screen
    property var monitorData: {
        const monitors = Services.HyprlandData.monitors;
        for (let i = 0; i < monitors.length; i++) {
            if (monitors[i].name === root.screen.name)
                return monitors[i];
        }
        return null;
    }

    // Visible workspace IDs: always show 1-5, extras if occupied
    property var visibleIds: {
        const base = [1, 2, 3, 4, 5];
        const extra = Services.HyprlandData.workspaceIds.filter(id => id > 5);
        return base.concat(extra).sort((a, b) => a - b);
    }

    property int activeId: Services.HyprlandData.activeWorkspace?.id ?? 1

    RowLayout {
        id: wsRow
        spacing: 4

        Repeater {
            model: root.visibleIds

            delegate: WorkspacePill {
                required property int modelData
                workspaceId: modelData
                active: modelData === root.activeId
            }
        }
    }
}
