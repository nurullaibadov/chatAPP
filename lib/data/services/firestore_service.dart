import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ================= USERS COLLECTION =================

  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Stream<UserModel?> streamUser(String userId) {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Stream<List<UserModel>> streamUsersByIds(List<String> uids) {
    if (uids.isEmpty) return Stream.value([]);
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .where(FieldPath.documentId, whereIn: uids.take(10).toList())
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    try {
      if (query.trim().isEmpty) return [];
      final normalized = query.trim().toLowerCase();

      final snapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .get();

      final results = <UserModel>[];
      for (final doc in snapshot.docs) {
        if (doc.id == currentUserId) continue;
        final user = UserModel.fromFirestore(doc);
        if (user.name.toLowerCase().contains(normalized) ||
            user.email.toLowerCase().contains(normalized)) {
          results.add(user);
        }
      }
      return results;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
        FirestoreConstants.isOnline: isOnline,
        FirestoreConstants.lastSeen: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently log or handle offline status update
    }
  }

  Future<void> updateFcmToken(String userId, String? token) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
        FirestoreConstants.fcmToken: token,
      });
    } catch (e) {
      // Handle or ignore if doc doesn't exist yet
    }
  }

  Future<void> updateUserProfile(
    String userId, {
    String? name,
    String? photoUrl,
    String? statusMessage,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates[FirestoreConstants.name] = name;
      if (photoUrl != null) updates[FirestoreConstants.photoUrl] = photoUrl;
      if (statusMessage != null) {
        updates[FirestoreConstants.statusMessage] = statusMessage;
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection(FirestoreConstants.usersCollection)
            .doc(userId)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(currentUserId)
          .update({
        FirestoreConstants.blockedUsers: FieldValue.arrayUnion([targetUserId]),
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(currentUserId)
          .update({
        FirestoreConstants.blockedUsers: FieldValue.arrayRemove([targetUserId]),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // ================= CHATS COLLECTION =================

  Future<String> createOrGetDirectChat(
      String currentUserId, String otherUserId) async {
    try {
      // Check if chat already exists
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .where(FirestoreConstants.isGroup, isEqualTo: false)
          .where(FirestoreConstants.participantIds, arrayContains: currentUserId)
          .get();

      for (final doc in querySnapshot.docs) {
        final chat = ChatModel.fromFirestore(doc);
        if (chat.participantIds.contains(otherUserId)) {
          return chat.id;
        }
      }

      // Create new direct chat
      final chatDoc =
          _firestore.collection(FirestoreConstants.chatsCollection).doc();
      final newChat = ChatModel(
        id: chatDoc.id,
        isGroup: false,
        participantIds: [currentUserId, otherUserId],
        unreadCount: {currentUserId: 0, otherUserId: 0},
        createdAt: DateTime.now(),
      );

      await chatDoc.set(newChat.toMap());
      return chatDoc.id;
    } catch (e) {
      throw Exception('Failed to create or open chat: $e');
    }
  }

  Future<String> createGroupChat({
    required String groupName,
    String? groupPhotoUrl,
    required List<String> participantIds,
    required String adminId,
  }) async {
    try {
      final chatDoc =
          _firestore.collection(FirestoreConstants.chatsCollection).doc();

      final allParticipants = {...participantIds, adminId}.toList();
      final unreadMap = <String, int>{for (var id in allParticipants) id: 0};

      final newGroup = ChatModel(
        id: chatDoc.id,
        isGroup: true,
        groupName: groupName,
        groupPhotoUrl: groupPhotoUrl,
        participantIds: allParticipants,
        adminId: adminId,
        unreadCount: unreadMap,
        createdAt: DateTime.now(),
      );

      await chatDoc.set(newGroup.toMap());
      return chatDoc.id;
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _firestore
        .collection(FirestoreConstants.chatsCollection)
        .where(FirestoreConstants.participantIds, arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats =
          snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
      chats.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.createdAt ?? DateTime(1970);
        final bTime = b.lastMessageTime ?? b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
      return chats;
    });
  }

  Stream<ChatModel?> streamChat(String chatId) {
    return _firestore
        .collection(FirestoreConstants.chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? ChatModel.fromFirestore(doc) : null);
  }

  Future<void> updateTypingStatus(
      String chatId, String userId, bool isTyping) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .update({
        FirestoreConstants.typingUsers: isTyping
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      // Silently ignore typing error
    }
  }

  Future<void> resetUnreadCount(String chatId, String userId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .update({
        '${FirestoreConstants.unreadCount}.$userId': 0,
      });
    } catch (e) {
      // Silently handle reset error
    }
  }

  // ================= MESSAGES SUBCOLLECTION =================

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      final chatRef =
          _firestore.collection(FirestoreConstants.chatsCollection).doc(chatId);
      final messageRef = chatRef
          .collection(FirestoreConstants.messagesCollection)
          .doc(message.id);

      final chatSnapshot = await chatRef.get();
      if (!chatSnapshot.exists) return;

      final chat = ChatModel.fromFirestore(chatSnapshot);
      final Map<String, dynamic> updatedUnread = Map.from(chat.unreadCount);

      for (final participant in chat.participantIds) {
        if (participant != message.senderId) {
          updatedUnread[participant] = (updatedUnread[participant] ?? 0) + 1;
        }
      }

      final batch = _firestore.batch();
      batch.set(messageRef, message.toMap());
      batch.update(chatRef, {
        FirestoreConstants.lastMessage: message.displayText,
        FirestoreConstants.lastMessageTime: Timestamp.fromDate(message.timestamp),
        FirestoreConstants.lastMessageType: message.type,
        FirestoreConstants.lastMessageSenderId: message.senderId,
        FirestoreConstants.unreadCount: updatedUnread,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection(FirestoreConstants.chatsCollection)
        .doc(chatId)
        .collection(FirestoreConstants.messagesCollection)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateMessageStatus(
      String chatId, String messageId, String status) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .collection(FirestoreConstants.messagesCollection)
          .doc(messageId)
          .update({FirestoreConstants.status: status});
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> addMessageReaction(
      String chatId, String messageId, String userId, String emoji) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .collection(FirestoreConstants.messagesCollection)
          .doc(messageId)
          .update({
        '${FirestoreConstants.reactions}.$userId': emoji,
      });
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  Future<void> removeMessageReaction(
      String chatId, String messageId, String userId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .collection(FirestoreConstants.messagesCollection)
          .doc(messageId)
          .update({
        '${FirestoreConstants.reactions}.$userId': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  Future<void> editMessage(
      String chatId, String messageId, String newText) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .collection(FirestoreConstants.messagesCollection)
          .doc(messageId)
          .update({
        FirestoreConstants.text: newText,
        FirestoreConstants.isEdited: true,
      });
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  Future<void> deleteMessageForSelf(
      String chatId, String messageId, String userId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .collection(FirestoreConstants.messagesCollection)
          .doc(messageId)
          .update({
        FirestoreConstants.deletedFor: FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<void> deleteMessageForEveryone(
      String chatId, String messageId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.chatsCollection)
          .doc(chatId)
          .collection(FirestoreConstants.messagesCollection)
          .doc(messageId)
          .update({
        FirestoreConstants.isDeletedForEveryone: true,
        FirestoreConstants.text: null,
        FirestoreConstants.imageUrl: null,
        FirestoreConstants.audioUrl: null,
      });
    } catch (e) {
      throw Exception('Failed to delete message for everyone: $e');
    }
  }
}
