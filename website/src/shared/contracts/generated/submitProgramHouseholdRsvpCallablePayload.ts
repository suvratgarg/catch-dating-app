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
}
