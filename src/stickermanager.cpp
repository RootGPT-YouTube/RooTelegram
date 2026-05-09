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

#include "stickermanager.h"
#include <QListIterator>

#define DEBUG_MODULE StickerManager
#include "debuglog.h"

StickerManager::StickerManager(TDLibWrapper *tdLibWrapper, QObject *parent) : QObject(parent)
{
    LOG("Initializing...");
    this->tdLibWrapper = tdLibWrapper;
    this->reloadNeeded = false;

    connect(this->tdLibWrapper, SIGNAL(recentStickersUpdated(QVariantList)), this, SLOT(handleRecentStickersUpdated(QVariantList)));
    connect(this->tdLibWrapper, SIGNAL(stickersReceived(QVariantList)), this, SLOT(handleStickersReceived(QVariantList)));
    connect(this->tdLibWrapper, SIGNAL(installedStickerSetsUpdatedByType(QVariantList, QString)), this, SLOT(handleInstalledStickerSetsUpdatedByType(QVariantList, QString)));
    connect(this->tdLibWrapper, SIGNAL(stickerSetsReceived(QVariantList)), this, SLOT(handleStickerSetsReceived(QVariantList)));
    connect(this->tdLibWrapper, SIGNAL(stickerSetReceived(QVariantMap)), this, SLOT(handleStickerSetReceived(QVariantMap)));
}

StickerManager::~StickerManager()
{
    LOG("Destroying myself...");
}

QVariantList StickerManager::getRecentStickers()
{
    return this->recentStickers;
}

QVariantList StickerManager::getInstalledStickerSets()
{
    return this->installedStickerSets;
}
QVariantList StickerManager::getInstalledCustomEmojiSets()
{
    return this->installedCustomEmojiSets;
}

QVariantMap StickerManager::getStickerSet(const QString &stickerSetId)
{
    if (this->stickerSets.contains(stickerSetId)) {
        return this->stickerSets.value(stickerSetId).toMap();
    }
    return this->customEmojiStickerSets.value(stickerSetId).toMap();
}

bool StickerManager::hasStickerSet(const QString &stickerSetId)
{
    return this->stickerSets.contains(stickerSetId) || this->customEmojiStickerSets.contains(stickerSetId);
}

bool StickerManager::isStickerSetInstalled(const QString &stickerSetId)
{
    return this->installedStickerSetIds.contains(stickerSetId) || this->installedCustomEmojiSetIds.contains(stickerSetId);
}

bool StickerManager::needsReload()
{
    return this->reloadNeeded;
}

void StickerManager::setNeedsReload(const bool &reloadNeeded)
{
    this->reloadNeeded = reloadNeeded;
}

void StickerManager::handleRecentStickersUpdated(const QVariantList &stickerIds)
{
    LOG("Receiving recent stickers...." << stickerIds);
    this->recentStickerIds = stickerIds;
}

void StickerManager::handleStickersReceived(const QVariantList &stickers)
{
    LOG("Receiving stickers....");
    QListIterator<QVariant> stickersIterator(stickers);
    while (stickersIterator.hasNext()) {
        QVariantMap newSticker = stickersIterator.next().toMap();
        this->stickers.insert(newSticker.value("sticker").toMap().value("id").toString(), newSticker);
    }

    this->recentStickers.clear();
    QListIterator<QVariant> stickerIdIterator(this->recentStickerIds);
    while (stickerIdIterator.hasNext()) {
        QString stickerId = stickerIdIterator.next().toString();
        this->recentStickers.append(this->stickers.value(stickerId));
    }
}

void StickerManager::handleInstalledStickerSetsUpdated(const QVariantList &stickerSetIds)
{
    LOG("Receiving installed sticker IDs...." << stickerSetIds);
    this->installedStickerSetIds = stickerSetIds;
}
void StickerManager::handleInstalledStickerSetsUpdatedByType(const QVariantList &stickerSetIds, const QString &stickerType)
{
    if (stickerType == QLatin1String("stickerTypeCustomEmoji")) {
        LOG("Receiving installed custom emoji sticker IDs...." << stickerSetIds);
        this->installedCustomEmojiSetIds = stickerSetIds;
    } else {
        LOG("Receiving installed sticker IDs...." << stickerSetIds);
        this->installedStickerSetIds = stickerSetIds;
    }
}

void StickerManager::handleStickerSetsReceived(const QVariantList &stickerSets)
{
    LOG("Receiving sticker sets....");
    QListIterator<QVariant> stickerSetsIterator(stickerSets);
    while (stickerSetsIterator.hasNext()) {
        QVariantMap newStickerSet = stickerSetsIterator.next().toMap();
        QString newSetId = newStickerSet.value("id").toString();
        QString stickerType = newStickerSet.value("sticker_type").toMap().value("@type").toString();
        bool isCustomEmojiSet = stickerType == QLatin1String("stickerTypeCustomEmoji");
        if (!isCustomEmojiSet && stickerType.isEmpty()
                && this->installedCustomEmojiSetIds.contains(newSetId)
                && !this->installedStickerSetIds.contains(newSetId)) {
            isCustomEmojiSet = true;
        }
        bool hasInstalledFlag = newStickerSet.contains("is_installed");
        bool isInstalled = hasInstalledFlag ? newStickerSet.value("is_installed").toBool() : true;
        QVariantList *installedSetIds = isCustomEmojiSet ? &this->installedCustomEmojiSetIds : &this->installedStickerSetIds;
        QVariantMap *allSets = isCustomEmojiSet ? &this->customEmojiStickerSets : &this->stickerSets;
        if (isInstalled && !installedSetIds->contains(newSetId)) {
            installedSetIds->append(newSetId);
        }
        if (hasInstalledFlag && !isInstalled && installedSetIds->contains(newSetId)) {
            installedSetIds->removeAll(newSetId);
        }
        allSets->insert(newSetId, newStickerSet);
    }

    this->installedStickerSets.clear();
    this->installedCustomEmojiSets.clear();
    QListIterator<QVariant> stickerSetIdIterator(this->installedStickerSetIds);
    int i = 0;
    this->stickerSetMap.clear();
    while (stickerSetIdIterator.hasNext()) {
        QString stickerSetId = stickerSetIdIterator.next().toString();
        if (this->stickerSets.contains(stickerSetId)) {
            this->installedStickerSets.append(this->stickerSets.value(stickerSetId));
            this->stickerSetMap.insert(stickerSetId, i);
            i++;
        }
    }
    QListIterator<QVariant> customSetIdIterator(this->installedCustomEmojiSetIds);
    int customIndex = 0;
    this->customEmojiStickerSetMap.clear();
    while (customSetIdIterator.hasNext()) {
        QString stickerSetId = customSetIdIterator.next().toString();
        if (this->customEmojiStickerSets.contains(stickerSetId)) {
            this->installedCustomEmojiSets.append(this->customEmojiStickerSets.value(stickerSetId));
            this->customEmojiStickerSetMap.insert(stickerSetId, customIndex);
            customIndex++;
        }
    }
    emit stickerSetsReceived();
    emit customEmojiStickerSetsReceived();
}

void StickerManager::handleStickerSetReceived(const QVariantMap &stickerSet)
{
    QString stickerSetId = stickerSet.value("id").toString();
    QString stickerType = stickerSet.value("sticker_type").toMap().value("@type").toString();
    bool isCustomEmojiSet = stickerType == QLatin1String("stickerTypeCustomEmoji");
    if (!isCustomEmojiSet && stickerType.isEmpty()
            && this->installedCustomEmojiSetIds.contains(stickerSetId)
            && !this->installedStickerSetIds.contains(stickerSetId)) {
        isCustomEmojiSet = true;
    }
    QVariantMap *allSets = isCustomEmojiSet ? &this->customEmojiStickerSets : &this->stickerSets;
    QVariantList *installedSetIds = isCustomEmojiSet ? &this->installedCustomEmojiSetIds : &this->installedStickerSetIds;
    QVariantMap *stickerSetIndexMap = isCustomEmojiSet ? &this->customEmojiStickerSetMap : &this->stickerSetMap;
    QVariantList *installedSets = isCustomEmojiSet ? &this->installedCustomEmojiSets : &this->installedStickerSets;

    allSets->insert(stickerSetId, stickerSet);
    if (installedSetIds->contains(stickerSetId)) {
        LOG("Receiving installed sticker set...." << stickerSetId);
        if (stickerSetIndexMap->contains(stickerSetId)) {
            int setIndex = stickerSetIndexMap->value(stickerSetId).toInt();
            if (setIndex >= 0 && setIndex < installedSets->size()) {
                installedSets->replace(setIndex, stickerSet);
            }
        } else {
            int setIndex = installedSets->size();
            stickerSetIndexMap->insert(stickerSetId, setIndex);
            installedSets->append(stickerSet);
        }
    } else {
        LOG("Receiving new sticker set...." << stickerSetId);
    }
    if (!isCustomEmojiSet) {
        QVariantList stickerList = stickerSet.value("stickers").toList();
        QListIterator<QVariant> stickerIterator(stickerList);
        while (stickerIterator.hasNext()) {
            QVariantMap singleSticker = stickerIterator.next().toMap();
            QVariantMap thumbnailFile = singleSticker.value("thumbnail").toMap().value("file").toMap();
            QVariantMap thumbnailLocalFile = thumbnailFile.value("local").toMap();
            if (!thumbnailFile.isEmpty() && !thumbnailLocalFile.value("is_downloading_completed").toBool()) {
                tdLibWrapper->downloadFile(thumbnailFile.value("id").toInt());
            }
        }
    }
    if (isCustomEmojiSet) {
        emit customEmojiStickerSetsReceived();
    } else {
        emit stickerSetsReceived();
    }
}
