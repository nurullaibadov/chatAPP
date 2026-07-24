import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/user_avatar.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/chat_provider.dart';
import '../../domain/providers/user_provider.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final _groupNameController = TextEditingController();
  final _searchController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  File? _groupImage;

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _groupImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to pick group photo: $e');
      }
    }
  }

  Future<void> _handleCreateGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      SnackBarUtils.showError(context, 'Please enter a group name.');
      return;
    }

    if (_selectedUserIds.isEmpty) {
      SnackBarUtils.showError(context, 'Please select at least 1 member.');
      return;
    }

    final currentUser = ref.read(currentUserModelProvider).asData?.value;
    if (currentUser == null) return;

    final chatId = await ref.read(chatActionNotifierProvider.notifier).createGroupChat(
          groupName: groupName,
          groupImageFile: _groupImage,
          participantIds: _selectedUserIds.toList(),
          adminId: currentUser.uid,
        );

    if (!mounted) return;
    if (chatId != null) {
      context.pushReplacement(
        '/chat/$chatId',
        extra: {
          'title': groupName,
          'photo': null,
          'isGroup': true,
        },
      );
    } else {
      final error = ref.read(chatActionNotifierProvider).errorMessage;
      if (error != null) {
        SnackBarUtils.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchUsersProvider);
    final chatActionState = ref.watch(chatActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: chatActionState.isSending ? null : _handleCreateGroup,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        _groupImage != null ? FileImage(_groupImage!) : null,
                    child: _groupImage == null
                        ? const Icon(Icons.camera_alt, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    hint: 'Group Name...',
                    controller: _groupNameController,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomTextField(
              hint: 'Search members to add...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search, size: 20),
              onChanged: (val) {
                ref.read(userSearchQueryProvider.notifier).state = val;
              },
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              data: (users) {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.uid);

                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      secondary: UserAvatar(
                        name: user.name,
                        photoUrl: user.photoUrl,
                        size: 40,
                      ),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedUserIds.add(user.uid);
                          } else {
                            _selectedUserIds.remove(user.uid);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, __) => Center(child: Text('Error: $err')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Create Group (${_selectedUserIds.length} selected)',
              isLoading: chatActionState.isSending,
              onPressed: _handleCreateGroup,
            ),
          ),
        ],
      ),
    );
  }
}
