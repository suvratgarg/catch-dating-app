/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Delete a program guest group and scrub its id from member programGuests.groupIds in bounded batches.
 */
export interface DeleteProgramGuestGroupCallablePayload {
  programId: string;
  groupId: string;
  expectedRevision?: number;
}
