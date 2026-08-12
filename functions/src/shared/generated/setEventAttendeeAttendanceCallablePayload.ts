/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Absolute, revision-checked Host attendance mutation with an idempotent client operation id.
 */
export interface SetEventAttendeeAttendanceCallablePayload {
  eventId: string;
  attendeeId: string;
  desiredCheckedIn: boolean;
  expectedRevision: number;
  clientOperationId: string;
}
