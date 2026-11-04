import QtQuick 2.12
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

Window {
    id: root

    visible: true
    width: 1350
    height: 800

    minimumHeight: 400
    minimumWidth: 500
    title: qsTr("Telemetry Dashboard")
    color: root.backgroundColor

    // ==============================================================
    // Properties
    // ==============================================================
    property string selectedParameter: ""

    property int telemetryIndex: 0
    property int dialCount: 0
    property var addedParameters: []

    property string theme: "dark"

    property var parameterDatabase: ({
                                         "Temperature": {
                                             "title": "Temperature",
                                             "parameterName": "Temperature",
                                             "backendProperty": "temperature",
                                             "unit": "°C",
                                             "minimum": 0,
                                             "maximum": 100,
                                             "majorTickCount": 10,
                                             "tickInterval": 10,
                                             "thresholds": [{
                                                     "from": 0,
                                                     "to": 10,
                                                     "color": "green",
                                                     "status": "Normal"
                                                 }, {
                                                     "from": 10,
                                                     "to": 20,
                                                     "color": "yellow",
                                                     "status": "Warning"
                                                 }, {
                                                     "from": 20,
                                                     "to": 50,
                                                     "color": "orange",
                                                     "status": "Caution"
                                                 }, {
                                                     "from": 50,
                                                     "to": 100,
                                                     "color": "red",
                                                     "status": "Critical"
                                                 }]
                                         },
                                         "Pressure": {
                                             "title": "Pressure",
                                             "parameterName": "Pressure",
                                             "backendProperty": "pressure",
                                             "unit": "bar",
                                             "minimum": 0,
                                             "maximum": 30,
                                             "majorTickCount": 6,
                                             "tickInterval": 5,
                                             "thresholds": [{
                                                     "from": 0,
                                                     "to": 10,
                                                     "color": "green",
                                                     "status": "Normal"
                                                 }, {
                                                     "from": 10,
                                                     "to": 20,
                                                     "color": "yellow",
                                                     "status": "Warning"
                                                 }, {
                                                     "from": 20,
                                                     "to": 25,
                                                     "color": "orange",
                                                     "status": "High"
                                                 }, {
                                                     "from": 25,
                                                     "to": 30,
                                                     "color": "red",
                                                     "status": "Critical"
                                                 }]
                                         },
                                         "Voltage": {
                                             "title": "Voltage",
                                             "parameterName": "Voltage",
                                             "backendProperty": "voltage",
                                             "unit": "V",
                                             "minimum": 0,
                                             "maximum": 28,
                                             "majorTickCount": 7,
                                             "tickInterval": 4,
                                             "thresholds": [{
                                                     "from": 0,
                                                     "to": 18,
                                                     "color": "green",
                                                     "status": "Normal"
                                                 }, {
                                                     "from": 18,
                                                     "to": 22,
                                                     "color": "yellow",
                                                     "status": "Warning"
                                                 }, {
                                                     "from": 22,
                                                     "to": 25,
                                                     "color": "orange",
                                                     "status": "High"
                                                 }, {
                                                     "from": 25,
                                                     "to": 28,
                                                     "color": "red",
                                                     "status": "Critical"
                                                 }]
                                         },
                                         "RPM": {
                                             "title": "RPM",
                                             "parameterName": "RPM",
                                             "backendProperty": "rpm",
                                             "unit": "RPM",
                                             "minimum": 1000,
                                             "maximum": 10000,
                                             "majorTickCount": 9,
                                             "tickInterval": 1000,
                                             "thresholds": [{
                                                     "from": 1000,
                                                     "to": 3000,
                                                     "color": "green",
                                                     "status": "Idle"
                                                 }, {
                                                     "from": 3000,
                                                     "to": 6000,
                                                     "color": "yellow",
                                                     "status": "Cruise"
                                                 }, {
                                                     "from": 6000,
                                                     "to": 8000,
                                                     "color": "orange",
                                                     "status": "High"
                                                 }, {
                                                     "from": 8000,
                                                     "to": 10000,
                                                     "color": "red",
                                                     "status": "Danger"
                                                 }]
                                         }
                                     })

    // ==============================================================
    // Theme Colors
    // ==============================================================
    property color backgroundColor: theme === "dark" ? "#111111" : "#F2F2F2"
    property color dashboardColor: theme === "dark" ? "#222222" : "#FFFFFF"
    property color textColor: theme === "dark" ? "white" : "#222222"
    property color parameterColor: theme === "dark" ? "#333333" : "#DDDDDD"
    property color borderColor: theme === "dark" ? "#555555" : "#999999"

    // ==============================================================
    // Header
    // ==============================================================

    // -------------------- Title --------------------
    Text {
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter

        text: "TELEMETRY DASHBOARD"
        font.family: "Modern No. 20"
        color: root.textColor
        font.pixelSize: 32
        font.bold: true
        font.underline: true
        style: Text.Outline
        styleColor: "#f50808"
    }

    // -------------------- Theme Toggle --------------------
    Rectangle {
        id: themeSwitch

        x: root.width - 130
        y: 40

        width: 80
        height: 40

        radius: 20

        color: root.theme === "dark" ? "#333333" : "#DDDDDD"

        border.color: root.theme === "dark" ? "#666666" : "#AAAAAA"
        border.width: 1

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text: "☀"

            font.pixelSize: 20
            color: root.theme === "dark" ? "#777777" : "#222222"
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text: "☾"

            font.pixelSize: 20
            color: root.theme === "dark" ? "white" : "#777777"
        }

        Rectangle {
            id: toggleCircle

            width: 32
            height: 32

            radius: width / 2

            anchors.verticalCenter: parent.verticalCenter

            x: root.theme === "dark" ? 44 : 4

            color: root.theme === "dark" ? "#111111" : "white"

            Behavior on x {
                NumberAnimation {
                    duration: 250
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.theme = root.theme === "dark" ? "light" : "dark"
                }
            }
        }
    }

    // -------------------- ComboBox --------------------
    ComboBox {
        id: parameterComboBox

        x: 40
        y: 40

        width: 225
        height: 45

        model: ["Select Parameter", "Temperature", "Pressure", "Voltage", "RPM"]

        currentIndex: 0

        onActivated: {
            if (currentIndex === 0) {
                root.selectedParameter = ""
                selectedParameterBox.visible = false
            } else {
                root.selectedParameter = currentText

                selectedParameterBox.x = 30
                selectedParameterBox.y = 100
                selectedParameterBox.visible = true
            }
        }
    }

    // ==============================================================
    // Selected Parameter Box
    // ==============================================================
    Rectangle {
        id: selectedParameterBox

        x: 30
        y: 100

        width: 220
        height: 45

        color: root.parameterColor
        radius: 8

        z: 100

        visible: root.selectedParameter !== ""

        Text {
            anchors.centerIn: parent

            text: root.selectedParameter

            color: root.textColor
            font.pixelSize: 16
        }

        MouseArea {
            id: parameterMouseArea

            anchors.fill: parent

            drag.target: selectedParameterBox

            onReleased: {
                selectedParameterBox.Drag.drop()
            }
        }

        Drag.active: parameterMouseArea.pressed
        Drag.keys: ["telemetry"]

        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
    }

    // ==============================================================
    // Dashboard
    // ==============================================================
    Rectangle {
        id: dashboardArea

        x: 20
        y: 100
        width: 1300
        height: 580

        color: root.dashboardColor
        border.color: root.borderColor
        border.width: 2
        radius: 10

        // -------------------- Container --------------------
        Item {
            id: dashboardContainer

            anchors.fill: parent
            z: 1
        }

        // -------------------- Component --------------------
        Component {
            id: telemetryDialComponent

            Item {
                id: dialContainer

                width: 380
                height: 380

                function loadConfiguration(config, currentValue) {
                    dial.loadConfiguration(config, currentValue)
                }

                TelemetryDial {
                    id: dial
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    anchors.margins: 10

                    theme: root.theme

                    onRemoveRequested: {
                        root.removeParameterFromList(dial.title)
                        root.dialCount--
                        dialContainer.destroy()
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    drag.target: dialContainer

                    onPressed: {
                        dialContainer.z = 100
                    }
                }

                Timer {
                    interval: 300
                    running: true
                    repeat: true

                    onTriggered: {
                        dial.value = root.backendValue(dial.backendProperty)
                    }
                }
            }
        }

        // -------------------- DropArea --------------------
        DropArea {
            id: dashboardDropArea

            anchors.fill: parent
            z: 0

            onEntered: {
                dashboardArea.border.color = "green"
            }

            onExited: {
                dashboardArea.border.color = root.borderColor
            }

            onDropped: {
                if (root.isParameterAdded(root.selectedParameter)) {
                    console.log("Parameter already added:",
                                root.selectedParameter)

                    selectedParameterBox.visible = false
                    root.selectedParameter = ""
                    parameterComboBox.currentIndex = 0

                    return
                }

                console.log("DROPPED:", root.selectedParameter)

                var newDial = telemetryDialComponent.createObject(
                            dashboardContainer, {
                                "x": 25 + (root.dialCount % 2) * 380,
                                "y": 25 + Math.floor(root.dialCount / 2) * 380
                            })

                if (newDial === null) {
                    console.log("Failed to create dial")
                    return
                }

                root.dialCount++
                root.addParameterToList(root.selectedParameter)

                var config = root.parameterDatabase[root.selectedParameter]

                newDial.loadConfiguration(config, root.backendValue(
                                              config.backendProperty))

                selectedParameterBox.visible = false

                root.selectedParameter = ""
                parameterComboBox.currentIndex = 0
            }
        }
    }

    // ==============================================================
    // Helper Functions
    // ==============================================================
    function backendValue(propertyName) {
        switch (propertyName) {
        case "temperature":
            return backend.temperature
        case "pressure":
            return backend.pressure
        case "voltage":
            return backend.voltage
        case "rpm":
            return backend.rpm
        default:
            return 0
        }
    }

    function isParameterAdded(paramName) {
        return root.addedParameters.indexOf(paramName) !== -1
    }

    function addParameterToList(paramName) {
        root.addedParameters.push(paramName)
    }

    function removeParameterFromList(paramName) {
        var index = root.addedParameters.indexOf(paramName)

        if (index !== -1) {
            root.addedParameters.splice(index, 1)
        }
    }
}
