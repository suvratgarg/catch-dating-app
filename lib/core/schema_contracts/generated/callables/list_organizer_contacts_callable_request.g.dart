// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/list_organizer_contacts_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Manager-authorized paginated organizer audience query.
final class ListOrganizerContactsCallableRequest {
  const ListOrganizerContactsCallableRequest({
    required this.organizerId,
    this.limit,
    this.cursor,
    this.query,
    this.segmentId,
  });

  final String organizerId;
  final int? limit;
  final String? cursor;
  final String? query;
  final String? segmentId;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'limit': ?limit,
    'cursor': ?cursor,
    'query': ?query,
    'segmentId': ?segmentId,
  };
}
