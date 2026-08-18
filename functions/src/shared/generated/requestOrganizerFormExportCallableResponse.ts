/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Asynchronous export status and expiring download when complete.
 */
export interface RequestOrganizerFormExportCallableResponse {
  exportId: string;
  status: "pending" | "running" | "completed" | "failed" | "expired";
  format: "csv" | "xlsx";
  rowCount: number;
  downloadUrl: string | null;
  expiresAtMillis: number;
  errorMessage: string | null;
}
