pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuUsage: 0
    property real memUsedGb: 0
    property int  gpuUsage: 0
    property real gpuPowerW: 0

    // ── CPU usage from /proc/stat ─────────────────────────
    property var _prevCpu: null

    Process {
        id: cpuProc
        command: ["sh", "-c", "cat /proc/stat | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                const user   = parseInt(parts[1])
                const nice   = parseInt(parts[2])
                const system = parseInt(parts[3])
                const idle   = parseInt(parts[4])
                const iowait = parseInt(parts[5])
                const irq    = parseInt(parts[6])
                const softirq= parseInt(parts[7])

                const total = user + nice + system + idle + iowait + irq + softirq
                const idleT = idle + iowait

                if (root._prevCpu) {
                    const diffTotal = total - root._prevCpu.total
                    const diffIdle  = idleT - root._prevCpu.idle
                    root.cpuUsage = diffTotal > 0
                        ? Math.round((1 - diffIdle / diffTotal) * 100)
                        : 0
                }
                root._prevCpu = { total: total, idle: idleT }
            }
        }
    }

    // ── Memory from /proc/meminfo ─────────────────────────
    Process {
        id: memProc
        command: ["sh", "-c", "awk '/MemTotal|MemAvailable/{print $2}' /proc/meminfo | tr '\n' ' '"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length >= 2) {
                    const total = parseInt(parts[0])
                    const avail = parseInt(parts[1])
                    root.memUsedGb = Math.round((total - avail) / 1024 / 102.4) / 10
                }
            }
        }
    }

    // ── GPU stats from nvidia-smi ─────────────────────────
    Process {
        id: gpuProc
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,power.draw",
                  "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                if (parts.length >= 2) {
                    root.gpuUsage  = parseInt(parts[0].trim())
                    root.gpuPowerW = Math.round(parseFloat(parts[1].trim()))
                }
            }
        }
    }

    // ── Poll every 10 seconds ─────────────────────────────
    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running) cpuProc.running = true
            if (!memProc.running) memProc.running = true
            if (!gpuProc.running) gpuProc.running = true
        }
    }
}
