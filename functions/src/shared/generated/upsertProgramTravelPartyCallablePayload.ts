/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned ride-together membership for specific travel legs. This is independent of invitation households and does not apply to a guest's other journeys.
 */
export type UpsertProgramTravelPartyCallablePayload = {
  [k: string]: unknown;
} & {
  programId: string;
  partyId?: string;
  expectedRevision?: number;
  label?: string | null;
  dedicatedVehicle: boolean;
  /**
   * Explicit travel legs in this ride-together party. Guest identities are derived from those legs. An existing un-dispatched party may be emptied to release its members.
   *
   * @minItems 0
   * @maxItems 50
   */
  legIds: string[];
};
