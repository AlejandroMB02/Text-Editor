import QtQuick 2.15
import QtQuick.Controls 2.15
import Editor 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 600
    height: 400
    title: "MiniPad - Test"

    // Modelo de texto
    TextDocumentModel {
        id: textDoc
        filePath: "/home/alejandro/set_resolution.sh"  // <- Cambia aquí por un archivo real
        Component.onCompleted: textDoc.load()
    }

    // Vista simple
    ListView {
        anchors.fill: parent
        model: textDoc
        delegate: Text {
            text: line
            font.family: "Monospace"
            font.pointSize: 12
        }
    }
}
