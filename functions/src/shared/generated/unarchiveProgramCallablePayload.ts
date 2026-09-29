/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Restore an archived program to its pre-archive status. Only valid while the grace window is still open; expectedRevision fences concurrent edits.
 */
export interface UnarchiveProgramCallablePayload {
  programId: string;
  expectedRevision: number;
}
