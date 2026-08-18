// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/list_organizer_form_responses_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Manager-authorized bounded response inbox query.
final class ListOrganizerFormResponsesCallableRequest {
  const ListOrganizerFormResponsesCallableRequest({
    required this.organizerId,
    required this.formId,
    required this.versionId,
    required this.statuses,
    required this.identityKinds,
    required this.sourceLinkId,
    required this.query,
    required this.fromMillis,
    required this.toMillis,
    required this.cursor,
    required this.limit,
  });

  final String organizerId;
  final String? formId;
  final String? versionId;
  final List<String> statuses;
  final List<String> identityKinds;
  final String? sourceLinkId;
  final String? query;
  final int? fromMillis;
  final int? toMillis;
  final String? cursor;
  final int limit;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'formId': formId,
    'versionId': versionId,
    'statuses': statuses,
    'identityKinds': identityKinds,
    'sourceLinkId': sourceLinkId,
    'query': query,
    'fromMillis': fromMillis,
    'toMillis': toMillis,
    'cursor': cursor,
    'limit': limit,
  };
}
