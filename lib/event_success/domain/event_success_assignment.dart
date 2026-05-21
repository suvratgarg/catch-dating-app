import 'package:cloud_firestore/cloud_firestore.dart';

final class EventSuccessAssignment {
  const EventSuccessAssignment({
    required this.id,
    required this.eventId,
    required this.clubId,
    required this.uid,
    required this.moduleId,
    required this.label,
    required this.displayTitle,
    required this.peerUids,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.displaySubtitle,
    this.rotationSlots = const [],
  });

  factory EventSuccessAssignment.fromJson(Map<String, dynamic> json) {
    return EventSuccessAssignment(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      clubId: json['clubId'] as String,
      uid: json['uid'] as String,
      moduleId: json['moduleId'] as String,
      label: json['label'] as String,
      displayTitle: json['displayTitle'] as String,
      displaySubtitle: json['displaySubtitle'] as String?,
      peerUids: (json['peerUids'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      rotationSlots: (json['rotationSlots'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (slot) => EventSuccessRotationSlot.fromJson(
              Map<String, dynamic>.from(slot),
            ),
          )
          .toList(growable: false),
      source: json['source'] as String? ?? 'server',
      createdAt: _requiredTimestamp(json['createdAt'], 'createdAt'),
      updatedAt: _requiredTimestamp(json['updatedAt'], 'updatedAt'),
    );
  }

  final String id;
  final String eventId;
  final String clubId;
  final String uid;
  final String moduleId;
  final String label;
  final String displayTitle;
  final String? displaySubtitle;
  final List<String> peerUids;
  final List<EventSuccessRotationSlot> rotationSlots;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    'uid': uid,
    'moduleId': moduleId,
    'label': label,
    'displayTitle': displayTitle,
    'displaySubtitle': displaySubtitle,
    'peerUids': peerUids,
    'rotationSlots': rotationSlots.map((slot) => slot.toJson()).toList(),
    'source': source,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

final class EventSuccessRotationSlot {
  const EventSuccessRotationSlot({
    required this.roundIndex,
    required this.label,
    required this.startsAt,
    required this.endsAt,
    required this.peerUid,
    required this.compatibility,
  });

  factory EventSuccessRotationSlot.fromJson(Map<String, dynamic> json) {
    return EventSuccessRotationSlot(
      roundIndex: json['roundIndex'] as int? ?? 0,
      label: json['label'] as String? ?? 'Round',
      startsAt: _requiredTimestamp(json['startsAt'], 'startsAt'),
      endsAt: _requiredTimestamp(json['endsAt'], 'endsAt'),
      peerUid: json['peerUid'] as String,
      compatibility: json['compatibility'] as String? ?? 'social',
    );
  }

  final int roundIndex;
  final String label;
  final DateTime startsAt;
  final DateTime endsAt;
  final String peerUid;
  final String compatibility;

  Map<String, Object?> toJson() => {
    'roundIndex': roundIndex,
    'label': label,
    'startsAt': Timestamp.fromDate(startsAt),
    'endsAt': Timestamp.fromDate(endsAt),
    'peerUid': peerUid,
    'compatibility': compatibility,
  };
}

final class EventSuccessRotationOverrideRound {
  const EventSuccessRotationOverrideRound({
    required this.roundIndex,
    required this.pairings,
  });

  final int roundIndex;
  final List<EventSuccessRotationOverridePair> pairings;

  Map<String, Object?> toJson() => {
    'roundIndex': roundIndex,
    'pairings': pairings.map((pairing) => pairing.toJson()).toList(),
  };
}

final class EventSuccessRotationOverridePair {
  const EventSuccessRotationOverridePair({
    required this.uidA,
    required this.uidB,
  });

  final String uidA;
  final String uidB;

  Map<String, Object?> toJson() => {'uidA': uidA, 'uidB': uidB};
}

String eventSuccessAssignmentId({
  required String eventId,
  required String moduleId,
  required String uid,
}) => '${eventId}_${moduleId}_$uid';

DateTime _requiredTimestamp(Object? value, String field) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  throw StateError('Missing timestamp field $field.');
}
