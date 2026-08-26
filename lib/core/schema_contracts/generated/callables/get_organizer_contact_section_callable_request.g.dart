// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/get_organizer_contact_section_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Manager-authorized request for one independently loadable organizer contact section.
final class GetOrganizerContactSectionCallableRequest {
  const GetOrganizerContactSectionCallableRequest({
    required this.organizerId,
    required this.contactId,
    required this.section,
  });

  final String organizerId;
  final String contactId;
  final String section;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'contactId': contactId,
    'section': section,
  };
}
