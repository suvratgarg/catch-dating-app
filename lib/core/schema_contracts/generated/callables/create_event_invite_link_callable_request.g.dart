// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/create_event_invite_link_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Callable payload accepted by createEventInviteLink. Hosts use this to create named share links such as Instagram bio, WhatsApp alumni, or venue partner.
final class CreateEventInviteLinkCallableRequest {
  const CreateEventInviteLinkCallableRequest({
    required this.eventId,
    required this.label,
    this.source,
  });

  final String eventId;
  final String label;
  final String? source;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'label': label,
    'source': ?source,
  };
}
