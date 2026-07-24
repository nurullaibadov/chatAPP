import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firestore_constants.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final int? audioDuration; // in seconds
  final String type; // text | image | audio | system
  final DateTime timestamp;
  final String status; // sent | delivered | read
  final String? replyToMessageId;
  final String? replyToText;
  final String? replyToSenderName;
  final Map<String, String> reactions; // userId -> emoji
  final bool isEdited;
  final List<String> deletedFor;
  final bool isDeletedForEveryone;

  const MessageModel({
    required this.id,
    required this.senderId,
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.audioDuration,
    this.type = AppConstants.messageTypeText,
    required this.timestamp,
    this.status = AppConstants.statusSent,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSenderName,
    this.reactions = const {},
    this.isEdited = false,
    this.deletedFor = const [],
    this.isDeletedForEveryone = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data[FirestoreConstants.senderId] ?? '',
      text: data[FirestoreConstants.text],
      imageUrl: data[FirestoreConstants.imageUrl],
      audioUrl: data[FirestoreConstants.audioUrl],
      audioDuration: data[FirestoreConstants.audioDuration],
      type: data[FirestoreConstants.type] ?? AppConstants.messageTypeText,
      timestamp: (data[FirestoreConstants.timestamp] as Timestamp?)?.toDate() ??
          DateTime.now(),
      status: data[FirestoreConstants.status] ?? AppConstants.statusSent,
      replyToMessageId: data[FirestoreConstants.replyToMessageId],
      replyToText: data[FirestoreConstants.replyToText],
      replyToSenderName: data[FirestoreConstants.replyToSenderName],
      reactions: Map<String, String>.from(
          data[FirestoreConstants.reactions] ?? {}),
      isEdited: data[FirestoreConstants.isEdited] ?? false,
      deletedFor:
          List<String>.from(data[FirestoreConstants.deletedFor] ?? []),
      isDeletedForEveryone:
          data[FirestoreConstants.isDeletedForEveryone] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.senderId: senderId,
      FirestoreConstants.text: text,
      FirestoreConstants.imageUrl: imageUrl,
      FirestoreConstants.audioUrl: audioUrl,
      FirestoreConstants.audioDuration: audioDuration,
      FirestoreConstants.type: type,
      FirestoreConstants.timestamp: Timestamp.fromDate(timestamp),
      FirestoreConstants.status: status,
      FirestoreConstants.replyToMessageId: replyToMessageId,
      FirestoreConstants.replyToText: replyToText,
      FirestoreConstants.replyToSenderName: replyToSenderName,
      FirestoreConstants.reactions: reactions,
      FirestoreConstants.isEdited: isEdited,
      FirestoreConstants.deletedFor: deletedFor,
      FirestoreConstants.isDeletedForEveryone: isDeletedForEveryone,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
    int? audioDuration,
    String? type,
    DateTime? timestamp,
    String? status,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
    Map<String, String>? reactions,
    bool? isEdited,
    List<String>? deletedFor,
    bool? isDeletedForEveryone,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      deletedFor: deletedFor ?? this.deletedFor,
      isDeletedForEveryone:
          isDeletedForEveryone ?? this.isDeletedForEveryone,
    );
  }

  bool isDeletedFor(String userId) {
    return isDeletedForEveryone || deletedFor.contains(userId);
  }

  String get displayText {
    if (isDeletedForEveryone) return '\u{1F6AB} This message was deleted';
    switch (type) {
      case AppConstants.messageTypeImage:
        return '\u{1F4F7} Photo';
      case AppConstants.messageTypeAudio:
        return '\u{1F3A4} Voice message';
      default:
        return text ?? '';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
