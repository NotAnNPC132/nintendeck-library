import QtQuick 2.15
import QtGraphicalEffects 1.15
import SortFilterProxyModel 0.2
import "Utils.js" as Utils

FocusScope {
    id: root

    signal prevTabRequested()
    signal nextTabRequested()
    signal exitRequested()
    signal sortMenuRequested()

    property var  gamesModel: api.allGames
    property bool isCollections: false
    property bool inCollectionGames: false
    property var  activeCollectionGames: null
    property string activeCollectionName: ""
    readonly property var  currentEntry:  grid.currentItem ? grid.currentItem.entry : null
    readonly property bool showingGames:  !isCollections || inCollectionGames
    property string currentSortId: "alpha_asc"
    property bool preserveSourceOrder: false

    SortFilterProxyModel {
        id: sortProxy

        sourceModel: {
            if (!root.isCollections)    return root.gamesModel
                if (root.inCollectionGames) return root.activeCollectionGames
                    return null
        }

        sorters: [
            RoleSorter { roleName: "sortBy";     sortOrder: Qt.AscendingOrder;  enabled: !root.preserveSourceOrder && root.currentSortId === "alpha_asc"      },
            RoleSorter { roleName: "sortBy";     sortOrder: Qt.DescendingOrder; enabled: !root.preserveSourceOrder && root.currentSortId === "alpha_desc"     },
            RoleSorter { roleName: "rating";     sortOrder: Qt.DescendingOrder; enabled: !root.preserveSourceOrder && root.currentSortId === "rating_desc"    },
            RoleSorter { roleName: "rating";     sortOrder: Qt.AscendingOrder;  enabled: !root.preserveSourceOrder && root.currentSortId === "rating_asc"     },
            RoleSorter { roleName: "playTime";   sortOrder: Qt.DescendingOrder; enabled: !root.preserveSourceOrder && root.currentSortId === "playtime_desc"  },
            RoleSorter { roleName: "playTime";   sortOrder: Qt.AscendingOrder;  enabled: !root.preserveSourceOrder && root.currentSortId === "playtime_asc"   },
            RoleSorter { roleName: "releaseYear";sortOrder: Qt.DescendingOrder; enabled: !root.preserveSourceOrder && root.currentSortId === "release_desc"   },
            RoleSorter { roleName: "releaseYear";sortOrder: Qt.AscendingOrder;  enabled: !root.preserveSourceOrder && root.currentSortId === "release_asc"    },
            RoleSorter { roleName: "players";    sortOrder: Qt.DescendingOrder; enabled: !root.preserveSourceOrder && root.currentSortId === "players_desc"   }
        ]
    }

    property var effectiveModel: {
        if (root.isCollections && !root.inCollectionGames) return api.collections
            if (sortProxy.sourceModel !== null)                return sortProxy
                return root.gamesModel
    }

    onIsCollectionsChanged: { inCollectionGames = false; activeCollectionGames = null; grid.currentIndex = 0 }
    onGamesModelChanged:    { inCollectionGames = false; grid.currentIndex = 0 }

    function toggleFavorite() {
        if (currentEntry && showingGames) currentEntry.favorite = !currentEntry.favorite
    }
    function launchCurrent() {
        if (grid.currentItem) activateEntry(grid.currentItem.entry)
    }

    readonly property int  columns:    6
    readonly property real cellWidth:  Math.floor(width / columns)

    readonly property bool showingCollectionList: isCollections && !inCollectionGames
    readonly property real gridAvailableHeight:   height
    readonly property real cellHeight: showingCollectionList
    ? Math.floor(gridAvailableHeight / 3.0)
    : Math.floor(cellWidth * 1.4)

    readonly property real contentY: grid.contentY

    ConsoleColors { id: consoleColors }

    GridView {
        id: grid

        anchors {
            top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom
            bottomMargin: vpx(10)
        }
        focus: true
        clip:  false

        model:      root.effectiveModel
        cellWidth:  root.cellWidth
        cellHeight: root.cellHeight

        flickDeceleration:    1500
        maximumFlickVelocity: 2500

        delegate: Item {
            id: cell
            width:  root.cellWidth
            height: root.cellHeight

            property var  entry:     modelData
            property bool isCurrent: GridView.isCurrentItem

            readonly property bool isGame: !root.showingCollectionList

            readonly property string sortBadgeText: {
                if (root.preserveSourceOrder || !isGame || !entry) return ""
                var sid = root.currentSortId
                if (sid === "alpha_asc") return ""

                if (sid === "alpha_desc") return "Z→A"

                if (sid === "rating_desc" || sid === "rating_asc")
                    return Math.round((entry.rating || 0) * 100) + "%"

                if (sid === "playtime_desc" || sid === "playtime_asc") {
                    var secs = entry.playTime || 0
                    var h  = Math.floor(secs / 3600)
                    var m  = Math.floor((secs % 3600) / 60)
                    var s  = secs % 60
                    return (h  < 10 ? "0" + h  : "" + h)  + ":" +
                           (m  < 10 ? "0" + m  : "" + m)  + ":" +
                           (s  < 10 ? "0" + s  : "" + s)
                }

                if (sid === "release_desc" || sid === "release_asc") {
                    var y = entry.releaseYear || 0
                    return y > 0 ? "" + y : ""
                }

                if (sid === "players_desc") {
                    var p = entry.players || 1
                    return "" + p
                }

                return ""
            }

            property string consoleColor: {
                if (!root.showingCollectionList) return "#1a1a1a"
                    if (!entry || !entry.name) return "#1a1a1a"
                        var sn = entry.shortName || entry.name.toLowerCase()
                        return consoleColors.data[sn] || "#1a1a1a"
            }
            property string systemLogoUrl: {
                if (!root.showingCollectionList) return ""
                    if (!entry || !entry.name) return ""
                        var sn = entry.shortName || entry.name.toLowerCase()
                        return "assets/systems/" + sn + ".png"
            }
            property string coverUrl: {
                if (root.isCollections && !root.inCollectionGames)
                    return entry.assets.background || entry.assets.boxFront || ""
                    return entry.assets.boxFront || ""
            }
            property string coverLabel: {
                if (root.isCollections && !root.inCollectionGames) return entry.name
                    return entry.title
            }

            Item {
                id: glowSource
                anchors.fill: parent; anchors.margins: vpx(10)
                visible: false
                Rectangle { anchors.fill: parent; color: cell.consoleColor; visible: root.showingCollectionList; Behavior on color { ColorAnimation { duration: 200 } } }
                Image { anchors.centerIn: parent; width: parent.width * 0.65; height: parent.height * 0.65; source: cell.systemLogoUrl; fillMode: Image.PreserveAspectFit; asynchronous: true; mipmap: true; visible: root.showingCollectionList }
                Image { anchors.fill: parent; source: cell.coverUrl; fillMode: Image.PreserveAspectCrop; asynchronous: true; mipmap: true; visible: !root.showingCollectionList }
            }
            FastBlur {
                id: glowBlur
                anchors.fill: glowSource; anchors.margins: vpx(-15)
                source: glowSource; radius: 75; transparentBorder: true
                opacity: cell.isCurrent && grid.activeFocus ? 0.40 : 0.0
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }
            Image {
                id: cover
                anchors.fill: parent; anchors.margins: vpx(10)
                source: cell.coverUrl; fillMode: Image.PreserveAspectCrop; asynchronous: true; mipmap: true
                Rectangle { anchors.fill: parent; color: root.showingCollectionList ? cell.consoleColor : "#1a1a1a"; visible: cover.status !== Image.Ready; Behavior on color { ColorAnimation { duration: 200 } } }
            }
            Image {
                id: systemLogo
                anchors.centerIn: cover; width: cover.width * 0.65; height: cover.height * 0.65
                source: cell.systemLogoUrl; fillMode: Image.PreserveAspectFit; asynchronous: true; mipmap: true
                visible: root.showingCollectionList; opacity: 0.6; z: 1
            }
            Text {
                anchors { left: cover.left; right: cover.right; bottom: cover.bottom; leftMargin: vpx(6); rightMargin: vpx(6); bottomMargin: vpx(8) }
                visible: root.showingCollectionList; text: cell.coverLabel; color: "#ffffff"
                font.family: global.fonts.sans; font.pixelSize: vpx(11); wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter; style: Text.Outline; styleColor: "#05070a"; z: 2
            }
            Item {
                id: favBadge
                readonly property bool sortActive: cell.sortBadgeText !== ""

                anchors {
                    right:        cover.right
                    rightMargin:  vpx(2)
                    bottom:       sortActive ? sortBadge.top : cover.bottom
                    bottomMargin: sortActive ? vpx(4) : vpx(2)
                }

                width: vpx(32); height: vpx(32)
                visible: cell.isGame && cell.entry && cell.entry.favorite === true

                Behavior on anchors.bottomMargin { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Rectangle { anchors.fill: parent; radius: width / 2; color: Qt.rgba(0,0,0,0.70) }
                Image { id: favIconSrc; anchors.centerIn: parent; width: vpx(25); height: vpx(25); source: "assets/icons/favorite.svg"; fillMode: Image.PreserveAspectFit; mipmap: true; visible: false }
                ColorOverlay { anchors.fill: favIconSrc; source: favIconSrc; color: "#00ff08" }
            }
            Item {
                id: sortBadge
                anchors { left: cover.left; right: cover.right; bottom: cover.bottom }
                height: vpx(34)
                visible: cell.sortBadgeText !== ""

                Rectangle {
                    anchors.fill: parent
                    color: "#2b3034"
                }

                Text {
                    id: sortBadgeLabel
                    anchors.centerIn: parent
                    text: cell.sortBadgeText
                    color: "#ffffff"
                    font.family: global.fonts.sans
                    font.pixelSize: vpx(16)
                    font.bold: true
                    font.letterSpacing: vpx(0.3)
                }
            }
            Rectangle {
                id: selectionRect
                anchors.fill: cover
                property real borderExtra: 0
                anchors.margins: vpx(-3.5) - borderExtra
                border.width: vpx(1.5) + borderExtra
                color: "transparent"; border.color: "#c7c7c7"; radius: 0; opacity: 0
                SequentialAnimation on opacity {
                    running: cell.isCurrent && grid.activeFocus; loops: Animation.Infinite
                    NumberAnimation { to: 0.8; duration: 600; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
                    onStopped: selectionRect.opacity = 0
                }
                SequentialAnimation on borderExtra {
                    id: borderPulse; running: false
                    NumberAnimation { to: vpx(3.5); duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 0;        duration: 250; easing.type: Easing.InQuad }
                }
            }
            onIsCurrentChanged: { if (cell.isCurrent && grid.activeFocus) borderPulse.restart() }
            scale: cell.isCurrent && grid.activeFocus ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 120 } }
            MouseArea {
                anchors.fill: parent
                onClicked:       grid.currentIndex = index
                onDoubleClicked: root.activateEntry(cell.entry)
            }
        }

        Keys.onDownPressed: {
            var next = grid.currentIndex + root.columns
            grid.currentIndex = next >= grid.count ? grid.count - 1 : next
            event.accepted = true
        }

        Keys.onPressed: {
            if (!event.isAutoRepeat && api.keys.isAccept(event))  { event.accepted = true; if (grid.currentItem) root.activateEntry(grid.currentItem.entry); return }
            if (api.keys.isDetails(event) && root.showingGames)   { event.accepted = true; root.toggleFavorite(); return }
            if (api.keys.isCancel(event)) {
                event.accepted = true
                if (root.isCollections && root.inCollectionGames) { root.inCollectionGames = false; root.activeCollectionGames = null; grid.currentIndex = 0 }
                else root.exitRequested()
                    return
            }
            if (api.keys.isPrevPage(event)) { event.accepted = true; root.prevTabRequested(); return }
            if (api.keys.isNextPage(event)) { event.accepted = true; root.nextTabRequested(); return }
            if (api.keys.isFilters(event) && root.showingGames) { event.accepted = true; root.sortMenuRequested(); return }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: grid.count === 0 && !root.showingCollectionList
        text: "No games here yet"; color: "#555555"
        font.family: global.fonts.sans; font.pixelSize: vpx(18)
    }

    function activateEntry(entry) {
        if (!entry) return
            if (root.isCollections && !root.inCollectionGames) {
                if (!entry.games || entry.games.count === 0) return
                    root.activeCollectionName  = entry.name
                    root.activeCollectionGames = entry.games
                    root.inCollectionGames     = true
                    grid.currentIndex          = 0
            } else {
                entry.launch()
            }
    }
}
