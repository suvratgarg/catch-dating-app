/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned ride-together membership for specific travel legs. This is independent of invitation households and does not apply to a guest's other journeys.
 */
export interface ProgramTravelPartyDocument {
  programId: string;
  organizerId: string;
  label: string | null;
  dedicatedVehicle: boolean;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
  /**
   * Explicit travel legs in this ride-together party. Guest identities are derived from those legs. An existing un-dispatched party may be emptied to release its members.
   *
   * @minItems 0
   * @maxItems 50
   */
  legIds: string[];
}
