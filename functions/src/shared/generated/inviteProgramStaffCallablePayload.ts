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
  /**
   * Invite redemption deadline and the access-window end for the grant it materializes. Claims after this time fail.
   */
  expiresAtMillis: number;
}
