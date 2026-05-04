import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUser {
  const BlockedUser({
    required this.uid,
    required this.createdAt,
    required this.source,
  });

  final String uid;
  final DateTime? createdAt;
  final String source;

  factory BlockedUser.fromFirestore(Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    return BlockedUser(
      uid: data['blockedUserId'] as String,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
      source: data['source'] as String? ?? 'profile',
    );
  }
}
