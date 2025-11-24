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
                if (textDoc.modified) {
                    saveAsFileDialog.open()
                } else {
                    console.log("El archivo no ha sido modificado.")
                }
            }
        }
        onSaveAsRequested: saveAsFileDialog.open()
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
                text: textDoc.fileName
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
        nameFilters: ["Todos (*)"]

        onAccepted: {
            var localPath = selectedFile.toString().replace("file://", "")
            textDoc.filePath = localPath
            textDoc.load()
        }
    }

    FileDialog {
        id: saveAsFileDialog
        title: "Guardar archivo como..."
        fileMode: FileDialog.SaveFile // Indica que la operación es para guardar
        nameFilters: ["Archivos de Texto (*.txt)", "Todos (*.*)"]

        onAccepted: {
            var newLocalPath = selectedFile.toString().replace("file://", "")
            
            // 1. Asegurar que el texto actual del editor esté en el modelo C++
            textDoc.setContent(editorArea.text) 
            
            // 2. Llamar a la función saveAs en C++
            if (textDoc.saveAs(newLocalPath)) {
                console.log("Archivo guardado como " + newLocalPath)
            } else {
                console.log("Error al guardar archivo como.")
            }
        }
    }
}
