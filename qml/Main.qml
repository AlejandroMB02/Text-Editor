import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Editor
import Main

ApplicationWindow {
    id: window
    visible: true
    width: 600
    height: 400
    title: "MiniPad"

    MenuDesplegable {
        id: menu
        onOpenFileRequested: fileDialog.open()
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("⋮")
                onClicked: menu.open()
            }
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: "Title"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
        }
    }

    // Modelo de texto
    TextDocumentModel {
        id: textDoc
        filePath: ""
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

    FileDialog {
        id: fileDialog
        title: "Selecciona un archivo"
        nameFilters: ["Todos (*.*)"]

        onAccepted: {
            var localPath = selectedFile.toString().replace("file://", "")
            textDoc.filePath = localPath
            textDoc.load()
        }
    }
}
