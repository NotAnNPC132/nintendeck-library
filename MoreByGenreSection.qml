import QtQuick 2.15
import QtGraphicalEffects 1.15
import "Utils.js" as Utils

Item {
    id: root

    property var game: null

    readonly property bool hasGrid: hasGames
    readonly property bool gridActiveFocus: _grid.activeFocus
    function gridFocus() { _grid.forceActiveFocus(); }
    function gridFocusAtZero() { _grid.currentIndex = 0; _grid.forceActiveFocus(); }
    readonly property var currentGame: root._games[_grid.currentIndex] || null
    signal tabFocusRequested()
    signal gameSelected(var game)

    readonly property string _genre: game ? Utils.getFirstGenre(game) : ""

    readonly property var _games: {
        if (_genre === "") return [];

        var unplayed = [];
        var played   = [];
        var key      = _genre.toLowerCase();

        for (var i = 0; i < api.allGames.count; i++) {
            var g = api.allGames.get(i);
            if (!g || g.title === game.title) continue;

            var genres = Utils.cleanAndSplitGenres(
                (g.genreList && g.genreList.length > 0)
                    ? g.genreList.join(",")
                    : (g.genre || "")
            );

            var match = false;
            for (var j = 0; j < genres.length; j++) {
                if (genres[j].toLowerCase() === key) { match = true; break; }
            }
            if (!match) continue;

            if (g.playCount === 0) unplayed.push(g);
            else                   played.push(g);
        }

        function sortGroup(arr) {
            return arr.slice().sort(function(a, b) {
                var diff = b.rating - a.rating;
                return diff !== 0 ? diff : (Math.random() - 0.5);
            });
        }

        return sortGroup(unplayed).concat(sortGroup(played)).slice(0, 8);
    }

    readonly property bool hasGames: _games.length > 0
    implicitHeight: hasGames ? _title.height + vpx(14) + _grid.height
                             : _title.height + vpx(14) + vpx(60)
    visible: true

    Text {
        id: _title
        anchors { top: parent.top; left: parent.left }
        text: "MORE " + root._genre.toUpperCase()
        font.pixelSize: vpx(13); font.bold: true
        font.letterSpacing: vpx(0.8); font.family: global.fonts.sans
        color: "#607d8b"
    }

    Text {
        anchors { top: _title.bottom; left: parent.left; topMargin: vpx(14) }
        visible: !root.hasGames
        text: "No other games found for this genre."
        font.pixelSize: vpx(13); font.family: global.fonts.sans
        color: "#ffffff"
    }

    GridView {
        id: _grid
        visible: root.hasGames
        anchors { top: _title.bottom; left: parent.left; right: parent.right; topMargin: vpx(14) }

        readonly property real cardW: Math.floor((width - vpx(30) * 3) / 4)
        readonly property real imgH:  Math.round(cardW * 0.70)
        readonly property real cardH: imgH

        cellWidth:  cardW + vpx(20)
        cellHeight: cardH + vpx(10)
        height: Math.ceil(root._games.length / 4) * cellHeight - vpx(10)

        model: root._games.length
        interactive: false
        clip: false
        keyNavigationEnabled: true
        keyNavigationWraps: false

        Keys.onUpPressed: {
            if (currentIndex < 4) { event.accepted = true; root.tabFocusRequested(); }
            else { currentIndex -= 4; event.accepted = true; }
        }
        Keys.onDownPressed: {
            var next = currentIndex + 4;
            if (next < root._games.length) { currentIndex = next; event.accepted = true; }
            else { event.accepted = true; }
        }
        Keys.onLeftPressed:  { if (currentIndex > 0) currentIndex--; event.accepted = true; }
        Keys.onRightPressed: { if (currentIndex < root._games.length - 1) currentIndex++; event.accepted = true; }

        Keys.onPressed: {
            if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                event.accepted = true;
                var g = root._games[currentIndex] || null;
                if (g) root.gameSelected(g);
                return;
            }
            if (!event.isAutoRepeat && api.keys.isDetails(event)) {
                event.accepted = true;
                var gf = root._games[currentIndex] || null;
                if (gf) gf.favorite = !gf.favorite;
                return;
            }
            if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                event.accepted = true; root.tabFocusRequested();
            }
        }

        delegate: Item {
            id: _card
            readonly property bool isCurrent: GridView.isCurrentItem && _grid.activeFocus
            readonly property var _game: root._games[index] || null

            width:  _grid.cardW
            height: _grid.cardH

            Item {
                id: _glowSrc; anchors.fill: parent; visible: false
                Rectangle { anchors.fill: parent; color: "#1a1a1a" }
                Image { anchors.fill: parent; source: _art.source; fillMode: Image.PreserveAspectCrop; asynchronous: true; smooth: true }
            }

            FastBlur {
                anchors.fill: _glowSrc; anchors.margins: vpx(-16)
                source: _glowSrc; radius: 72; transparentBorder: true
                opacity: _card.isCurrent ? 0.40 : 0.0
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }

            Item {
                id: _imgArea
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: Math.round(_card.height * 0.48)
                clip: true

                Image {
                    id: _art
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true; smooth: true
                    source: {
                        var g = _card._game;
                        if (!g) return "";
                        return g.assets.background || g.assets.screenshot
                             || g.assets.banner     || g.assets.titlescreen || "";
                    }
                    Rectangle { anchors.fill: parent; color: "#1c2533"; visible: parent.status !== Image.Ready }
                }

                Image {
                    id: _logo
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: vpx(5) }
                    height: vpx(26)
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft; verticalAlignment: Image.AlignVCenter
                    asynchronous: true; smooth: true
                    source: _card._game ? (_card._game.assets.logo || "") : ""
                    visible: status === Image.Ready && source !== ""
                }

                Item {
                    anchors { right: parent.right; top: parent.top; margins: vpx(4) }
                    width: vpx(22); height: vpx(22)
                    visible: _card._game ? _card._game.favorite === true : false
                    Rectangle { anchors.fill: parent; radius: width/2; color: Qt.rgba(0,0,0,0.70) }
                    Image {
                        id: _favIco; anchors.centerIn: parent; width: vpx(14); height: vpx(14)
                        source: "assets/icons/favorite.svg"; fillMode: Image.PreserveAspectFit; mipmap: true; visible: false
                    }
                    ColorOverlay { anchors.fill: _favIco; source: _favIco; color: "#00ff08" }
                }
            }

            Rectangle {
                anchors { top: _imgArea.bottom; left: parent.left; right: parent.right }
                height: vpx(85)
                color: Qt.rgba(0.07, 0.10, 0.15, 0.96)

                Column {
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: vpx(6) }
                    spacing: vpx(3)

                    Text {
                        width: parent.width
                        text: _card._game ? _card._game.title : ""
                        font.pixelSize: vpx(13); font.bold: true; font.family: global.fonts.sans
                        color: "#ffffff"; elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: (_card._game && _card._game.collections.count > 0) ? _card._game.collections.get(0).name : ""
                        font.pixelSize: vpx(11); font.family: global.fonts.sans
                        color: "#556677"; elide: Text.ElideRight; visible: text !== ""
                    }

                    Row {
                        spacing: vpx(2)
                        visible: _card._game ? (_card._game.rating > 0) : false
                        Repeater {
                            model: 5
                            Image {
                                property real threshold: (index + 1) / 5
                                property real r: _card._game ? _card._game.rating : 0
                                property real half: threshold - 0.1
                                source: r >= threshold ? "assets/icons/star1.png"
                                      : r >= half      ? "assets/icons/star2.png"
                                      :                  "assets/icons/star0.png"
                                width: vpx(13); height: vpx(13)
                                fillMode: Image.PreserveAspectFit; mipmap: true; smooth: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Row {
                        spacing: vpx(4)
                        Rectangle {
                            width: _newTxt.width + vpx(8); height: vpx(16); radius: vpx(3); color: "#1a3a4a"
                            visible: _card._game ? (_card._game.playCount === 0) : false
                            Text { id: _newTxt; anchors.centerIn: parent; text: "NEW"
                                font.pixelSize: vpx(10); font.bold: true; font.family: global.fonts.sans; color: "#57cbde" }
                        }
                        Row {
                            spacing: vpx(3); visible: _card._game ? (_card._game.playCount > 0) : false
                            Text { text: "▶"; font.pixelSize: vpx(10); color: "#57cbde"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: _card._game ? _card._game.playCount + "×" : ""; font.pixelSize: vpx(11); font.family: global.fonts.sans; color: "#57cbde" }
                        }
                    }
                }
            }

            Rectangle {
                id: _selRect
                property real borderExtra: 0
                property real _m: vpx(2) + borderExtra
                x: -_m
                y: -_m
                width:  _card.width + _m * 2
                height: _imgArea.height + vpx(85) + _m * 2
                border.width: vpx(1.5) + borderExtra
                border.color: "#c7c7c7"
                color: "transparent"
                opacity: 0

                SequentialAnimation on opacity {
                    running: _card.isCurrent
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.8; duration: 600; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
                    onStopped: _selRect.opacity = 0
                }
                SequentialAnimation on borderExtra {
                    id: _borderPulse; running: false
                    NumberAnimation { to: vpx(3.5); duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 0;        duration: 250; easing.type: Easing.InQuad }
                }
            }

            onIsCurrentChanged: { if (isCurrent) _borderPulse.restart(); }

            scale: isCurrent ? 1.05 : 1.0
            opacity: isCurrent ? 1.0  : (_grid.activeFocus ? 0.65 : 0.80)
            Behavior on scale { NumberAnimation { duration: 120 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                onClicked: { _grid.currentIndex = index; _grid.forceActiveFocus(); }
                onDoubleClicked: { _grid.currentIndex = index; if (_card._game) root.gameSelected(_card._game); }
            }
        }
    }
}
