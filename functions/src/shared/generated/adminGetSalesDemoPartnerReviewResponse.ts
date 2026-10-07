/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminGetSalesDemoPartnerReviewResponse {
  organizerId: string;
  blueprintId: string;
  blueprintRevision: number;
  partnerUid: string;
  assignmentRevision: number;
  preview: {
    brandName: string;
    headline: string;
    scenario: string;
    /**
     * @minItems 3
     * @maxItems 3
     */
    steps: string[];
    /**
     * @maxItems 8
     */
    retainedTools: string[];
    /**
     * @minItems 1
     * @maxItems 8
     */
    limitations: string[];
    cta: string;
  };
  previewHash: string;
  sharingRevision: number;
  proposedWording: {
    headline: string;
    scenario: string;
    cta: string;
  } | null;
  proposalRevision: number;
  sharingState: "none" | "active" | "withdrawn";
  expiresAt: string | null;
  sharingCurrent: boolean;
  maximumExpiresAt: string;
  evaluatedAt: string;
  sendAuthority: false;
  capabilityApprovalAuthority: false;
  organizerControlAuthority: false;
}
