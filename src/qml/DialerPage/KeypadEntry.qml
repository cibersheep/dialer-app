/*
 * Copyright 2012-2013 Canonical Ltd.
 *
 * This file is part of dialer-app.
 *
 * dialer-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * dialer-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItems
import Ubuntu.Telephony.PhoneNumber 0.1

FocusScope {
    id: keypadEntry

    property alias value: input.text
    property alias input: input
    property alias placeHolder: hint.text
    property alias placeHolderPixelFontSize: hint.font.pixelSize

    height: input.height

    TextInput {
        id: input

        property bool __adjusting: false

        anchors.left: parent.left
        anchors.leftMargin: units.gu(2)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: TextInput.AlignHCenter
        font.pixelSize: units.dp(39)
        font.weight: Font.Light
        font.family: "Ubuntu"
        color: "#AAAAAA"
        maximumLength: 20
        focus: true
        cursorVisible: true
        clip: true
        opacity: 0.9

        AsYouTypeFormatter {
            id: formatter

            // FIXME: this should probably be done in the component itself
            property string firstDigit: input.text.slice(0,1)
            enabled: firstDigit != "*" && firstDigit != "#"
            defaultRegionCode: "US"
            text: input.text
        }

        Binding {
            target: input
            property: "text"
            value: formatter.formattedText
        }

        // Use a custom cursor that does not blink to avoid extra CPU usage.
        // https://bugs.launchpad.net/dialer-app/+bug/1188669
        cursorDelegate: Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: units.dp(3)
            color: "#DD4814"
            visible: input.text != ""
        }

        // force cursor to be always visible
        onCursorVisibleChanged: {
            if (!cursorVisible)
                cursorVisible = true
        }

        onContentWidthChanged: {
            // avoid infinite recursion here
            if (__adjusting) {
                return;
            }

            __adjusting = true;

            // start by resetting the font size to discover the scale that should be used
            font.pixelSize = units.dp(39);

            // check if it really needs to be scaled
            if (contentWidth > width) {
                var factor = width / contentWidth;
                font.pixelSize = font.pixelSize * factor;
            }
            __adjusting = false;
        }
    }

    MouseArea {
        anchors.fill: input
        property bool held: false
        onClicked: {
            input.cursorPosition = input.positionAt(mouseX,TextInput.CursorOnCharacter)
        }
        onPressAndHold: {
            if (input.text != "") {
                held = true
                input.selectAll()
                input.copy()
            } else {
                input.paste()
            }
        }
        onReleased: {
            if(held) {
                input.deselect()
                held = false
            }

        }
    }

    Label {
        id: hint
        visible: input.text == ""
        anchors.centerIn: input
        text: ""
        fontSize: "x-large"
        font.weight: Font.Light
        font.family: "Ubuntu"
        color: "#464646"
        opacity: 0.9
    }

}
