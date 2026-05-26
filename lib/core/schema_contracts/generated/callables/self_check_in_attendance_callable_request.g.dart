// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/self_check_in_attendance_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Callable payload accepted by selfCheckInAttendance.
final class SelfCheckInAttendanceCallableRequest {
  const SelfCheckInAttendanceCallableRequest({
    required this.eventId,
    this.latitude,
    this.longitude,
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
