//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import "./modules/overview/"
import "./modules/bar/"
import "./modules/notifications/"
import "./services/"
import "./common/"
import "./common/functions/"
import "./common/widgets/"

import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    // Top bar: Workspaces + Clock + Volume/Notifications
    TopBar {}

    // Bottom bar: Overview trigger
    // BottomBar {}

    // Workspace overview (existing)
    Overview {}

    // Toast notifications
    NotificationToast {}
}
