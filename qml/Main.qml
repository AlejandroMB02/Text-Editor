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
        onSaveRequested: {
            if(textDoc.modified && textDoc.filePath !== ""){
                handleSaveRequest()
            }
            else {
                console.log("No es posible guardar el archivo")
            }
        }
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
                text: "MiniPad"
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
    /*
    ListView {
        anchors.fill: parent
        model: textDoc
        delegate: Text {
            text: line
            font.family: "Monospace"
            font.pointSize: 12
        }
    }
    */
    TextArea {
        id: editorArea
        anchors.fill: parent
        anchors.margins: 5
        
        // Enlace bidireccional simple (content se actualizará al cargar)
        text: textDoc.content

        onTextChanged: {
            if (textDoc.filePath !== "") {
                // Llama a setModified(true) en C++ sin cambiar el contenido interno de m_lines
                textDoc.setModified(true) 
            }
        }
        
        // Estilo de fuente
        font.family: "Monospace"
        font.pointSize: 12
    }

    // Manejadores de señales

    function handleSaveRequest() {
        textDoc.setContent(editorArea.text)
        if (textDoc.save()) {
            console.log("Archivo guardado con éxito.")
        } else {
            console.log("Error al guardar archivo.")
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
