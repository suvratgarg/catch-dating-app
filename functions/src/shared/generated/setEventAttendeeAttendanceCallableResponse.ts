/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Authoritative outcome for an absolute operational-roster attendance mutation.
 */
export interface SetEventAttendeeAttendanceCallableResponse {
  attendeeId: string;
  checkedIn: boolean;
  acceptedRevision: number;
  replayed: boolean;
  changed: boolean;
}
