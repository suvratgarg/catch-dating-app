import 'package:cloud_firestore/cloud_firestore.dart';

final class EventSuccessPreference {
  const EventSuccessPreference({
    required this.id,
    required this.eventId,
    required this.clubId,
    required this.uid,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventSuccessPreference.fromJson(Map<String, dynamic> json) {
    return EventSuccessPreference(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      clubId: json['clubId'] as String,
      uid: json['uid'] as String,
      microPodsOptedOut: json['microPodsOptedOut'] as bool? ?? false,
      guidedRotationsOptedOut:
          json['guidedRotationsOptedOut'] as bool? ?? false,
      createdAt: _requiredTimestamp(json['createdAt'], 'createdAt'),
      updatedAt: _requiredTimestamp(json['updatedAt'], 'updatedAt'),
    );
  }

  final String id;
  final String eventId;
  final String clubId;
  final String uid;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    'uid': uid,
    'microPodsOptedOut': microPodsOptedOut,
    'guidedRotationsOptedOut': guidedRotationsOptedOut,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

String eventSuccessPreferenceId({
  required String eventId,
  required String uid,
}) => '${eventId}_$uid';

DateTime _requiredTimestamp(Object? value, String field) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  throw StateError('Missing timestamp field $field.');
}
