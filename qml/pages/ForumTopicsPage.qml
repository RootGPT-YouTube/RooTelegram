/*
    Copyright (C) 2020 Sebastian J. Wolf and other contributors
    This file is part of RooTelegram. GNU GPL v3 or later.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import WerkWolf.RooTelegram 1.0

Page {
    id: forumTopicsPage
    allowedOrientations: Orientation.All

    property var chatInformation
    property bool loading: false
    property bool loaded: false
    // Thread ID dell'ultimo topic visitato (per il reload ritardato)
    property int lastViewedThreadId: 0
    // Se true, al prossimo refresh topics proviamo a sincronizzare anche il badge chat in home.
    property bool syncHomeUnreadOnNextLoad: false
    function numberFromCandidates(candidates, fallbackValue) {
        for (var i = 0; i < candidates.length; i++) {
            var value = candidates[i]
            if (value === undefined || value === null || value === "") {
                continue
            }
            var numericValue = Number(value)
            if (!isNaN(numericValue)) {
                return numericValue
            }
        }
        return fallbackValue
    }

    function topicCounter(topic, info, fieldNames) {
        var candidates = []
        for (var i = 0; i < fieldNames.length; i++) {
            var fieldName = fieldNames[i]
            candidates.push(topic ? topic[fieldName] : undefined)
            candidates.push(info ? info[fieldName] : undefined)
        }
        return numberFromCandidates(candidates, 0)
    }

    function threadIdFromTopic(topic, info) {
        return numberFromCandidates([
            info ? info.message_thread_id : undefined,
            topic ? topic.message_thread_id : undefined,
            topic && topic.last_message ? topic.last_message.message_thread_id : undefined,
            info ? info.forum_topic_id : undefined,
            topic ? topic.forum_topic_id : undefined,
            topic ? topic.id : undefined
        ], 0)
    }

    function applyTopicDetails(topic) {
        var info = topic && topic.info ? topic.info : {}
        var threadId = threadIdFromTopic(topic, info)
        if (!threadId) {
            return
        }
        var unreadCount = topicCounter(topic, info, ["unread_count", "unreadCount", "unread_message_count", "unread_messages_count"])
        var unreadMentionCount = topicCounter(topic, info, ["unread_mention_count", "unread_mentions_count", "unreadMentionCount", "unreadMentionsCount"])
        var unreadReactionCount = topicCounter(topic, info, ["unread_reaction_count", "unread_reactions_count", "unreadReactionCount", "unreadReactionsCount"])
        var lastReadInboxMessageId = topicCounter(topic, info, ["last_read_inbox_message_id", "read_inbox_max_id", "lastReadInboxMessageId"])
        var lastReadOutboxMessageId = topicCounter(topic, info, ["last_read_outbox_message_id", "read_outbox_max_id", "lastReadOutboxMessageId"])
        var lastMsg = topic && topic.last_message ? topic.last_message : {}
        var lastSender = lastMsg && lastMsg.sender_id ? lastMsg.sender_id : {}
        var lastContent = lastMsg && lastMsg.content ? lastMsg.content : {}
        for (var i = 0; i < topicsModel.count; i++) {
            if (topicsModel.get(i).threadId !== threadId) {
                continue
            }
            if (info.name) topicsModel.setProperty(i, "topicName", info.name)
            if (info.is_closed !== undefined) topicsModel.setProperty(i, "topicIsClosed", info.is_closed)
            if (info.is_pinned !== undefined) topicsModel.setProperty(i, "isPinned", info.is_pinned)
            topicsModel.setProperty(i, "unreadCount", unreadCount)
            topicsModel.setProperty(i, "unreadMentionCount", unreadMentionCount)
            topicsModel.setProperty(i, "unreadReactionCount", unreadReactionCount)
            topicsModel.setProperty(i, "lastReadInboxMessageId", lastReadInboxMessageId)
            topicsModel.setProperty(i, "lastReadOutboxMessageId", lastReadOutboxMessageId)
            if (lastMsg.id !== undefined) topicsModel.setProperty(i, "anchorMsgId", lastMsg.id || 0)
            if (lastSender.user_id !== undefined) topicsModel.setProperty(i, "lastSenderId", lastSender.user_id || 0)
            if (lastMsg.date !== undefined) topicsModel.setProperty(i, "lastMessageDate", lastMsg.date || 0)
            if (lastContent.text && lastContent.text.text !== undefined) topicsModel.setProperty(i, "lastMessageText", lastContent.text.text || "")
            break
        }
    }

    function loadTopics() {
        if (!chatInformation || !chatInformation.id) return
        if (loading) return   // debounce: evita ricarichi multipli simultanei
        loaded = true
        loading = true
        tdLibWrapper.getForumTopics(chatInformation.id)
    }

    // Reload ritardato di 800ms — dà tempo a TDLib di aggiornare
    // lo stato interno dopo viewMessages con message_thread_id
    Timer {
        id: delayedReloadTimer
        interval: 800
        repeat: false
        onTriggered: {
            loading = false  // sblocca il debounce
            loadTopics()
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (lastViewedThreadId > 0) {
                // Ritorno da un topic: aspetta che TDLib elabori il viewMessages
                syncHomeUnreadOnNextLoad = true
                lastViewedThreadId = 0
                delayedReloadTimer.restart()
            } else if (!loaded) {
                loadTopics()
            }
        } else if (status === PageStatus.Inactive || status === PageStatus.Deactivating) {
            // Evita che chiamate future a viewMessage fuori dal topic ereditino message_thread_id stale.
            tdLibWrapper.setCurrentMessageThreadId(0)
        }
    }

    Connections {
        target: tdLibWrapper
        onForumTopicsReceived: {
            if (!forumTopicsPage.chatInformation) return
            if (chatId !== forumTopicsPage.chatInformation.id) return
            loading = false
            if (!topics) return
            topicsModel.clear()  // Svuota solo quando i nuovi dati sono pronti
            var totalUnread = 0
            var totalUnreadMentions = 0
            for (var i = 0; i < topics.length; i++) {
                var t = topics[i]
                var info = t.info || {}
                var icon = info.icon || {}
                var lastMsg = t.last_message || {}
                var lastSender = lastMsg.sender_id || {}
                var lastContent = lastMsg.content || {}
                var unreadCount = topicCounter(t, info, ["unread_count", "unreadCount", "unread_message_count", "unread_messages_count"])
                var unreadMentionCount = topicCounter(t, info, ["unread_mention_count", "unread_mentions_count", "unreadMentionCount", "unreadMentionsCount"])
                var unreadReactionCount = topicCounter(t, info, ["unread_reaction_count", "unread_reactions_count", "unreadReactionCount", "unreadReactionsCount"])
                var lastReadInboxMessageId = topicCounter(t, info, ["last_read_inbox_message_id", "read_inbox_max_id", "lastReadInboxMessageId"])
                var lastReadOutboxMessageId = topicCounter(t, info, ["last_read_outbox_message_id", "read_outbox_max_id", "lastReadOutboxMessageId"])
                var threadId = threadIdFromTopic(t, info)
                totalUnread += unreadCount
                totalUnreadMentions += unreadMentionCount
                // Log struttura primo topic per debug
                topicsModel.append({
                    threadId:         threadId,
                    anchorMsgId:      lastMsg.id || 0,
                    topicName:        info.name || ("Topic " + (i + 1)),
                    topicIsClosed:    info.is_closed || false,
                    unreadCount:      unreadCount,
                    unreadMentionCount: unreadMentionCount,
                    unreadReactionCount: unreadReactionCount,
                    isPinned:         info.is_pinned || false,
                    iconColor:        icon.color || 0,
                    iconEmoji:        icon.custom_emoji_id || "",
                    lastReadInboxMessageId: lastReadInboxMessageId,
                    lastReadOutboxMessageId: lastReadOutboxMessageId,
                    lastSenderId:     lastSender.user_id || 0,
                    lastMessageText:  lastContent.text ? lastContent.text.text || "" : "",
                    lastMessageDate:  lastMsg.date || 0
                })
                if (threadId > 0) {
                    tdLibWrapper.getForumTopic(forumTopicsPage.chatInformation.id, threadId)
                }
            }

            // Se tutti i topic risultano letti, forza una sincronizzazione del badge in home.
            // In alcuni casi TDLib aggiorna subito i topic ma ritarda/non invia updateChatReadInbox.
            if (forumTopicsPage.syncHomeUnreadOnNextLoad) {
                forumTopicsPage.syncHomeUnreadOnNextLoad = false
                if (totalUnread === 0 && totalUnreadMentions === 0) {
                    tdLibWrapper.setCurrentMessageThreadId(0)
                    var chatLastMessage = forumTopicsPage.chatInformation.last_message || {}
                    var chatLastMessageId = Number(chatLastMessage.id || 0)
                    if (chatLastMessageId > 0) {
                        tdLibWrapper.viewMessage(forumTopicsPage.chatInformation.id, chatLastMessageId, true)
                    }
                    tdLibWrapper.readAllChatMentions(forumTopicsPage.chatInformation.id)
                    tdLibWrapper.readAllChatReactions(forumTopicsPage.chatInformation.id)
                    tdLibWrapper.toggleChatIsMarkedAsUnread(forumTopicsPage.chatInformation.id, false)
                }
            }
        }

        onForumTopicReceived: {
            if (!forumTopicsPage.chatInformation) return
            if (chatId !== forumTopicsPage.chatInformation.id) return
            if (!topic) return
            applyTopicDetails(topic)
        }

        onForumTopicUpdated: {
            // updateForumTopic — inviato da TDLib dopo viewMessages con message_thread_id
            // Aggiorniamo i metadati di lettura e poi ricarichiamo da TDLib
            // per avere unread_count autorevole.
            if (!forumTopicsPage.chatInformation) return
            if (chatId !== forumTopicsPage.chatInformation.id) return
            for (var i = 0; i < topicsModel.count; i++) {
                var t = topicsModel.get(i)
                if (t.threadId === threadId) {
                    topicsModel.setProperty(i, "lastReadInboxMessageId", lastReadInboxMessageId)
                    topicsModel.setProperty(i, "lastReadOutboxMessageId", lastReadOutboxMessageId)
                    topicsModel.setProperty(i, "unreadMentionCount", unreadMentionCount)
                    var anchorMessageId = Number(t.anchorMsgId || 0)
                    if (anchorMessageId > 0 && Number(lastReadInboxMessageId || 0) >= anchorMessageId) {
                        topicsModel.setProperty(i, "unreadCount", 0)
                    }
                    break
                }
            }
            if (threadId > 0) {
                tdLibWrapper.getForumTopic(forumTopicsPage.chatInformation.id, threadId)
            }
        }

        onForumTopicInfoUpdated: {
            // Aggiorna campi quando TDLib notifica un aggiornamento del topic
            // NOTA: updateForumTopicInfo porta forumTopicInfo che ha message_thread_id,
            // NON forum_topic_id. Aggiorna solo i campi effettivamente presenti.
            if (!forumTopicsPage.chatInformation) return
            if (chatId !== forumTopicsPage.chatInformation.id) return
            var threadId = topicInfo.message_thread_id || topicInfo.forum_topic_id || 0
            var unreadCount = numberFromCandidates([
                topicInfo.unread_count,
                topicInfo.unreadCount,
                topicInfo.unread_message_count,
                topicInfo.unread_messages_count
            ], null)
            var unreadMentionCount = numberFromCandidates([
                topicInfo.unread_mention_count,
                topicInfo.unread_mentions_count,
                topicInfo.unreadMentionCount,
                topicInfo.unreadMentionsCount
            ], null)
            var unreadReactionCount = numberFromCandidates([
                topicInfo.unread_reaction_count,
                topicInfo.unread_reactions_count,
                topicInfo.unreadReactionCount,
                topicInfo.unreadReactionsCount
            ], null)
            for (var i = 0; i < topicsModel.count; i++) {
                if (topicsModel.get(i).threadId === threadId) {
                    // Aggiorna nome e stato (sempre presenti in forumTopicInfo)
                    if (topicInfo.name) topicsModel.setProperty(i, "topicName", topicInfo.name)
                    if (topicInfo.is_closed !== undefined) topicsModel.setProperty(i, "topicIsClosed", topicInfo.is_closed)
                    if (topicInfo.is_pinned !== undefined) topicsModel.setProperty(i, "isPinned", topicInfo.is_pinned)
                    if (unreadCount !== null) topicsModel.setProperty(i, "unreadCount", unreadCount)
                    if (unreadMentionCount !== null) topicsModel.setProperty(i, "unreadMentionCount", unreadMentionCount)
                    if (unreadReactionCount !== null) topicsModel.setProperty(i, "unreadReactionCount", unreadReactionCount)
                    break
                }
            }
        }
    }

    ListModel { id: topicsModel }

    SilicaListView {
        id: topicListView
        anchors.fill: parent
        model: topicsModel

        header: PageHeader {
            title: chatInformation ? chatInformation.title : ""
            description: qsTr("Topics")
        }

        ViewPlaceholder {
            enabled: loading && topicsModel.count === 0
            text: qsTr("Loading topics...")
        }

        ViewPlaceholder {
            enabled: !loading && topicsModel.count === 0
            text: qsTr("No topics found")
            hintText: qsTr("This group has no topics yet.")
        }

        delegate: ListItem {
            width: ListView.view.width
            contentHeight: Theme.itemSizeExtraLarge

            onClicked: {
                var tid = Number(threadId)
                if (!tid || tid <= 0) return
                var lastMsgId = Number(anchorMsgId) || 0
                forumTopicsPage.lastViewedThreadId = tid
                tdLibWrapper.setCurrentMessageThreadId(tid)
                if (lastMsgId > 0) {
                    // Allineato a Yottagram: forziamo subito il read del topic dalla lista
                    tdLibWrapper.viewMessage(forumTopicsPage.chatInformation.id, lastMsgId, true)
                }
                pageStack.push(Qt.resolvedUrl("ChatPage.qml"), {
                    chatInformation: forumTopicsPage.chatInformation,
                    messageThreadId: tid,
                    topicLastMessageId: lastMsgId,
                    currentTopicInfo: { name: topicName, is_closed: topicIsClosed }
                })
            }

            // Icona colorata del topic (pallino con #)
            Rectangle {
                id: topicIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.itemSizeMedium * 0.8
                height: width
                radius: width / 2
                // Colore TDLib: int ARGB -> estraiamo RGB
                color: iconColor ? Qt.rgba(
                    ((iconColor >> 16) & 0xFF) / 255.0,
                    ((iconColor >> 8)  & 0xFF) / 255.0,
                    ( iconColor        & 0xFF) / 255.0,
                    1.0) : Theme.secondaryHighlightColor

                Label {
                    anchors.centerIn: parent
                    text: "#"
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: "white"
                }
            }

            // Badge messaggi non letti
            Rectangle {
                id: badge
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                visible: unreadCount > 0 || unreadMentionCount > 0
                width: visible ? (badgeLbl.width + Theme.paddingSmall * 2) : 0
                height: Theme.fontSizeSmall + Theme.paddingSmall
                radius: height / 2
                color: Theme.highlightColor

                Label {
                    id: badgeLbl
                    anchors.centerIn: parent
                    text: {
                        var badgeCount = unreadCount > 0 ? unreadCount : unreadMentionCount
                        return badgeCount > 999 ? "999+" : ("" + badgeCount)
                    }
                    font.pixelSize: Theme.fontSizeTiny
                    font.bold: true
                    color: "white"
                }
            }

            // Nome topic + preview
            Column {
                anchors.left: topicIcon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: badge.left
                anchors.rightMargin: Theme.paddingSmall
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingSmall / 2

                Label {
                    width: parent.width
                    text: topicName
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 1
                }

                Label {
                    width: parent.width
                    visible: lastMessageText !== ""
                    text: {
                        if (lastSenderId === tdLibWrapper.myUserId) {
                            return qsTr("You") + ": " + lastMessageText
                        } else if (lastSenderId > 0) {
                            var userInfo = tdLibWrapper.getUserInformation(lastSenderId)
                            var name = userInfo ? (userInfo.first_name || "") : ""
                            return name !== "" ? (name + ": " + lastMessageText) : lastMessageText
                        }
                        return lastMessageText
                    }
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 1
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
