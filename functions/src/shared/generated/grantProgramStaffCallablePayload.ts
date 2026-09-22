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
  expiresAtMillis: number;
}
