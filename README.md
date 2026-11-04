# Telemetry Dashboard

A desktop dashboard built with C++, Qt Quick, and QML to
visualise simulated temperature, pressure, voltage, and RPM.

## Features

- Drag and drop parameters to create dials.
- Animated needles and numerical readings.
- Configurable coloured thresholds and status labels.
- Full, half, and three-quarter dial views.
- Dark and light themes.
- Right-click menus for dial customisation and removal.
- Duplicate parameter prevention.

## Technologies

- C++11
- Qt 5.12
- Qt Quick and QML
- JavaScript
- QML Canvas
- qmake

## How It Works

The C++ backend uses QTimer to cycle through predefined
sample values every five seconds.

Backend properties are exposed to QML using Q_PROPERTY
and QQmlContext. Each dial checks its backend value every
300 milliseconds and animates the needle towards it.

The dial uses Canvas drawing, value-to-angle mapping,
and trigonometry to draw the scale and needle.

## Build and Run

1. Install Qt 5.12 with Qt Creator and a compatible compiler kit.
2. Download or clone this repository.
3. Open TelemetryDial_QML.pro in Qt Creator.
4. Select a compatible Qt kit.
5. Build and run the project.

Qt Quick Controls 2 and Qt Graphical Effects must be available.

## Usage

1. Select a parameter from the dropdown.
2. Drag the selected parameter box onto the dashboard.
3. Observe the simulated readings.
4. Right-click a dial to customise or remove it.

## Current Limitations

- Data is simulated; no hardware connection is implemented.
- Dashboard layout needs improvement for smaller windows.
- Removing and adding dials can produce overlapping positions.
- The temperature alert blinking condition needs a spelling fix.

## Author

Manjunath Reddy
