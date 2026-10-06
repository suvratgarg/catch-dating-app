// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/admin_revoke_sales_partner_marketing_grant_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

final class AdminRevokeSalesPartnerMarketingGrantCallableRequest {
  const AdminRevokeSalesPartnerMarketingGrantCallableRequest({
    required this.requestId,
    required this.partnerUid,
    required this.grantId,
    required this.expectedMembershipRevision,
    required this.expectedGrantRevision,
    required this.reason,
  });

  final String requestId;
  final String partnerUid;
  final String grantId;
  final int expectedMembershipRevision;
  final int expectedGrantRevision;
  final String reason;

  Map<String, Object?> toJson() => {
    'requestId': requestId,
    'partnerUid': partnerUid,
    'grantId': grantId,
    'expectedMembershipRevision': expectedMembershipRevision,
    'expectedGrantRevision': expectedGrantRevision,
    'reason': reason,
  };
}
