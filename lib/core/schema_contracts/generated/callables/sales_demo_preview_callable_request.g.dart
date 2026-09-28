// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/sales_demo_preview.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Anonymous read-only preview. Fetching never opens or consumes an invitation.
final class SalesDemoPreviewCallableRequest {
  const SalesDemoPreviewCallableRequest({
    required this.invitationId,
  });

  final String invitationId;

  Map<String, Object?> toJson() => {
    'invitationId': invitationId,
  };
}
