/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned ride-together relationship across guest legs. Members are never split across suggested vehicles; oversized parties surface for review.
 */
export interface ProgramTravelPartyDocument {
  programId: string;
  organizerId: string;
  label: string | null;
  /**
   * @minItems 2
   * @maxItems 50
   */
  memberGuestIds: string[];
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
}
