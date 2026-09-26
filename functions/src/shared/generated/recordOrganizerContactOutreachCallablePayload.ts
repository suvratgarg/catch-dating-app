/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized request to log one outreach attempt on an organizer contact. An omitted occurredAtMillis records the attempt at server receipt; explicit times may not be in the future.
 */
export interface RecordOrganizerContactOutreachCallablePayload {
  organizerId: string;
  contactId: string;
  channel: "phoneCall" | "whatsapp" | "email" | "sms" | "inPerson" | "other";
  outcome:
    | "reached"
    | "noAnswer"
    | "leftMessage"
    | "wrongContact"
    | "attempted";
  note?: string;
  occurredAtMillis?: number;
}
