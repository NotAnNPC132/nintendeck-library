import QtQuick 2.15
import SortFilterProxyModel 0.2

FocusScope {
    id: root
    focus: true

    function vpx(value) {
        return value * (width / 1280);
    }

    property string currentScreen: "home"

    readonly property bool onHome:    currentScreen === "home"
    readonly property bool onLibrary: currentScreen === "library"

    function goHome() {
        currentScreen = "home";
        if (homeLoader.item) homeLoader.item.forceActiveFocus();
    }

    function goLibrary() {
        currentScreen = "library";
        gameGridLoader.active = true;
        _focusGridTimer.start();
    }

    Timer {
        id: _focusGridTimer
        interval: 0
        repeat:   false
        onTriggered: {
            if (gameGridLoader.item) gameGridLoader.item.forceActiveFocus();
        }
    }

    function goLibraryKeepFocus() {
        currentScreen = "library";
        gameGridLoader.active = true;
        _restoreSearchFocusTimer.start();
    }

    Timer {
        id: _restoreSearchFocusTimer
        interval: 0
        repeat:   false
        onTriggered: searchBar.activate()
    }

    SplashScreen {
        id: splashScreen
        anchors.fill: parent
        z: 1003
    }

    readonly property string _bottomActiveView: {
        if (onHome) {
            if (homeLoader.item && homeLoader.item.onViewMoreFocused) return "home_viewmore";
            return "grid";
        }

        if (searchBar.hasFocus)    return "search";
        if (collecBar.activeFocus) return "collec";

        var gridItem = gameGridLoader.item;
        if (gridItem && gridItem.isCollections && !gridItem.inCollectionGames)
            return "collections";
        return "grid";
    }

    readonly property var _bottomGame: {
        if (onHome && homeLoader.item) {
            var rec = homeLoader.item.recCurrentGame;
            if (rec) return rec;
            return homeLoader.item.currentGame;
        }
        if (onLibrary && gameGridLoader.item) return gameGridLoader.item.currentEntry;
        return null;
    }

    readonly property bool _bottomIsRoot: {
        if (onHome) return true;
        return false;
    }

    readonly property string activeView: _bottomActiveView

    SortFilterProxyModel {
        id: searchResultModel
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "sortBy"; sortOrder: Qt.AscendingOrder }
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

    Rectangle { anchors.fill: parent; color: "#0b1117"; z: 0 }

    Loader {
        id: homeLoader
        anchors.fill: parent
        active: false
        visible: root.onHome && status === Loader.Ready
        z: 1

        sourceComponent: HomeView {
            onGoToLibrary: root.goLibrary()
            onFocusSearchRequested: searchBar.activate()

            Component.onCompleted: {
                console.log("HomeView cargado completamente");

                Qt.callLater(function() {
                    splashScreen.opacity = 0;
                    resetFocus();
                });
            }
        }

        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("HomeLoader listo");
            }
        }
    }

    Rectangle {
        id: collecBarBg
        anchors { top: searchBar.bottom; left: parent.left; right: parent.right }
        height:  collecBar.height + vpx(3)
        z:       1000
        color:   "#05070a"
        opacity: root.onLibrary && gameGridLoader.item && gameGridLoader.item.contentY > vpx(10) ? 0.97 : 0.0
        Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.InOutQuad } }
    }

    NavButton {
        id: btnL1; label: "L1"; side: "left"
        anchors { verticalCenter: collecBar.verticalCenter; left: parent.left; leftMargin: vpx(55) }
        width: vpx(40); height: vpx(30); z: 1001
        visible: root.onLibrary
        onClicked: collecBar.prevTab()
    }

    NavButton {
        id: btnR1; label: "R1"; side: "right"
        anchors { verticalCenter: collecBar.verticalCenter; right: parent.right; rightMargin: vpx(55) }
        width: vpx(40); height: vpx(30); z: 1001
        visible: root.onLibrary
        onClicked: collecBar.nextTab()
    }

    CollecListView {
        id: collecBar
        anchors {
            top: searchBar.bottom; left: parent.left; right: parent.right
            leftMargin: vpx(72); rightMargin: vpx(72)
        }
        height:  vpx(56)
        z:       1000
        visible: root.onLibrary
        enabled: root.onLibrary

        Keys.onPressed: {
            if (api.keys.isPrevPage(event)) { event.accepted = true; collecBar.prevTab(); }
            if (api.keys.isNextPage(event)) { event.accepted = true; collecBar.nextTab(); }
            if (api.keys.isCancel(event))   {
                event.accepted = true;
                collecBar.focus = false;
                if (gameGridLoader.item) gameGridLoader.item.forceActiveFocus();
            }
        }
        onFocusUpRequested: { collecBar.focus = false; searchBar.activate(); }
        Keys.onDownPressed: {
            if (gameGridLoader.item) gameGridLoader.item.forceActiveFocus();
            collecBar.focus = false;
        }
    }

    Loader {
        id: gameGridLoader
        anchors {
            top: collecBar.bottom; left: parent.left; right: parent.right; bottom: bottomBar.top
            leftMargin: vpx(50); rightMargin: vpx(50); topMargin: vpx(12)
        }
        z: 0
        active: false
        visible: root.onLibrary && status === Loader.Ready

        sourceComponent: GamesGridView {
            id: gameGrid

            focus: root.onLibrary

            gamesModel:    searchBar.isSearching ? searchResultModel : collecBar.currentGames
            isCollections: searchBar.isSearching ? false             : collecBar.currentIsCollections

            onPrevTabRequested: collecBar.prevTab()
            onNextTabRequested: collecBar.nextTab()
            onExitRequested:    root.goHome()

            Keys.onUpPressed: {
                if (!isCollections || !inCollectionGames) {
                    focus           = false;
                    collecBar.focus = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: { parent.forceActiveFocus(); mouse.accepted = false; }
            }
        }

        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("GameGridLoader listo");
            }
        }
    }

    SearchBar {
        id: searchBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: vpx(48)
        gameGridContentY: root.onLibrary && gameGridLoader.item ? gameGridLoader.item.contentY : vpx(11)
        z: 1002

        onFocusDownRequested: {
            searchBar.focus = false;
            if (root.onLibrary) collecBar.focus = true;
            else if (homeLoader.item) homeLoader.item.forceActiveFocus();
        }
        onBackToGridRequested: {
            searchBar.clearSearch();
            searchBar.focus = false;
            if (root.onLibrary && gameGridLoader.item) gameGridLoader.item.forceActiveFocus();
            else if (homeLoader.item) homeLoader.item.forceActiveFocus();
        }
    }

    Connections {
        target: searchBar
        function onIsSearchingChanged() {
            if (searchBar.isSearching && root.onHome) root.goLibraryKeepFocus();
        }
    }

    BottomBar {
        id: bottomBar
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: vpx(48)
        z:      1002

        activeView:    root._bottomActiveView
        currentGame:   root._bottomGame
        searchHasText: searchBar.hasText
        isRootGrid:    root._bottomIsRoot

        onFavoriteClicked: {
            if (root.onHome && homeLoader.item) {
                var g = homeLoader.item.recCurrentGame || homeLoader.item.currentGame;
                if (g) g.favorite = !g.favorite;
            } else if (root.onLibrary && gameGridLoader.item) {
                gameGridLoader.item.toggleFavorite();
            }
        }

        onPlayClicked: {
            if (root.onHome && homeLoader.item && homeLoader.item.currentGame)
                homeLoader.item.currentGame.launch();
            else if (root.onLibrary && gameGridLoader.item)
                gameGridLoader.item.launchCurrent();
        }

        onBackClicked: {
            if (root.onHome) {
                Qt.quit();
            } else {
                if (root._bottomActiveView === "search") {
                    if (searchBar.isSearching) searchBar.backspaceOne();
                    else {
                        searchBar.clearSearch();
                        searchBar.focus = false;
                        if (gameGridLoader.item) gameGridLoader.item.forceActiveFocus();
                    }
                } else if (root._bottomActiveView === "collec") {
                    collecBar.focus = false;
                    if (gameGridLoader.item) gameGridLoader.item.forceActiveFocus();
                } else if (root._bottomActiveView === "collections") {
                    if (gameGridLoader.item) gameGridLoader.item.focus = false;
                    collecBar.focus = true;
                } else {
                    root.goHome();
                }
            }
        }
    }

    Component.onCompleted: {
        loadTimer.start();
    }

    Timer {
        id: loadTimer
        interval: 100
        onTriggered: {
            console.log("Iniciando carga de HomeView");
            homeLoader.active = true;
        }
    }
}
