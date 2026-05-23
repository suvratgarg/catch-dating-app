/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical event roster edge stored at eventParticipations/{participationId}.
 */
export interface EventParticipationDocument {
  eventId: string;
  clubId: string;
  uid: string;
  status: "signedUp" | "waitlisted" | "attended" | "cancelled" | "deleted";
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
  signedUpAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  waitlistedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  attendedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  deletedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  genderAtSignup: ("man" | "woman" | "nonBinary" | "other") | null;
  cohortAtSignup?: string | null;
  paymentId: string | null;
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
