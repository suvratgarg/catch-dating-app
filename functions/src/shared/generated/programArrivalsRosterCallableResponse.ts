/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Station-scoped, duty-redacted arrivals roster. Greeter/dispatcher rows carry operational fields only: no phone numbers, emails, RSVP internals or other stations' legs.
 */
export interface ProgramArrivalsRosterCallableResponse {
  programId: string;
  /**
   * The station this page covers; null when the duty spans all stations.
   */
  pickupPointId: string | null;
  generatedAtMillis: number;
  /**
   * @maxItems 500
   */
  rows: {
    legId: string;
    guestId: string;
    partyId: string | null;
    guestDisplayName: string;
    partyLabel: string | null;
    /**
     * Ride-together membership for dispatcher merge decisions.
     *
     * @maxItems 50
     */
    partyGuestIds: string[];
    passengers: number;
    luggageUnits: number;
    flightNumber: string | null;
    originIata: string | null;
    flightStatus:
      | "scheduled"
      | "enroute"
      | "landed"
      | "delayed"
      | "cancelled"
      | "diverted"
      | "unknown";
    /**
     * Resolved curb estimate from arrivalTiming; null means unusable timing (cancelled, diverted or missing).
     */
    curbAtMillis: number | null;
    curbSource:
      | "ready"
      | "manual"
      | "actualLanding"
      | "estimatedLanding"
      | "scheduledLanding"
      | null;
    unavailableReason?: "cancelled" | "diverted" | "missingTiming" | null;
    readiness:
      | "expected"
      | "ready"
      | "dispatched"
      | "arrived"
      | "disrupted"
      | "noShow";
    /**
     * Claiming staff member's display name, never their uid beyond the caller's own claim flag.
     */
    claimedByDisplay: string | null;
    claimedByMe?: boolean;
    destinationHotelId: string | null;
    destinationLabel: string;
    requiredCapabilities: (
      | "wheelchairAccessible"
      | "extraLuggage"
      | "childSeat"
    )[];
    dedicatedVehicle: boolean;
    revision: number;
    /**
     * Provider-reported arrival terminal; null until the leg is enriched or when unannounced.
     */
    arrivalTerminal: string | null;
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
  /**
   * Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active.
   */
  accessExpiresAtMillis: number | null;
}
