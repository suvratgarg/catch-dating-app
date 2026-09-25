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
  }[];
}
