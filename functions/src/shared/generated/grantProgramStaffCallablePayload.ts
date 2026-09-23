/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Grant named, station-scoped program duties to a signed-in account. Manager-only.
 */
export interface GrantProgramStaffCallablePayload {
  programId: string;
  phoneNumber: string;
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
  expiresAtMillis: number;
}
