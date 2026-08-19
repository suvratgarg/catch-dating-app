// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/control_event_rehearsal_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Revision-fenced Host lifecycle or virtual-clock control.
final class ControlEventRehearsalCallableRequest {
  const ControlEventRehearsalCallableRequest({
    required this.sessionId,
    required this.expectedRevision,
    required this.clientActionId,
    required this.action,
    this.minutes,
  });

  final String sessionId;
  final int expectedRevision;
  final String clientActionId;
  final String action;
  final int? minutes;

  Map<String, Object?> toJson() => {
    'sessionId': sessionId,
    'expectedRevision': expectedRevision,
    'clientActionId': clientActionId,
    'action': action,
    'minutes': ?minutes,
  };
}
