/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotently submits one completed version-bound draft.
 */
export interface SubmitOrganizerFormResponseCallablePayload {
  draftId: string;
  draftToken: string | null;
  expectedRevision: number;
  requestId: string;
}
