import QtQuick
import org.kde.ksysguard.process as Process

// Per-process network usage, provided by libksysguard's network plugin
// (the same data source as the Download/Upload columns in System Monitor).
// Loaded through a Loader so the widget keeps working when it is missing.
Item {
    id: monitor

    // While active, libksysguard runs ksgrd_network_helper to capture traffic
    property bool active: false
    property int maxCount: 5

    // [{ name, down, up }] in bytes per second, sorted by total speed
    property var processes: []
    property bool hasData: false

    readonly property int nameColumn: 0
    readonly property int downColumn: 1
    readonly property int upColumn: 2

    Process.ProcessDataModel {
        id: processModel
        enabled: monitor.active
        flatList: true
        // The network plugin starts its capture helper as soon as these
        // attributes are enabled, regardless of the model's enabled flag
        enabledAttributes: monitor.active ? ['name', 'netInbound', 'netOutbound'] : []
    }

    Timer {
        interval: 1000
        repeat: true
        running: monitor.active
        onTriggered: monitor.update()
    }

    onActiveChanged: {
        if (!active) {
            processes = []
            hasData = false
        }
    }

    function value(row, column) {
        return processModel.data(processModel.index(row, column), Process.ProcessDataModel.Value)
    }

    function update() {
        const rowCount = processModel.rowCount()
        const byName = {}

        for (let row = 0; row < rowCount; row++) {
            const down = Number(value(row, downColumn)) || 0
            const up = Number(value(row, upColumn)) || 0
            if (down + up <= 0) {
                continue
            }

            // Group processes of the same program (e.g. browser helpers)
            const name = value(row, nameColumn) || '?'
            if (!byName[name]) {
                byName[name] = { name: name, down: 0, up: 0 }
            }
            byName[name].down += down
            byName[name].up += up
        }

        processes = Object.values(byName)
            .sort((a, b) => (b.down + b.up) - (a.down + a.up))
            .slice(0, maxCount)
        hasData = rowCount > 0
    }
}
