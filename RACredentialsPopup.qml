// WTF-Library Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/

import QtQuick 2.15
import QtGraphicalEffects 1.15

FocusScope {
    id: root

    property bool isOpen: false
    readonly property bool buttonFocused: _okBtn.activeFocus || _cancelBtn.activeFocus
    readonly property bool credentialsHasText: _userInput.text.length > 0 || _keyInput.text.length > 0

    signal credentialsSaved()
    signal popupClosed()

    property string _testState: "idle"
    property string _testMsg:   ""

    function open() {
        _userInput.text = api.memory.has("ra_api_user") ? api.memory.get("ra_api_user") : ""
        _keyInput.text  = api.memory.has("ra_api_key")  ? api.memory.get("ra_api_key")  : ""
        _testState = "idle"
        _testMsg   = ""
        isOpen = true
        _focusTimer.start()
    }

    function close() {
        isOpen = false
        root.popupClosed()
    }

    function _save() {
        var u = _userInput.text.trim()
        var k = _keyInput.text.trim()
        if (u === "" || k === "") {
            _testState = "error"
            _testMsg   = "Both fields are required."
            return
        }
        api.memory.set("ra_api_user", u)
        api.memory.set("ra_api_key",  k)
        _testState = "testing"
        _testMsg   = ""
        _testConnection(u, k)
    }

    function _testConnection(user, key) {
        var url = "https://retroachievements.org/API/API_GetUserSummary.php"
                  + "?y=" + encodeURIComponent(key)
                  + "&u=" + encodeURIComponent(user)
                  + "&g=1"
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url, true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    if (data && (data.User || data.Username || data.MemberSince)) {
                        var displayName = data.User || data.Username || user
                        _testState = "success"
                        _testMsg   = "Connected as " + displayName
                        _closeTimer.start()
                    } else {
                        _testState = "error"
                        _testMsg   = "Invalid credentials. Check your API User and Key."
                    }
                } catch(e) {
                    _testState = "error"
                    _testMsg   = "Could not parse server response."
                }
            } else if (xhr.status === 0) {
                // Sin red: guardamos de todas formas
                _testState = "success"
                _testMsg   = "Saved. (No network — could not verify)"
                _closeTimer.start()
            } else {
                _testState = "error"
                _testMsg   = "Server error: HTTP " + xhr.status
            }
        }
        xhr.send()
    }

    Timer {
        id: _closeTimer
        interval: 1400
        onTriggered: {
            isOpen = false
            root.credentialsSaved()
        }
    }

    Timer {
        id: _focusTimer
        interval: 30
        onTriggered: _userInput.forceActiveFocus()
    }

    property real _panelOpacity: isOpen ? 1.0 : 0.0
    Behavior on _panelOpacity { NumberAnimation { duration: 210; easing.type: Easing.InOutQuad } }

    visible: _panelOpacity > 0.001
    opacity: _panelOpacity

    Rectangle {
        id: _panel

        property real _slideOffset: root.isOpen ? 0 : vpx(-8)
        Behavior on _slideOffset { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        anchors.horizontalCenter: parent.horizontalCenter
        width:  vpx(460)
        y:      _slideOffset
        height: _col.height + vpx(36)

        color:  "#0b1117"
        radius: vpx(6)

        Rectangle {
            anchors { fill: parent; margins: vpx(-1) }
            color: "transparent"
            border { color: "#243444"; width: vpx(1) }
            radius: parent.radius + vpx(1)
            z: -1
        }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: vpx(3); color: "#f5a623"; radius: vpx(3)
        }

        Column {
            id: _col
            anchors {
                top: parent.top;   topMargin:   vpx(20)
                left: parent.left; leftMargin:  vpx(22)
                right: parent.right; rightMargin: vpx(22)
            }
            spacing: vpx(12)

            Row {
                spacing: vpx(8)
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    width: vpx(32); height: vpx(32)
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: _titleIcon
                        anchors.fill: parent
                        source: "assets/icons/retroachievements.svg"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true; visible: false
                    }
                    ColorOverlay {
                        anchors.fill: _titleIcon; source: _titleIcon
                        color: "#f5a623"; visible: _titleIcon.status === Image.Ready
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: _titleIcon.status !== Image.Ready
                        text: "RA"; font.pixelSize: vpx(13); font.bold: true; color: "#f5a623"
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Enter your RA credentials here."
                    font.pixelSize: vpx(18); font.family: global.fonts.sans
                    font.bold: true; color: "#c6d4df"
                }
            }

            Rectangle { width: parent.width; height: vpx(1); color: "#1e2e3e" }

            Column {
                width: parent.width; spacing: vpx(5)

                Text {
                    text: "USER NAME:"
                    font.pixelSize: vpx(11); font.family: global.fonts.sans
                    font.letterSpacing: 0.6; color: "#8b929a"
                }

                Rectangle {
                    width: parent.width; height: vpx(32); radius: vpx(4)
                    color:        _userInput.activeFocus ? "#0f2232" : "#292b2d"
                    border.color: _userInput.activeFocus ? "white"   : "#292b2d"
                    border.width: vpx(1)
                    Behavior on color        { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    TextInput {
                        id: _userInput
                        anchors {
                            left: parent.left; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: vpx(10); rightMargin: vpx(10)
                        }
                        color: "#ffffff"; font.pixelSize: vpx(13)
                        font.family: global.fonts.sans
                        selectionColor: "#2a6496"; selectedTextColor: "#ffffff"
                        clip: true
                        readOnly: root._testState === "testing"

                        Text {
                            anchors.fill: parent
                            text: "your username"; color: "#3a4a5a"
                            font: _userInput.font
                            visible: _userInput.text.length === 0
                        }

                        Keys.onDownPressed:   { event.accepted = true; _keyInput.forceActiveFocus() }
                        Keys.onTabPressed:    { event.accepted = true; _keyInput.forceActiveFocus() }
                        Keys.onReturnPressed: { event.accepted = true; _keyInput.forceActiveFocus() }

                        Keys.onPressed: {
                            if (root._testState === "testing") { event.accepted = true; return }
                            if (api.keys.isCancel(event)) {
                                event.accepted = true
                                if (_userInput.text.length > 0)
                                    _userInput.text = _userInput.text.slice(0, -1)
                                return
                            }
                        }
                    }
                }
            }

            Column {
                width: parent.width; spacing: vpx(5)

                Text {
                    text: "API KEY:"
                    font.pixelSize: vpx(11); font.family: global.fonts.sans
                    font.letterSpacing: 0.6; color: "#8b929a"
                }

                Rectangle {
                    width: parent.width; height: vpx(32); radius: vpx(4)
                    color:        _keyInput.activeFocus ? "#0f2232" : "#292b2d"
                    border.color: _keyInput.activeFocus ? "white"   : "#292b2d"
                    border.width: vpx(1)
                    Behavior on color        { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    TextInput {
                        id: _keyInput
                        anchors {
                            left: parent.left; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: vpx(10); rightMargin: vpx(10)
                        }
                        color: "#ffffff"; font.pixelSize: vpx(13)
                        font.family: global.fonts.sans
                        selectionColor: "#2a6496"; selectedTextColor: "#ffffff"
                        clip: true
                        readOnly: root._testState === "testing"

                        Text {
                            anchors.fill: parent
                            text: "your API key"; color: "#3a4a5a"
                            font: _keyInput.font
                            visible: _keyInput.text.length === 0
                        }

                        Keys.onUpPressed:   { event.accepted = true; _userInput.forceActiveFocus() }
                        Keys.onDownPressed: { event.accepted = true; _okBtn.forceActiveFocus() }
                        Keys.onTabPressed:  { event.accepted = true; _okBtn.forceActiveFocus() }

                        Keys.onPressed: {
                            if (root._testState === "testing") { event.accepted = true; return }
                            // isCancel con texto → borrar último carácter (no cerrar)
                            if (api.keys.isCancel(event)) {
                                event.accepted = true
                                if (_keyInput.text.length > 0)
                                    _keyInput.text = _keyInput.text.slice(0, -1)
                                return
                            }
                            if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                                event.accepted = true; root._save()
                            }
                        }
                    }
                }
            }

            Item {
                width:  parent.width
                height: root._testState !== "idle" ? vpx(34) : 0
                clip:   true
                Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }

                Rectangle {
                    anchors { fill: parent; topMargin: vpx(2) }
                    radius: vpx(4)
                    color: {
                        if (root._testState === "testing") return "#1a2535"
                        if (root._testState === "success") return "#0d2918"
                        return "#2a100e"
                    }
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        anchors {
                            left: parent.left; leftMargin: vpx(10)
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: vpx(8)

                        Item {
                            width: vpx(16); height: vpx(16)
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root._testState === "testing"
                            Rectangle {
                                anchors.fill: parent; radius: width / 2
                                color: "transparent"
                                border.width: vpx(2); border.color: "#57cbde"
                                Rectangle {
                                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                                    width: vpx(2); height: vpx(5); color: "#57cbde"; radius: vpx(1)
                                }
                                RotationAnimator on rotation {
                                    running: root._testState === "testing"
                                    loops: Animation.Infinite; from: 0; to: 360; duration: 900
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root._testState === "success" || root._testState === "error"
                            text:  root._testState === "success" ? "✔" : "✘"
                            color: root._testState === "success" ? "#2ecc71" : "#e74c3c"
                            font.pixelSize: vpx(13); font.bold: true
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                if (root._testState === "testing") return "Verifying credentials…"
                                return root._testMsg
                            }
                            color: {
                                if (root._testState === "testing") return "#57cbde"
                                if (root._testState === "success") return "#2ecc71"
                                return "#e74c3c"
                            }
                            font.pixelSize: vpx(11); font.family: global.fonts.sans
                            elide: Text.ElideRight; width: vpx(370)
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: vpx(12)

                Item {
                    id: _okBtn
                    width: vpx(90); height: vpx(32)
                    readonly property bool _busy: root._testState === "testing"

                    Rectangle {
                        anchors.fill: parent; radius: vpx(15)
                        color: {
                            if (_okBtn._busy)       return "#1a2535"
                            if (_okBtn.activeFocus) return "white"
                            return "#292b2d"
                        }
                        border.color: (_okBtn.activeFocus && !_okBtn._busy) ? "#0b1117" : "#292b2d"
                        border.width: vpx(1)
                        opacity: _okBtn._busy ? 0.5 : 1.0
                        Behavior on color        { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on opacity      { NumberAnimation { duration: 150 } }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "OK"
                        font.pixelSize: vpx(13); font.family: global.fonts.sans; font.bold: true
                        color: (_okBtn.activeFocus && !_okBtn._busy) ? "#0b1117" : "white"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Keys.onUpPressed:    { event.accepted = true; _keyInput.forceActiveFocus() }
                    Keys.onRightPressed: { event.accepted = true; _cancelBtn.forceActiveFocus() }
                    Keys.onPressed: {
                        if (_okBtn._busy) { event.accepted = true; return }
                        if (api.keys.isCancel(event)) { event.accepted = true; root.close(); return }
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            event.accepted = true; root._save(); return
                        }
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true; root._save()
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (!_okBtn._busy) root._save() }
                    }
                }

                Item {
                    id: _cancelBtn
                    width: vpx(90); height: vpx(32)

                    Rectangle {
                        anchors.fill: parent; radius: vpx(15)
                        color:        _cancelBtn.activeFocus ? "#2a0f0f" : "#292b2d"
                        border.color: _cancelBtn.activeFocus ? "#e74c3c" : "#292b2d"
                        border.width: vpx(1)
                        Behavior on color        { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: vpx(13); font.family: global.fonts.sans; font.bold: true
                        color: _cancelBtn.activeFocus ? "#e74c3c" : "#8b929a"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Keys.onUpPressed:   { event.accepted = true; _keyInput.forceActiveFocus() }
                    Keys.onLeftPressed: { event.accepted = true; _okBtn.forceActiveFocus() }
                    Keys.onPressed: {
                        if (root._testState === "testing") { event.accepted = true; return }
                        if (api.keys.isCancel(event) || api.keys.isAccept(event)
                            || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true; root.close()
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (root._testState !== "testing") root.close() }
                    }
                }
            }

            Item { width: 1; height: vpx(4) }
        }
    }
}
