/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-asserted outreach attempt on one organizer contact. Records are append-only through the manager-authorized record callable, appear on the contact timeline, and are excluded from contact exports.
 */
export interface OrganizerContactOutreachDocument {
  organizerId: string;
  contactId: string;
  authorUid: string;
  channel: "phoneCall" | "whatsapp" | "email" | "sms" | "inPerson" | "other";
  outcome: "reached" | "noAnswer" | "leftMessage" | "wrongContact";
  note?: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  occurredAt: {
    _seconds: number;
    _nanoseconds: number;
  };
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
