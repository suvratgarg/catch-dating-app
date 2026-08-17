/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revokes the authenticated participant's organizer access grant without deleting the platform audit snapshot.
 */
export interface RevokeParticipantOrganizerDataGrantCallablePayload {
  organizerId: string;
  applicationId: string;
  expectedRevision: number;
}
