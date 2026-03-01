import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root

    color:   "#0b1117"
    visible: opacity > 0
    opacity: 1.0

    function hide() { root.opacity = 0; }

    Behavior on opacity { NumberAnimation { duration: 300 } }

    Column {
        anchors.centerIn: parent
        spacing: vpx(20)

        Image {
            id: splashLogo
            anchors.horizontalCenter: parent.horizontalCenter
            source:   "assets/icons/icon_0.png"
            width:    vpx(160)
            height:   vpx(160)
            fillMode: Image.PreserveAspectFit
            mipmap:   true

            layer.enabled: true
            layer.effect: Glow {
                samples: 100
                color:   Qt.rgba(156/255, 156/255, 156/255, 0.1)
                spread:  0.1
                radius:  80
            }

            scale: 1.0
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0;  to: 3.15; duration: 600; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 3.15; to: 1.0;  duration: 600; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "Loading...."
            color:          "#ffffff"
            font.family:    global.fonts.sans
            font.pixelSize: vpx(36)

            layer.enabled: true
            layer.effect: Glow {
                samples: 100
                color:   Qt.rgba(156/255, 156/255, 156/255, 0.1)
                spread:  0.1
                radius:  80
            }

            opacity: 0.8
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.8; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.0; to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
            }

            scale: 1.0
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0;  to: 2.15; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 2.15; to: 1.0;  duration: 800; easing.type: Easing.InOutQuad }
            }
        }
    }
}
