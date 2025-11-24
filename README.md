# 📝 Notepad++-Like Text Editor (C++ & Qt/QML)

Un editor de texto ligero, desarrollado en **C++** utilizando **Qt/QML**.  
Se centra en la simplicidad, la velocidad y una interfaz minimalista pero funcional.

## 🚀 Características actuales

- ✏️ Edición de texto
- 💾 Guardar cambios
- 🎨 Interfaz moderna construida con QML
- 🔧 Arquitectura modular en C++ + QML

## 🚀 Características en desarrollo
- ⌨️ Atajos de teclado

## 🛠️ Tecnologías utilizadas

- C++
- Qt
- QML / Qt Quick
- CMake

## Instalación y compilación

```bash
gh repo clone AlejandroMB02/Text-Editor
cd Text-Editor
cmake -DCMAKE_PREFIX_PATH=/ruta/a/QT/gcc_64 -S ./ -B ./build -G Ninja
cmake --build build
./build/MiniPad
```
