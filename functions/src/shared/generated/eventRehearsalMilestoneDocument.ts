/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Durable organizer rehearsal completion, stamped only by a successful completion transaction; not deleted with expiring sessions.
 */
export interface EventRehearsalMilestoneDocument {
  organizerId: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
