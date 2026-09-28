/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminApplySalesPrivacyBatchResponse {
  batch: {
    organizerId: string;
    planId: string;
    previousCursor: number;
    nextCursor: number;
    itemCount: number;
    deletedCount: number;
    retainedCount: number;
    unresolvedCount: number;
    status: "processing" | "internal_processed_with_unresolved";
    completeDeletion: false;
    receiptId: string;
  };
}
