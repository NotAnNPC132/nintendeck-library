import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: bottomBar

    width: parent.width
    height: vpx(48)
    color: "#0b1117"
    z: 1002

    property string activeView: "grid"
    property var currentGame: null
    property bool searchHasText: false
    property bool isRootGrid: false

    signal favoriteClicked()
    signal selectClicked()
    signal playClicked()
    signal backClicked()
    signal filterClicked()

    property bool showFilter: false

    // Hub sub-state: synced from GameHubView via theme.qml
    property int  hubActiveTab:  0   // 0 = GAME INFO, 1 = publisher, 2 = genre
    property bool hubPlayFocus: false // true when the PLAY button has focus
    property bool hubGridFocus: false // true when a publisher/genre grid has focus

    readonly property bool showFavorite: activeView === "grid"
                                      || (activeView === "hub" && hubGridFocus)
    readonly property bool showSelect: activeView === "grid"
                                    || activeView === "collections"
                                    || activeView === "home"
                                    || (activeView === "hub" && (hubPlayFocus || hubActiveTab > 0))
    readonly property bool isFav: currentGame ? (currentGame.favorite === true) : false

    readonly property string bLabel: {
        if (activeView === "search" && searchHasText) return "BACKSPACE";
        if (activeView === "grid" && isRootGrid)      return "EXIT";
        if (activeView === "home_viewmore")            return "EXIT";
        if (activeView === "hub")                      return "BACK";
        return "BACK";
    }

    readonly property string aLabel: {
        if (activeView === "collections") return "OK";
        if (activeView === "hub")         return hubPlayFocus ? "PLAY" : "SELECT";
        return "SELECT";
    }

    Image {
        id: logoIcon
        anchors {
            left: parent.left
            leftMargin: vpx(18)
            verticalCenter: parent.verticalCenter
        }
        width: vpx(40)
        height: vpx(40)
        source: "assets/icons/icon_0.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
    }

    Row {
        id: btnRow
        anchors {
            right: parent.right
            rightMargin: vpx(20)
            verticalCenter: parent.verticalCenter
        }
        spacing: vpx(8)

        Item {
            id: btnFav
            visible: bottomBar.showFavorite
            height: vpx(36)
            width: favInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                opacity: favHover.containsMouse ? 0.07 : 0.0
                radius: vpx(4)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Row {
                id: favInner
                anchors.centerIn: parent
                spacing: vpx(7)

                Image {
                    width: vpx(35); height: vpx(35)
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/x.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true; smooth: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: bottomBar.isFav ? "REMOVE FAVORITE" : "ADD FAVORITE"
                    color: "#ffffff"
                    font.family: global.fonts.sans
                    font.pixelSize: vpx(13)
                    font.bold: true
                    font.letterSpacing: vpx(0.6)
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
            MouseArea {
                id: favHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: bottomBar.favoriteClicked()
            }
        }

        Item {
            id: btnSelect
            visible: bottomBar.showSelect
            height: vpx(36)
            width: selectInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                opacity: selectHover.containsMouse ? 0.07 : 0.0
                radius: vpx(4)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Row {
                id: selectInner
                anchors.centerIn: parent
                spacing: vpx(7)

                Image {
                    width: vpx(35); height: vpx(35)
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/a.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true; smooth: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: bottomBar.aLabel
                    color: "#ffffff"
                    font.family: global.fonts.sans
                    font.pixelSize: vpx(13)
                    font.bold: true
                    font.letterSpacing: vpx(0.6)
                }
            }

            MouseArea {
                id: selectHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (bottomBar.activeView === "hub")
                        bottomBar.playClicked();
                    else
                        bottomBar.selectClicked();
                }
            }
        }

        Item {
            id: btnFilter
            visible: bottomBar.showFilter
            height: vpx(36)
            width: filterInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                opacity: filterHover.containsMouse ? 0.07 : 0.0
                radius: vpx(4)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Row {
                id: filterInner
                anchors.centerIn: parent
                spacing: vpx(7)

                Image {
                    width: vpx(35); height: vpx(35)
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/y.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true; smooth: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "SORT BY"
                    color: "#ffffff"
                    font.family: global.fonts.sans
                    font.pixelSize: vpx(13)
                    font.bold: true
                    font.letterSpacing: vpx(0.6)
                }
            }
            MouseArea {
                id: filterHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: bottomBar.filterClicked()
            }
        }

        Item {
            id: btnBack
            height: vpx(36)
            width: backInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                opacity: backHover.containsMouse ? 0.07 : 0.0
                radius: vpx(4)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Row {
                id: backInner
                anchors.centerIn: parent
                spacing: vpx(7)

                Image {
                    width: vpx(35); height: vpx(35)
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/b.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true; smooth: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: bottomBar.bLabel
                    color: "#ffffff"
                    font.family: global.fonts.sans
                    font.pixelSize: vpx(13)
                    font.bold: true
                    font.letterSpacing: vpx(0.6)
                }
            }

            MouseArea {
                id: backHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: bottomBar.backClicked()
            }
        }
    }
}
