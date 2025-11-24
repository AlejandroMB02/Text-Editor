import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Menu {
    id: menu

    property bool isDocumentModified: false

    signal openFileRequested()
    signal saveRequested()
    signal saveAsRequested()

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
    MenuItem {
        text: "Opciones"
        enabled: false
        onTriggered: console.log("Opciones seleccionada")
    }
    MenuItem {
        text: "Configuración"
        enabled: false
        onTriggered: console.log("Configuración seleccionada")
    }
    MenuSeparator {}
    MenuItem {
        text: "Salir"
        onTriggered: Qt.quit()
    }
}