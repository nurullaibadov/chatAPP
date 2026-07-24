import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/user_provider.dart';
import '../router/app_router.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _statusController = TextEditingController(text: 'Hey there! I am using ChatApp.');
  File? _selectedImage;

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to select image: $e');
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final user = ref.read(currentUserModelProvider).asData?.value;
    if (user == null) return;

    final success = await ref.read(profileNotifierProvider.notifier).updateProfile(
          userId: user.uid,
          statusMessage: _statusController.text,
          newPhotoFile: _selectedImage,
        );

    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(profileNotifierProvider).errorMessage;
      if (error != null) {
        SnackBarUtils.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserModelProvider).asData?.value;
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'Add Profile Photo & Bio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help your friends recognize you',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              Stack(
                children: [
                  _selectedImage != null
                      ? CircleAvatar(
                          radius: 56,
                          backgroundImage: FileImage(_selectedImage!),
                        )
                      : UserAvatar(
                          name: user?.name ?? 'User',
                          photoUrl: user?.photoUrl,
                          size: 112,
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              CustomTextField(
                label: 'Status Message',
                hint: 'e.g. At work, Sleeping, Available',
                controller: _statusController,
                prefixIcon: const Icon(Icons.info_outline, size: 20),
                maxLength: 100,
              ),
              const SizedBox(height: 36),
              CustomButton(
                text: 'Save & Continue',
                isLoading: profileState.isLoading,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
