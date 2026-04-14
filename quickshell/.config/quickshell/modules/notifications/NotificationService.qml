pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

/**
 * Central notification store.
 * Tracks active + dismissed notifications.
 * Exposes unreadCount for the bell badge.
 */
Singleton {
    id: root

    property int unreadCount: 0
    property var notifications: []

    NotificationServer {
        id: server
        keepOnReload: true

        onNotification: notif => {
            // Prepend new notification
            root.notifications = [notif].concat(root.notifications);
            root.unreadCount += 1;
        }
    }

    function dismiss(id) {
        root.notifications = root.notifications.filter(n => n.id !== id);
        root.unreadCount = Math.max(0, root.unreadCount - 1);
    }

    function clearAll() {
        root.notifications = [];
        root.unreadCount = 0;
    }

    function markAllRead() {
        root.unreadCount = 0;
    }
}
