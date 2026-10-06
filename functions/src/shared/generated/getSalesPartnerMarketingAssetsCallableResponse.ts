/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetSalesPartnerMarketingAssetsCallableResponse {
  grantId: string;
  revision: number;
  organizerId: string;
  campaignId: string;
  channel: "email" | "whatsapp" | "other";
  expiresAt: string;
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
  guestAuthority: false;
  providerAuthority: false;
}
