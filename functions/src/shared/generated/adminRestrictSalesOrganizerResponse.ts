/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminRestrictSalesOrganizerResponse {
  restriction: {
    schemaVersion: 1;
    classification: "sales_private";
    organizerId: string;
    status: "restricted" | "processing" | "internal_processed_with_unresolved";
    revision: number;
    reason: string;
    requestId: string;
    materialHash: string;
    restrictedByUid: string;
    restrictedAt: string;
    activePlanId: string | null;
  };
}
