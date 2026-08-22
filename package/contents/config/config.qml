import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18n('General')
         icon: 'preferences-desktop-color'
         source: 'config/ConfigGeneral.qml'
    }
    ConfigCategory {
         name: i18n('Advanced')
         icon: 'preferences-desktop-launch-feedback'
         source: 'config/ConfigAdvanced.qml'
    }
}
