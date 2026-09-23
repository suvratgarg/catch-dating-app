/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned single-use staff invite bound to a phone number. Redeeming the invite requires a signed-in account whose verified phone matches; redemption materializes a programStaffGrants document.
 */
export interface ProgramStaffInviteDocument {
  organizerId: string;
  programId: string;
  /**
   * Normalized E.164 phone the invite is bound to. Only a verified auth token carrying this number may claim the invite.
   */
  phoneE164: string;
  displayName: string;
  /**
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
  }[];
  status: "pending" | "claimed" | "revoked";
  createdBy: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Invite redemption deadline. The resulting grant uses its own expiry.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  claimedByUid: string | null;
  claimedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
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
