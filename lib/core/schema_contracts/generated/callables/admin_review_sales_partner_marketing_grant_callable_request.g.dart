// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/admin_review_sales_partner_marketing_grant_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

final class AdminReviewSalesPartnerMarketingGrantCallableRequest {
  const AdminReviewSalesPartnerMarketingGrantCallableRequest({
    required this.partnerUid,
    required this.organizerId,
    required this.campaignId,
    required this.channel,
    required this.assetIds,
    required this.requestId,
    required this.expectedMembershipRevision,
    required this.expectedGrantRevision,
    required this.sourceHash,
    required this.expiresAt,
    required this.reason,
  });

  final String partnerUid;
  final String organizerId;
  final String campaignId;
  final String channel;
  final List<String> assetIds;
  final String requestId;
  final int expectedMembershipRevision;
  final int expectedGrantRevision;
  final String sourceHash;
  final String expiresAt;
  final String reason;

  Map<String, Object?> toJson() => {
    'partnerUid': partnerUid,
    'organizerId': organizerId,
    'campaignId': campaignId,
    'channel': channel,
    'assetIds': assetIds,
    'requestId': requestId,
    'expectedMembershipRevision': expectedMembershipRevision,
    'expectedGrantRevision': expectedGrantRevision,
    'sourceHash': sourceHash,
    'expiresAt': expiresAt,
    'reason': reason,
  };
}
