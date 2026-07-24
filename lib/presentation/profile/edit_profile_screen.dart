import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserModelProvider).asData?.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _statusController = TextEditingController(text: user?.statusMessage ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
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
          _newPhoto = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserModelProvider).asData?.value;
    if (user == null) return;

    final success =
        await ref.read(profileNotifierProvider.notifier).updateProfile(
              userId: user.uid,
              name: _nameController.text.trim(),
              statusMessage: _statusController.text.trim(),
              newPhotoFile: _newPhoto,
            );

    if (!mounted) return;
    if (success) {
      SnackBarUtils.showSuccess(context, 'Profile updated!');
      context.pop();
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
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    _newPhoto != null
                        ? CircleAvatar(
                            radius: 54,
                            backgroundImage: FileImage(_newPhoto!),
                          )
                        : UserAvatar(
                            name: user?.name ?? 'User',
                            photoUrl: user?.photoUrl,
                            size: 108,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Display Name',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                validator: (val) => Validators.validateRequired(val, 'Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Status Message',
                controller: _statusController,
                prefixIcon: const Icon(Icons.info_outline, size: 20),
                maxLength: 100,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Changes',
                isLoading: profileState.isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
