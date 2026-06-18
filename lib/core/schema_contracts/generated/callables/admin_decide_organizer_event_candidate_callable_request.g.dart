// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/admin_decide_organizer_event_candidate_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Callable payload accepted by adminDecideOrganizerEventCandidate. This records a manual admin review decision for a private external event candidate without importing the event.
final class AdminDecideOrganizerEventCandidateCallableRequest {
  const AdminDecideOrganizerEventCandidateCallableRequest({
    required this.candidateId,
    required this.decision,
    required this.checklist,
    required this.note,
  });

  final String candidateId;
  final String decision;
  final Map<String, Object?> checklist;
  final String note;

  Map<String, Object?> toJson() => {
    'candidateId': candidateId,
    'decision': decision,
    'checklist': checklist,
    'note': note,
  };
}
