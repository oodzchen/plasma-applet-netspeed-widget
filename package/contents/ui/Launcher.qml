import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: launcher

    Plasma5Support.DataSource {
        id: executableSource
        engine: 'executable'
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
        }
    }

    function launch(entryPath) {
        if (!entryPath) {
            return
        }
        var path = entryPath.toString().replace(/^file:\/\//, "").replace(/^file:/, "")
        var cmd = 'kstart --application "' + path + '" || xdg-open "' + path + '"'
        executableSource.connectSource(cmd)
    }
}
