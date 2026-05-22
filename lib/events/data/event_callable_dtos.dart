import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';

final class CreateEventCallableRequest {
  const CreateEventCallableRequest({
    required this.eventId,
    required this.clubId,
    required this.details,
    required this.capacityLimit,
    required this.priceInPaise,
    required this.currency,
    required this.constraints,
    required this.eventPolicy,
    required this.eventFormat,
    required this.eventSuccessDefaults,
    required this.inviteCode,
  });

  factory CreateEventCallableRequest.fromEvent(
    Event event, {
    String? inviteCode,
    Map<String, Object?>? eventSuccessDefaults,
  }) => CreateEventCallableRequest(
    eventId: event.id,
    clubId: event.clubId,
    details: EventDetailsCallableDto.fromEvent(event),
    capacityLimit: event.capacityLimit,
    priceInPaise: event.priceInPaise,
    currency: event.currency,
    constraints: EventConstraintsCallableDto.fromDomain(event.constraints),
    eventPolicy: event.eventPolicy?.toJson(),
    eventFormat: event.eventFormat.toJson(),
    eventSuccessDefaults: eventSuccessDefaults,
    inviteCode: inviteCode,
  );

  final String eventId;
  final String clubId;
  final EventDetailsCallableDto details;
  final int capacityLimit;
  final int priceInPaise;
  final String currency;
  final EventConstraintsCallableDto constraints;
  final Map<String, Object?>? eventPolicy;
  final Map<String, Object?> eventFormat;
  final Map<String, Object?>? eventSuccessDefaults;
  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    ...details.toJson(),
    'capacityLimit': capacityLimit,
    'priceInPaise': priceInPaise,
    'currency': currency,
    'constraints': constraints.toJson(),
    'eventPolicy': ?eventPolicy,
    'eventFormat': eventFormat,
    'eventSuccessDefaults': ?eventSuccessDefaults,
    'privateAccess': ?_privateAccessJson(inviteCode),
  };
}

final class UpdateEventCallableRequest {
  const UpdateEventCallableRequest({
    required this.eventId,
    required this.fields,
  });

  factory UpdateEventCallableRequest.fromEvent(
    Event event, {
    bool includePolicy = false,
    String? inviteCode,
  }) {
    final fields = EventDetailsCallableDto.fromEvent(event).toJson();
    if (includePolicy) {
      fields.addAll({
        'capacityLimit': event.capacityLimit,
        'priceInPaise': event.priceInPaise,
        'constraints': EventConstraintsCallableDto.fromDomain(
          event.constraints,
        ).toJson(),
        'eventPolicy': event.eventPolicy?.toJson(),
        'privateAccess': ?_privateAccessJson(inviteCode),
      });
    }
    return UpdateEventCallableRequest(eventId: event.id, fields: fields);
  }

  final String eventId;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {'eventId': eventId, 'fields': fields};
}

final class EventDetailsCallableDto {
  const EventDetailsCallableDto({
    required this.startTimeMillis,
    required this.endTimeMillis,
    required this.meetingPoint,
    required this.meetingLocation,
    required this.startingPointLat,
    required this.startingPointLng,
    required this.locationDetails,
    required this.photoUrl,
    required this.distanceKm,
    required this.pace,
    required this.description,
  });

  factory EventDetailsCallableDto.fromEvent(Event event) {
    final meetingLocation = event.effectiveMeetingLocation;
    if (meetingLocation == null) {
      throw StateError('Event ${event.id} is missing a meeting location.');
    }
    return EventDetailsCallableDto(
      startTimeMillis: event.startTime.millisecondsSinceEpoch,
      endTimeMillis: event.endTime.millisecondsSinceEpoch,
      meetingPoint: meetingLocation.name,
      meetingLocation: meetingLocation.normalized(),
      startingPointLat: meetingLocation.latitude,
      startingPointLng: meetingLocation.longitude,
      locationDetails: meetingLocation.notes,
      photoUrl: event.photoUrl,
      distanceKm: event.distanceKm,
      pace: event.pace.name,
      description: event.description,
    );
  }

  final int startTimeMillis;
  final int endTimeMillis;
  final String meetingPoint;
  final EventMeetingLocation meetingLocation;
  final double? startingPointLat;
  final double? startingPointLng;
  final String? locationDetails;
  final String? photoUrl;
  final double distanceKm;
  final String pace;
  final String description;

  Map<String, Object?> toJson() => {
    'startTimeMillis': startTimeMillis,
    'endTimeMillis': endTimeMillis,
    'meetingPoint': meetingPoint,
    'meetingLocation': meetingLocation.toJson(),
    'startingPointLat': startingPointLat,
    'startingPointLng': startingPointLng,
    'locationDetails': locationDetails,
    'photoUrl': photoUrl,
    'distanceKm': distanceKm,
    'pace': pace,
    'description': description,
  };
}

final class EventConstraintsCallableDto {
  const EventConstraintsCallableDto({
    required this.minAge,
    required this.maxAge,
    required this.maxMen,
    required this.maxWomen,
  });

  factory EventConstraintsCallableDto.fromDomain(
    EventConstraints constraints,
  ) => EventConstraintsCallableDto(
    minAge: constraints.minAge,
    maxAge: constraints.maxAge,
    maxMen: constraints.maxMen,
    maxWomen: constraints.maxWomen,
  );

  final int minAge;
  final int maxAge;
  final int? maxMen;
  final int? maxWomen;

  Map<String, Object?> toJson() => {
    'minAge': minAge,
    'maxAge': maxAge,
    'maxMen': maxMen,
    'maxWomen': maxWomen,
  };
}

final class EventIdCallableRequest {
  const EventIdCallableRequest(this.eventId, {this.inviteCode});

  final String eventId;
  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'inviteCode': ?inviteCode,
  };
}

final class CancelEventCallableRequest {
  const CancelEventCallableRequest({required this.eventId, this.reason});

  final String eventId;
  final String? reason;

  Map<String, Object?> toJson() => {'eventId': eventId, 'reason': ?reason};
}

Map<String, Object?>? _privateAccessJson(String? inviteCode) {
  final normalized = inviteCode?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return {'inviteCode': normalized};
}

final class MarkEventAttendanceCallableRequest {
  const MarkEventAttendanceCallableRequest({
    required this.eventId,
    required this.userId,
  });

  final String eventId;
  final String userId;

  Map<String, Object?> toJson() => {'eventId': eventId, 'userId': userId};
}

final class MarkEventAttendanceCallableResponse {
  const MarkEventAttendanceCallableResponse({required this.attended});

  factory MarkEventAttendanceCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final attended = map['attended'];
      if (attended is bool) {
        return MarkEventAttendanceCallableResponse(attended: attended);
      }
    }
    throw StateError('markEventAttendance response was missing attended.');
  }

  final bool attended;
}

final class SelfCheckInAttendanceCallableRequest {
  const SelfCheckInAttendanceCallableRequest({
    required this.eventId,
    required this.latitude,
    required this.longitude,
  });

  final String eventId;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'latitude': ?latitude,
    'longitude': ?longitude,
  };
}
