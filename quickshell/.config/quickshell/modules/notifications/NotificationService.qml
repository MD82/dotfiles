pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

/**
 * Central notification store.
 * Keeps the latest notifications for toast popups.
 */
Singleton {
    id: root

    property var notifications: []

    NotificationServer {
        id: server
        keepOnReload: true

        onNotification: notif => {
            // Replace updates for the same notification, then place it at the top.
            const key = root.notificationKey(notif);
            root.notifications = [notif]
                .concat(root.notifications.filter(n => root.notificationKey(n) !== key))
                .slice(0, 50);
        }
    }

    function notificationKey(notif) {
        return notif?.id ?? `${notif?.appName ?? ""}:${notif?.summary ?? ""}:${notif?.body ?? ""}`;
    }
}
