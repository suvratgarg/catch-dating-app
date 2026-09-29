/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Archive a program: explicit owner/manager action that starts the 14-day anonymization grace window. expectedRevision fences concurrent edits.
 */
export interface ArchiveProgramCallablePayload {
  programId: string;
  expectedRevision: number;
}
