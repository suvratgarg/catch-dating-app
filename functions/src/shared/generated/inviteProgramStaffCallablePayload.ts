/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create a single-use, phone-bound staff invite for a program. The invite redeems into a station-scoped grant when a signed-in account with the matching verified phone claims it. Manager-only.
 */
export interface InviteProgramStaffCallablePayload {
  programId: string;
  phoneNumber: string;
  displayName: string;
  /**
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
  }[];
  /**
   * Invite redemption deadline and the access-window end for the grant it materializes. Claims after this time fail.
   */
  expiresAtMillis: number;
}
