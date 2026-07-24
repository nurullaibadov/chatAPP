import 'dart:io';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  UserRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? StorageService();

  Future<UserModel?> getUser(String userId) {
    return _firestoreService.getUser(userId);
  }

  Stream<UserModel?> streamUser(String userId) {
    return _firestoreService.streamUser(userId);
  }

  Stream<List<UserModel>> streamUsersByIds(List<String> uids) {
    return _firestoreService.streamUsersByIds(uids);
  }

  Future<List<UserModel>> searchUsers(String query, String currentUserId) {
    return _firestoreService.searchUsers(query, currentUserId);
  }

  Future<String> updateProfilePhoto(String userId, File photoFile) async {
    final photoUrl = await _storageService.uploadProfileImage(photoFile, userId);
    await _firestoreService.updateUserProfile(userId, photoUrl: photoUrl);
    return photoUrl;
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? statusMessage,
    File? newPhotoFile,
  }) async {
    String? photoUrl;
    if (newPhotoFile != null) {
      photoUrl = await _storageService.uploadProfileImage(newPhotoFile, userId);
    }

    await _firestoreService.updateUserProfile(
      userId,
      name: name,
      photoUrl: photoUrl,
      statusMessage: statusMessage,
    );
  }

  Future<void> updatePresence(String userId, bool isOnline) {
    return _firestoreService.updateUserStatus(userId, isOnline);
  }

  Future<void> updateFcmToken(String userId, String? token) {
    return _firestoreService.updateFcmToken(userId, token);
  }

  Future<void> blockUser(String currentUserId, String targetUserId) {
    return _firestoreService.blockUser(currentUserId, targetUserId);
  }

  Future<void> unblockUser(String currentUserId, String targetUserId) {
    return _firestoreService.unblockUser(currentUserId, targetUserId);
  }
}
