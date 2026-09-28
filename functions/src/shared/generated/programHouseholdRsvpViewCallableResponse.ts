/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * The household's RSVP page model: program display facts, consent state, and each member's invited functions with current responses. Contains no data outside the token's household.
 */
export interface ProgramHouseholdRsvpViewCallableResponse {
  programId: string;
  programTitle: string;
  timezone: string;
  householdId: string;
  householdLabel: string;
  /**
   * Current consent state so the page can pre-tick.
   */
  messagingConsentGranted: boolean;
  members: {
    guestId: string;
    displayName: string;
    functions: {
      functionId: string;
      name: string;
      startsAtMillis: number;
      endsAtMillis: number;
      venueName?: string | null;
      dressCode?: string | null;
      instructions?: string | null;
      rsvpStatus: "pending" | "attending" | "declined" | "maybe";
      partySize: number | null;
      responseNote: string | null;
    }[];
    /**
     * This member's previously captured travel blocks, one per journey kind, echoed so the form can pre-fill. Only household-submitted (formResponse) legs appear.
     *
     * @maxItems 6
     */
    travel: {
      kind: "inbound" | "outbound" | "ground";
      flightNumber: string | null;
      carrierCode: string | null;
      originIata: string | null;
      destinationIata: string | null;
      scheduledArrivalAtMillis: number | null;
      destinationHotelId: string | null;
      destinationLabel: string | null;
      passengers: number;
      luggageUnits: number;
    }[];
  }[];
  /**
   * The program's configured hotels for the travel destination picker; names only.
   *
   * @maxItems 50
   */
  hotels: {
    hotelId: string;
    name: string;
  }[];
}
