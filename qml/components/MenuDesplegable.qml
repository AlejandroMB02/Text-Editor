import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Menu {
    id: menu

    property bool isDocumentModified: false

    signal openFileRequested()
    signal saveRequested()
    signal saveAsRequested()
    signal changeThemeRequested()

    MenuItem {
        text: "Abrir archivo..."
        onTriggered: menu.openFileRequested()
    }
    MenuItem {
        text: "Guardar"
        enabled: isDocumentModified
        onTriggered: menu.saveRequested()
    }
    MenuItem {
        text: "Guardar como..."
        onTriggered: menu.saveAsRequested()
    }
    Menu {
        title: "Configuración"
        cascade: true
        MenuItem {
            text: "Cambiar Tema"
            onTriggered: menu.changeThemeRequested()
        }
    }
    MenuSeparator {}
    MenuItem {
        text: "Salir"
        onTriggered: Qt.quit()
    }
}
