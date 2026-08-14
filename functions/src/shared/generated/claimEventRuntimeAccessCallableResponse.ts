/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Result of claiming or requesting approval for Event Success runtime access.
 */
export interface ClaimEventRuntimeAccessCallableResponse {
  status: "pendingApproval" | "needsInput" | "ready";
  attendeeId: string | null;
  /**
   * @maxItems 10
   */
  requiredFieldIds: string[];
  /**
   * @maxItems 10
   */
  completedFieldIds: string[];
}
