import QtQuick 2.15
import QtGraphicalEffects 1.15

// ─────────────────────────────────────────────────────────────────────────────
//  GameMediaSection.qml
//  Shows all game media assets in a 4-column × 2-row thumbnail grid.
//  Selecting an item emits mediaViewRequested → GameHubView opens GameMediaView.
// ─────────────────────────────────────────────────────────────────────────────

FocusScope {
    id: root

    property var game: null

    // ── Section interface (expected by GameHubView._connectSection) ───────────
    signal tabFocusRequested()
    signal mediaViewRequested(var mediaList, int startIndex)

    property bool gridActiveFocus: _grid.activeFocus
    property bool hasGrid:         availableMedia.length > 0

    function gridFocusAtZero() {
        _grid.currentIndex = 0
        _grid.forceActiveFocus()
    }

    implicitHeight: _header.height + vpx(12) + _grid.height + vpx(8)

    // ── Media gathering ───────────────────────────────────────────────────────
    property var availableMedia: {
        if (!game) return []
        var assets = game.assets
        var all    = []

        // --- Screenshots ---
        if (assets.screenshotList && assets.screenshotList.length > 0) {
            for (var i = 0; i < assets.screenshotList.length; i++) {
                var ss = assets.screenshotList[i]
                if (ss && ss.toString() !== "")
                    all.push({ source: ss,
                               label: "Screenshot" + (assets.screenshotList.length > 1 ? " "+(i+1) : ""),
                               isVideo: false, orderPriority: 1 })
            }
        } else if (assets.screenshot && assets.screenshot.toString() !== "") {
            all.push({ source: assets.screenshot, label: "Screenshot",
                       isVideo: false, orderPriority: 1 })
        }

        // --- Title screens ---
        if (assets.titlescreenList && assets.titlescreenList.length > 0) {
            for (var j = 0; j < assets.titlescreenList.length; j++) {
                var ts = assets.titlescreenList[j]
                if (ts && ts.toString() !== "")
                    all.push({ source: ts,
                               label: "Title Screen" + (assets.titlescreenList.length > 1 ? " "+(j+1) : ""),
                               isVideo: false, orderPriority: 2 })
            }
        } else if (assets.titlescreen && assets.titlescreen.toString() !== "") {
            all.push({ source: assets.titlescreen, label: "Title Screen",
                       isVideo: false, orderPriority: 2 })
        }

        // --- Other image assets ---
        var others = [
            { prop: "logo",         label: "Logo",        p: 3  },
            { prop: "boxFront",     label: "Box Front",   p: 4  },
            { prop: "boxFull",      label: "Box Full",    p: 5  },
            { prop: "boxBack",      label: "Box Back",    p: 6  },
            { prop: "boxSpine",     label: "Box Spine",   p: 7  },
            { prop: "background",   label: "Background",  p: 8  },
            { prop: "banner",       label: "Banner",      p: 9  },
            { prop: "poster",       label: "Poster",      p: 10 },
            { prop: "tile",         label: "Tile",        p: 11 },
            { prop: "steam",        label: "Steam Grid",  p: 12 },
            { prop: "marquee",      label: "Marquee",     p: 13 },
            { prop: "bezel",        label: "Bezel",       p: 14 },
            { prop: "panel",        label: "Panel",       p: 15 },
            { prop: "cabinetLeft",  label: "Cabinet L",   p: 16 },
            { prop: "cabinetRight", label: "Cabinet R",   p: 17 },
            { prop: "cartridge",    label: "Cartridge",   p: 18 }
        ]
        for (var k = 0; k < others.length; k++) {
            var a  = others[k]
            var ln = a.prop + "List"
            if (assets[ln] && assets[ln].length > 0) {
                for (var l = 0; l < assets[ln].length; l++) {
                    var ls = assets[ln][l]
                    if (ls && ls.toString() !== "")
                        all.push({ source: ls,
                                   label: a.label + (assets[ln].length > 1 ? " "+(l+1) : ""),
                                   isVideo: false, orderPriority: a.p })
                }
            } else if (assets[a.prop] && assets[a.prop].toString() !== "") {
                all.push({ source: assets[a.prop], label: a.label,
                           isVideo: false, orderPriority: a.p })
            }
        }

        // --- Videos ---
        if (assets.videoList && assets.videoList.length > 0) {
            for (var m = 0; m < assets.videoList.length; m++) {
                var vs = assets.videoList[m]
                if (vs && vs.toString() !== "")
                    all.push({ source: vs,
                               label: "Video" + (assets.videoList.length > 1 ? " "+(m+1) : ""),
                               isVideo: true, orderPriority: 99 })
            }
        } else if (assets.video && assets.video.toString() !== "") {
            all.push({ source: assets.video, label: "Video",
                       isVideo: true, orderPriority: 99 })
        }

        all.sort(function(a, b) { return a.orderPriority - b.orderPriority })
        return all
    }

    // ── Header ────────────────────────────────────────────────────────────────
    Row {
        id: _header
        anchors { top: parent.top; left: parent.left }
        spacing: vpx(8)

        Text {
            text: "MEDIA"
            color: "#607d8b"
            font.family: global.fonts.sans
            font.pixelSize: vpx(11)
            font.bold: true
            font.letterSpacing: vpx(1.2)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.availableMedia.length > 0 ? ("" + root.availableMedia.length) : ""
            color: "#3a4a56"
            font.family: global.fonts.sans
            font.pixelSize: vpx(11)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── Empty state ───────────────────────────────────────────────────────────
    Text {
        anchors { top: _header.bottom; topMargin: vpx(20); horizontalCenter: parent.horizontalCenter }
        visible: root.availableMedia.length === 0
        text: "No media available for this game"
        color: "#3a4a56"
        font.family: global.fonts.sans
        font.pixelSize: vpx(13)
    }

    // ── Grid ─────────────────────────────────────────────────────────────────
    GridView {
        id: _grid
        anchors {
            top: _header.bottom; topMargin: vpx(12)
            left: parent.left;   right: parent.right
        }

        readonly property int  _columns: 4
        readonly property real _cellW: Math.floor(parent.width / _columns)
        cellWidth:  _cellW
        cellHeight: Math.floor(_cellW * 9 / 16)   // 16:9 thumbnails
        height:     cellHeight * 2                 // show exactly 2 rows
        clip: false
        focus: true
        keyNavigationEnabled: true
        model: root.availableMedia

        Keys.onPressed: {
            if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                event.accepted = true
                root.tabFocusRequested()
                return
            }
            if (!event.isAutoRepeat && event.key === Qt.Key_Up) {
                // if we're on the first row, go back to the tab bar
                if (_grid.currentIndex < _columns) {
                    event.accepted = true
                    root.tabFocusRequested()
                }
                return
            }
            if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                event.accepted = true
                root.mediaViewRequested(root.availableMedia, _grid.currentIndex)
                return
            }
        }

        // ── Cell delegate ─────────────────────────────────────────────────────
        delegate: Item {
            id: _cell
            width:  _grid.cellWidth
            height: _grid.cellHeight

            readonly property bool isCurrent: _grid.activeFocus && _grid.currentIndex === index

            // Thumbnail source used for both the visible card and the glow
            readonly property string _thumbSrc: modelData.isVideo
                ? (root.game ? (root.game.assets.screenshot || root.game.assets.background || "") : "")
                : modelData.source

            // ── 1. Glow source (invisible, feeds FastBlur) ────────────────────
            Item {
                id: _glowSource
                anchors { fill: _card; margins: vpx(-4) }
                visible: false

                Rectangle {
                    anchors.fill: parent
                    color: "#1c222b"
                }
                Image {
                    anchors.fill: parent
                    source: _cell._thumbSrc
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    mipmap: true
                }
            }

            // ── 2. FastBlur glow ──────────────────────────────────────────────
            FastBlur {
                anchors { fill: _glowSource; margins: vpx(-16) }
                source: _glowSource
                radius: 75
                transparentBorder: true
                opacity: _cell.isCurrent ? 0.40 : 0.0
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }

            // ── 3. Card with rounded clipping ─────────────────────────────────
            Rectangle {
                id: _card
                anchors { fill: parent; margins: vpx(10) }
                radius: vpx(0)
                color: "#0d1921"
                layer.enabled: true

                // Image thumbnail
                Image {
                    anchors.fill: parent
                    source: modelData.isVideo ? "" : modelData.source
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    visible: !modelData.isVideo
                }

                // Video overlay: game screenshot (dim) + play badge
                Item {
                    anchors.fill: parent
                    visible: modelData.isVideo

                    Image {
                        anchors.fill: parent
                        source: root.game
                                ? (root.game.assets.screenshot || root.game.assets.background || "")
                                : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                        opacity: 0.35
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: vpx(28); height: vpx(28)
                        radius: vpx(0)
                        color: "#99000000"
                        border.width: vpx(1)
                        border.color: "#88ffffff"

                        Image {
                            id: _playIconImg
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: vpx(1)
                            width: vpx(10); height: vpx(10)
                            source: "assets/icons/play.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            smooth: true
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: _playIconImg
                            source: _playIconImg
                            color: "#ddffffff"
                        }
                    }
                }

                // Bottom gradient for label legibility
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: vpx(24)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: "#dd000000" }
                    }
                }

                // Media type label
                Text {
                    anchors {
                        left: parent.left; right: parent.right; bottom: parent.bottom
                        leftMargin: vpx(5); rightMargin: vpx(5); bottomMargin: vpx(3)
                    }
                    text: modelData.label
                    color: "#ccffffff"
                    font.family: global.fonts.sans
                    font.pixelSize: vpx(8)
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            // ── 4. Selection rect (pulsing border, identical to GamesGridView) ─
            Rectangle {
                id: _selectionRect
                anchors { fill: _card; margins: -vpx(3.5) - _borderExtra }
                property real _borderExtra: 0
                border.width: vpx(1.5) + _borderExtra
                color: "transparent"
                border.color: "#c7c7c7"
                radius: vpx(0)
                opacity: 0

                SequentialAnimation on opacity {
                    running: _cell.isCurrent
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.8; duration: 600; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
                    onStopped: _selectionRect.opacity = 0
                }

                SequentialAnimation on _borderExtra {
                    id: _borderPulse
                    running: false
                    NumberAnimation { to: vpx(3.5); duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 0;        duration: 250; easing.type: Easing.InQuad }
                }
            }

            // ── 5. Scale ──────────────────────────────────────────────────────
            scale: _cell.isCurrent ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 120 } }

            onIsCurrentChanged: {
                if (_cell.isCurrent) _borderPulse.restart()
            }

            // Mouse: single click focuses, double click opens viewer
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    _grid.currentIndex = index
                    _grid.forceActiveFocus()
                }
                onDoubleClicked: {
                    _grid.currentIndex = index
                    root.mediaViewRequested(root.availableMedia, index)
                }
            }
        }
    }
}
