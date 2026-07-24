class FirestoreConstants {
  FirestoreConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // User fields
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String photoUrl = 'photoUrl';
  static const String statusMessage = 'statusMessage';
  static const String isOnline = 'isOnline';
  static const String lastSeen = 'lastSeen';
  static const String fcmToken = 'fcmToken';
  static const String blockedUsers = 'blockedUsers';
  static const String createdAt = 'createdAt';

  // Chat fields
  static const String isGroup = 'isGroup';
  static const String groupName = 'groupName';
  static const String groupPhotoUrl = 'groupPhotoUrl';
  static const String participantIds = 'participantIds';
  static const String adminId = 'adminId';
  static const String lastMessage = 'lastMessage';
  static const String lastMessageTime = 'lastMessageTime';
  static const String lastMessageType = 'lastMessageType';
  static const String lastMessageSenderId = 'lastMessageSenderId';
  static const String unreadCount = 'unreadCount';
  static const String typingUsers = 'typingUsers';

  // Message fields
  static const String senderId = 'senderId';
  static const String text = 'text';
  static const String imageUrl = 'imageUrl';
  static const String audioUrl = 'audioUrl';
  static const String audioDuration = 'audioDuration';
  static const String type = 'type';
  static const String timestamp = 'timestamp';
  static const String status = 'status';
  static const String replyToMessageId = 'replyToMessageId';
  static const String replyToText = 'replyToText';
  static const String replyToSenderName = 'replyToSenderName';
  static const String reactions = 'reactions';
  static const String isEdited = 'isEdited';
  static const String deletedFor = 'deletedFor';
  static const String isDeletedForEveryone = 'isDeletedForEveryone';
}
