/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Function-scoped door roster for check-in staff. Returns the function header, the invited roster (allGuests functions resolve every program guest; selectedGuests functions resolve invited join rows plus checked-in walk-ins), the recent journal tail for the activity rail, and live counts. Guest rows carry display names only — no contact fields.
 */
export interface ProgramFunctionDoorViewCallableResponse {
  programId: string;
  functionId: string;
  /**
   * Server clock at read time so the client can render relative check-in times without trusting the device clock.
   */
  serverTimeMillis: number;
  /**
   * Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active.
   */
  accessExpiresAtMillis: number | null;
  function: {
    name: string;
    /**
     * Whether the function invites every program guest or only the programFunctionGuests rows marked invited.
     */
    invitationMode: "allGuests" | "selectedGuests";
    checkInEnabled: boolean;
    status: "scheduled" | "completed" | "cancelled";
    startsAtMillis: number;
    endsAtMillis: number;
    venueName: string | null;
    venueNotes: string | null;
    dressCode: string | null;
    instructions: string | null;
    expectedCount: number;
    checkedInCount: number;
  };
  counts: {
    /**
     * Guests on this function's door roster.
     */
    listedCount: number;
    /**
     * Attending party-size sum across the roster.
     */
    expectedHeads: number;
    /**
     * Party-size sum of checked-in rows, including walk-ins.
     */
    checkedInHeads: number;
    checkedInParties: number;
    noShowCount: number;
    /**
     * Rows created at the door (invited=false).
     */
    walkInCount: number;
  };
  /**
   * @maxItems 500
   */
  guests: {
    guestId: string;
    displayName: string;
    /**
     * False for walk-ins created at the door.
     */
    invited: boolean;
    rsvpStatus: "pending" | "attending" | "declined" | "maybe";
    /**
     * Door/arrival state for one guest at one function. expected is the default for invited guests; noShow is marked after the function ends.
     */
    attendanceStatus: "expected" | "checkedIn" | "noShow";
    partySize: number | null;
    householdLabel: string | null;
    responseNote: string | null;
  }[];
  /**
   * Most recent journal entries first, for the door activity rail.
   *
   * @maxItems 60
   */
  journal: {
    journalId: string;
    guestId: string;
    /**
     * Resolved guest name when the guest record is readable; null for deleted guests.
     */
    displayName: string | null;
    action:
      | "checkIn"
      | "undoCheckIn"
      | "markNoShow"
      | "walkInCreate"
      | "partySizeAdjust";
    occurredAtMillis: number;
    partySize: number | null;
    note: string | null;
    /**
     * Staff display name resolved through programStaffGrants; never a uid.
     */
    actorLabel: string | null;
  }[];
}
