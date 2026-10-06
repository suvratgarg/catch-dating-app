/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminPreviewSalesPartnerMarketingGrantCallablePayload {
  partnerUid: string;
  organizerId: string;
  campaignId: string;
  channel: "email" | "whatsapp" | "other";
  /**
   * @minItems 1
   * @maxItems 12
   */
  assetIds: string[];
}
