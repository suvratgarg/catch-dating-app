/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Program staff attention feed: staffAttention moment sends raised for this program, filtered to the caller's active duties. Coordinators and managers receive every duty's alerts. Send fanout is deduplicated per run and duty.
 */
export interface ProgramStaffAttentionCallableResponse {
  programId: string;
  /**
   * @maxItems 100
   */
  items: {
    itemId: string;
    runId: string;
    momentId: string;
    duty: string;
    severity: "info" | "warning" | "urgent";
    title: string;
    createdAtMillis: number;
  }[];
  truncated: boolean;
}
