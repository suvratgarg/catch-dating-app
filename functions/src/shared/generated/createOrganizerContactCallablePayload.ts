/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only creation of an organizer CRM contact with a required name, at least one unverified phone or email endpoint, and an optional initial private note. It does not create an attendee, Consumer account, or messaging permission.
 */
export type CreateOrganizerContactCallablePayload = {
  [k: string]: unknown;
} & {
  organizerId: string;
  displayName: string;
  phoneE164?: string;
  email?: string;
  initialNote?: string;
};
