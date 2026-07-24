import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/user_provider.dart';
import '../router/app_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is irreversible. All your messages, profile info, and chat records will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).deleteAccount();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsersDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserModelProvider).asData?.value;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final blockedAsync =
                ref.watch(usersByIdsStreamProvider(user.blockedUsers));

            return AlertDialog(
              title: const Text('Blocked Users'),
              content: SizedBox(
                width: double.maxFinite,
                child: blockedAsync.when(
                  data: (blockedUsers) {
                    if (blockedUsers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No blocked users'),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: blockedUsers.length,
                      itemBuilder: (context, index) {
                        final blocked = blockedUsers[index];
                        return ListTile(
                          title: Text(blocked.name),
                          subtitle: Text(blocked.email),
                          trailing: TextButton(
                            child: const Text('Unblock'),
                            onPressed: () {
                              ref
                                  .read(profileNotifierProvider.notifier)
                                  .unblockUser(user.uid, blocked.uid);
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, __) => Text('Error: $err'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance & Notifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode_outlined,
            ),
            title: const Text('Dark Theme'),
            subtitle: const Text('Enable dark mode UI'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Privacy & Safety',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Blocked Users'),
            subtitle: const Text('Manage your blocked contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBlockedUsersDialog(context, ref),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Sign Out', style: TextStyle(color: Colors.orange)),
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),
        ],
      ),
    );
  }
}
