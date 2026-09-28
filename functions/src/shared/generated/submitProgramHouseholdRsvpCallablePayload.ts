/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Token-authenticated household RSVP submit. Responses are limited to guests in the token's household and apply atomically. messagingConsent records the explicit checkbox state; it is never implied by submitting.
 */
export interface SubmitProgramHouseholdRsvpCallablePayload {
  token: string;
  /**
   * @maxItems 2000
   */
  responses: {
    guestId: string;
    functionId: string;
    rsvpStatus: "pending" | "attending" | "declined" | "maybe";
    partySize?: number | null;
    responseNote?: string | null;
  }[];
  /**
   * The explicit household messaging-consent checkbox; recorded exactly as ticked.
   */
  messagingConsent: boolean;
  /**
   * Optional per-member travel capture. Each block writes one programTravelLegs row keyed deterministically by household, guest, and journey kind, so resubmits update in place. A block is the complete desired state of that leg; absent blocks never delete planner-owned or previously captured journeys.
   *
   * @maxItems 400
   */
  travel?:
    | {
        guestId: string;
        kind: "inbound" | "outbound" | "ground";
        flightNumber?: string | null;
        carrierCode?: string | null;
        originIata?: string | null;
        destinationIata?: string | null;
        scheduledArrivalAtMillis?: number | null;
        pickupPointId?: string | null;
        destinationHotelId?: string | null;
        destinationLabel?: string | null;
        /**
         * Defaults to 1 when omitted.
         */
        passengers?: number | null;
        /**
         * Defaults to 0 when omitted.
         */
        luggageUnits?: number | null;
      }[]
    | null;
}
