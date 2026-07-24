import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final userChatsStreamProvider = StreamProvider<List<ChatModel>>((ref) {
  final currentUserState = ref.watch(currentUserModelProvider);
  final userId = currentUserState.asData?.value?.uid;

  if (userId == null) return Stream.value([]);

  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.streamUserChats(userId);
});

final activeChatStreamProvider =
    StreamProvider.family<ChatModel?, String>((ref, chatId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.streamChat(chatId);
});

final chatMessagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.streamMessages(chatId);
});

final selectedReplyMessageProvider =
    StateProvider.family<MessageModel?, String>((ref, chatId) => null);

final editingMessageProvider =
    StateProvider.family<MessageModel?, String>((ref, chatId) => null);

class ChatActionState {
  final bool isSending;
  final String? errorMessage;

  const ChatActionState({
    this.isSending = false,
    this.errorMessage,
  });

  ChatActionState copyWith({
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatActionState(
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}

class ChatActionNotifier extends StateNotifier<ChatActionState> {
  final ChatRepository _chatRepo;

  ChatActionNotifier(this._chatRepo) : super(const ChatActionState());

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
    MessageModel? replyToMessage,
    String? replyToSenderName,
  }) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await _chatRepo.sendTextMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
        replyToMessageId: replyToMessage?.id,
        replyToText: replyToMessage?.displayText,
        replyToSenderName: replyToSenderName,
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required File imageFile,
    String? caption,
    MessageModel? replyToMessage,
    String? replyToSenderName,
  }) async {
    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await _chatRepo.sendImageMessage(
        chatId: chatId,
        senderId: senderId,
        imageFile: imageFile,
        caption: caption,
        replyToMessageId: replyToMessage?.id,
        replyToText: replyToMessage?.displayText,
        replyToSenderName: replyToSenderName,
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> sendAudioMessage({
    required String chatId,
    required String senderId,
    required File audioFile,
    required int durationInSeconds,
    MessageModel? replyToMessage,
    String? replyToSenderName,
  }) async {
    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await _chatRepo.sendAudioMessage(
        chatId: chatId,
        senderId: senderId,
        audioFile: audioFile,
        durationInSeconds: durationInSeconds,
        replyToMessageId: replyToMessage?.id,
        replyToText: replyToMessage?.displayText,
        replyToSenderName: replyToSenderName,
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> toggleReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String emoji,
    required Map<String, String> currentReactions,
  }) async {
    try {
      if (currentReactions[userId] == emoji) {
        await _chatRepo.removeReaction(chatId, messageId, userId);
      } else {
        await _chatRepo.addReaction(chatId, messageId, userId, emoji);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newText,
  }) async {
    if (newText.trim().isEmpty) return;
    try {
      await _chatRepo.editMessage(chatId, messageId, newText.trim());
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteForSelf({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _chatRepo.deleteMessageForSelf(chatId, messageId, userId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _chatRepo.deleteMessageForEveryone(chatId, messageId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String?> createGroupChat({
    required String groupName,
    File? groupImageFile,
    required List<String> participantIds,
    required String adminId,
  }) async {
    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      final chatId = await _chatRepo.createGroupChat(
        groupName: groupName,
        groupImageFile: groupImageFile,
        participantIds: participantIds,
        adminId: adminId,
      );
      state = state.copyWith(isSending: false);
      return chatId;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}

final chatActionNotifierProvider =
    StateNotifierProvider<ChatActionNotifier, ChatActionState>((ref) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return ChatActionNotifier(chatRepo);
});
