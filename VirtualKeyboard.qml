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
    readonly property real _kbH: _screenH * 0.35

    height:  _kbH
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        bottomMargin: root.bottomBarHeight
    }
    z:    2000
    clip: true

    property bool isVisible: false
    property bool capsLock: false
    property bool shiftMode: false

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
                {lbl:"1",   shiftLbl:"!",  val:"1",   shiftVal:"!",  isLetter:false, type:"char",  w:1   },
                {lbl:"2",   shiftLbl:"@",  val:"2",   shiftVal:"@",  isLetter:false, type:"char",  w:1   },
                {lbl:"3",   shiftLbl:"#",  val:"3",   shiftVal:"#",  isLetter:false, type:"char",  w:1   },
                {lbl:"4",   shiftLbl:"$",  val:"4",   shiftVal:"$",  isLetter:false, type:"char",  w:1   },
                {lbl:"5",   shiftLbl:"%",  val:"5",   shiftVal:"%",  isLetter:false, type:"char",  w:1   },
                {lbl:"6",   shiftLbl:"^",  val:"6",   shiftVal:"^",  isLetter:false, type:"char",  w:1   },
                {lbl:"7",   shiftLbl:"&",  val:"7",   shiftVal:"&",  isLetter:false, type:"char",  w:1   },
                {lbl:"8",   shiftLbl:"*",  val:"8",   shiftVal:"*",  isLetter:false, type:"char",  w:1   },
                {lbl:"9",   shiftLbl:"(",  val:"9",   shiftVal:"(",  isLetter:false, type:"char",  w:1   },
                {lbl:"0",   shiftLbl:")",  val:"0",   shiftVal:")",  isLetter:false, type:"char",  w:1   },
                {lbl:"-",   shiftLbl:"_",  val:"-",   shiftVal:"_",  isLetter:false, type:"char",  w:1   },
                {lbl:"=",   shiftLbl:"+",  val:"=",   shiftVal:"+",  isLetter:false, type:"char",  w:1   },
                {lbl:"⌫",   shiftLbl:"⌫",  val:"",    shiftVal:"",   isLetter:false, type:"bs",    w:1.8 }
            ],
            [
                {lbl:"q",   shiftLbl:"q",  val:"q",   shiftVal:"q",  isLetter:true,  type:"char",  w:1   },
                {lbl:"w",   shiftLbl:"w",  val:"w",   shiftVal:"w",  isLetter:true,  type:"char",  w:1   },
                {lbl:"e",   shiftLbl:"e",  val:"e",   shiftVal:"e",  isLetter:true,  type:"char",  w:1   },
                {lbl:"r",   shiftLbl:"r",  val:"r",   shiftVal:"r",  isLetter:true,  type:"char",  w:1   },
                {lbl:"t",   shiftLbl:"t",  val:"t",   shiftVal:"t",  isLetter:true,  type:"char",  w:1   },
                {lbl:"y",   shiftLbl:"y",  val:"y",   shiftVal:"y",  isLetter:true,  type:"char",  w:1   },
                {lbl:"u",   shiftLbl:"u",  val:"u",   shiftVal:"u",  isLetter:true,  type:"char",  w:1   },
                {lbl:"i",   shiftLbl:"i",  val:"i",   shiftVal:"i",  isLetter:true,  type:"char",  w:1   },
                {lbl:"o",   shiftLbl:"o",  val:"o",   shiftVal:"o",  isLetter:true,  type:"char",  w:1   },
                {lbl:"p",   shiftLbl:"p",  val:"p",   shiftVal:"p",  isLetter:true,  type:"char",  w:1   },
                {lbl:"[",   shiftLbl:"{",  val:"[",   shiftVal:"{",  isLetter:false, type:"char",  w:1   },
                {lbl:"]",   shiftLbl:"}",  val:"]",   shiftVal:"}",  isLetter:false, type:"char",  w:1   },
                {lbl:"\\",  shiftLbl:"|",  val:"\\",  shiftVal:"|",  isLetter:false, type:"char",  w:1   }
            ],
            [
                {lbl:"Caps", shiftLbl:"Caps", val:"", shiftVal:"", isLetter:false, type:"caps",  w:1.5 },
                {lbl:"a",   shiftLbl:"a",  val:"a",   shiftVal:"a",  isLetter:true,  type:"char",  w:1   },
                {lbl:"s",   shiftLbl:"s",  val:"s",   shiftVal:"s",  isLetter:true,  type:"char",  w:1   },
                {lbl:"d",   shiftLbl:"d",  val:"d",   shiftVal:"d",  isLetter:true,  type:"char",  w:1   },
                {lbl:"f",   shiftLbl:"f",  val:"f",   shiftVal:"f",  isLetter:true,  type:"char",  w:1   },
                {lbl:"g",   shiftLbl:"g",  val:"g",   shiftVal:"g",  isLetter:true,  type:"char",  w:1   },
                {lbl:"h",   shiftLbl:"h",  val:"h",   shiftVal:"h",  isLetter:true,  type:"char",  w:1   },
                {lbl:"j",   shiftLbl:"j",  val:"j",   shiftVal:"j",  isLetter:true,  type:"char",  w:1   },
                {lbl:"k",   shiftLbl:"k",  val:"k",   shiftVal:"k",  isLetter:true,  type:"char",  w:1   },
                {lbl:"l",   shiftLbl:"l",  val:"l",   shiftVal:"l",  isLetter:true,  type:"char",  w:1   },
                {lbl:";",   shiftLbl:":",  val:";",   shiftVal:":",  isLetter:false, type:"char",  w:1   },
                {lbl:"'",   shiftLbl:"\"", val:"'",   shiftVal:"\"", isLetter:false, type:"char",  w:1   }
            ],
            [
                {lbl:"Shift", shiftLbl:"Shift", val:"", shiftVal:"", isLetter:false, type:"shift", w:1.5 },
                {lbl:"z",   shiftLbl:"z",  val:"z",   shiftVal:"z",  isLetter:true,  type:"char",  w:1   },
                {lbl:"x",   shiftLbl:"x",  val:"x",   shiftVal:"x",  isLetter:true,  type:"char",  w:1   },
                {lbl:"c",   shiftLbl:"c",  val:"c",   shiftVal:"c",  isLetter:true,  type:"char",  w:1   },
                {lbl:"v",   shiftLbl:"v",  val:"v",   shiftVal:"v",  isLetter:true,  type:"char",  w:1   },
                {lbl:"b",   shiftLbl:"b",  val:"b",   shiftVal:"b",  isLetter:true,  type:"char",  w:1   },
                {lbl:"n",   shiftLbl:"n",  val:"n",   shiftVal:"n",  isLetter:true,  type:"char",  w:1   },
                {lbl:"m",   shiftLbl:"m",  val:"m",   shiftVal:"m",  isLetter:true,  type:"char",  w:1   },
                {lbl:",",   shiftLbl:"<",  val:",",   shiftVal:"<",  isLetter:false, type:"char",  w:1   },
                {lbl:".",   shiftLbl:">",  val:".",   shiftVal:">",  isLetter:false, type:"char",  w:1   },
                {lbl:"/",   shiftLbl:"?",  val:"/",   shiftVal:"?",  isLetter:false, type:"char",  w:1   },
                {lbl:"SPACE", shiftLbl:"SPACE", val:" ", shiftVal:" ", isLetter:false, type:"space", w:1.8},
                {lbl:"▼",   shiftLbl:"▼",  val:"",    shiftVal:"",   isLetter:false, type:"hide",  w:0.75}
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

            function activateKeyData(kd) {
                var t = kd.type
                if      (t === "caps")  { root.capsLock  = !root.capsLock;  return }
                else if (t === "shift") { root.shiftMode = !root.shiftMode; return }
                else if (t === "bs")    { root.backspacePressed();          return }
                else if (t === "hide")  { root.closeRequested();            return }
                else if (t === "space") { root.keyTapped(" ");              return }
                var base = root.shiftMode ? kd.shiftVal : kd.val
                root.keyTapped((kd.isLetter && root.capsLock) ? base.toUpperCase() : base)
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
                    activateKeyData(panel.rows[focusRow][focusCol])
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
                        property int rowIdx:  index
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
                                    property var  kd:      rowItem.rowData[index]
                                    property int  colIdx:  index
                                    property bool isActive: keyGrid.focusRow === rowItem.rowIdx &&
                                                            keyGrid.focusCol === colIdx

                                    property bool isCapsOn:   kd.type === "caps"  && root.capsLock
                                    property bool isShiftOn:  kd.type === "shift" && root.shiftMode
                                    property bool isToggleOn: isCapsOn || isShiftOn

                                    property string displayLabel: {
                                        var t = kd.type
                                        if (t === "caps")  return root.capsLock  ? "CAPS"  : "Caps"
                                        if (t === "shift") return root.shiftMode ? "SHIFT" : "Shift"
                                        if (t === "bs" || t === "hide") return kd.lbl
                                        if (t === "space") return "SPACE"
                                        var base = root.shiftMode ? kd.shiftLbl : kd.lbl
                                        return (kd.isLetter && root.capsLock) ? base.toUpperCase() : base
                                    }

                                    width: (rowItem.totalWeight > 0)
                                           ? ((rowItem.width - vpx(3) * (rowItem.rowData.length - 1))
                                              * kd.w / rowItem.totalWeight)
                                           : vpx(40)
                                    height: parent.height
                                    radius: vpx(0)

                                    color: isActive   ? "#ffffff"
                                         : isToggleOn ? "#0c2236"
                                         : (kd.type === "bs"    || kd.type === "hide" ||
                                            kd.type === "caps"  || kd.type === "shift") ? "#1a2330"
                                         : "#111921"

                                    border.color: isActive   ? "#ffffff"
                                                : isToggleOn ? "#4a9fd4"
                                                :              "#1e2a35"
                                    border.width: vpx(1)

                                    Behavior on color        { ColorAnimation { duration: 80 } }
                                    Behavior on border.color { ColorAnimation { duration: 80 } }

                                    Rectangle {
                                        visible: keyRect.isToggleOn && !keyRect.isActive
                                        anchors {
                                            top:         parent.top
                                            right:       parent.right
                                            topMargin:   vpx(4)
                                            rightMargin: vpx(4)
                                        }
                                        width:  vpx(5)
                                        height: vpx(5)
                                        radius: vpx(3)
                                        color:  "#4a9fd4"
                                    }

                                    Item {
                                        anchors.centerIn: parent
                                        width:   vpx(25)
                                        height:  vpx(25)
                                        visible: kd.type === "bs"

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
                                        visible: kd.type === "hide"

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
                                        visible: kd.type !== "bs" && kd.type !== "hide"
                                        text: keyRect.displayLabel
                                        color: {
                                            if (keyRect.isActive)   return "#020508"
                                            if (keyRect.isToggleOn) return "#4a9fd4"
                                            return "#c6d4df"
                                        }
                                        font.pixelSize: {
                                            var t = kd.type
                                            if (t === "space")               return vpx(14)
                                            if (t === "caps" || t === "shift") return vpx(15)
                                            return vpx(20)
                                        }
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
                                            keyGrid.activateKeyData(kd)
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
