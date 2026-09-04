/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized organizer contact detail request.
 */
export interface GetOrganizerContactDetailCallablePayload {
  organizerId: string;
  contactId: string;
  /**
   * False loads overview facts without send, reply, form-response timeline, or merge-history reads. Omission preserves the full response for existing clients.
   */
  includeHistory?: boolean;
}
