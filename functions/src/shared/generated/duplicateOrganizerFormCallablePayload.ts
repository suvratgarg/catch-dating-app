/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates an idempotent new draft copy with entirely new nested identities.
 */
export interface DuplicateOrganizerFormCallablePayload {
  organizerId: string;
  sourceFormId: string;
  requestId: string;
  title: string | null;
}
