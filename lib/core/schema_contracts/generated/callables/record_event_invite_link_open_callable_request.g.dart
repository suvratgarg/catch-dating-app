// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/record_event_invite_link_open_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Callable payload accepted by recordEventInviteLinkOpen. It increments a live open counter and returns whether attribution can be attached to downstream booking actions.
final class RecordEventInviteLinkOpenCallableRequest {
  const RecordEventInviteLinkOpenCallableRequest({
    required this.eventId,
    required this.inviteLinkId,
  });

  final String eventId;
  final String inviteLinkId;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'inviteLinkId': inviteLinkId,
  };
}
