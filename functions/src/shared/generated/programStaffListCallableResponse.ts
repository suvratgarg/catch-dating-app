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
       * Exclusive expiry of this exact duty and resource scope. Independent of other assignments.
       */
      expiresAtMillis: number;
    }[];
    status: "active" | "expired" | "revoked";
    expiresAtMillis: number;
    revision: number;
  }[];
}
