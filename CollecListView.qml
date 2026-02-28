import QtQuick 2.15
import "Utils.js" as Utils

FocusScope {
    id: root

    property var  currentGames: api.allGames
    property bool currentIsCollections: false

    signal focusUpRequested()

    CollecListModel { id: collecModel }

    function prevTab() {
        if (listView.currentIndex > 0)
            listView.currentIndex--;
    }

    function nextTab() {
        if (listView.currentIndex < listView.model.count - 1)
            listView.currentIndex++;
    }

    function updateCurrent(index) {
        if (collecModel.model.count === 0) return;
        var entry = collecModel.model.get(index);
        if (!entry) return;
        currentIsCollections = entry.isCollections;
        if (!entry.isCollections)
            currentGames = entry.games;
    }

    implicitHeight: listView.height

    ListView {
        id: listView

        anchors.horizontalCenter: parent.horizontalCenter
        width:  Math.min(contentWidth, parent.width)
        height: vpx(56)

        interactive: false

        model: collecModel.model
        orientation: ListView.Horizontal
        spacing: 0
        clip: false
        focus: true

        delegate: Item {
            id: tabItem

            property bool active:   ListView.isCurrentItem
            property bool hasFocus: listView.activeFocus
            property bool hovered:  hoverArea.containsMouse

            width:  tabLabel.implicitWidth + vpx(48)
            height: listView.height

            Rectangle {
                anchors.centerIn: parent
                width:  tabLabel.implicitWidth + vpx(40)
                height: vpx(40)
                radius: vpx(20)
                color: tabItem.active
                ? (tabItem.hasFocus ? "#ffffff" : "#292b2d")
                : (tabItem.hovered ? "#292b2d" : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                id: tabLabel
                anchors.centerIn: parent
                text: model.name
                color: tabItem.active
                ? (tabItem.hasFocus ? "#000000" : "#ffffff")
                : "#ffffff"
                font.family: global.fonts.sans
                font.pixelSize: vpx(18)
                font.bold: tabItem.active
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: listView.currentIndex = index
            }
        }

        Keys.onLeftPressed:  if (currentIndex > 0) currentIndex--
        Keys.onRightPressed: if (currentIndex < model.count - 1) currentIndex++

        Keys.onUpPressed: {
            root.focusUpRequested();
            event.accepted = true;
        }

        onCurrentIndexChanged: root.updateCurrent(currentIndex)
    }

    Component.onCompleted: {
        var saved = api.memory.get("selectedTab");
        if (saved !== undefined && saved < collecModel.model.count)
            listView.currentIndex = saved;
        else
            root.updateCurrent(0);
    }

    Component.onDestruction: {
        api.memory.set("selectedTab", listView.currentIndex);
    }
}
