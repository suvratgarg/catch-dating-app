/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Result receipt for a committed organizer application import.
 */
export interface ImportOrganizerApplicationsCallableResponse {
  receiptId: string;
  status: "completed" | "partial" | "failed";
  rowCount: number;
  createdCount: number;
  skippedCount: number;
  /**
   * @maxItems 100
   */
  errors: {
    rowId: string;
    code: string;
    message: string;
  }[];
  replayed: boolean;
}
