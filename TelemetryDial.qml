// ==================================================================
// 1. Imports
// ==================================================================
import QtQuick 2.12
import QtQuick.Controls 2.12

// ==================================================================
// 2. Root Item
// ==================================================================
Item {
    id: root

    anchors.fill: parent

    // ==============================================================
    // 3. Signals
    // ==============================================================
    signal removeRequested

    // ==============================================================
    // 4. Properties
    // ==============================================================
    property real minimumValue: 0
    property real maximumValue: 100 // if int is given it will take only int values not decimal
    property real value: 0 // drives the needle
    property real displayedValue: 0 // animated value actually painted
    property bool blink: true

    Behavior on displayedValue {
        NumberAnimation {
            duration: 4000
            easing.type: Easing.InOutQuad
        }
    }

    onValueChanged: {
        displayedValue = value
        updateStatus(value)
    }

    onDisplayedValueChanged: {
        dialCanvas.requestPaint()
    }

    property string status: "Normal"
    property color statusColor: "green"

    // ==============================================================
    // 5. Appearance Properties
    // ==============================================================
    property string title: "Telemetry"
    property string unit: "%"

    property string parameterName: ""
    property string backendProperty: ""

    property bool showTitle: true
    property bool showUnit: true
    property bool showValue: true
    property bool showMinimum: true
    property bool showMaximum: true

    property string dialType: "ThreeQuarter" //for changing dial Arc

    property int majorTickCount: 10
    property real tickInterval: 10
    property int minorTicksPerMajor: 5

    property real startAngle: 225
    property real endAngle: -45
    onShowMinimumChanged: dialCanvas.requestPaint()
    onShowMaximumChanged: dialCanvas.requestPaint()

    // ==============================================================
    // 6. Theme Properties
    // ==============================================================
    property string theme: "dark"

    property color currentDialColor: theme === "light" ? "#F5F5F5" : "#151515"
    property color currentTextColor: theme === "light" ? "#222222" : "white"
    property color currentTickColor: theme === "light" ? "#222222" : "white"
    property color bezelColor: "#71bfb1"
    property color minMaxColor: "#e530f2"

    property color needleColor: "#FF5500" //needle color changing
    property bool useThresholdNeedleColor: true

    onThemeChanged: dialCanvas.requestPaint()

    // ==============================================================
    // 8. Threshold Model
    // ==============================================================
    property var thresholds: []

    function clearThresholds() {
        thresholds = []
        dialCanvas.requestPaint()
    }

    function addThreshold(from, to, color, status) {
        thresholds.push({
                            "from": from,
                            "to": to,
                            "color": color,
                            "status": status
                        })
        dialCanvas.requestPaint()
    }

    function loadThresholds(list) {
        clearThresholds()

        for (var i = 0; i < list.length; i++) {
            addThreshold(list[i].from, list[i].to, list[i].color,
                         list[i].status)
        }
    }

    function loadConfiguration(config, currentValue) {
        title = config.title
        parameterName = config.parameterName
        backendProperty = config.backendProperty
        unit = config.unit

        minimumValue = config.minimum
        maximumValue = config.maximum
        tickInterval = config.tickInterval
        majorTickCount = config.majorTickCount

        value = currentValue

        loadThresholds(config.thresholds)

        updateStatus(currentValue)

        dialCanvas.requestPaint()
    }

    function updateStatus(v) {
        for (var i = 0; i < thresholds.length; i++) {
            var threshold = thresholds[i]

            if (v >= threshold.from && v < threshold.to) {
                status = threshold.status
                statusColor = threshold.color
                dialCanvas.requestPaint()
                return
            }
        }
        if (thresholds.length > 0 && v === maximumValue) {
            var lastThreshold = thresholds[thresholds.length - 1]
            status = lastThreshold.status
            statusColor = lastThreshold.color
        }

        dialCanvas.requestPaint()
    }

    function updateDial() {
        switch (dialType) {
        case "Full":
            startAngle = 270
            endAngle = -89
            break
        case "Half":
            startAngle = 180
            endAngle = 0
            break
        default:
            // ThreeQuarter
            startAngle = 225
            endAngle = -45
            break
        }
        console.log("Dial Type:", dialType)
        console.log("Start:", startAngle)
        console.log("End:", endAngle)

        dialCanvas.requestPaint()
    }
    Component.onCompleted: {
        updateDial()
    }

    onDialTypeChanged: {
        updateDial()
    }

    // ==============================================================
    // 9. Helper Functions
    // ==============================================================

    // If value is exactly the maximum value
    function thresholdColorForValue(v) {
        if (root.thresholds.length === 0)
            return root.needleColor

        for (var i = 0; i < root.thresholds.length; i++) {
            if (v >= root.thresholds[i].from && v < root.thresholds[i].to)
                return root.thresholds[i].color
        }

        return root.thresholds[root.thresholds.length - 1].color
    }
    function valueToAngle(v) {
        var ratio = (v - minimumValue) / (maximumValue - minimumValue) //convertion from value to %
        var sweep = endAngle - startAngle // total angle

        return startAngle + sweep * ratio //actual angle calculation
    }

    function angleToPoint(angle, radiusValue) {
        var rad = angle * Math.PI / 180

        return {
            "x": dialCanvas.width / 2 + radiusValue * Math.cos(rad),
            "y": dialCanvas.height / 2 - radiusValue * Math.sin(rad)
        }
    }
    function tickValue(index) {
        return minimumValue + index * tickInterval
    }

    function majorTickPoint(index, radiusValue) {

        var sweep = endAngle - startAngle

        var angle = startAngle + sweep * index / majorTickCount

        return angleToPoint(angle, radiusValue)
    }

    function minorTickAngle(majorIndex, subIndex) {
        var sweep = endAngle - startAngle

        var start = startAngle + sweep * majorIndex / majorTickCount

        var end = startAngle + sweep * (majorIndex + 1) / majorTickCount

        return start + (end - start) * subIndex / minorTicksPerMajor
    }

    function drawBezel(ctx, cx, cy, radius) {
        ctx.beginPath()
        ctx.arc(cx, cy, radius, 0, 2 * Math.PI)

        var gradient = ctx.createRadialGradient(cx, cy, radius * 0.2, cx,
                                                cy, radius)

        gradient.addColorStop(0, "#909090")
        gradient.addColorStop(0.3, "#707070")
        gradient.addColorStop(0.6, "#505050")
        gradient.addColorStop(1, "#202020")

        ctx.fillStyle = gradient
        ctx.fill()

        ctx.lineWidth = radius * 0.03
        ctx.strokeStyle = root.bezelColor
        ctx.stroke()
    }

    function drawDialFace(ctx, cx, cy, radius) {
        ctx.beginPath()
        ctx.arc(cx, cy, radius - 18, 0, 2 * Math.PI)

        ctx.fillStyle = root.currentDialColor
        ctx.fill()
    }

    function drawThresholdArc(ctx, cx, cy, radius, sweepAngle) {
        var arcRadius = radius - 8

        for (var t = 0; t < root.thresholds.length; t++) {
            var threshold = root.thresholds[t]

            var startRatio = (threshold.from - root.minimumValue)
                    / (root.maximumValue - root.minimumValue)

            var endRatio = (threshold.to - root.minimumValue)
                    / (root.maximumValue - root.minimumValue)

            var thresholdStart = startAngle + sweepAngle * startRatio

            var thresholdEnd = startAngle + sweepAngle * endRatio

            var startRad = thresholdStart * Math.PI / 180

            var endRad = thresholdEnd * Math.PI / 180

            ctx.beginPath()

            ctx.lineWidth = radius * 0.07
            ctx.strokeStyle = threshold.color

            ctx.arc(cx, cy, arcRadius, -startRad, -endRad, false)

            ctx.stroke()
        }
    }

    function drawMajorTicks(ctx, cx, cy, radius, majorTickLength, sweepAngle) {
        ctx.strokeStyle = root.currentTickColor
        ctx.lineWidth = radius * 0.012

        var totalTicks = root.majorTickCount

        for (var majorIndex = 0; majorIndex <= totalTicks; majorIndex++) {
            var outerPoint = majorTickPoint(majorIndex, radius)
            var innerPoint = majorTickPoint(majorIndex,
                                            radius - majorTickLength)

            ctx.beginPath()
            ctx.moveTo(innerPoint.x, innerPoint.y)
            ctx.lineTo(outerPoint.x, outerPoint.y)
            ctx.stroke()
        }
    }

    function drawMinorTicks(ctx, cx, cy, radius, minorTickLength, sweepAngle) {
        ctx.strokeStyle = root.currentTickColor
        ctx.lineWidth = 1.5

        var totalTicks = root.majorTickCount
        var minorPerMajor = root.minorTicksPerMajor

        for (var tickIndex = 0; tickIndex < totalTicks; tickIndex++) {
            for (var subTickIndex = 1; subTickIndex < minorPerMajor; subTickIndex++) {
                var minorAngle = minorTickAngle(tickIndex, subTickIndex)

                var minorRad = minorAngle * Math.PI / 180

                var outerX = cx + radius * Math.cos(minorRad)

                var outerY = cy - radius * Math.sin(minorRad)

                var innerX = cx + (radius - minorTickLength) * Math.cos(
                            minorRad)

                var innerY = cy - (radius - minorTickLength) * Math.sin(
                            minorRad)

                ctx.beginPath()
                ctx.moveTo(innerX, innerY)
                ctx.lineTo(outerX, outerY)
                ctx.stroke()
            }
        }
    }

    function drawNumbers(ctx, radius) {
        ctx.fillStyle = root.currentTextColor
        ctx.font = "bold " + (radius * 0.13) + "px Arial"
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"

        var totalTicks = root.majorTickCount

        for (var labelIndex = 0; labelIndex <= totalTicks; labelIndex++) {
            var labelValue = tickValue(labelIndex)

            if (labelValue > root.maximumValue)
                labelValue = root.maximumValue

            if (root.dialType === "Full" && labelIndex === totalTicks)
                continue

            var labelAngle = valueToAngle(labelValue)

            var point = angleToPoint(labelAngle, radius - 45)

            ctx.fillText(labelValue, point.x, point.y)
        }
    }

    function drawTexts(ctx, cx, cy, radius) {
        //-----------------------------
        // Title
        //-----------------------------
        if (root.showTitle) {
            ctx.fillStyle = root.currentTextColor
            ctx.font = "bold " + Math.round(radius * 0.1) + "px Arial"
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"

            ctx.fillText(root.title, cx, cy - 55)
        }

        //-----------------------------
        // Unit
        //-----------------------------
        if (root.showUnit) {
            ctx.fillStyle = root.currentTextColor
            ctx.font = "bold " + Math.round(radius * 0.1) + "px Arial"

            ctx.fillText(root.unit, cx, cy - 30)
        }

        //-----------------------------
        // Minimum
        //-----------------------------
        if (root.showMinimum) {
            ctx.fillStyle = root.minMaxColor
            ctx.font = "bold " + Math.round(radius * 0.1) + "px Arial"

            ctx.fillText(root.minimumValue.toFixed(1), cx - radius + 30,
                         cy + radius - 30)
        }

        //-----------------------------
        // Maximum
        //-----------------------------
        if (root.showMaximum) {
            ctx.fillStyle = root.minMaxColor
            ctx.font = "bold " + Math.round(radius * 0.1) + "px Arial"

            ctx.fillText(root.maximumValue.toFixed(1), cx + radius - 30,
                         cy + radius - 30)
        }

        //-----------------------------
        // Current Value
        //-----------------------------
        if (root.showValue) {
            ctx.fillStyle = root.currentTextColor
            ctx.font = "bold " + Math.round(radius * 0.1) + "px Arial"

            ctx.fillText(root.displayedValue.toFixed(1), cx, cy + 40)
        }

        //-----------------------------
        // Status
        //-----------------------------
        if (root.showValue) {
            ctx.fillStyle = root.statusColor
            ctx.font = "bold " + Math.round(radius * 0.09) + "px Arial"
            if (blink) {
                ctx.fillText(root.status.toUpperCase(), cx, cy + 70)
            }
        }
    }

    function drawNeedle(ctx, cx, cy, radius) {
        var needleAngle = valueToAngle(displayedValue)
        var needleRad = needleAngle * Math.PI / 180

        var tip = angleToPoint(needleAngle, radius - 50)

        var needleX = tip.x
        var needleY = tip.y

        var needleWidth = radius * 0.03

        var perpX = -Math.sin(needleRad) * needleWidth
        var perpY = -Math.cos(needleRad) * needleWidth

        var baseLength = radius * 0.18

        var baseX = cx - baseLength * Math.cos(needleRad)
        var baseY = cy + baseLength * Math.sin(needleRad)

        ctx.beginPath()

        ctx.moveTo(baseX + perpX, baseY + perpY)

        ctx.lineTo(needleX, needleY)

        ctx.lineTo(baseX - perpX, baseY - perpY)

        ctx.closePath()

        ctx.fillStyle = root.useThresholdNeedleColor ? thresholdColorForValue(
                                                           root.displayedValue) : root.needleColor

        ctx.strokeStyle = "white"
        ctx.lineWidth = 2

        ctx.fill()
    }

    function drawNeedleHub(ctx, cx, cy, radius) {
        //------------------------
        // Outer Hub
        //------------------------
        ctx.beginPath()

        ctx.arc(cx, cy, radius * 0.07, 0, 2 * Math.PI)

        ctx.fillStyle = "#151515"
        ctx.fill()

        ctx.strokeStyle = "#6EC6E8"
        ctx.lineWidth = 2
        ctx.stroke()

        //------------------------
        // Inner Hub
        //------------------------
        ctx.beginPath()

        ctx.arc(cx, cy, radius * 0.03, 0, 2 * Math.PI)

        ctx.fillStyle = "#D5D5D5"
        ctx.fill()

        //------------------------
        // Highlight
        //------------------------
        ctx.beginPath()

        ctx.arc(cx - 2, cy - 2, 2, 0, 2 * Math.PI)

        ctx.fillStyle = "white"
        ctx.fill()
    }

    function toggleTheme() {
        root.theme = (root.theme === "dark") ? "light" : "dark"
    }

    function setNeedleColor(color) {
        root.useThresholdNeedleColor = false
        root.needleColor = color
        dialCanvas.requestPaint()
    }

    function enableThresholdNeedle() {
        root.useThresholdNeedleColor = true
        dialCanvas.requestPaint()
    }

    //-------------------------Timer------------------------
    Timer {
        id: blinkTimer

        interval: 500
        running: true
        repeat: true

        onTriggered: {
            if (parameterName === "Temprature" && status === "Critical") {
                blink = !blink
            } else if (parameterName === "RPM" && status === "Danger") {
                blink = !blink
            } else {
                blink = true
            }

            dialCanvas.requestPaint()
        }
    }

    // ==============================================================
    // 10. Canvas
    // ==============================================================
    Canvas {
        id: dialCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            // Shared dial geometry used by every drawing step below
            var cx = width / 2
            var cy = height / 2
            var radius = Math.min(width, height) / 2 - 15
            var majorTickLength = radius * 0.10
            var minorTickLength = radius * 0.06
            var sweepAngle = endAngle - startAngle

            // ----------------------------------------------------
            // 10.1 Draw Bezel
            // ----------------------------------------------------
            drawBezel(ctx, cx, cy, radius)

            // ----------------------------------------------------
            // 10.2 Draw Dial Face
            // ----------------------------------------------------
            drawDialFace(ctx, cx, cy, radius)

            // ----------------------------------------------------
            // 10.3 Draw Threshold Arc
            // ----------------------------------------------------
            drawThresholdArc(ctx, cx, cy, radius, sweepAngle)

            // ----------------------------------------------------
            // 10.4 Draw Major Ticks
            // ----------------------------------------------------
            var totalTicks = root.majorTickCount

            drawMajorTicks(ctx, cx, cy, radius, majorTickLength, sweepAngle)

            // ----------------------------------------------------
            // 10.5 Draw Minor Ticks
            // ----------------------------------------------------
            drawMinorTicks(ctx, cx, cy, radius, minorTickLength, sweepAngle)

            // ----------------------------------------------------
            // 10.6 Draw Numbers
            // ----------------------------------------------------
            drawNumbers(ctx, radius)

            // ----------------------------------------------------
            // 10.7 Draw Title, Unit, Min, Max, Value, Status
            // ----------------------------------------------------
            drawTexts(ctx, cx, cy, radius)

            // ----------------------------------------------------
            // 10.12 Draw Needle
            // ----------------------------------------------------
            drawNeedle(ctx, cx, cy, radius)

            // ----------------------------------------------------
            // 10.13 Draw Needle Hub
            // ----------------------------------------------------
            drawNeedleHub(ctx, cx, cy, radius)
        }
    }

    // ==============================================================
    // 11. MouseArea
    // ==============================================================
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                contextMenu.popup()
            }
        }
    }

    // ==============================================================
    // 12. Context Menu
    // ==============================================================
    Menu {
        id: contextMenu

        Menu {
            title: "Display"

            MenuItem {
                text: root.showTitle ? "✓ Title" : "Title"

                onTriggered: {
                    root.showTitle = !root.showTitle
                }
            }

            MenuItem {
                text: root.showUnit ? "✓ Unit" : "Unit"

                onTriggered: {
                    root.showUnit = !root.showUnit
                }
            }

            MenuItem {
                text: root.showValue ? "✓ Value" : "Value"

                onTriggered: {
                    root.showValue = !root.showValue
                }
            }

            MenuItem {
                text: root.showMinimum ? "✓ Minimum" : "Minimum"

                onTriggered: {
                    root.showMinimum = !root.showMinimum
                }
            }

            MenuItem {
                text: root.showMaximum ? "✓ Maximum" : "Maximum"

                onTriggered: {
                    root.showMaximum = !root.showMaximum
                }
            }
        }

        MenuSeparator {}
        Menu {
            title: "Dial Type"

            MenuItem {
                text: "Three Quarter"

                onTriggered: {
                    root.dialType = "ThreeQuarter"
                }
            }

            MenuItem {
                text: "Half"

                onTriggered: {
                    root.dialType = "Half"
                }
            }

            MenuItem {
                text: "Full"

                onTriggered: {
                    root.dialType = "Full"
                }
            }
        }

        MenuItem {
            text: root.theme === "dark" ? "☀ Light Mode" : "🌙 Dark Mode"
            onTriggered: toggleTheme()
        }

        Menu {
            title: "Needle"

            MenuItem {
                text: "Use Threshold Color"

                onTriggered: enableThresholdNeedle()
            }

            MenuSeparator {}

            MenuItem {
                text: "Red"
                onTriggered: setNeedleColor("red")
            }

            MenuItem {
                text: "Green"
                onTriggered: setNeedleColor("green")
            }

            MenuItem {
                text: "Blue"
                onTriggered: setNeedleColor("blue")
            }
            MenuItem {
                text: "Yellow"
                onTriggered: setNeedleColor("yellow")
            }
        }
        MenuItem {
            text: "Remove Dial"
            onTriggered: root.removeRequested()
        }
    }
}
