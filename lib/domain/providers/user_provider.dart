import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

final userSearchQueryProvider = StateProvider<String>((ref) => '');

final searchUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final query = ref.watch(userSearchQueryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final currentUserState = ref.watch(currentUserModelProvider);
  final currentUserId = currentUserState.asData?.value?.uid ?? '';

  if (query.trim().isEmpty) return [];
  return userRepo.searchUsers(query, currentUserId);
});

final userStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.streamUser(userId);
});

final usersByIdsStreamProvider =
    StreamProvider.family<List<UserModel>, List<String>>((ref, uids) {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.streamUsersByIds(uids);
});

class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserRepository _userRepo;

  ProfileNotifier(this._userRepo) : super(const ProfileState());

  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? statusMessage,
    File? newPhotoFile,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _userRepo.updateProfile(
        userId: userId,
        name: name,
        statusMessage: statusMessage,
        newPhotoFile: newPhotoFile,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    try {
      await _userRepo.blockUser(currentUserId, targetUserId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    try {
      await _userRepo.unblockUser(currentUserId, targetUserId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void clearStatus() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ProfileNotifier(userRepo);
});
