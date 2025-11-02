cmake_minimum_required(VERSION 3.20)
project(MiniPad LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(MiniPad 
    src/main.cpp
)

qt_add_qml_module(MiniPad
    URI "Main"
    QML_FILES 
        src/Main.qml
)

target_include_directories(MiniPad
    PRIVATE
        include
)

target_link_libraries(MiniPad
    PRIVATE
        Qt6::Quick
)