/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PlasmaComponents

Item {
    id: appPicker

    property string menuId

    width: childrenRect.width
    height: childrenRect.height

    onMenuIdChanged: updateButton()

    function updateButton() {
        if (menuId && appsSource.data[menuId]) {
            appButton.text = appsSource.data[menuId].name || menuId
            appButton.icon.name = appsSource.data[menuId].iconName || "application-x-executable"
        } else if (menuId) {
            appButton.text = menuId
            appButton.icon.name = "application-x-executable"
        } else {
            appButton.text = i18n('Choose application ...')
            appButton.icon.name = ""
        }
    }

    Plasma5Support.DataSource {
        id: appsSource
        engine: 'apps'
        connectedSources: sources
        onSourceAdded: (source) => {
            if (source === menuId) {
                updateButton()
            }
        }
        onDataChanged: {
            updateButton()
        }
    }

    PlasmaComponents.Button {
        id: appButton
        text: i18n('Choose application ...')
        onClicked: appMenuDialog.open()
    }

    AppMenuDialog {
        id: appMenuDialog
        x: (parent.width - width) / 2
        onAccepted: {
            menuId = selectedMenuId
        }
    }
}
