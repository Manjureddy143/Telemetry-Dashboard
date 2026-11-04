#include "telemetrybackend.h"
#include <QQmlContext>
#include <QDebug>

#include <QtCore/qglobal.h>
#if QT_VERSION >= 0x050000
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#else
#endif

int main(int argc, char *argv[])
{
    qDebug() << "Application Started";

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qDebug() << "QGuiApplication Created";

    QQmlApplicationEngine engine;

    qDebug() << "Engine Created";

    TelemetryBackend backend;
    engine.rootContext()->setContextProperty("backend", &backend);

    qDebug() << "Backend Connected";

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    qDebug() << "Root Objects =" << engine.rootObjects().size();

    if(engine.rootObjects().isEmpty())
    {
        qDebug() << "FAILED TO LOAD QML";
        return -1;
    }

    qDebug() << "Starting Event Loop";

    return app.exec();
}
