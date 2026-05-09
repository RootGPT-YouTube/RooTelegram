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
import "../"

MessageContentBase {
    id: messagePhotoContent

    readonly property alias photoData: photo.photo;
    readonly property real landscapePreviewAspectRatio: (16.0 / 9.0)
    readonly property real portraitPreviewAspectRatio: (9.0 / 16.0)
    readonly property real targetPreviewAspectRatio: getAspectRatio() < 1 ? portraitPreviewAspectRatio : landscapePreviewAspectRatio
    readonly property real previewAreaBase: width * Math.max(Theme.itemSizeExtraSmall, Math.round(width * 0.66666666))
    readonly property real photoPreviewWidth: Math.min(width, Math.round(Math.sqrt(previewAreaBase * targetPreviewAspectRatio)))
    readonly property real photoPreviewHeight: Math.max(Theme.itemSizeExtraSmall, Math.round(photoPreviewWidth / targetPreviewAspectRatio))

    height: photoPreviewHeight

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../../pages/MediaAlbumPage.qml"), {
            "messages" : [rawMessage],
        })
    }
    function getAspectRatio() {
        if (!photoData || !photoData.sizes || photoData.sizes.length === 0) {
            return 1;
        }
        var candidate = photoData.sizes[photoData.sizes.length - 1];
        if ((!candidate || candidate.width === 0 || candidate.height === 0) && photoData.sizes.length > 1) {
           for (var i = (photoData.sizes.length - 2); i >= 0; i--) {
               candidate = photoData.sizes[i];
               if (candidate.width > 0 && candidate.height > 0) {
                   break;
               }
           }
        }
        if (!candidate || candidate.width <= 0 || candidate.height <= 0) {
            return 1;
        }
        return candidate.width / candidate.height;
    }
    TDLibPhoto {
        id: photo
        width: parent.photoPreviewWidth
        height: parent.photoPreviewHeight
        anchors.centerIn: parent
        photo: rawMessage.content.photo
        highlighted: parent.highlighted
    }
}
