import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ChatRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final Uuid _uuid;

  ChatRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
    Uuid? uuid,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? StorageService(),
        _uuid = uuid ?? const Uuid();

  Future<String> createOrGetDirectChat(String currentUserId, String otherUserId) {
    return _firestoreService.createOrGetDirectChat(currentUserId, otherUserId);
  }

  Future<String> createGroupChat({
    required String groupName,
    File? groupImageFile,
    required List<String> participantIds,
    required String adminId,
  }) async {
    final groupId = _uuid.v4();
    String? groupPhotoUrl;

    if (groupImageFile != null) {
      groupPhotoUrl = await _storageService.uploadGroupImage(groupImageFile, groupId);
    }

    return _firestoreService.createGroupChat(
      groupName: groupName,
      groupPhotoUrl: groupPhotoUrl,
      participantIds: participantIds,
      adminId: adminId,
    );
  }

  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _firestoreService.streamUserChats(userId);
  }

  Stream<ChatModel?> streamChat(String chatId) {
    return _firestoreService.streamChat(chatId);
  }

  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50}) {
    return _firestoreService.streamMessages(chatId, limit: limit);
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
  }) async {
    final messageId = _uuid.v4();
    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      text: text.trim(),
      type: AppConstants.messageTypeText,
      timestamp: DateTime.now(),
      status: AppConstants.statusSent,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSenderName: replyToSenderName,
    );

    await _firestoreService.sendMessage(chatId, message);
  }

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required File imageFile,
    String? caption,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
  }) async {
    final messageId = _uuid.v4();
    final imageUrl = await _storageService.uploadChatImage(imageFile, chatId, messageId);

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      text: caption?.trim(),
      imageUrl: imageUrl,
      type: AppConstants.messageTypeImage,
      timestamp: DateTime.now(),
      status: AppConstants.statusSent,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSenderName: replyToSenderName,
    );

    await _firestoreService.sendMessage(chatId, message);
  }

  Future<void> sendAudioMessage({
    required String chatId,
    required String senderId,
    required File audioFile,
    required int durationInSeconds,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
  }) async {
    final messageId = _uuid.v4();
    final audioUrl = await _storageService.uploadChatAudio(audioFile, chatId, messageId);

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      audioUrl: audioUrl,
      audioDuration: durationInSeconds,
      type: AppConstants.messageTypeAudio,
      timestamp: DateTime.now(),
      status: AppConstants.statusSent,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSenderName: replyToSenderName,
    );

    await _firestoreService.sendMessage(chatId, message);
  }

  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping) {
    return _firestoreService.updateTypingStatus(chatId, userId, isTyping);
  }

  Future<void> markAsRead(String chatId, String userId) {
    return _firestoreService.resetUnreadCount(chatId, userId);
  }

  Future<void> markMessageAsRead(String chatId, String messageId) {
    return _firestoreService.updateMessageStatus(chatId, messageId, AppConstants.statusRead);
  }

  Future<void> addReaction(String chatId, String messageId, String userId, String emoji) {
    return _firestoreService.addMessageReaction(chatId, messageId, userId, emoji);
  }

  Future<void> removeReaction(String chatId, String messageId, String userId) {
    return _firestoreService.removeMessageReaction(chatId, messageId, userId);
  }

  Future<void> editMessage(String chatId, String messageId, String newText) {
    return _firestoreService.editMessage(chatId, messageId, newText);
  }

  Future<void> deleteMessageForSelf(String chatId, String messageId, String userId) {
    return _firestoreService.deleteMessageForSelf(chatId, messageId, userId);
  }

  Future<void> deleteMessageForEveryone(String chatId, String messageId) {
    return _firestoreService.deleteMessageForEveryone(chatId, messageId);
  }
}
