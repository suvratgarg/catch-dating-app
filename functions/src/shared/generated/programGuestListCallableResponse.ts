/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager/coordinator guest inventory with household labels. Contact fields are present because this surface requires the programCoordinator duty or organizer management.
 */
export interface ProgramGuestListCallableResponse {
  programId: string;
  /**
   * @maxItems 200
   */
  guests: {
    guestId: string;
    displayName: string;
    householdId: string | null;
    phoneE164: string | null;
    email: string | null;
    externalReference: string | null;
    invitationStatus: "notInvited" | "invited" | "delivered" | "responded";
    rsvpStatus: "pending" | "attending" | "declined" | "maybe";
    revision: number;
  }[];
  /**
   * @maxItems 500
   */
  households: {
    householdId: string;
    label: string;
    /**
     * @maxItems 50
     */
    memberGuestIds: string[];
    revision: number;
  }[];
  /**
   * Per-function invitation/RSVP/attendance join rows covering the paged guests. Rows exist only where a programFunctionGuests document was written; an allGuests function with no row reads as implicitly invited and pending.
   *
   * @maxItems 4000
   */
  functionGuests: {
    guestId: string;
    functionId: string;
    invited: boolean;
    rsvpStatus: "pending" | "attending" | "declined" | "maybe";
    /**
     * Door/arrival state for one guest at one function. expected is the default for invited guests; noShow is marked after the function ends.
     */
    attendanceStatus: "expected" | "checkedIn" | "noShow";
    partySize: number | null;
  }[];
  nextCursor: string | null;
}
