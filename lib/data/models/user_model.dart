import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String statusMessage;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? fcmToken;
  final List<String> blockedUsers;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.statusMessage = '',
    this.isOnline = false,
    this.lastSeen,
    this.fcmToken,
    this.blockedUsers = const [],
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data[FirestoreConstants.name] ?? '',
      email: data[FirestoreConstants.email] ?? '',
      photoUrl: data[FirestoreConstants.photoUrl],
      statusMessage: data[FirestoreConstants.statusMessage] ?? '',
      isOnline: data[FirestoreConstants.isOnline] ?? false,
      lastSeen: (data[FirestoreConstants.lastSeen] as Timestamp?)?.toDate(),
      fcmToken: data[FirestoreConstants.fcmToken],
      blockedUsers:
          List<String>.from(data[FirestoreConstants.blockedUsers] ?? []),
      createdAt: (data[FirestoreConstants.createdAt] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data[FirestoreConstants.name] ?? '',
      email: data[FirestoreConstants.email] ?? '',
      photoUrl: data[FirestoreConstants.photoUrl],
      statusMessage: data[FirestoreConstants.statusMessage] ?? '',
      isOnline: data[FirestoreConstants.isOnline] ?? false,
      lastSeen: (data[FirestoreConstants.lastSeen] as Timestamp?)?.toDate(),
      fcmToken: data[FirestoreConstants.fcmToken],
      blockedUsers:
          List<String>.from(data[FirestoreConstants.blockedUsers] ?? []),
      createdAt: (data[FirestoreConstants.createdAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.uid: uid,
      FirestoreConstants.name: name,
      FirestoreConstants.email: email,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.statusMessage: statusMessage,
      FirestoreConstants.isOnline: isOnline,
      FirestoreConstants.lastSeen:
          lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      FirestoreConstants.fcmToken: fcmToken,
      FirestoreConstants.blockedUsers: blockedUsers,
      FirestoreConstants.createdAt:
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? statusMessage,
    bool? isOnline,
    DateTime? lastSeen,
    String? fcmToken,
    List<String>? blockedUsers,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool isBlockedBy(String userId) => blockedUsers.contains(userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, email: $email, isOnline: $isOnline)';
}
