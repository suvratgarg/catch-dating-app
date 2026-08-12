/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-manager request to revoke one event staff member immediately.
 */
export interface RevokeEventStaffCallablePayload {
  eventId: string;
  uid: string;
  expectedRevision: number;
}
