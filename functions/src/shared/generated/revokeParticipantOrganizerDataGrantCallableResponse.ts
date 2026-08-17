/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revocation outcome and application revision.
 */
export interface RevokeParticipantOrganizerDataGrantCallableResponse {
  organizerId: string;
  applicationId: string;
  revokedAtMillis: number;
  revision: number;
  replayed: boolean;
}
