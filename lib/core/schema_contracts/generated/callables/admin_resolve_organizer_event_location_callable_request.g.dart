// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/admin_resolve_organizer_event_location_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Callable payload accepted by adminResolveOrganizerEventLocation. This records reviewed coordinates for a private external event candidate without importing the event.
final class AdminResolveOrganizerEventLocationCallableRequest {
  const AdminResolveOrganizerEventLocationCallableRequest({
    required this.candidateId,
    required this.location,
    required this.checklist,
    required this.note,
  });

  final String candidateId;
  final Map<String, Object?> location;
  final Map<String, Object?> checklist;
  final String note;

  Map<String, Object?> toJson() => {
    'candidateId': candidateId,
    'location': location,
    'checklist': checklist,
    'note': note,
  };
}
