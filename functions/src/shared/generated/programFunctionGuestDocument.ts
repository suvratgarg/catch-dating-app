/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned per-function invitation, RSVP and door-attendance join record. One document per (functionId, guestId) pair; the document id is the deterministic `${functionId}_${guestId}` join key so invites and responses upsert idempotently. Per-function truth lives here; programGuests.rsvpStatus is only a derived rollup.
 */
export interface ProgramFunctionGuestDocument {
  programId: string;
  organizerId: string;
  functionId: string;
  guestId: string;
  /**
   * Whether this guest is on the function's invitation list. Rows exist only for functions with invitationMode=selectedGuests when invited=false; allGuests functions may omit rows entirely.
   */
  invited: boolean;
  rsvpStatus: "pending" | "attending" | "declined" | "maybe";
  /**
   * Door/arrival state for one guest at one function. expected is the default for invited guests; noShow is marked after the function ends.
   */
  attendanceStatus: "expected" | "checkedIn" | "noShow";
  /**
   * Attending party size including children when the guest RSVPs for more than themselves; null reads as 1.
   */
  partySize?: number | null;
  /**
   * When the guest's current RSVP response was recorded; null while still pending.
   */
  respondedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Optional guest note captured with the response, such as dietary or plus-one detail.
   */
  responseNote?: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
}
