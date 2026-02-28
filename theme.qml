import QtQuick 2.15
import SortFilterProxyModel 0.2

FocusScope {
    id: root
    focus: true

    function vpx(value) {
        return value * (width / 1280);
    }

    readonly property string activeView: {
        if (searchBar.hasFocus)     return "search";
        if (collecBar.activeFocus)  return "collec";
        if (gameGrid.isCollections && !gameGrid.inCollectionGames)
            return "collections";
        return "grid";
    }

    readonly property bool gridIsRoot: {
        if (!gameGrid.isCollections) return true;
        if (gameGrid.inCollectionGames) return false;
        return false;
    }

    SortFilterProxyModel {
        id: searchResultModel
        sourceModel: api.allGames

        sorters: RoleSorter {
            roleName: "sortBy"
            sortOrder: Qt.AscendingOrder
        }

        filters: ExpressionFilter {
            id: searchFilter
            enabled: searchBar.isSearching
            expression: {
                var q = searchBar.searchQuery;
                if (!q) return true;
                var fields = [
                    (model.title     || "").toLowerCase(),
                    (model.developer || "").toLowerCase(),
                    (model.publisher || "").toLowerCase(),
                    (model.genre     || "").toLowerCase()
                ];
                for (var i = 0; i < fields.length; i++) {
                    if (fields[i].indexOf(q) !== -1) return true;
                }
                return false;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#0b1117"
        z: 0
    }

    SearchBar {
        id: searchBar
        anchors {
            top:   parent.top
            left:  parent.left
            right: parent.right
        }
        height: vpx(48)
        gameGridContentY: gameGrid.contentY
        z:                1002

        onFocusDownRequested: {
            searchBar.focus = false;
            collecBar.focus = true;
        }

        onBackToGridRequested: {
            searchBar.clearSearch();
            searchBar.focus = false;
            gameGrid.focus  = true;
        }
    }

    Rectangle {
        id: collecBarBg
        anchors {
            top:   searchBar.bottom
            left:  parent.left
            right: parent.right
        }
        height:  collecBar.height + vpx(3)
        z:       1000
        color:   "#05070a"
        opacity: gameGrid.contentY > vpx(10) ? 0.97 : 0.0
        Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.InOutQuad } }
    }

    NavButton {
        id: btnL1
        label: "L1"
        side:  "left"
        anchors {
            verticalCenter: collecBar.verticalCenter
            left:           parent.left
            leftMargin:     vpx(55)
        }
        width:  vpx(40)
        height: vpx(30)
        z:      1001
        onClicked: collecBar.prevTab()
    }

    NavButton {
        id: btnR1
        label: "R1"
        side:  "right"
        anchors {
            verticalCenter: collecBar.verticalCenter
            right:          parent.right
            rightMargin:    vpx(55)
        }
        width:  vpx(40)
        height: vpx(30)
        z:      1001
        onClicked: collecBar.nextTab()
    }

    CollecListView {
        id: collecBar
        anchors {
            top:         searchBar.bottom
            left:        parent.left
            right:       parent.right
            leftMargin:  vpx(72)
            rightMargin: vpx(72)
        }
        height: vpx(56)
        z:      1000

        Keys.onPressed: {
            if (api.keys.isPrevPage(event)) { event.accepted = true; collecBar.prevTab(); }
            if (api.keys.isNextPage(event)) { event.accepted = true; collecBar.nextTab(); }

            if (api.keys.isCancel(event)) {
                event.accepted = true;
                collecBar.focus = false;
                gameGrid.focus  = true;
            }
        }

        onFocusUpRequested: {
            collecBar.focus = false;
            searchBar.activate();
        }

        Keys.onDownPressed: {
            gameGrid.focus  = true;
            collecBar.focus = false;
        }
    }

    BottomBar {
        id: bottomBar
        anchors {
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        height: vpx(48)
        z:      1002
        opacity: gameGrid.contentY > vpx(10) ? 0.97 : 1.0

        activeView:    root.activeView
        currentGame:   gameGrid.currentEntry
        searchHasText: searchBar.hasText
        isRootGrid:    root.gridIsRoot

        onFavoriteClicked: {
            gameGrid.toggleFavorite();
        }

        onPlayClicked: {
            gameGrid.launchCurrent();
        }

        onBackClicked: {
            if (root.activeView === "search") {
                if (searchBar.isSearching) {
                    searchBar.backspaceOne();
                } else {
                    searchBar.clearSearch();
                    searchBar.focus = false;
                    gameGrid.focus  = true;
                }
            } else if (root.activeView === "collec") {
                collecBar.focus = false;
                gameGrid.focus  = true;
            } else if (root.activeView === "collections") {
                gameGrid.focus  = false;
                collecBar.focus = true;
            } else {
                //Qt.quit();
            }
        }
    }

    GamesGridView {
        id: gameGrid
        anchors {
            top:         collecBar.bottom
            left:        parent.left
            right:       parent.right
            bottom:      bottomBar.top
            leftMargin:  vpx(50)
            rightMargin: vpx(50)
            topMargin:   vpx(12)
        }
        z: 0

        gamesModel:    searchBar.isSearching ? searchResultModel  : collecBar.currentGames
        isCollections: searchBar.isSearching ? false              : collecBar.currentIsCollections

        focus: true

        onPrevTabRequested: collecBar.prevTab()
        onNextTabRequested: collecBar.nextTab()

        onExitRequested: Qt.quit()

        Keys.onUpPressed: {
            if (!isCollections || !inCollectionGames) {
                gameGrid.focus  = false;
                collecBar.focus = true;
            }
        }
    }
}
