#include "telemetrybackend.h"
#include<QList>

#include <QRandomGenerator>

TelemetryBackend::TelemetryBackend(QObject *parent)
    : QObject(parent),

      m_temperature(0.0),
      m_pressure(0.0),
      m_voltage(0.0),
      m_rpm(0.0),
      m_connected(true)
{
    m_timer = new QTimer(this);

    connect(m_timer,
            &QTimer::timeout,
            this,
            &TelemetryBackend::updateTelemetry);

    m_temperatureValues << 0 << 5 <<9.9 << 10 << 15 << 20
                 << 35 << 50 << 75 << 100;
    m_pressureValues << 5 << 6 << 8 << 10 << 12
                     << 14 << 15 << 13 << 11 << 9;
    m_voltageValues << 22 << 23 << 24 << 25 << 26
                    << 27 << 28 << 27 << 26 << 25;
    m_rpmValues << 1000 << 1500 << 2200 << 3500 << 5000
                << 6500 << 8000 << 9200 << 10000 << 7500;

    m_currentIndex = 0;

    m_timer->start(5000);
}


double TelemetryBackend::temperature() const
{
    return m_temperature;
}

bool TelemetryBackend::connected() const
{
    return m_connected;
}

double TelemetryBackend::pressure() const
{
    return m_pressure;
}

double TelemetryBackend::voltage() const
{
    return m_voltage;
}

double TelemetryBackend::rpm() const
{
    return m_rpm;
}

//void TelemetryBackend::updateTelemetry()          this is for Random numbers
//{
//    m_value =
//            QRandomGenerator::global()->generateDouble()
//            * 100.0;

//    m_temperature =
//            QRandomGenerator::global()->generateDouble()
//            * 100.0;

//    m_pressure =
//            QRandomGenerator::global()->generateDouble()
//            * 100.0;
//    m_voltage =
//            QRandomGenerator::global()->generateDouble()
//            * 100.0;
//    m_connected = true;

//    emit valueChanged();
//    emit temperatureChanged();
//    emit pressureChanged();
//    emit voltageChanged();
//    emit connectedChanged();
//}

void TelemetryBackend::updateTelemetry()
{
    m_temperature = m_temperatureValues[m_currentIndex];

    m_pressure = m_pressureValues[m_currentIndex];

    m_voltage = m_voltageValues[m_currentIndex];

    m_rpm = m_rpmValues[m_currentIndex];

    m_connected = true;

    emit temperatureChanged();
    emit pressureChanged();
    emit voltageChanged();
    emit connectedChanged();
    emit rpmChanged();

    m_currentIndex++;

    if (m_currentIndex >= m_temperatureValues.size())
    {
        m_currentIndex = 0;
    }
}
