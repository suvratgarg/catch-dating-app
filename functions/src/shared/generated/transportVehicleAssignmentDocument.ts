/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned organizer-wide occupancy of a normalized vehicle plate. Dispatch reserves the vehicle atomically with its passenger assignments. Arrival or void releases only the matching trip; active reservations never expire by age.
 */
export interface TransportVehicleAssignmentDocument {
  programId: string;
  tripId: string;
  status: "active" | "released";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  assignedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  releasedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  revision: number;
  organizerId: string;
  plateNormalized: string;
}
