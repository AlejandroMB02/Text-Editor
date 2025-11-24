import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Menu {
    id: menu

    signal openFileRequested()
    signal saveRequested()
    signal saveAsRequested()

    MenuItem {
        text: "Abrir archivo..."
        onTriggered: menu.openFileRequested()
    }
    MenuItem {
        text: "Guardar"
        onTriggered: menu.saveRequested()
    }
    MenuItem {
        text: "Guardar como..."
        onTriggered: menu.saveAsRequested()
    }
    MenuItem {
        text: "Opciones"
        onTriggered: console.log("Opciones seleccionada")
    }
    MenuItem {
        text: "Configuración"
        onTriggered: console.log("Configuración seleccionada")
    }
    MenuSeparator {}
    MenuItem {
        text: "Salir"
        onTriggered: Qt.quit()
    }
}