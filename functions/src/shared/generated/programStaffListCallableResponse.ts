/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager's view of program staff grants.
 */
export interface ProgramStaffListCallableResponse {
  programId: string;
  /**
   * @maxItems 50
   */
  members: {
    uid: string;
    displayName: string;
    phoneLastFour: string;
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
    status: "active" | "expired" | "revoked";
    expiresAtMillis: number;
    revision: number;
  }[];
  nextCursor: string | null;
}
