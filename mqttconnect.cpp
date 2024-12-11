#include "mqttconnect.h"
#include <QSslConfiguration>

MqttConnect::MqttConnect(QObject *parent) : QObject(parent) {
    m_client = new QMqttClient(this);
    connect(m_client, &QMqttClient::connected, this, &MqttConnect::onConnected);
    connect(m_client, &QMqttClient::disconnected, this, &MqttConnect::onDisconnected);
    connect(m_client, &QMqttClient::messageReceived, this, &MqttConnect::onMessageReceived);

}


void MqttConnect::connectToHost(
    const QString& hostname,
    int port,
    const QString& username,
    const QString& password,
    const QString& topic
    ) {
    // Store topic for later use
    m_topic = topic;

    // Configure SSL/TLS
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setPeerVerifyMode(QSslSocket::VerifyPeer);

    // Set MQTT client parameters
    m_client->setHostname(hostname);
    m_client->setPort(port);
    m_client->setUsername(username);
    m_client->setPassword(password);
    m_client->setProtocolVersion(QMqttClient::MQTT_3_1_1);

    // Connect using SSL/TLS
    m_client->connectToHostEncrypted(sslConfig);
}

void MqttConnect::disconnectFromHost() {
    m_client->disconnectFromHost();
}

bool MqttConnect::isConnected() const {
    return m_client->state() == QMqttClient::Connected;
}

void MqttConnect::onConnected() {
    // Subscribe to topic
    auto subscription = m_client->subscribe(m_topic, 0);

    if (subscription) {
        emit connectionStatusChanged("Connected to " + m_client->hostname(), true);
        qDebug() << "Connected and subscribed to topic:" << m_topic;
    } else {
        emit connectionStatusChanged("Connected, but subscription failed", false);
    }
}

void MqttConnect::onDisconnected() {
    emit connectionStatusChanged("Disconnected", false);
    qDebug() << "Disconnected from MQTT broker";
}

// void MqttConnect::onErrorChanged(QMqttClient::ClientError error) {
// QString errorMsg;

// switch (error) {
// case QMqttClient::ClientError::TransportInvalid:
//     errorMsg = "Invalid transport";
//     break;
// case QMqttClient::ClientError::TransportConnectionRefused:
//     errorMsg = "Connection refused";
//     break;
// case QMqttClient::ClientError::TransportUnknown:
//     errorMsg = "Unknown transport error";
//     break;
// case QMqttClient::ClientError::InvalidClient:
//     errorMsg = "Invalid client ID";
//     break;
// case QMqttClient::ClientError::InternalError:
//     errorMsg = "Internal error";
//     break;
// default:
//     errorMsg = "Unknown error: " + QString::number(static_cast<int>(error));
//     break;
// }

// emit connectionStatusChanged("Connection Error: " + errorMsg, false);
// qDebug() << "Connection Error:" << errorMsg;
// }

void MqttConnect::onMessageReceived(const QByteArray &message, const QMqttTopicName &topic) {
    QString receivedMessage = QString::fromUtf8(message);

    // Emit signal with the received message
    emit messageReceived(topic.name(), receivedMessage);

    // Handle specific commands
    if (receivedMessage == "Start") {
        emit connectionStatusChanged("Received 'Start' command", true);
        QMetaObject::invokeMethod(parent(), "setIsDashboardActive", Q_ARG(bool, true));
    } else if (receivedMessage == "Stop") {
        emit connectionStatusChanged("Received 'Stop' command", true);
        QMetaObject::invokeMethod(parent(), "setIsDashboardActive", Q_ARG(bool, false));
    }
}

