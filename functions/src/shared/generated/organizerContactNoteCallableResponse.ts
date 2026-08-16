/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe organizer contact note state returned after a create or edit.
 */
export interface OrganizerContactNoteCallableResponse {
  organizerId: string;
  contactId: string;
  noteId: string;
  body: string;
  authorUid: string;
  createdAtMillis: number;
  updatedAtMillis: number;
  revision: number;
}
