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
    this.groupRotationSlots = const [],
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
      groupRotationSlots:
          (json['groupRotationSlots'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map(
                (slot) => EventSuccessGroupRotationSlot.fromJson(
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
  final List<EventSuccessGroupRotationSlot> groupRotationSlots;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  List<String> get allPeerUids {
    final uids = <String>{
      ...peerUids,
      for (final slot in rotationSlots) slot.peerUid,
      for (final slot in groupRotationSlots) ...slot.peerUids,
    }.toList()..sort();
    return uids;
  }

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
    'groupRotationSlots': groupRotationSlots
        .map((slot) => slot.toJson())
        .toList(),
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

final class EventSuccessGroupRotationSlot {
  const EventSuccessGroupRotationSlot({
    required this.roundIndex,
    required this.label,
    required this.unitLabel,
    required this.startsAt,
    required this.endsAt,
    required this.peerUids,
    required this.compatibility,
  });

  factory EventSuccessGroupRotationSlot.fromJson(Map<String, dynamic> json) {
    return EventSuccessGroupRotationSlot(
      roundIndex: json['roundIndex'] as int? ?? 0,
      label: json['label'] as String? ?? 'Round',
      unitLabel: json['unitLabel'] as String? ?? 'Group',
      startsAt: _requiredTimestamp(json['startsAt'], 'startsAt'),
      endsAt: _requiredTimestamp(json['endsAt'], 'endsAt'),
      peerUids: (json['peerUids'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      compatibility: json['compatibility'] as String? ?? 'mixed',
    );
  }

  final int roundIndex;
  final String label;
  final String unitLabel;
  final DateTime startsAt;
  final DateTime endsAt;
  final List<String> peerUids;
  final String compatibility;

  Map<String, Object?> toJson() => {
    'roundIndex': roundIndex,
    'label': label,
    'unitLabel': unitLabel,
    'startsAt': Timestamp.fromDate(startsAt),
    'endsAt': Timestamp.fromDate(endsAt),
    'peerUids': peerUids,
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

final class EventSuccessGroupOverrideRound {
  const EventSuccessGroupOverrideRound({
    required this.roundIndex,
    required this.groups,
  });

  final int roundIndex;
  final List<EventSuccessGroupOverrideUnit> groups;

  Map<String, Object?> toJson() => {
    'roundIndex': roundIndex,
    'groups': groups.map((group) => group.toJson()).toList(),
  };
}

final class EventSuccessGroupOverrideUnit {
  const EventSuccessGroupOverrideUnit({
    required this.label,
    required this.participantUids,
  });

  final String label;
  final List<String> participantUids;

  Map<String, Object?> toJson() => {
    'label': label,
    'participantUids': participantUids,
  };
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
