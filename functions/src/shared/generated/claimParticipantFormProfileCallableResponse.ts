/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private claim result. No public or room sharing is inferred.
 */
export interface ClaimParticipantFormProfileCallableResponse {
  profileRevision: number;
  organizerCardId: string | null;
  claimedAtMillis: number;
  replayed: boolean;
}
