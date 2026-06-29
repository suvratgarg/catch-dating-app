import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_meeting_location.freezed.dart';
part 'event_meeting_location.g.dart';

/// Canonical meeting-location object embedded in `events/{eventId}.meetingLocation`
/// (and accepted by event callables). Mirrors the
/// `eventMeetingLocation` definition in
/// `contracts/shared/event_common.schema.json`.
///
/// The legacy meeting-point/string + nullable lat/lng fields on Event remain
/// for back-compat reads; new writes use [EventMeetingLocation] and
/// `event.effectiveMeetingLocation` for unified consumption.
@freezed
abstract class EventMeetingLocation with _$EventMeetingLocation {
  const EventMeetingLocation._();

  const factory EventMeetingLocation({
    required String name,
    String? address,
    String? placeId,
    required double latitude,
    required double longitude,
    String? notes,
  }) = _EventMeetingLocation;

  factory EventMeetingLocation.fromJson(Map<String, dynamic> json) =>
      _$EventMeetingLocationFromJson(json);

  /// Reconstructs a meeting location from legacy `meetingPoint` + `startingPoint{Lat,Lng}`
  /// fields on Event. Returns null if there's no usable name or coordinates.
  static EventMeetingLocation? legacy({
    required String name,
    required double? latitude,
    required double? longitude,
    String? notes,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty || latitude == null || longitude == null) {
      return null;
    }
    return EventMeetingLocation(
      name: normalizedName,
      latitude: latitude,
      longitude: longitude,
      notes: _trimToNull(notes),
    );
  }

  EventMeetingLocation normalized() {
    return EventMeetingLocation(
      name: name.trim(),
      address: _trimToNull(address),
      placeId: _trimToNull(placeId),
      latitude: latitude,
      longitude: longitude,
      notes: _trimToNull(notes),
    );
  }
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
