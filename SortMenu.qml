import QtQuick 2.15

FocusScope {
    id: root

    anchors.fill: parent
    visible: false

    signal sortSelected(string sortId)
    signal menuClosed()

    property string activeSortId: "alpha_asc"

    function open() {
        for (var i = 0; i < sortItems.count; i++) {
            if (sortItems.get(i).sortId === root.activeSortId) {
                menuList.currentIndex = i;
                break;
            }
        }
        root.visible = true;
        root.forceActiveFocus();
        openAnim.restart();
    }

    function close() {
        closeAnim.restart();
    }

    ListModel {
        id: sortItems
        ListElement { label: "Alphabetical  A → Z";  sortId: "alpha_asc"     }
        ListElement { label: "Alphabetical  Z → A";  sortId: "alpha_desc"    }
        ListElement { label: "Highest Rated First";  sortId: "rating_desc"   }
        ListElement { label: "Lowest Rated First";   sortId: "rating_asc"    }
        ListElement { label: "Most Played First";    sortId: "playtime_desc" }
        ListElement { label: "Least Played First";   sortId: "playtime_asc"  }
        ListElement { label: "Newest Release First"; sortId: "release_desc"  }
        ListElement { label: "Oldest Release First"; sortId: "release_asc"   }
        ListElement { label: "Most Players First";   sortId: "players_desc"  }
        ListElement { label: "Cancel";               sortId: "__cancel__"    }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.55

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        width:  vpx(320)
        height: menuList.contentHeight
        color:  "#23262e"
        opacity: 0

        ListView {
            id: menuList

            anchors.fill: parent
            model: sortItems
            clip: true
            focus: true
            interactive: false

            delegate: Item {
                id: row
                width:  menuList.width
                height: vpx(56)

                readonly property bool isCurrent: ListView.isCurrentItem
                readonly property bool isHovered: rowArea.containsMouse
                readonly property bool isCancel:  model.sortId === "__cancel__"

                Rectangle {
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    height: vpx(2)
                    color: "#05070a"
                    visible: row.isCancel
                }

                Rectangle {
                    anchors.fill: parent
                    color: row.isCurrent
                    ? "#ffffff"
                    : (row.isHovered ? "#3d4450" : "transparent")

                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: vpx(24)
                        rightMargin: vpx(24)
                    }

                    text: model.label
                    color: row.isCurrent ? "#23262e" : "#c6d4df"
                    font.pixelSize: vpx(14)
                    font.family: global.fonts.sans

                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    preventStealing: true

                    onClicked: {
                        menuList.currentIndex = index
                        root._activate(index)
                    }
                }
            }

            Keys.onPressed: {
                if (api.keys.isAccept(event)) {
                    event.accepted = true
                    root._activate(menuList.currentIndex)
                    return
                }

                if (api.keys.isCancel(event) || api.keys.isFilters(event)) {
                    event.accepted = true
                    root.close()
                    return
                }
            }

            Keys.onUpPressed: {
                menuList.currentIndex =
                (menuList.currentIndex - 1 + menuList.count) % menuList.count
                event.accepted = true
            }

            Keys.onDownPressed: {
                menuList.currentIndex =
                (menuList.currentIndex + 1) % menuList.count
                event.accepted = true
            }
        }
    }

    NumberAnimation {
        id: openAnim
        target: panel
        property: "opacity"
        from: 0
        to: 1
        duration: 160
        easing.type: Easing.OutQuad
    }

    SequentialAnimation {
        id: closeAnim

        NumberAnimation {
            target: panel
            property: "opacity"
            from: 1
            to: 0
            duration: 120
            easing.type: Easing.InQuad
        }

        ScriptAction {
            script: {
                root.visible = false
                root.menuClosed()
            }
        }
    }

    function _activate(index) {
        var item = sortItems.get(index)
        if (!item)
            return

            if (item.sortId === "__cancel__") {
                root.close()
                return
            }

            root.activeSortId = item.sortId
            root.sortSelected(item.sortId)
            root.close()
    }
}
