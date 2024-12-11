#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtMqtt/QtMqtt>
#include "mqttconnect.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Register QMqttClient in QML
    qmlRegisterType<MqttConnect>("MqttConnect", 1, 0, "MqttConnect");


    engine.loadFromModule("VehicleDashboard", "Main");

    return app.exec();
}
