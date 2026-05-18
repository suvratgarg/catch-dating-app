import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventPrivateAccess {
  const EventPrivateAccess({
    required this.id,
    required this.eventId,
    required this.clubId,
    required this.inviteCode,
    required this.createdAt,
  });

  factory EventPrivateAccess.fromJson(Map<String, dynamic> json) {
    return EventPrivateAccess(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      clubId: json['clubId'] as String,
      inviteCode: json['inviteCode'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );
  }

  final String id;
  final String eventId;
  final String clubId;
  final String inviteCode;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    'inviteCode': inviteCode,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
