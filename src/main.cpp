#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "models/PlainTextModel.h"

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);

  qmlRegisterType<PlainTextModel>("Editor", 1, 0, "TextDocumentModel");

  QQmlApplicationEngine engine;
  engine.loadFromModule("Main", "Main");
  if (engine.rootObjects().isEmpty())
    exit(-1);
  return app.exec();
}