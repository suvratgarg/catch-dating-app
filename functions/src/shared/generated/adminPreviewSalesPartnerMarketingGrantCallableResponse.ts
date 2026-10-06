/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminPreviewSalesPartnerMarketingGrantCallableResponse {
  partnerUid: string;
  organizerId: string;
  campaignId: string;
  channel: "email" | "whatsapp" | "other";
  /**
   * @minItems 1
   * @maxItems 12
   */
  assetIds: string[];
  grantId: string;
  expectedMembershipRevision: number;
  expectedGrantRevision: number;
  sourceHash: string;
  expiresBefore: string;
  /**
   * @minItems 1
   * @maxItems 12
   */
  assets: {
    assetId: string;
    kind: "capability" | "reference" | "cta";
    text: string;
    validUntil: string;
  }[];
  sendAuthority: false;
  publicationAuthority: false;
}
