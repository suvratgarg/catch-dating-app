/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminPreviewSalesPrivacyPlanResponse {
  organizerId: string;
  restrictionRevision: number;
  policyHash: string;
  inventoryHash: string;
  counts: {
    deletable: number;
    retained: number;
    unresolved: number;
  };
  /**
   * @maxItems 240
   */
  blockers: {
    code: string;
    fingerprint: string;
  }[];
  overflow: boolean;
  effectsApplied: false;
  activePlanId: string | null;
}
