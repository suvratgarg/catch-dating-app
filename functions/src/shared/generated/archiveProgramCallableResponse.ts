/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Archive acknowledgement: committed program revision plus the anonymization deadline the grace window grants for unarchive.
 */
export interface ArchiveProgramCallableResponse {
  entityId: string;
  revision: number;
  /**
   * True when an exact clientOperationId replay returned the original result.
   */
  alreadyApplied: boolean;
  /**
   * Identity fields are scrubbed at this deadline unless the program is unarchived first.
   */
  anonymizeAtMillis: number;
}
