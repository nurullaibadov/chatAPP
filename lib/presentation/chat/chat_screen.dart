import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/models/message_model.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/chat_provider.dart';
import '../../domain/providers/user_provider.dart';
import 'widgets/chat_bubble_widget.dart';
import 'widgets/message_actions_sheet.dart';
import 'widgets/message_input_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? otherUserName;
  final String? otherUserPhoto;
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.otherUserName,
    this.otherUserPhoto,
    this.isGroup = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
    });
  }

  void _markAsRead() {
    final user = ref.read(currentUserModelProvider).asData?.value;
    if (user != null) {
      ref.read(chatRepositoryProvider).markAsRead(widget.chatId, user.uid);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSendTextMessage(String text) {
    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    final replyMessage = ref.read(selectedReplyMessageProvider(widget.chatId));
    final editingMessage = ref.read(editingMessageProvider(widget.chatId));

    if (editingMessage != null) {
      ref.read(chatActionNotifierProvider.notifier).editMessage(
            chatId: widget.chatId,
            messageId: editingMessage.id,
            newText: text,
          );
      ref.read(editingMessageProvider(widget.chatId).notifier).state = null;
    } else {
      ref.read(chatActionNotifierProvider.notifier).sendTextMessage(
            chatId: widget.chatId,
            senderId: currentUser.uid,
            text: text,
            replyToMessage: replyMessage,
            replyToSenderName: replyMessage != null ? currentUser.name : null,
          );
      ref.read(selectedReplyMessageProvider(widget.chatId).notifier).state = null;
    }
  }

  void _handleSendImageMessage(File imageFile) {
    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    ref.read(chatActionNotifierProvider.notifier).sendImageMessage(
          chatId: widget.chatId,
          senderId: currentUser.uid,
          imageFile: imageFile,
        );
  }

  void _handleSendAudioMessage(File audioFile, int duration) {
    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    ref.read(chatActionNotifierProvider.notifier).sendAudioMessage(
          chatId: widget.chatId,
          senderId: currentUser.uid,
          audioFile: audioFile,
          durationInSeconds: duration,
        );
  }

  void _handleTypingChanged(bool isTyping) {
    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    ref
        .read(chatRepositoryProvider)
        .updateTypingStatus(widget.chatId, currentUser.uid, isTyping);
  }

  void _showMessageActions(BuildContext context, MessageModel message, bool isMe) {
    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MessageActionsSheet(
        message: message,
        isMe: isMe,
        onReactionSelected: (emoji) {
          ref.read(chatActionNotifierProvider.notifier).toggleReaction(
                chatId: widget.chatId,
                messageId: message.id,
                userId: currentUser.uid,
                emoji: emoji,
                currentReactions: message.reactions,
              );
        },
        onReply: () {
          ref.read(selectedReplyMessageProvider(widget.chatId).notifier).state =
              message;
        },
        onEdit: () {
          ref.read(editingMessageProvider(widget.chatId).notifier).state = message;
        },
        onDeleteForSelf: () {
          ref.read(chatActionNotifierProvider.notifier).deleteForSelf(
                chatId: widget.chatId,
                messageId: message.id,
                userId: currentUser.uid,
              );
        },
        onDeleteForEveryone: () {
          ref.read(chatActionNotifierProvider.notifier).deleteForEveryone(
                chatId: widget.chatId,
                messageId: message.id,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserModelProvider).asData?.value;
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final chatAsync = ref.watch(activeChatStreamProvider(widget.chatId));
    final replyMessage = ref.watch(selectedReplyMessageProvider(widget.chatId));
    final editingMessage = ref.watch(editingMessageProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
              )
            : chatAsync.when(
                data: (chat) {
                  if (widget.isGroup) {
                    return Row(
                      children: [
                        UserAvatar(
                          name: widget.otherUserName ?? 'Group',
                          photoUrl: widget.otherUserPhoto,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.otherUserName ?? 'Group Chat',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${chat?.participantIds.length ?? 0} members',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  final otherUserId = chat?.participantIds.firstWhere(
                        (id) => id != currentUser?.uid,
                        orElse: () => '',
                      ) ??
                      '';

                  final otherUserAsync = ref.watch(userStreamProvider(otherUserId));

                  return otherUserAsync.when(
                    data: (otherUser) {
                      final isOnline = otherUser?.isOnline ?? false;
                      return Row(
                        children: [
                          UserAvatar(
                            name: otherUser?.name ?? widget.otherUserName ?? 'User',
                            photoUrl: otherUser?.photoUrl ?? widget.otherUserPhoto,
                            size: 36,
                            showOnlineIndicator: true,
                            isOnline: isOnline,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                otherUser?.name ?? widget.otherUserName ?? 'Chat',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOnline ? Colors.greenAccent : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => Text(widget.otherUserName ?? 'Chat'),
                    error: (_, __) => Text(widget.otherUserName ?? 'Chat'),
                  );
                },
                loading: () => Text(widget.otherUserName ?? 'Chat'),
                error: (_, __) => Text(widget.otherUserName ?? 'Chat'),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (allMessages) {
                final messages = _searchQuery.isEmpty
                    ? allMessages
                    : allMessages
                        .where((m) =>
                            (m.text ?? '').toLowerCase().contains(_searchQuery))
                        .toList();

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matching messages found'
                              : 'Say hi to start the conversation!',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;

                    // Automatically mark unread message as read
                    if (!isMe && message.status != 'read') {
                      ref.read(chatRepositoryProvider).markMessageAsRead(
                            widget.chatId,
                            message.id,
                          );
                    }

                    return ChatBubbleWidget(
                      message: message,
                      isMe: isMe,
                      currentUserId: currentUser?.uid ?? '',
                      onLongPress: () =>
                          _showMessageActions(context, message, isMe),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, __) => Center(child: Text('Error: $err')),
            ),
          ),
          MessageInputWidget(
            onSendTextMessage: _handleSendTextMessage,
            onSendImageMessage: _handleSendImageMessage,
            onSendAudioMessage: _handleSendAudioMessage,
            onTypingChanged: _handleTypingChanged,
            replyMessage: replyMessage,
            onCancelReply: () {
              ref
                  .read(selectedReplyMessageProvider(widget.chatId).notifier)
                  .state = null;
            },
            editingMessage: editingMessage,
            onCancelEdit: () {
              ref.read(editingMessageProvider(widget.chatId).notifier).state =
                  null;
            },
          ),
        ],
      ),
    );
  }
}
