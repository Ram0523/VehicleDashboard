#ifndef MQTTCONNECT_H
#define MQTTCONNECT_H
// #include <QtMqtt/QtMqtt>

#include <QObject>
#include <QtMqtt/QMqttClient>
#include <QDebug>

class MqttConnect : public QObject{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)


public:
    explicit MqttConnect(QObject *parent = nullptr);
    Q_INVOKABLE void connectToHost(
        const QString& hostname,
        int port,
        const QString& username,
        const QString& password,
        const QString& topic
        );

    Q_INVOKABLE void disconnectFromHost();
    bool isConnected() const;

signals:
    void connectionStatusChanged(const QString& status, bool connected);
    void messageReceived(const QString& topic, const QString& message);

private slots:
    void onConnected();
    void onDisconnected();
    // void onErrorChanged(QMqttClient::ClientError error);
    void onMessageReceived(const QByteArray &message, const QMqttTopicName &topic);

private:
    QMqttClient *m_client;
    QString m_topic;
};

#endif // MQTTCONNECT_H
