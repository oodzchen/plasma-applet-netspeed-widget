import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: launcher

    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
        }
    }

    function launch(urlOrPath) {
        if (!urlOrPath) return
        var path = urlOrPath.toString().replace(/^file:\/\//, "")
        var base = path.replace(/^.*[\\\/]/, "")
        var cmd = "gio launch '" + path.replace(/'/g, "'\\''") + "' 2>/dev/null || gtk-launch '" + base.replace(/'/g, "'\\''") + "' 2>/dev/null"
        execSource.connectSource(cmd)
    }
}
