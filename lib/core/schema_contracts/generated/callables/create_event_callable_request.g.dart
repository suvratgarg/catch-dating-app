// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements
import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_meeting_location.dart';


// Typed callable request DTO emitted from callables/create_event_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Nested private-access payload accepted by createEvent.
final class CreateEventPrivateAccess {
  const CreateEventPrivateAccess({this.inviteCode});

  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'inviteCode': ?inviteCode,
  };
}

/// Callable payload accepted by createEvent.
final class CreateEventCallableRequest {
  const CreateEventCallableRequest({
    this.eventId,
    required this.clubId,
    required this.startTimeMillis,
    required this.endTimeMillis,
    required this.meetingPoint,
    required this.meetingLocation,
    required this.startingPointLat,
    required this.startingPointLng,
    this.locationDetails,
    this.photoUrl,
    this.eventPhotos,
    required this.distanceKm,
    required this.pace,
    required this.capacityLimit,
    required this.description,
    required this.priceInPaise,
    this.currency,
    this.eventPolicy,
    this.privateAccess,
    this.eventFormat,
    this.eventSuccessDefaults,
    this.constraints,
  });

  final String? eventId;
  final String clubId;
  final int startTimeMillis;
  final int endTimeMillis;
  final String meetingPoint;
  final EventMeetingLocation meetingLocation;
  final double startingPointLat;
  final double startingPointLng;
  final String? locationDetails;
  final String? photoUrl;
  final List<Map<String, Object?>>? eventPhotos;
  final double distanceKm;
  final String pace;
  final int capacityLimit;
  final String description;
  final int priceInPaise;
  final String? currency;
  final EventPolicyBundle? eventPolicy;
  final CreateEventPrivateAccess? privateAccess;
  final EventFormatSnapshot? eventFormat;
  final EventSuccessDefaults? eventSuccessDefaults;
  final EventConstraints? constraints;

  Map<String, Object?> toJson() => {
    'eventId': ?eventId,
    'clubId': clubId,
    'startTimeMillis': startTimeMillis,
    'endTimeMillis': endTimeMillis,
    'meetingPoint': meetingPoint,
    'meetingLocation': meetingLocation.toJson(),
    'startingPointLat': startingPointLat,
    'startingPointLng': startingPointLng,
    'locationDetails': ?locationDetails,
    'photoUrl': ?photoUrl,
    'eventPhotos': ?eventPhotos,
    'distanceKm': distanceKm,
    'pace': pace,
    'capacityLimit': capacityLimit,
    'description': description,
    'priceInPaise': priceInPaise,
    'currency': ?currency,
    'eventPolicy': ?eventPolicy?.toJson(),
    'privateAccess': ?privateAccess?.toJson(),
    'eventFormat': ?eventFormat?.toJson(),
    'eventSuccessDefaults': ?eventSuccessDefaults?.toJson(),
    'constraints': ?constraints?.toJson(),
  };
}
