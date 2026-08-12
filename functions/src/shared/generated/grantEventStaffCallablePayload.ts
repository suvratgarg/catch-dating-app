/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-manager request to grant an existing phone-auth account expiring event-operator access.
 */
export interface GrantEventStaffCallablePayload {
  eventId: string;
  phoneNumber: string;
  expiresAtMillis: number;
}
