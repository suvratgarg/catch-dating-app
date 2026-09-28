/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminReviewSalesPrivacyPlanPayload {
  organizerId: string;
  requestId: string;
  restrictionRevision: number;
  policyHash: string;
  inventoryHash: string;
  expectedActivePlanId: string | null;
}
