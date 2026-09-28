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
    /**
     * Optional link to organizerContacts. Lets program-scoped surfaces (the host inbox scope chip) attribute contact-linked threads to this program's guests.
     */
    contactId: string | null;
    phoneE164: string | null;
    email: string | null;
    externalReference: string | null;
    /**
     * programGuestGroups ids this guest belongs to. Resolve labels via the groups array on this response.
     *
     * @maxItems 20
     */
    groupIds: string[];
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
  /**
   * programGuestGroups documents referenced by groupIds on the paged guests. Page-scoped like households; a group referenced but absent here is corrupt and surfaces as a reconciliation error.
   *
   * @maxItems 500
   */
  groups: {
    groupId: string;
    label: string;
    dimension: string;
    sortOrder: number;
    memberCount: number;
    revision: number;
  }[];
  nextCursor: string | null;
}
