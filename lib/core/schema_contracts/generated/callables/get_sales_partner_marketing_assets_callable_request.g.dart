// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// Typed callable request DTO emitted from callables/get_sales_partner_marketing_assets_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

final class GetSalesPartnerMarketingAssetsCallableRequest {
  const GetSalesPartnerMarketingAssetsCallableRequest({
    required this.grantId,
    required this.expectedGrantRevision,
  });

  final String grantId;
  final int expectedGrantRevision;

  Map<String, Object?> toJson() => {
    'grantId': grantId,
    'expectedGrantRevision': expectedGrantRevision,
  };
}
