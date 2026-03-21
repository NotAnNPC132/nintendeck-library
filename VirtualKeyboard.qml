// WTF-Library Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/

import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root

    property real bottomBarHeight: vpx(48)

    signal keyTapped(string ch)
    signal backspacePressed()
    signal closeRequested()

    readonly property real _screenH: parent ? parent.height : 720
    readonly property real _kbH:     _screenH * 0.35

    height:  _kbH
    anchors {
        left:         parent.left
        right:        parent.right
        bottom:       parent.bottom
        bottomMargin: root.bottomBarHeight
    }
    z:    2000
    clip: true

    property bool isVisible: false

    function show() {
        isVisible = true
        keyGrid.focusRow = 0
        keyGrid.focusCol = 0
        keyGrid.forceActiveFocus()
    }

    function hide() {
        isVisible = false
    }

    function forceActiveFocusOnKeyGrid() {
        keyGrid.forceActiveFocus()
    }

    Item {
        id: panel
        anchors.fill: parent

        transform: Translate {
            y: root.isVisible ? 0 : root._kbH
            Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        }

        Rectangle { anchors.fill: parent; color: "#0b1117" }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: vpx(1); color: "#1e2a35"
        }

        property var rows: [
            [
                {lbl:"1",val:"1",w:1},{lbl:"2",val:"2",w:1},{lbl:"3",val:"3",w:1},
                {lbl:"4",val:"4",w:1},{lbl:"5",val:"5",w:1},{lbl:"6",val:"6",w:1},
                {lbl:"7",val:"7",w:1},{lbl:"8",val:"8",w:1},{lbl:"9",val:"9",w:1},
                {lbl:"0",val:"0",w:1},{lbl:"-",val:"-",w:1},{lbl:"⌫",val:"__BS__",w:1.8}
            ],
            [
                {lbl:"Q",val:"q",w:1},{lbl:"W",val:"w",w:1},{lbl:"E",val:"e",w:1},
                {lbl:"R",val:"r",w:1},{lbl:"T",val:"t",w:1},{lbl:"Y",val:"y",w:1},
                {lbl:"U",val:"u",w:1},{lbl:"I",val:"i",w:1},{lbl:"O",val:"o",w:1},
                {lbl:"P",val:"p",w:1},{lbl:"[",val:"[",w:1},{lbl:"]",val:"]",w:1}
            ],
            [
                {lbl:"A",val:"a",w:1},{lbl:"S",val:"s",w:1},{lbl:"D",val:"d",w:1},
                {lbl:"F",val:"f",w:1},{lbl:"G",val:"g",w:1},{lbl:"H",val:"h",w:1},
                {lbl:"J",val:"j",w:1},{lbl:"K",val:"k",w:1},{lbl:"L",val:"l",w:1},
                {lbl:";",val:";",w:1},{lbl:"'",val:"'",w:1},{lbl:"\\",val:"\\",w:1}
            ],
            [
                {lbl:"Z",val:"z",w:1},{lbl:"X",val:"x",w:1},{lbl:"C",val:"c",w:1},
                {lbl:"V",val:"v",w:1},{lbl:"B",val:"b",w:1},{lbl:"N",val:"n",w:1},
                {lbl:"M",val:"m",w:1},{lbl:",",val:",",w:1},{lbl:".",val:".",w:1},
                {lbl:"/",val:"/",w:1},{lbl:"SPACE",val:" ",w:1.8},{lbl:"▼",val:"__HIDE__",w:0.75}
            ]
        ]

        FocusScope {
            id: keyGrid
            anchors {
                fill:         parent
                topMargin:    vpx(5)
                bottomMargin: vpx(5)
                leftMargin:   vpx(6)
                rightMargin:  vpx(6)
            }
            focus: root.isVisible

            property int focusRow: 0
            property int focusCol: 0

            function clampRow(r) { return Math.max(0, Math.min(panel.rows.length - 1, r)) }
            function clampCol(r, c) { return Math.max(0, Math.min(panel.rows[r].length - 1, c)) }

            function moveFocus(dr, dc) {
                var nr = clampRow(focusRow + dr)
                var nc = (dc !== 0) ? clampCol(nr, focusCol + dc) : clampCol(nr, focusCol)
                focusRow = nr
                focusCol = nc
            }

            function activateKey(val) {
                if      (val === "__BS__")   root.backspacePressed()
                else if (val === "__HIDE__") root.closeRequested()
                else                         root.keyTapped(val)
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Up) {
                    if (focusRow === 0) {
                        event.accepted = true
                        root.closeRequested()
                        return
                    }
                    moveFocus(-1, 0); event.accepted = true; return
                }
                if (event.key === Qt.Key_Down)  { moveFocus( 1, 0); event.accepted = true; return }
                if (event.key === Qt.Key_Left)  { moveFocus( 0,-1); event.accepted = true; return }
                if (event.key === Qt.Key_Right) { moveFocus( 0, 1); event.accepted = true; return }

                if (api.keys.isAccept(event)) {
                    event.accepted = true
                    activateKey(panel.rows[focusRow][focusCol].val)
                    return
                }
                if (api.keys.isCancel(event)) {
                    event.accepted = true
                    root.closeRequested()
                    return
                }
            }

            Column {
                anchors.fill: parent
                spacing:      vpx(3)

                Repeater {
                    model: panel.rows.length

                    Item {
                        id: rowItem
                        property int rowIdx: index
                        property var rowData: panel.rows[index]
                        width:  parent.width
                        height: (parent.height - vpx(3) * (panel.rows.length - 1)) / panel.rows.length

                        property real totalWeight: {
                            var s = 0
                            for (var i = 0; i < rowData.length; i++) s += rowData[i].w
                            return s
                        }

                        Row {
                            anchors.fill: parent
                            spacing:      vpx(3)

                            Repeater {
                                model: rowItem.rowData.length

                                Rectangle {
                                    id: keyRect
                                    property var  kd:        rowItem.rowData[index]
                                    property int  colIdx:    index
                                    property bool isActive:  keyGrid.focusRow === rowItem.rowIdx &&
                                                             keyGrid.focusCol === colIdx
                                    property bool isSpecial: kd.val === "__BS__" ||
                                                             kd.val === "__HIDE__"

                                    width: (rowItem.totalWeight > 0)
                                           ? ((rowItem.width - vpx(3) * (rowItem.rowData.length - 1))
                                              * kd.w / rowItem.totalWeight)
                                           : vpx(40)
                                    height: parent.height
                                    radius: vpx(0)

                                    color: isActive  ? "#ffffff"
                                         : isSpecial ? "#1a2330"
                                         : "#111921"

                                    border.color: isActive ? "#ffffff" : "#1e2a35"
                                    border.width: vpx(1)

                                    Behavior on color        { ColorAnimation { duration: 80 } }
                                    Behavior on border.color { ColorAnimation { duration: 80 } }

                                    Item {
                                        anchors.centerIn: parent
                                        width:   vpx(25)
                                        height:  vpx(25)
                                        visible: kd.val === "__BS__"

                                        Image {
                                            id: bsImg
                                            anchors.fill: parent
                                            source: "assets/icons/delete.svg"
                                            fillMode: Image.PreserveAspectFit
                                            mipmap: true
                                            visible: false
                                        }

                                        ColorOverlay {
                                            anchors.fill: bsImg
                                            source: bsImg
                                            visible: bsImg.status === Image.Ready
                                            color: keyRect.isActive ? "#020508" : "#c6d4df"
                                            Behavior on color { ColorAnimation { duration: 80 } }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: bsImg.status !== Image.Ready
                                            text: "⌫"
                                            color: keyRect.isActive ? "#020508" : "#c6d4df"
                                            font.pixelSize: vpx(16)
                                            font.family: global.fonts.sans
                                            Behavior on color { ColorAnimation { duration: 80 } }
                                        }
                                    }

                                    Item {
                                        anchors.centerIn: parent
                                        width:   vpx(30)
                                        height:  vpx(30)
                                        visible: kd.val === "__HIDE__"

                                        Image {
                                            id: hideImg
                                            anchors.fill: parent
                                            source: "assets/icons/hide.svg"
                                            fillMode: Image.PreserveAspectFit
                                            mipmap: true
                                            visible: false
                                        }

                                        ColorOverlay {
                                            anchors.fill: hideImg
                                            source: hideImg
                                            visible: hideImg.status === Image.Ready
                                            color: keyRect.isActive ? "#020508" : "#7a8fa3"
                                            Behavior on color { ColorAnimation { duration: 80 } }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: hideImg.status !== Image.Ready
                                            text: "▼"
                                            color: keyRect.isActive ? "#020508" : "#7a8fa3"
                                            font.pixelSize: vpx(11)
                                            font.bold: true
                                            font.family: global.fonts.sans
                                            Behavior on color { ColorAnimation { duration: 80 } }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: kd.val !== "__BS__" && kd.val !== "__HIDE__"
                                        text: kd.lbl
                                        color: keyRect.isActive ? "#020508" : "#c6d4df"
                                        font.pixelSize: kd.lbl === "SPACE" ? vpx(18) : vpx(22)
                                        font.family: global.fonts.sans
                                        font.bold: true
                                        Behavior on color { ColorAnimation { duration: 80 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape:  Qt.PointingHandCursor
                                        onClicked: {
                                            keyGrid.focusRow = rowItem.rowIdx
                                            keyGrid.focusCol = colIdx
                                            keyGrid.activateKey(kd.val)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
