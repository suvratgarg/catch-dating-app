// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/export_organizer_contacts_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Manager-only bounded organizer audience export request.
final class ExportOrganizerContactsCallableRequest {
  const ExportOrganizerContactsCallableRequest({
    required this.organizerId,
    this.segmentId,
  });

  final String organizerId;
  final String? segmentId;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'segmentId': ?segmentId,
  };
}
