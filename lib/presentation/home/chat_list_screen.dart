import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/models/chat_model.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/chat_provider.dart';
import '../../domain/providers/user_provider.dart';
import '../router/app_router.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserModelProvider).asData?.value;
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (currentUser != null)
              GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: UserAvatar(
                  name: currentUser.name,
                  photoUrl: currentUser.photoUrl,
                  size: 36,
                ),
              ),
            const SizedBox(width: 12),
            const Text(
              'Chats',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'New Group',
            onPressed: () => context.push(AppRoutes.newGroup),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the search icon below to find friends and start chatting',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(
              indent: 72,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatTile(chat: chat, currentUserId: currentUser?.uid ?? '');
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => Center(
          child: Text('Error loading chats: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.userSearch),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}

class _ChatTile extends ConsumerWidget {
  final ChatModel chat;
  final String currentUserId;

  const _ChatTile({
    required this.chat,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = chat.getUnreadCount(currentUserId);

    if (chat.isGroup) {
      return ListTile(
        onTap: () => context.push(
          '/chat/${chat.id}',
          extra: {
            'title': chat.groupName ?? 'Group',
            'photo': chat.groupPhotoUrl,
            'isGroup': true,
          },
        ),
        leading: UserAvatar(
          name: chat.groupName ?? 'G',
          photoUrl: chat.groupPhotoUrl,
          size: 50,
        ),
        title: Text(
          chat.groupName ?? 'Group Chat',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubtitle(context, chat, false),
        trailing: _buildTrailing(context, chat, unread),
      );
    }

    // Direct 1-on-1 chat - fetch target user details
    final otherUserId = chat.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final otherUserAsync = ref.watch(userStreamProvider(otherUserId));

    return otherUserAsync.when(
      data: (otherUser) {
        final name = otherUser?.name ?? 'User';
        final photo = otherUser?.photoUrl;
        final isOnline = otherUser?.isOnline ?? false;

        return ListTile(
          onTap: () => context.push(
            '/chat/${chat.id}',
            extra: {
              'title': name,
              'photo': photo,
              'isGroup': false,
            },
          ),
          leading: UserAvatar(
            name: name,
            photoUrl: photo,
            size: 50,
            showOnlineIndicator: true,
            isOnline: isOnline,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: _buildSubtitle(context, chat, chat.isTyping(otherUserId)),
          trailing: _buildTrailing(context, chat, unread),
        );
      },
      loading: () => const ListTile(
        leading: CircleAvatar(radius: 25),
        title: Text('Loading...'),
      ),
      error: (_, __) => ListTile(
        title: Text('User $otherUserId'),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, ChatModel chat, bool isTyping) {
    if (isTyping) {
      return const Text(
        'typing...',
        style: TextStyle(
          color: AppColors.primary,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Text(
      chat.lastMessage ?? 'No messages yet',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, ChatModel chat, int unread) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (chat.lastMessageTime != null)
          Text(
            DateFormatter.formatChatTimestamp(chat.lastMessageTime!),
            style: TextStyle(
              fontSize: 11,
              color: unread > 0 ? AppColors.primary : Colors.grey,
            ),
          ),
        const SizedBox(height: 4),
        if (unread > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              unread > 99 ? '99+' : unread.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
