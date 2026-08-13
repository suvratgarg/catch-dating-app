// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/create_organizer_contact_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Manager-only creation of a name-only organizer CRM contact. It does not create an attendee, Consumer account, or messaging permission.
final class CreateOrganizerContactCallableRequest {
  const CreateOrganizerContactCallableRequest({
    required this.organizerId,
    required this.displayName,
  });

  final String organizerId;
  final String displayName;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'displayName': displayName,
  };
}
