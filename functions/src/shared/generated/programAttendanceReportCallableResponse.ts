/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Per-function attendance report for reconciliationViewer staff, coordinators, and organizer managers. Separates RSVP truth (who promised what) from door truth (who actually arrived) and lists exception guest ids a reconciler chases by hand. Ids and counts only — no names, contacts, or notes.
 */
export interface ProgramAttendanceReportCallableResponse {
  programId: string;
  serverTimeMillis: number;
  /**
   * Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active.
   */
  accessExpiresAtMillis: number | null;
  /**
   * Distinct guests with any function row in the program.
   */
  programGuests: number;
  programInvitedGuests: number;
  programAttendingGuests: number;
  programCheckedInGuests: number;
  programNoShowGuests: number;
  /**
   * @maxItems 500
   */
  functions: {
    functionId: string;
    invitedGuests: number;
    respondedGuests: number;
    attendingGuests: number;
    /**
     * Sum of attending party sizes (null reads as 1).
     */
    attendingHeads: number;
    maybeGuests: number;
    declinedGuests: number;
    noResponseGuests: number;
    checkedInGuests: number;
    checkedInHeads: number;
    noShowGuests: number;
    expectedGuests: number;
    /**
     * Checked-in guests with no invite row.
     */
    walkInGuests: number;
    walkInHeads: number;
    exceptions: {
      /**
       * Invited guests who never responded, sorted.
       *
       * @maxItems 5000
       */
      invitedNoResponseGuestIds: string[];
      /**
       * Declined guests who checked in anyway, sorted.
       *
       * @maxItems 5000
       */
      declinedCheckedInGuestIds: string[];
      /**
       * Guests marked noShow at the door, sorted.
       *
       * @maxItems 5000
       */
      noShowGuestIds: string[];
      /**
       * Checked-in guests with no invite row, sorted.
       *
       * @maxItems 5000
       */
      walkInGuestIds: string[];
    };
  }[];
}
