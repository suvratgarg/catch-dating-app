/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Hard-deletes only a never-published organizer form draft.
 */
export interface DeleteOrganizerFormDraftCallablePayload {
  organizerId: string;
  formId: string;
  expectedRevision: number;
}
