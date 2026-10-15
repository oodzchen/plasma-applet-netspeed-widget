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
        var path = urlOrPath.toString().replace(/^file:\/\//, "").replace(/^file:/, "")
        var base = path.replace(/^.*[\\\/]/, "")
        var quotedPath = "'" + path.replace(/'/g, "'\\''") + "'"
        var quotedBase = "'" + base.replace(/'/g, "'\\''") + "'"
        var cmd = "kstart --application " + quotedPath + " 2>/dev/null"
            + " || gio launch " + quotedPath + " 2>/dev/null"
            + " || gtk-launch " + quotedBase + " 2>/dev/null"
        execSource.connectSource(cmd)
    }
}
