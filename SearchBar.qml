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

    property string committedQuery: ""
    readonly property bool isActive: inputField.activeFocus || inputField.text.length > 0
    readonly property bool hasFocus:  inputField.activeFocus
    readonly property bool hasText:   inputField.text.length > 0

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
            : (root.gameGridContentY > vpx(10) ? 0.97 : 0.0))

            Behavior on color { ColorAnimation  { duration: 300; easing.type: Easing.InOutQuad } }
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
            opacity: root.gameGridContentY > vpx(10) ? 0.97 : 0.0
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

        Text {
            id: clockLabel
            anchors {
                right: clockZone.right
                rightMargin: vpx(10)
                verticalCenter: parent.verticalCenter
            }
            color: root._clockColor
            font.pixelSize: vpx(17)
            font.family: global.fonts.sans
            font.bold: true
            text: "--:--"
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

    function activate() { inputField.forceActiveFocus(); }
    function clearSearch() { inputField.text = ""; }

    function backspaceOne() {
        if (inputField.text.length > 0)
            inputField.text = inputField.text.slice(0, -1);
        else
            root.backToGridRequested();
    }
}
