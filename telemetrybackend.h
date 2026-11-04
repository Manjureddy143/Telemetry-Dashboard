#ifndef TELEMETRYBACKEND_H
#define TELEMETRYBACKEND_H
#include <QTimer>
#include <QObject>
#include <QList>

class TelemetryBackend : public QObject
{
    Q_OBJECT


    Q_PROPERTY(double temperature
               READ temperature
               NOTIFY temperatureChanged)

    Q_PROPERTY(double pressure
               READ pressure
               NOTIFY pressureChanged)
    Q_PROPERTY(double voltage
               READ voltage
               NOTIFY voltageChanged)
    Q_PROPERTY(double rpm
               READ rpm
               NOTIFY rpmChanged)
    Q_PROPERTY(bool connected
               READ connected
               NOTIFY connectedChanged)

public:
    explicit TelemetryBackend(QObject *parent = nullptr);


    double temperature() const;
    double pressure() const;
    double voltage() const;
    double rpm() const;
    bool connected() const;

signals:

    void temperatureChanged();
    void pressureChanged();
    void voltageChanged();
    void rpmChanged();
    void connectedChanged();

private slots:
    void updateTelemetry();

private:

    double m_temperature;
    double m_pressure;
    double m_voltage;
    double m_rpm;
    bool m_connected;

    QList<double> m_temperatureValues;
    QList<double> m_pressureValues;
    QList<double> m_voltageValues;
    QList<double> m_rpmValues;


    int m_currentIndex;
    QTimer *m_timer;
};

#endif // TELEMETRYBACKEND_H
