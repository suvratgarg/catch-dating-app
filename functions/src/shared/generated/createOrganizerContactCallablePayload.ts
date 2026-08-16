/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only creation of an organizer CRM contact with optional unverified contact details and an initial private note. It does not create an attendee, Consumer account, or messaging permission.
 */
export interface CreateOrganizerContactCallablePayload {
  organizerId: string;
  displayName: string;
  phoneE164?: string;
  email?: string;
  initialNote?: string;
}
