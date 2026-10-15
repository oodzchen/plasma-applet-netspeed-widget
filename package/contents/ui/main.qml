/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import "../code/utils.js" as Utils

PlasmoidItem {
    id: root

    property bool showSeparately: Plasmoid.configuration.showSeparately
    property bool showLowSpeeds: Plasmoid.configuration.showLowSpeeds
    property string speedLayout: Plasmoid.configuration.speedLayout
    property bool swapDownUp: Plasmoid.configuration.swapDownUp
    property bool showIcons: Plasmoid.configuration.showIcons
    property bool showUnits: Plasmoid.configuration.showUnits
    property string speedUnits: Plasmoid.configuration.speedUnits
    property bool shortUnits: Plasmoid.configuration.shortUnits
    property double fontSizeScale: (Plasmoid.configuration.fontSize || 100) / 100
    property double updateInterval: Plasmoid.configuration.updateInterval || 1.0
    property bool customColors: Plasmoid.configuration.customColors
    property color byteColor: Plasmoid.configuration.byteColor
    property color kilobyteColor: Plasmoid.configuration.kilobyteColor
    property color megabyteColor: Plasmoid.configuration.megabyteColor
    property color gigabyteColor: Plasmoid.configuration.gigabyteColor

    property bool launchApplicationEnabled: Plasmoid.configuration.launchApplicationEnabled
    property string launchApplication: Plasmoid.configuration.launchApplication
    property bool interfacesWhitelistEnabled: Plasmoid.configuration.interfacesWhitelistEnabled
    property var interfacesWhitelist: Plasmoid.configuration.interfacesWhitelist
    property bool showProcesses: Plasmoid.configuration.showProcesses
    property int processCount: Plasmoid.configuration.processCount || 5

    // Per-process capture only runs while hovered, plus a grace period so
    // quickly re-hovering doesn't restart the capture helper
    property bool representationHovered: false
    readonly property bool processMonitorActive: showProcesses && (representationHovered || processGraceTimer.running)

    property var transferDataTs: 0
    property var transferData: ({})
    property var speedData: ({})

    Plasmoid.icon: "network-connect"
    toolTipMainText: i18n("Network usage")
    toolTipTextFormat: Text.RichText
    toolTipSubText: {
        var details = ''
        for (var key in speedData) {
            if (interfacesWhitelistEnabled && interfacesWhitelist && interfacesWhitelist.indexOf(key) === -1) {
                continue
            }

            if (details !== '') {
                details += '<br><br>'
            }

            details += '<b>' + key + '</b><br>'
            details += 'Downloaded: <b>' + Utils.totalText(speedData[key].downTotal) + '</b>, Uploaded: <b>' + Utils.totalText(speedData[key].upTotal) + '</b>'
        }
        return details + processDetails()
    }

    compactRepresentation: CompactRepresentation {
        onHoveredChanged: root.representationHovered = hovered
    }
    fullRepresentation: CompactRepresentation {
        onHoveredChanged: root.representationHovered = hovered
    }
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRepresentation : compactRepresentation

    onRepresentationHoveredChanged: {
        if (!representationHovered) {
            processGraceTimer.restart()
        }
    }

    Timer {
        id: processGraceTimer
        interval: 10000
    }

    Loader {
        id: processMonitor
        active: root.showProcesses
        source: 'ProcessMonitor.qml'

        onLoaded: {
            item.active = Qt.binding(() => root.processMonitorActive)
            item.maxCount = Qt.binding(() => root.processCount)
        }
    }

    function processDetails() {
        const monitor = processMonitor.item
        if (!monitor || !monitor.active) {
            return ''
        }

        var details = '<br><br><b>' + i18n('Top processes') + '</b>'
        if (!monitor.hasData) {
            return details + '<br>' + i18n('Measuring…')
        }
        if (monitor.processes.length === 0) {
            return details + '<br>' + i18n('No process network activity')
        }

        details += '<table cellspacing="0" cellpadding="1">'
        for (const proc of monitor.processes) {
            details += '<tr><td>' + Utils.escapeHtml(proc.name) + '&nbsp;&nbsp;</td>'
                + '<td align="right">↓ ' + Utils.speedText(proc.down, speedUnits) + '&nbsp;&nbsp;</td>'
                + '<td align="right">↑ ' + Utils.speedText(proc.up, speedUnits) + '</td></tr>'
        }
        return details + '</table>'
    }

    Plasma5Support.DataSource {
        id: dataSource
        engine: 'executable'
        connectedSources: [Utils.NET_DATA_SOURCE]
        interval: Math.max(100, root.updateInterval * 1000)

        onNewData: (sourceName, data) => {
            if (data['exit code'] > 0) {
                print(data.stderr)
            } else {
                const now = Date.now()
                const duration = now - transferDataTs
                const nextTransferData = Utils.parseTransferData(data.stdout)

                speedData = Utils.calcSpeedData(transferData, nextTransferData, duration)

                transferDataTs = now
                transferData = nextTransferData
            }
        }
    }
}
