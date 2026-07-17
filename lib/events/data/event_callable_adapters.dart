import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        CreateEventCallableRequest,
        CreateEventPrivateAccess,
        UpdateEventCallableRequest;
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/domain/event.dart';

CreateEventCallableRequest createEventCallableRequestFromEvent(
  Event event, {
  String? inviteCode,
  EventSuccessDefaults? eventSuccessDefaults,
}) {
  final effectiveMeetingLocation = event.effectiveMeetingLocation;
  if (effectiveMeetingLocation == null) {
    throw StateError(
      'Cannot create an event without exact meeting coordinates.',
    );
  }
  final meetingLocation = effectiveMeetingLocation.normalized();
  return CreateEventCallableRequest(
    eventId: event.id,
    clubId: event.clubId,
    startTimeMillis: event.startTime.millisecondsSinceEpoch,
    endTimeMillis: event.endTime.millisecondsSinceEpoch,
    meetingPoint: meetingLocation.name,
    meetingLocation: meetingLocation,
    startingPointLat: meetingLocation.latitude,
    startingPointLng: meetingLocation.longitude,
    locationDetails: meetingLocation.notes,
    photoUrl: event.photoUrl,
    distanceKm: event.distanceKm,
    pace: event.pace.name,
    capacityLimit: event.capacityLimit,
    description: event.description,
    priceInPaise: event.priceInPaise,
    currency: event.currency,
    constraints: event.constraints,
    eventPolicy: event.eventPolicy,
    eventFormat: event.eventFormat,
    eventSuccessDefaults: eventSuccessDefaults,
    privateAccess: _privateAccessJson(inviteCode),
  );
}

UpdateEventCallableRequest updateEventCallableRequestFromEvent(
  Event event, {
  bool includePolicy = false,
  String? inviteCode,
}) {
  final effectiveMeetingLocation = event.effectiveMeetingLocation;
  if (effectiveMeetingLocation == null) {
    throw StateError(
      'Cannot update an event without exact meeting coordinates.',
    );
  }
  final meetingLocation = effectiveMeetingLocation.normalized();
  final fields = <String, Object?>{
    'startTimeMillis': event.startTime.millisecondsSinceEpoch,
    'endTimeMillis': event.endTime.millisecondsSinceEpoch,
    'meetingPoint': meetingLocation.name,
    'meetingLocation': meetingLocation.toJson(),
    'startingPointLat': meetingLocation.latitude,
    'startingPointLng': meetingLocation.longitude,
    'locationDetails': meetingLocation.notes,
    'photoUrl': event.photoUrl,
    if (event.eventPhotos.isNotEmpty)
      'eventPhotos': event.eventPhotos.map((photo) => photo.toJson()).toList(),
    'distanceKm': event.distanceKm,
    'pace': event.pace.name,
    'description': event.description,
  };
  if (includePolicy) {
    fields.addAll({
      'capacityLimit': event.capacityLimit,
      'priceInPaise': event.priceInPaise,
      'constraints': event.constraints.toJson(),
      'eventPolicy': event.eventPolicy?.toJson(),
      'privateAccess': ?_privateAccessJson(inviteCode),
    });
  }
  return UpdateEventCallableRequest(eventId: event.id, fields: fields);
}

CreateEventPrivateAccess? _privateAccessJson(String? inviteCode) {
  final normalized = inviteCode?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return CreateEventPrivateAccess(inviteCode: normalized);
}
