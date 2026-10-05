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
     * @minItems 1
     * @maxItems 12
     */
    assetIds: string[];
    expiresAt: string;
    schemaVersion: 1;
    grantId: string;
    revision: number;
    status: "active" | "revoked";
    organizerId: string;
    assignmentRevision: number;
    sourceHash: string;
    reviewedAt: string;
    reviewedBy: string;
    reason: string;
    purpose: "manual_partner_outreach";
    approvalReceiptId: string;
    approvedMembershipRevision: number;
  }[];
}
