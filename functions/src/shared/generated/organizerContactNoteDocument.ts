/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-scoped, author-stamped CRM note. Notes are exposed only through manager-authorized callables and are excluded from contact exports.
 */
export interface OrganizerContactNoteDocument {
  organizerId: string;
  contactId: string;
  authorUid: string;
  body: string;
  revision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  updatedByUid: string;
}
