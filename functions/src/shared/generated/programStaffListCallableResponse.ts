/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager's view of program staff grants.
 */
export interface ProgramStaffListCallableResponse {
  programId: string;
  /**
   * @maxItems 100
   */
  members: {
    uid: string;
    displayName: string;
    phoneLastFour: string;
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
    status: "active" | "expired" | "revoked";
    expiresAtMillis: number;
    revision: number;
  }[];
}
