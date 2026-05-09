/*
    Copyright (C) 2020 Sebastian J. Wolf and other contributors

    This file is part of RooTelegram.

    RooTelegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    RooTelegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with RooTelegram. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0

Dialog {
    id: createSupergroupPage
    allowedOrientations: Orientation.All

    property bool isChannel: false

    canAccept: titleField.text.trim().length > 0

    onAccepted: {
        tdLibWrapper.sendRequest({
            "@type": "createNewSupergroupChat",
            "@extra": "openDirectly",
            "title": titleField.text.trim(),
            "is_channel": isChannel,
            "description": descriptionField.text.trim(),
            "for_import": false
        });
    }

    DialogHeader {
        id: dialogHeader
        title: isChannel ? "Nuovo Canale" : "Nuovo gruppo"
    }

    SilicaFlickable {
        anchors {
            top: dialogHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: contentColumn.height + Theme.paddingLarge

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingMedium

            TextField {
                id: titleField
                width: parent.width
                label: isChannel ? "Titolo canale" : "Titolo gruppo"
                placeholderText: isChannel ? "Inserisci il titolo del canale" : "Inserisci il titolo del gruppo"
                EnterKey.iconSource: isChannel ? "image://theme/icon-m-enter-next" : "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if (isChannel) {
                        descriptionField.forceActiveFocus();
                    } else if (titleField.text.trim().length > 0) {
                        createSupergroupPage.accept();
                    }
                }
            }

            TextArea {
                id: descriptionField
                visible: isChannel
                width: parent.width
                label: "Descrizione (opzionale)"
                placeholderText: "Inserisci una descrizione"
            }
        }

        VerticalScrollDecorator {}
    }
}
