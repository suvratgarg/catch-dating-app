// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/admin_publish_external_event_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Callable payload accepted by adminPublishExternalEvent. This publishes one preflight-approved read-only externalEvents/{eventId} document from eventSupplyReadiness/current.
final class AdminPublishExternalEventCallableRequest {
  const AdminPublishExternalEventCallableRequest({
    required this.sourceActionId,
    required this.targetPath,
    required this.reviewNote,
    required this.checklist,
  });

  final String sourceActionId;
  final String targetPath;
  final String reviewNote;
  final Map<String, Object?> checklist;

  Map<String, Object?> toJson() => {
    'sourceActionId': sourceActionId,
    'targetPath': targetPath,
    'reviewNote': reviewNote,
    'checklist': checklist,
  };
}
