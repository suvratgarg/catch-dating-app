/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned, expiring program staff access. Duties are named and station-scoped; a grant never confers organizer, CRM, messaging or cross-program authority.
 */
export interface ProgramStaffGrantDocument {
  organizerId: string;
  programId: string;
  uid: string;
  displayName: string;
  phoneLastFour: string;
  /**
   * At most one assignment per duty; each duty independently scopes pickup points and hotels.
   *
   * @minItems 1
   * @maxItems 8
   */
  duties: {
    duty:
      | "programCoordinator"
      | "airportGreeter"
      | "hotelDesk"
      | "transportDispatcher"
      | "reconciliationViewer";
    /**
     * Station scope for airportGreeter/transportDispatcher duties. Empty means all pickup points in the program.
     *
     * @maxItems 32
     */
    pickupPointIds: string[];
    /**
     * Hotel scope for hotelDesk duties. Empty means all hotels in the program.
     *
     * @maxItems 64
     */
    hotelIds: string[];
  }[];
  status: "active" | "revoked";
  createdBy: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Whole-grant expiry; individual duties do not outlive it.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revokedBy: string | null;
  revokedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
}
