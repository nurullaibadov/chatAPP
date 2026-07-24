import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/snackbar_utils.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/user_avatar.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/chat_provider.dart';
import '../../domain/providers/user_provider.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(String otherUserId, String name, String? photo) async {
    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final chatId = await chatRepo.createOrGetDirectChat(currentUser.uid, otherUserId);

      if (!mounted) return;
      context.pushReplacement(
        '/chat/$chatId',
        extra: {
          'title': name,
          'photo': photo,
          'isGroup': false,
        },
      );
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to start chat: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              hint: 'Search by name or email...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(userSearchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              onChanged: (val) {
                ref.read(userSearchQueryProvider.notifier).state = val;
              },
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              data: (users) {
                if (_searchController.text.trim().isEmpty) {
                  return Center(
                    child: Text(
                      'Type a name or email to search for people',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: UserAvatar(
                        name: user.name,
                        photoUrl: user.photoUrl,
                        size: 48,
                        showOnlineIndicator: true,
                        isOnline: user.isOnline,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email),
                      onTap: () => _startChat(user.uid, user.name, user.photoUrl),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, __) => Center(
                child: Text('Error searching users: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
