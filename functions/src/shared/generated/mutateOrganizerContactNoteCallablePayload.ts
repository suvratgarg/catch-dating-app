/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized optimistic edit of one organizer contact note.
 */
export interface MutateOrganizerContactNoteCallablePayload {
  organizerId: string;
  contactId: string;
  noteId: string;
  expectedRevision: number;
  body: string;
}
