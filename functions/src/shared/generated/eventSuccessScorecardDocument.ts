/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.
 */
export interface EventSuccessScorecardDocument {
  eventId: string;
  clubId: string;
  bookedCount: number;
  checkedInCount: number;
  feedbackCount: number;
  attendeesWhoMetTwoPlusPeople: number;
  mutualMatchCount: number;
  chatStartedCount: number;
  averageWelcomeRating: number;
  averageStructureRating: number;
  safetyIncidentCount: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Internal demo seed marker used for cleanup and diagnostics.
   */
  synthetic?: boolean;
  /**
   * Internal demo seed prefix used for cleanup and diagnostics.
   */
  seedPrefix?: string;
  /**
   * Internal demo seed scenario name used for cleanup and diagnostics.
   */
  scenario?: string;
  /**
   * Internal demo-operations marker used for cleanup and diagnostics.
   */
  demoOps?: boolean;
  /**
   * Internal demo-operations id used for cleanup and diagnostics.
   */
  demoOpsId?: string;
  /**
   * Internal demo-operations command name used for cleanup and diagnostics.
   */
  demoOpsCommand?: string;
}
