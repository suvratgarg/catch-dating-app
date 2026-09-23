/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned unique binding from a travel leg to its active trip. Created in the same transaction as dispatch so two staff cannot board one leg twice.
 */
export interface TransportActiveAssignmentDocument {
  programId: string;
  legId: string;
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
}
