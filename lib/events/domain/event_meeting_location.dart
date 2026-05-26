import 'package:catch_dating_app/core/sentinels.dart';

/// Canonical meeting-location object embedded in `events/{eventId}.meetingLocation`
/// (and accepted by event callables). Mirrors the
/// `eventMeetingLocation` definition in
/// `contracts/shared/event_common.schema.json`.
///
/// The legacy meeting-point/string + nullable lat/lng fields on Event remain
/// for back-compat reads; new writes use [EventMeetingLocation] and
/// `event.effectiveMeetingLocation` for unified consumption.
class EventMeetingLocation {
  const EventMeetingLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
    this.notes,
  });

  factory EventMeetingLocation.fromJson(Map<String, dynamic> json) {
    return EventMeetingLocation(
      name: json['name'] as String,
      address: json['address'] as String?,
      placeId: json['placeId'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

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

  final String name;
  final String? address;
  final String? placeId;
  final double latitude;
  final double longitude;
  final String? notes;

  EventMeetingLocation copyWith({
    String? name,
    Object? address = unsetSentinel,
    Object? placeId = unsetSentinel,
    double? latitude,
    double? longitude,
    Object? notes = unsetSentinel,
  }) {
    return EventMeetingLocation(
      name: name ?? this.name,
      address: identical(address, unsetSentinel)
          ? this.address
          : address as String?,
      placeId: identical(placeId, unsetSentinel)
          ? this.placeId
          : placeId as String?,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: identical(notes, unsetSentinel) ? this.notes : notes as String?,
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'address': address,
    'placeId': placeId,
    'latitude': latitude,
    'longitude': longitude,
    'notes': notes,
  };
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
