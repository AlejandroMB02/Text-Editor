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
    onClosing: (close) => {
        if (textDoc.modified) {
            // Cancelamos el cierre automático
            close.accepted = false
            
            // Mostramos la alerta
            discardDialog.pendingAction = discardDialog.close_window
            discardDialog.open()
        }
    }

    MenuDesplegable {
        id: menu
        isDocumentModified: textDoc.modified
        onOpenFileRequested: {
            if (textDoc.modified) {
                // Si está modificado, mostramos la alerta
                discardDialog.pendingAction = discardDialog.open_file
                discardDialog.open()
            } else {
                // Si no está modificado, abrimos el diálogo directamente
                fileDialog.open() 
            }
        }
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

    // DIÁLOGO DE CONFIRMACIÓN AL PERDER CAMBIOS
    MessageDialog {
        id: discardDialog
        title: "¡Cambios sin guardar!"
        text: "¿Deseas guardar los cambios antes de continuar?"
        
        // Botones: Guardar, Descartar, Cancelar
        buttons: MessageDialog.Save | MessageDialog.Discard | MessageDialog.Cancel
        
        // Propiedad auxiliar para saber qué acción inicial disparó el diálogo
        property int pendingAction: -1 
        readonly property int open_file: 1
        readonly property int close_window: 2
        
        // Manejo de la acción del usuario
        onButtonClicked: (button) => {
            if (button === MessageDialog.Save) {
                // 1. Si el usuario selecciona Guardar
                handleSaveRequest()
                
                // Si guardamos con éxito, procedemos con la acción pendiente
                if (!textDoc.modified) {
                    processPendingAction()
                }
            } else if (button === MessageDialog.Discard) {
                // 2. Si el usuario selecciona Descartar, procedemos sin guardar
                textDoc.setModified(false)
                processPendingAction()
            }
            // 3. Si el usuario selecciona Cancelar, no hacemos nada (el diálogo se cierra)
        }
        
        // Lógica para ejecutar la acción que estaba pendiente
        function processPendingAction() {
            if (pendingAction === open_file) {
                // Si la acción era abrir otro archivo, abrimos el diálogo de apertura
                textDoc.setModified(false)
                fileDialog.open()
            } else if (pendingAction === close_window) {
                // Si la acción era cerrar la ventana, permitimos el cierre
                window.close()
            }
            pendingAction = -1 // Resetear
        }
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("⋮")
                onClicked: menu.open()
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
