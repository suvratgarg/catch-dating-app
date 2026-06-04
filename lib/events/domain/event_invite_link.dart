import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventInviteLink {
  const EventInviteLink({
    required this.id,
    required this.eventId,
    required this.clubId,
    required this.hostUid,
    required this.label,
    required this.source,
    required this.openCount,
    required this.requestCount,
    required this.confirmedCount,
    required this.paidCount,
    required this.checkedInCount,
    required this.catcherCount,
    required this.matchCount,
    required this.chatStartedCount,
    required this.disabledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventInviteLink.fromJson(Map<String, dynamic> json) {
    return EventInviteLink(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      clubId: json['clubId'] as String,
      hostUid: json['hostUid'] as String,
      label: json['label'] as String,
      source: json['source'] as String?,
      openCount: _intFromJson(json['openCount']),
      requestCount: _intFromJson(json['requestCount']),
      confirmedCount: _intFromJson(json['confirmedCount']),
      paidCount: _intFromJson(json['paidCount']),
      checkedInCount: _intFromJson(json['checkedInCount']),
      catcherCount: _intFromJson(json['catcherCount']),
      matchCount: _intFromJson(json['matchCount']),
      chatStartedCount: _intFromJson(json['chatStartedCount']),
      disabledAt: const NullableTimestampConverter().fromJson(
        json['disabledAt'],
      ),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );
  }

  final String id;
  final String eventId;
  final String clubId;
  final String hostUid;
  final String label;
  final String? source;
  final int openCount;
  final int requestCount;
  final int confirmedCount;
  final int paidCount;
  final int checkedInCount;
  final int catcherCount;
  final int matchCount;
  final int chatStartedCount;
  final DateTime? disabledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDisabled => disabledAt != null;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    'hostUid': hostUid,
    'label': label,
    'source': source,
    'openCount': openCount,
    'requestCount': requestCount,
    'confirmedCount': confirmedCount,
    'paidCount': paidCount,
    'checkedInCount': checkedInCount,
    'catcherCount': catcherCount,
    'matchCount': matchCount,
    'chatStartedCount': chatStartedCount,
    'disabledAt': disabledAt == null ? null : Timestamp.fromDate(disabledAt!),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

int _intFromJson(Object? value) => value is num ? value.toInt() : 0;
