// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_attendee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventAttendee _$EventAttendeeFromJson(
  Map<String, dynamic> json,
) => _EventAttendee(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  clubId: json['clubId'] as String,
  organizerId: json['organizerId'] as String,
  displayName: json['displayName'] as String,
  searchName: json['searchName'] as String,
  source: $enumDecode(_$EventAttendeeSourceEnumMap, json['source']),
  status: $enumDecode(_$EventAttendeeStatusEnumMap, json['status']),
  linkedUid: json['linkedUid'] as String?,
  phoneE164: json['phoneE164'] as String?,
  email: json['email'] as String?,
  externalReference: json['externalReference'] as String?,
  ticketType: json['ticketType'] as String?,
  importId: json['importId'] as String?,
  sourceRowId: json['sourceRowId'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  registeredAt: const NullableTimestampConverter().fromJson(
    json['registeredAt'],
  ),
  waitlistedAt: const NullableTimestampConverter().fromJson(
    json['waitlistedAt'],
  ),
  checkedInAt: const NullableTimestampConverter().fromJson(json['checkedInAt']),
  cancelledAt: const NullableTimestampConverter().fromJson(json['cancelledAt']),
  checkedInBy: json['checkedInBy'] as String?,
  linkedAt: const NullableTimestampConverter().fromJson(json['linkedAt']),
);

Map<String, dynamic> _$EventAttendeeToJson(_EventAttendee instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'clubId': instance.clubId,
      'organizerId': instance.organizerId,
      'displayName': instance.displayName,
      'searchName': instance.searchName,
      'source': _$EventAttendeeSourceEnumMap[instance.source]!,
      'status': _$EventAttendeeStatusEnumMap[instance.status]!,
      'linkedUid': instance.linkedUid,
      'phoneE164': instance.phoneE164,
      'email': instance.email,
      'externalReference': instance.externalReference,
      'ticketType': instance.ticketType,
      'importId': instance.importId,
      'sourceRowId': instance.sourceRowId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'registeredAt': const NullableTimestampConverter().toJson(
        instance.registeredAt,
      ),
      'waitlistedAt': const NullableTimestampConverter().toJson(
        instance.waitlistedAt,
      ),
      'checkedInAt': const NullableTimestampConverter().toJson(
        instance.checkedInAt,
      ),
      'cancelledAt': const NullableTimestampConverter().toJson(
        instance.cancelledAt,
      ),
      'checkedInBy': instance.checkedInBy,
      'linkedAt': const NullableTimestampConverter().toJson(instance.linkedAt),
    };

const _$EventAttendeeSourceEnumMap = {
  EventAttendeeSource.catchBooking: 'catchBooking',
  EventAttendeeSource.hostImport: 'hostImport',
  EventAttendeeSource.hostManual: 'hostManual',
  EventAttendeeSource.webOtp: 'webOtp',
};

const _$EventAttendeeStatusEnumMap = {
  EventAttendeeStatus.invited: 'invited',
  EventAttendeeStatus.registered: 'registered',
  EventAttendeeStatus.waitlisted: 'waitlisted',
  EventAttendeeStatus.checkedIn: 'checkedIn',
  EventAttendeeStatus.cancelled: 'cancelled',
};
