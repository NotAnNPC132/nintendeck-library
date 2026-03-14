import QtQuick 2.15
import QtGraphicalEffects 1.15
import "Utils.js" as Utils

Item {
    id: root

    property real gameGridContentY: 0

    readonly property string searchQuery: committedQuery
    readonly property bool isSearching: committedQuery.length > 0

    signal focusDownRequested()
    signal backToGridRequested()

    property bool semiTransparent: false
    property bool solidInHub: false
    property bool hidden: false

    opacity: hidden ? 0.0 : 1.0
    visible: opacity > 0.0
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    property string committedQuery: ""

    readonly property bool isActive:        inputField.activeFocus || inputField.text.length > 0
    readonly property bool hasFocus:        inputField.activeFocus
    readonly property bool hasText:         inputField.text.length > 0
    readonly property bool credentialsOpen:          credentialsPopup.isOpen
    readonly property bool credentialsHasText:       credentialsPopup.isOpen && credentialsPopup.credentialsHasText
    readonly property bool credentialsButtonFocused: credentialsPopup.isOpen && credentialsPopup.buttonFocused
    readonly property bool raFocused:       raBtn.activeFocus
    readonly property color _bgDark: "#05070a"
    readonly property color _bgLight: "#ffffff"
    readonly property color _iconIdle: "#ffffff"
    readonly property color _iconActive: "#c6d4df"
    readonly property color _textColor: "#c6d4df"
    readonly property color _placeholder: "#8b929a"
    readonly property color _clockColor: "#ffffff"
    readonly property color _currentIconColor: isActive ? "#000000" : _iconIdle
    readonly property color _currentTextColor: isActive ? "#000000" : _textColor
    readonly property color _currentPlaceholder: isActive ? "#000000" : _placeholder
    property bool batteryCharging: api.device.batteryCharging
    property real batteryPercent:  api.device.batteryPercent
    property int  batteryLevel:    isNaN(batteryPercent) ? -1 : Math.round(batteryPercent * 100)
    property bool hasBattery:      !isNaN(api.device.batteryPercent)

    Timer {
        id: batteryTimer
        interval: 30000
        running:  true
        repeat:   true
        onTriggered: {
            root.batteryCharging = api.device.batteryCharging
            root.batteryPercent  = api.device.batteryPercent
            root.batteryLevel    = isNaN(root.batteryPercent) ? -1 : Math.round(root.batteryPercent * 100)
            root.hasBattery      = !isNaN(api.device.batteryPercent)
        }
    }

    Timer {
        id: debounceTimer
        interval: 250
        repeat: false
        onTriggered: root.committedQuery = Utils.normalizeForSearch(inputField.text)
    }

    Item {
        id: searchZone
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: parent.width * 0.80

        MouseArea {
            id: searchZoneHover
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        Rectangle {
            id: searchBarBg
            anchors.fill: parent
            z: -1

            color: root.isActive
            ? root._bgLight
            : (searchZoneHover.containsMouse ? "#505153" : root._bgDark)

            opacity: root.isActive
            ? 1.0
            : (searchZoneHover.containsMouse
            ? 1.0
            : (root.solidInHub   ? 1.0
            : (root.semiTransparent ? 0.75
            : (root.gameGridContentY > vpx(10) ? 0.97 : 0.0))))

            Behavior on color   { ColorAnimation  { duration: 300; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation  { duration: 450; easing.type: Easing.InOutQuad } }
        }

        Item {
            id: searchIconWrapper
            anchors {
                left: parent.left
                leftMargin: vpx(28)
                verticalCenter: parent.verticalCenter
            }
            width: vpx(20)
            height: vpx(20)
            visible: searchIconImg.status === Image.Ready

            Image {
                id: searchIconImg
                anchors.fill: parent
                source: "assets/icons/search.svg"
                fillMode: Image.PreserveAspectFit
                mipmap: true
                visible: false
            }

            ColorOverlay {
                anchors.fill: searchIconImg
                source: searchIconImg
                color: root._currentIconColor
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: inputField.forceActiveFocus()
            }
        }

        Text {
            id: iconFallback
            anchors {
                left: parent.left
                leftMargin: vpx(28)
                verticalCenter: parent.verticalCenter
            }
            visible: searchIconImg.status !== Image.Ready
            text: "\u2315"
            font.pixelSize: vpx(20)
            font.family: global.fonts.sans
            color: root._currentIconColor
            Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: inputField.forceActiveFocus()
            }
        }

        TextInput {
            id: inputField

            readonly property real _iconRight: searchIconWrapper.visible
            ? searchIconWrapper.x + searchIconWrapper.width
            : iconFallback.x + iconFallback.width

            anchors {
                left: parent.left
                leftMargin: _iconRight + vpx(10)
                right: clearBtn.visible ? clearBtn.left : parent.right
                rightMargin: vpx(12)
                verticalCenter: parent.verticalCenter
            }

            color: root._currentTextColor
            Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }

            font.pixelSize: vpx(17)
            font.family: global.fonts.sans
            clip: true
            maximumLength: 80
            selectionColor: "#2a6496"
            selectedTextColor: "#ffffff"

            Text {
                anchors.fill: parent
                text: "Search for games..."
                color: root._currentPlaceholder
                font: inputField.font
                visible: inputField.text.length === 0
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }

            onTextChanged: debounceTimer.restart()

            Keys.onEscapePressed: {
                inputField.text = "";
                root.focusDownRequested();
                event.accepted = true;
            }

            Keys.onDownPressed: {
                root.focusDownRequested();
                event.accepted = true;
            }

            Keys.onUpPressed: { event.accepted = true; }

            Keys.onPressed: {
                if (event.key === Qt.Key_Right) {
                    if (inputField.text.length === 0 ||
                        inputField.cursorPosition === inputField.text.length) {
                        event.accepted = true
                        raBtn.forceActiveFocus()
                    }

                    return
                }

                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    if (inputField.text.length > 0) {
                        inputField.text = inputField.text.slice(0, -1);
                    } else {
                        root.backToGridRequested();
                    }
                }
            }
        }

        Item {
            id: clearBtn
            anchors {
                right: parent.right
                rightMargin: vpx(14)
                verticalCenter: parent.verticalCenter
            }
            width: vpx(18)
            height: vpx(18)
            visible: inputField.text.length > 0
            opacity: clearMouse.containsMouse ? 1.0 : 0.55
            Behavior on opacity { NumberAnimation { duration: 120 } }

            Image {
                id: closeIconImg
                anchors.fill: parent
                source: "assets/icons/close.svg"
                fillMode: Image.PreserveAspectFit
                mipmap: true
                visible: false
            }

            ColorOverlay {
                anchors.fill: closeIconImg
                source: closeIconImg
                color: root._currentIconColor
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                visible: closeIconImg.status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: closeIconImg.status !== Image.Ready
                text: "\u2715"
                font.pixelSize: vpx(13)
                font.family: global.fonts.sans
                color: root._currentIconColor
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    inputField.text = "";
                    inputField.forceActiveFocus();
                }
            }
        }
    }

    Rectangle {
        id: clockZone
        color: root.isActive ? root._bgDark : "transparent"

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: searchZone.right
            right: parent.right
        }

        Rectangle {
            id: clockBg
            anchors.fill: parent
            z: -1
            color: "#05070a"
            opacity: root.solidInHub    ? 1.0
                   : root.semiTransparent ? 0.75
                   : (root.gameGridContentY > vpx(10) ? 0.97 : 0.0)
            Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.InOutQuad } }
        }

        Timer {
            id: clockTimer
            interval: 1000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
                var now = new Date();
                var h = now.getHours();
                var m = ("0" + now.getMinutes()).slice(-2);
                var ampm = h >= 12 ? "p.\u202fm." : "a.\u202fm.";
                h = h % 12;
                if (h === 0) h = 12;
                clockLabel.text = h + ":" + m + " " + ampm;
            }
        }

        Row {
            id: clockRow
            anchors {
                right: parent.right
                rightMargin: vpx(10)
                verticalCenter: parent.verticalCenter
            }
            spacing: vpx(12)
            layoutDirection: Qt.RightToLeft

            Text {
                id: clockLabel
                anchors.verticalCenter: parent.verticalCenter
                color: root._clockColor
                font.pixelSize: vpx(17)
                font.family: global.fonts.sans
                font.bold: true
                text: "--:--"
                opacity: root.semiTransparent ? 1.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.InOutQuad } }
            }

            Row {
                id: batteryIndicator
                spacing: vpx(2)
                anchors.verticalCenter: parent.verticalCenter
                visible: true

                Item {
                    id: batteryIconContainer
                    width:  vpx(26)
                    height: vpx(17)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: batteryIcon
                        anchors.fill: parent
                        source: {
                            if (!root.hasBattery) return "assets/icons/no_battery.svg"
                            if (root.batteryCharging) return "assets/icons/battery_charging.svg"
                            if (root.batteryLevel <= 9) return "assets/icons/battery_0.svg"
                            if (root.batteryLevel <= 34) return "assets/icons/battery_1.svg"
                            if (root.batteryLevel <= 59) return "assets/icons/battery_2.svg"
                            if (root.batteryLevel <= 84) return "assets/icons/battery_3.svg"
                            return "assets/icons/battery_4.svg"
                        }
                        fillMode: Image.PreserveAspectFit
                        mipmap:true
                        visible: true
                    }
                }

                Text {
                    id: batteryText
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!root.hasBattery) return "AC"
                        if (root.batteryCharging) return "⚡" + root.batteryLevel + "%"
                        return root.batteryLevel + "%"
                    }
                    color: {
                        if (!root.hasBattery) return Qt.rgba(1, 1, 1, 0.55)
                        if (root.batteryCharging) return "#4CAF50"
                        if (root.batteryLevel <= 15) return "#F44336"
                        if (root.batteryLevel <= 30) return "#FF9800"
                        return root._clockColor
                    }
                    Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    font.pixelSize: vpx(14)
                    font.family:    global.fonts.sans
                }
            }

            Rectangle {
                width:   vpx(1)
                height:  vpx(18)
                color: "#555555"
                opacity: 0.7
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                id: raBtn
                width: vpx(26)
                height: vpx(26)
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors {
                        fill: parent
                        margins: vpx(-5)
                    }
                    radius: vpx(5)
                    color: raBtn.activeFocus ? "#f5a623" : "transparent"
                    opacity: raBtn.activeFocus ? 0.18 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Image {
                    id: _raIcon
                    anchors.fill: parent
                    source: "assets/icons/retroachievements.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: _raIcon
                    source: _raIcon
                    color: raBtn.activeFocus ? "#f5a623" : "#ffffff"
                    visible: _raIcon.status === Image.Ready
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                }

                Text {
                    anchors.centerIn: parent
                    visible: _raIcon.status !== Image.Ready
                    text: "RA"
                    font.pixelSize: vpx(11)
                    font.bold: true
                    font.family: global.fonts.sans
                    color: raBtn.activeFocus ? "#f5a623" : "#ffffff"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Keys.onLeftPressed: {
                    event.accepted = true
                    inputField.forceActiveFocus()
                    inputField.cursorPosition = inputField.text.length
                }

                Keys.onPressed: {
                    if (api.keys.isCancel(event)) {
                        event.accepted = true
                        inputField.forceActiveFocus()
                        inputField.cursorPosition = inputField.text.length
                        return
                    }

                    if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                        event.accepted = true
                        credentialsPopup.open()
                        return
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (credentialsPopup.isOpen)
                            credentialsPopup.close()
                        else
                            credentialsPopup.open()
                    }
                }
            }
        }
    }

    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left }
        width: parent.width * 0.80
        height: vpx(1)
        color: root.isActive ? Qt.rgba(0, 0, 0, 0.12) : "transparent"
        opacity: root.isActive ? 1.0 : (root.gameGridContentY > vpx(10) ? 0.97 : 0.0)
        Behavior on color   { ColorAnimation  { duration: 300 } }
        Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.InOutQuad } }
    }

    RACredentialsPopup {
        id: credentialsPopup

        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        width:  parent.width
        height: vpx(260)

        onCredentialsSaved: raBtn.forceActiveFocus()
        onPopupClosed: raBtn.forceActiveFocus()
    }

    Component.onCompleted: {
        root.batteryCharging = api.device.batteryCharging
        root.batteryPercent = api.device.batteryPercent
        root.batteryLevel = isNaN(root.batteryPercent) ? -1 : Math.round(root.batteryPercent * 100)
        root.hasBattery = !isNaN(api.device.batteryPercent)
    }

    function activate() { inputField.forceActiveFocus(); }
    function clearSearch() { inputField.text = ""; }
    function clearSearchImmediate() {
        debounceTimer.stop();
        inputField.text = "";
        committedQuery  = "";
    }

    function backspaceOne() {
        if (inputField.text.length > 0)
            inputField.text = inputField.text.slice(0, -1);
        else
            root.backToGridRequested();
    }
}
