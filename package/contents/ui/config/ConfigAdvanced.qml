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
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import "../../code/utils.js" as Utils

Kirigami.FormLayout {
    property alias cfg_launchApplicationEnabled: launchApplicationEnabled.checked
    property alias cfg_launchApplication: launchApplication.menuId
    property alias cfg_interfacesWhitelistEnabled: interfacesWhitelistEnabled.checked
    property var cfg_interfacesWhitelist: []

    Loader {
        id: launcher
        source: '../Launcher.qml'
    }

    Plasma5Support.DataSource {
        id: dataSource
        engine: 'executable'
        connectedSources: [Utils.NET_DATA_SOURCE]

        onNewData: (sourceName, data) => {
            // run just once
            connectedSources.length = 0

            if (data['exit code'] > 0) {
                print(data.stderr)
            } else {
                const transferData = Utils.parseTransferData(data.stdout)

                interfacesModel.clear()

                const configWhitelist = cfg_interfacesWhitelist && cfg_interfacesWhitelist.length > 0
                    ? cfg_interfacesWhitelist
                    : ((typeof plasmoid !== 'undefined' ? plasmoid.configuration.interfacesWhitelist : Plasmoid.configuration.interfacesWhitelist) || [])

                for (const name of configWhitelist) {
                    interfacesModel.append({ name: name, shown: true })
                }

                for (var name in transferData) {
                    if (configWhitelist.indexOf(name) !== -1) {
                        continue
                    }

                    interfacesModel.append({ name: name, shown: false })
                }
            }
        }
    }

    ListModel {
        id: interfacesModel
    }

    GridLayout {
        columns: 2

        QQC2.CheckBox {
            id: launchApplicationEnabled
            text: i18n('Launch application when clicked:')
            enabled: launcher.item != null
        }

        AppPicker {
            id: launchApplication
            enabled: launcher.item != null && launchApplicationEnabled.checked
        }

        QQC2.Label {
            text: i18n('If you want to launch an application,\nyou need to install the package plasma-addons first.')
            visible: launcher.item == null
            Layout.columnSpan: 2
        }

        QQC2.CheckBox {
            id: interfacesWhitelistEnabled
            text: i18n('Show only the following network interfaces:')
            Layout.columnSpan: 2
        }

        Rectangle {
            height: 200
            border {
                width: 1
                color: Kirigami.Theme.alternateBackgroundColor
            }
            radius: 2
            color: Kirigami.Theme.backgroundColor
            Layout.columnSpan: 2
            Layout.fillWidth: true

            QQC2.ScrollView {
                anchors.fill: parent

                ListView {
                    id: interfacesWhitelist
                    anchors.fill: parent
                    clip: true
                    model: interfacesModel

                    delegate: Item {
                        id: interfaceItem
                        width: interfacesWhitelist.width
                        height: Kirigami.Units.iconSizes.smallMedium + 2 * Kirigami.Units.smallSpacing

                        QQC2.CheckBox {
                            x: Kirigami.Units.smallSpacing
                            anchors.verticalCenter: parent.verticalCenter

                            text: model.name
                            checked: model.shown
                            enabled: interfacesWhitelistEnabled.checked

                            onToggled: {
                                var list = cfg_interfacesWhitelist ? cfg_interfacesWhitelist.slice() : []
                                var index = list.indexOf(model.name)
                                if (checked && index === -1) {
                                    list.push(model.name)
                                } else if (!checked && index !== -1) {
                                    list.splice(index, 1)
                                }
                                cfg_interfacesWhitelist = list
                            }
                        }
                    }
                }
            }
        }
    }
}
