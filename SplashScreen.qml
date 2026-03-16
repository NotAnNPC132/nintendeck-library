// WTF-Library Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/

import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root

    color: "#0b1117"
    visible: opacity > 0
    opacity: 1.0

    function hide() { root.opacity = 0; }

    Behavior on opacity { NumberAnimation { duration: 300 } }

    Column {
        anchors.centerIn: parent
        spacing: vpx(20)

        Item {
            id: sniperContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: vpx(200)
            height: vpx(200)

            Image {
                id: splashLogo
                anchors.centerIn: parent
                source: "assets/icons/icon_0.png"
                width: vpx(120)
                height: vpx(120)
                fillMode: Image.PreserveAspectFit
                mipmap: true
                z: 2

                layer.enabled: true
                layer.effect: Glow {
                    samples: 100
                    color: Qt.rgba(156/255, 156/255, 156/255, 0.1)
                    spread: 0.1
                    radius: 80
                }

                scale: 1.0
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 1.15; duration: 600; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 1.15; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                }
            }

            Canvas {
                id: sniperCircle
                anchors.fill: parent
                z: 1

                property real angle: 0
                property real arcLength: 270

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = Math.min(width, height) * 0.45;
                    var lineWidth = vpx(4);

                    ctx.clearRect(0, 0, width, height);

                    ctx.strokeStyle = "#4a9eff";
                    ctx.lineWidth = lineWidth;
                    ctx.lineCap = "round";

                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius + lineWidth, 0, Math.PI * 2);
                    ctx.strokeStyle = Qt.rgba(74/255, 158/255, 255/255, 0.2);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.strokeStyle = "#4a9eff";

                    var startAngle = (angle * Math.PI / 180) - (arcLength * Math.PI / 360);
                    var endAngle = (angle * Math.PI / 180) + (arcLength * Math.PI / 360);

                    ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.fillStyle = "#4a9eff";
                    ctx.shadowColor = "#4a9eff";
                    ctx.shadowBlur = 10;

                    var dotX = centerX + radius * Math.cos(angle * Math.PI / 180);
                    var dotY = centerY + radius * Math.sin(angle * Math.PI / 180);

                    ctx.arc(dotX, dotY, lineWidth * 1.5, 0, Math.PI * 2);
                    ctx.fill();
                }

                SequentialAnimation on angle {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0
                        to: 360
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: 360
                        to: 720
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                }

                onAngleChanged: requestPaint()

                layer.enabled: true
                layer.effect: Glow {
                    samples: 50
                    color: "#4a9eff"
                    spread: 0.3
                    radius: 40
                }
            }

            Repeater {
                model: 4

                Rectangle {
                    x: sniperContainer.width / 2 + (sniperContainer.width * 0.45) * Math.cos(index * Math.PI/2) - width/2
                    y: sniperContainer.height / 2 + (sniperContainer.height * 0.45) * Math.sin(index * Math.PI/2) - height/2
                    width: vpx(6)
                    height: vpx(6)
                    radius: width/2
                    color: "#4a9eff"
                    opacity: 0.6

                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 20
                        color: "#4a9eff"
                        spread: 0.2
                        radius: 16
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "¡%$#@!-Library"
            color: "#ffffff"
            font.family: global.fonts.sans
            font.pixelSize: vpx(36)

            layer.enabled: true
            layer.effect: Glow {
                samples: 100
                color: Qt.rgba(156/255, 156/255, 156/255, 0.1)
                spread: 0.1
                radius: 80
            }

            opacity: 0.8
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.8; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.0; to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
            }
        }
    }
}
