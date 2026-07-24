import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$userId.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<String> uploadChatImage(
      File file, String chatId, String messageId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.chatImagesPath)
          .child(chatId)
          .child('$messageId.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  Future<String> uploadChatAudio(
      File file, String chatId, String messageId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.chatAudioPath)
          .child(chatId)
          .child('$messageId.m4a');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'audio/m4a'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload audio message: $e');
    }
  }

  Future<String> uploadGroupImage(File file, String groupId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.groupImagesPath)
          .child('$groupId.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload group image: $e');
    }
  }

  Future<void> deleteFileFromUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }
}
