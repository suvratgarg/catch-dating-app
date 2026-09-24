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
   * Up to eight independently expiring scope tuples. Identical tuples may be renewed; different tuples remain separate.
   *
   * @minItems 1
   * @maxItems 8
   */
  duties: {
    duty:
      | "programCoordinator"
      | "guestRelations"
      | "communications"
      | "functionCheckIn"
      | "functionLead"
      | "airportGreeter"
      | "hotelDesk"
      | "transportDispatcher"
      | "reconciliationViewer"
      | "stakeholderViewer";
    /**
     * Pickup restriction; empty means all program pickup points. Both resource restrictions must be met by the same assignment.
     *
     * @maxItems 32
     */
    pickupPointIds: string[];
    /**
     * Destination restriction; empty means all program hotels. Restrictions from different assignments never combine into new routes.
     *
     * @maxItems 64
     */
    hotelIds: string[];
    /**
     * Function restriction for functionCheckIn and functionLead duties; absent or empty means all program functions. Optional on documents written before function-scoped duties existed.
     *
     * @maxItems 64
     */
    functionIds?: string[];
    /**
     * Exclusive expiry of this exact duty and resource scope. Independent of other assignments.
     */
    expiresAtMillis: number;
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
   * Maximum assignment expiry for indexed grant inventory; authorization also checks each assignment expiry.
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
