import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';

class ChatModel {
  final String id;
  final bool isGroup;
  final String? groupName;
  final String? groupPhotoUrl;
  final List<String> participantIds;
  final String? adminId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageType;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount; // userId -> count
  final List<String> typingUsers;
  final DateTime? createdAt;

  const ChatModel({
    required this.id,
    this.isGroup = false,
    this.groupName,
    this.groupPhotoUrl,
    required this.participantIds,
    this.adminId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    this.typingUsers = const [],
    this.createdAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      isGroup: data[FirestoreConstants.isGroup] ?? false,
      groupName: data[FirestoreConstants.groupName],
      groupPhotoUrl: data[FirestoreConstants.groupPhotoUrl],
      participantIds:
          List<String>.from(data[FirestoreConstants.participantIds] ?? []),
      adminId: data[FirestoreConstants.adminId],
      lastMessage: data[FirestoreConstants.lastMessage],
      lastMessageTime:
          (data[FirestoreConstants.lastMessageTime] as Timestamp?)?.toDate(),
      lastMessageType: data[FirestoreConstants.lastMessageType],
      lastMessageSenderId: data[FirestoreConstants.lastMessageSenderId],
      unreadCount: Map<String, int>.from(
          data[FirestoreConstants.unreadCount] ?? {}),
      typingUsers:
          List<String>.from(data[FirestoreConstants.typingUsers] ?? []),
      createdAt: (data[FirestoreConstants.createdAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.isGroup: isGroup,
      FirestoreConstants.groupName: groupName,
      FirestoreConstants.groupPhotoUrl: groupPhotoUrl,
      FirestoreConstants.participantIds: participantIds,
      FirestoreConstants.adminId: adminId,
      FirestoreConstants.lastMessage: lastMessage,
      FirestoreConstants.lastMessageTime: lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      FirestoreConstants.lastMessageType: lastMessageType,
      FirestoreConstants.lastMessageSenderId: lastMessageSenderId,
      FirestoreConstants.unreadCount: unreadCount,
      FirestoreConstants.typingUsers: typingUsers,
      FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
    };
  }

  ChatModel copyWith({
    String? id,
    bool? isGroup,
    String? groupName,
    String? groupPhotoUrl,
    List<String>? participantIds,
    String? adminId,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageType,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    List<String>? typingUsers,
    DateTime? createdAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupPhotoUrl: groupPhotoUrl ?? this.groupPhotoUrl,
      participantIds: participantIds ?? this.participantIds,
      adminId: adminId ?? this.adminId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      typingUsers: typingUsers ?? this.typingUsers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getChatName(String currentUserId, Map<String, String> userNames) {
    if (isGroup) return groupName ?? 'Group Chat';
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return userNames[otherId] ?? 'Unknown';
  }

  String? getChatPhoto(
      String currentUserId, Map<String, String?> userPhotos) {
    if (isGroup) return groupPhotoUrl;
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return userPhotos[otherId];
  }

  int getUnreadCount(String userId) => unreadCount[userId] ?? 0;

  bool isTyping(String userId) => typingUsers.contains(userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
