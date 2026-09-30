/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Unarchive acknowledgement: committed program revision plus the status restored from the pre-archive record.
 */
export interface UnarchiveProgramCallableResponse {
  entityId: string;
  revision: number;
  /**
   * True when an exact clientOperationId replay returned the original result.
   */
  alreadyApplied: boolean;
  restoredStatus: "draft" | "active" | "completed" | "archived";
}
