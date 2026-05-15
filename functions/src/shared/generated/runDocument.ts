/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Canonical run document stored at runs/{runId}. The run id is the document id and is not stored in document data.
 */
export interface RunDocument {
  runClubId: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startTime: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  endTime: {
    _seconds: number;
    _nanoseconds: number;
  };
  meetingPoint: string;
  startingPointLat: number | null;
  startingPointLng: number | null;
  locationDetails: string | null;
  distanceKm: number;
  pace: "easy" | "moderate" | "fast" | "competitive";
  capacityLimit: number;
  description: string;
  priceInPaise: number;
  bookedCount: number;
  checkedInCount: number;
  waitlistedCount: number;
  status: "active" | "cancelled";
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancellationReason: string | null;
  constraints: {
    minAge: number;
    maxAge: number;
    maxMen: number | null;
    maxWomen: number | null;
  };
  genderCounts: {
    [k: string]: number;
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
