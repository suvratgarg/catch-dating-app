// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/admin_preview_sales_partner_marketing_grant_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

final class AdminPreviewSalesPartnerMarketingGrantCallableRequest {
  const AdminPreviewSalesPartnerMarketingGrantCallableRequest({
    required this.partnerUid,
    required this.organizerId,
    required this.campaignId,
    required this.channel,
    required this.assetIds,
  });

  final String partnerUid;
  final String organizerId;
  final String campaignId;
  final String channel;
  final List<String> assetIds;

  Map<String, Object?> toJson() => {
    'partnerUid': partnerUid,
    'organizerId': organizerId,
    'campaignId': campaignId,
    'channel': channel,
    'assetIds': assetIds,
  };
}
