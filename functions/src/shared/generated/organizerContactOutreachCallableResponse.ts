/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe organizer contact outreach state returned after recording an attempt.
 */
export interface OrganizerContactOutreachCallableResponse {
  organizerId: string;
  contactId: string;
  outreachId: string;
  channel: "phoneCall" | "whatsapp" | "email" | "sms" | "inPerson" | "other";
  outcome:
    | "reached"
    | "noAnswer"
    | "leftMessage"
    | "wrongContact"
    | "attempted";
  note: string | null;
  authorUid: string;
  occurredAtMillis: number;
  createdAtMillis: number;
  updatedAtMillis: number;
  revision: number;
}
