import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: bottomBar

    width:  parent.width
    height: vpx(48)
    color:  "#0b1117"
    z:      1002

    property string activeView:    "grid"
    property var    currentGame:   null
    property bool   searchHasText: false
    property bool   isRootGrid:    false

    signal favoriteClicked()
    signal playClicked()
    signal backClicked()

    readonly property bool showFavorite: activeView === "grid"
    readonly property bool showPlay:     activeView === "grid"
    readonly property bool isFav:        currentGame ? (currentGame.favorite === true) : false

    readonly property string bLabel: {
        if (activeView === "search" && searchHasText) return "BACKSPACE";
        if (activeView === "grid"   && isRootGrid)    return "EXIT";
        return "BACK";
    }

    Image {
        id: logoIcon
        anchors {
            left:           parent.left
            leftMargin:     vpx(18)
            verticalCenter: parent.verticalCenter
        }
        width:    vpx(40)
        height:   vpx(40)
        source:   "assets/icons/icon_0.png"
        fillMode: Image.PreserveAspectFit
        mipmap:   true
        smooth:   true
    }

    Row {
        id: btnRow
        anchors {
            right:          parent.right
            rightMargin:    vpx(20)
            verticalCenter: parent.verticalCenter
        }
        spacing: vpx(8)

        Item {
            id: btnFav
            visible: bottomBar.showFavorite
            height:  vpx(36)
            width:   favInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color:   "#ffffff"
                opacity: favHover.containsMouse ? 0.07 : 0.0
                radius:  vpx(4)
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
                }
            }
            MouseArea {
                id: favHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    bottomBar.favoriteClicked()
            }
        }

        Item {
            id: btnPlay
            visible: bottomBar.showPlay
            height:  vpx(36)
            width:   playInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color:   "#ffffff"
                opacity: playHover.containsMouse ? 0.07 : 0.0
                radius:  vpx(4)
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            Row {
                id: playInner
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
                    text:           "PLAY"
                    color:          "#ffffff"
                    font.family:    global.fonts.sans
                    font.pixelSize: vpx(13)
                    font.bold:      true
                    font.letterSpacing: vpx(0.6)
                }
            }
            MouseArea {
                id: playHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    bottomBar.playClicked()
            }
        }

        Item {
            id: btnBack
            height: vpx(36)
            width:  backInner.implicitWidth + vpx(20)

            Rectangle {
                anchors.fill: parent
                color:   "#ffffff"
                opacity: backHover.containsMouse ? 0.07 : 0.0
                radius:  vpx(4)
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
                    text:           bottomBar.bLabel
                    color:          "#ffffff"
                    font.family:    global.fonts.sans
                    font.pixelSize: vpx(13)
                    font.bold:      true
                    font.letterSpacing: vpx(0.6)
                }
            }
            MouseArea {
                id: backHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    bottomBar.backClicked()
            }
        }
    }
}
