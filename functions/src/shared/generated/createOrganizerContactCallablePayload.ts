/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only creation of a name-only organizer CRM contact. It does not create an attendee, Consumer account, or messaging permission.
 */
export interface CreateOrganizerContactCallablePayload {
  organizerId: string;
  displayName: string;
}
