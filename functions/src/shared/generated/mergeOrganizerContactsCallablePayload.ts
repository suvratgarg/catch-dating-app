/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-confirmed, revision-checked organizer contact merge.
 */
export interface MergeOrganizerContactsCallablePayload {
  organizerId: string;
  survivorContactId: string;
  sourceContactId: string;
  survivorRevision: number;
  sourceRevision: number;
  confirmConflicts: boolean;
  idempotencyKey: string;
}
