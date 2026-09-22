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
   * One to fifty people traveling together. A one-person party supports private transfers and staged manifest imports.
   *
   * @minItems 1
   * @maxItems 50
   */
  memberGuestIds: string[];
  dedicatedVehicle: boolean;
}
