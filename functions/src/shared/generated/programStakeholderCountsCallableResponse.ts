/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Counts-only program overview for stakeholderViewer staff and organizer managers: guest and household headcounts, per-function RSVP/attendance histograms, and per-hotel occupancy. The contract carries no PII — ids and counts only, never names, contacts, or notes.
 */
export interface ProgramStakeholderCountsCallableResponse {
  programId: string;
  serverTimeMillis: number;
  /**
   * Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active.
   */
  accessExpiresAtMillis: number | null;
  guestCount: number;
  householdCount: number;
  /**
   * @maxItems 500
   */
  functions: {
    functionId: string;
    status: "scheduled" | "completed" | "cancelled";
    /**
     * Guests invited to this function: every program guest for allGuests functions, else invited functionGuests rows.
     */
    invitedCount: number;
    /**
     * Invited guests with no response (or no join row yet on allGuests functions).
     */
    rsvpPending: number;
    rsvpAttending: number;
    rsvpDeclined: number;
    rsvpMaybe: number;
    /**
     * Sum of attending party sizes (null reads as 1).
     */
    expectedHeads: number;
    /**
     * Heads marked checkedIn at the door.
     */
    checkedInHeads: number;
    noShowCount: number;
  }[];
  /**
   * @maxItems 500
   */
  hotels: {
    hotelId: string;
    /**
     * Distinct guests with at least one leg routed to this hotel.
     */
    routedGuestCount: number;
    /**
     * Distinct routed guests whose hotel-bound leg already arrived.
     */
    arrivedGuestCount: number;
    legCount: number;
  }[];
}
