/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Generic program mutation acknowledgement carrying the committed entity id and revision.
 */
export interface ProgramMutationCallableResponse {
  entityId: string;
  revision: number;
  /**
   * True when an exact clientOperationId replay returned the original result.
   */
  alreadyApplied: boolean;
}
