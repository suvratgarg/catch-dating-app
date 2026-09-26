/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Work-shell bootstrap: the caller's role, duties, station scopes and labeled program resources. Staff receive only operational fields.
 */
export interface ProgramAccessCallableResponse {
  programId: string;
  organizerId: string;
  title: string;
  kind: "wedding" | "corporate" | "social" | "other";
  timezone: string;
  status: "draft" | "active" | "completed" | "archived";
  actorRole: "manager" | "staff";
  /**
   * Managers receive an empty list meaning unrestricted; staff receive their granted duties.
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
  grantExpiresAtMillis: number | null;
  capabilities: (
    | "arrivalsTransport"
    | "accommodation"
    | "forms"
    | "messaging"
  )[];
  /**
   * @maxItems 32
   */
  pickupPoints: {
    pickupPointId: string;
    label: string;
    kind: "airport" | "railway" | "venue" | "other";
    iataCode: string | null;
    terminal: string | null;
  }[];
  /**
   * @maxItems 64
   */
  hotels: {
    hotelId: string;
    name: string;
  }[];
  /**
   * Function-scoped door/check-in surfaces for functionCheckIn and functionLead holders, intersected with each assignment's functionIds. Empty for other duties.
   *
   * @maxItems 40
   */
  functions: {
    functionId: string;
    name: string;
    venueName: string | null;
    startsAtMillis: number;
    endsAtMillis: number;
    checkInEnabled: boolean;
    status: "scheduled" | "completed" | "cancelled";
    expectedCount: number;
    checkedInCount: number;
  }[];
  /**
   * @maxItems 16
   */
  vehicleClasses: {
    id: string;
    label: string;
    passengerCapacity: number;
    luggageCapacity: number;
    /**
     * @maxItems 12
     */
    capabilities: ("wheelchairAccessible" | "extraLuggage" | "childSeat")[];
    sortOrder: number;
  }[];
}
