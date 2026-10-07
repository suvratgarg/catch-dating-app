/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminShareSalesDemoPartnerReviewCallablePayload {
  requestId: string;
  blueprintId: string;
  expectedBlueprintRevision: number;
  expectedSharingRevision: number;
  partnerUid: string;
  expectedAssignmentRevision: number;
  expectedPreviewHash: string;
  decision: "share" | "withdraw";
  expiresAt: string | null;
}
