/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminShareSalesDemoPartnerReviewResponse {
  blueprintId: string;
  blueprintRevision: number;
  sharingRevision: number;
  sharingState: "active" | "withdrawn";
  previewHash: string;
  expiresAt: string;
  sendAuthority: false;
  capabilityApprovalAuthority: false;
  organizerControlAuthority: false;
}
