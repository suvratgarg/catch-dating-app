/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized request for one independently loadable organizer contact section.
 */
export interface GetOrganizerContactSectionCallablePayload {
  organizerId: string;
  contactId: string;
  section: "overview" | "history";
}
