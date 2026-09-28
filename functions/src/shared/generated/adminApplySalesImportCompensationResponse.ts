/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminApplySalesImportCompensationResponse {
  importId: string;
  organizerId: string;
  status: "compensated" | "already_compensated";
  mode?: "archive_companion" | "remove_cohorts";
  /**
   * @maxItems 30
   */
  cohortIdsRemoved?: string[];
  accountRevision?: number;
  receipt: {
    requestId: string;
    revision: number | null;
  };
}
