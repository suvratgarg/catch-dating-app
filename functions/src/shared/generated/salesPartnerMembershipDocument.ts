/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SalesPartnerMembershipDocument {
  schemaVersion: 1;
  classification: "sales_private";
  revision: number;
  createdAt: string;
  updatedAt: string;
  uid: string;
  status: "active" | "revoked";
  termsVersion: "referral-preview-v1";
  acceptedAt: string;
  expiresAt: string;
  displayName: string;
  /**
   * @maxItems 30
   */
  marketingGrants: {
    campaignId: string;
    channel: "email" | "whatsapp" | "other";
    /**
     * @maxItems 30
     */
    assetIds: string[];
    expiresAt: string;
  }[];
}
