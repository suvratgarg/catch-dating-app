import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';

final class CreateEventCallableRequest {
  const CreateEventCallableRequest({
    required this.eventId,
    required this.clubId,
    required this.details,
    required this.capacityLimit,
    required this.priceInPaise,
    required this.constraints,
    required this.eventPolicy,
  });

  factory CreateEventCallableRequest.fromEvent(Event event) =>
      CreateEventCallableRequest(
        eventId: event.id,
        clubId: event.clubId,
        details: EventDetailsCallableFields.fromEvent(event),
        capacityLimit: event.capacityLimit,
        priceInPaise: event.priceInPaise,
        constraints: EventConstraintsCallableDto.fromDomain(event.constraints),
        eventPolicy: event.eventPolicy?.toJson(),
      );

  final String eventId;
  final String clubId;
  final EventDetailsCallableFields details;
  final int capacityLimit;
  final int priceInPaise;
  final EventConstraintsCallableDto constraints;
  final Map<String, Object?>? eventPolicy;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'clubId': clubId,
    ...details.toJson(),
    'capacityLimit': capacityLimit,
    'priceInPaise': priceInPaise,
    'constraints': constraints.toJson(),
    'eventPolicy': ?eventPolicy,
  };
}

final class UpdateEventCallableRequest {
  const UpdateEventCallableRequest({
    required this.eventId,
    required this.fields,
  });

  factory UpdateEventCallableRequest.fromEvent(Event event) =>
      UpdateEventCallableRequest(
        eventId: event.id,
        fields: EventDetailsCallableFields.fromEvent(event),
      );

  final String eventId;
  final EventDetailsCallableFields fields;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'fields': fields.toJson(),
  };
}

final class EventDetailsCallableFields {
  const EventDetailsCallableFields({
    required this.startTimeMillis,
    required this.endTimeMillis,
    required this.meetingPoint,
    required this.startingPointLat,
    required this.startingPointLng,
    required this.locationDetails,
    required this.photoUrl,
    required this.distanceKm,
    required this.pace,
    required this.description,
  });

  factory EventDetailsCallableFields.fromEvent(Event event) =>
      EventDetailsCallableFields(
        startTimeMillis: event.startTime.millisecondsSinceEpoch,
        endTimeMillis: event.endTime.millisecondsSinceEpoch,
        meetingPoint: event.meetingPoint,
        startingPointLat: event.startingPointLat,
        startingPointLng: event.startingPointLng,
        locationDetails: event.locationDetails,
        photoUrl: event.photoUrl,
        distanceKm: event.distanceKm,
        pace: event.pace.name,
        description: event.description,
      );

  final int startTimeMillis;
  final int endTimeMillis;
  final String meetingPoint;
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
  const EventIdCallableRequest(this.eventId);

  final String eventId;

  Map<String, Object?> toJson() => {'eventId': eventId};
}

final class CancelEventCallableRequest {
  const CancelEventCallableRequest({required this.eventId, this.reason});

  final String eventId;
  final String? reason;

  Map<String, Object?> toJson() => {'eventId': eventId, 'reason': ?reason};
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
