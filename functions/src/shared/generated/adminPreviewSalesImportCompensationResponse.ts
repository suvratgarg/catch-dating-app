/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminPreviewSalesImportCompensationResponse {
  mode: "archive_companion" | "remove_cohorts" | "blocked";
  /**
   * @maxItems 32
   */
  blockers: string[];
  importId: string;
  organizerId: string;
  accountRevision: number | null;
  /**
   * @maxItems 30
   */
  cohortIdsRemoved: string[];
  previewHash: string;
  alreadyCompensated: boolean;
}
