import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/user_avatar.dart';
import '../../domain/providers/auth_provider.dart';
import '../router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserModelProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  UserAvatar(
                    name: user.name,
                    photoUrl: user.photoUrl,
                    size: 110,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline,
                                color: AppColors.primary),
                            title: const Text('Status Message'),
                            subtitle: Text(
                              user.statusMessage.isNotEmpty
                                  ? user.statusMessage
                                  : 'No status set',
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: AppColors.primary),
                            title: const Text('Member Since'),
                            subtitle: Text(
                              user.createdAt != null
                                  ? DateFormatter.formatFullDate(user.createdAt!)
                                  : 'Recently',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Edit Profile',
                    leadingIcon: Icons.edit,
                    onPressed: () => context.push(AppRoutes.editProfile),
                  ),
                ],
              ),
            ),
    );
  }
}
