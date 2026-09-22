/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update a ride-together travel party.
 */
export interface UpsertProgramTravelPartyCallablePayload {
  programId: string;
  partyId?: string;
  expectedRevision?: number;
  label?: string | null;
  /**
   * @minItems 2
   * @maxItems 50
   */
  memberGuestIds: string[];
  dedicatedVehicle: boolean;
}
