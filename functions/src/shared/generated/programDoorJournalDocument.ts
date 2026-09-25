/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned append-only door journal entry for one program function. The document id is the deterministic journalId derived from (scope, functionId, guestId, action, occurredAtMillis, actorUid), so device retries and offline outbox replays collapse to one entry. Attendance truth projects from this journal onto programFunctionGuests.attendanceStatus; clients never write either surface directly.
 */
export interface ProgramDoorJournalDocument {
  programId: string;
  organizerId: string;
  functionId: string;
  /**
   * programGuests member the entry acts on; walkInCreate entries may name a guest the function never invited.
   */
  guestId: string;
  /**
   * Staff uid who recorded the action at the door.
   */
  actorUid: string;
  action:
    | "checkIn"
    | "undoCheckIn"
    | "markNoShow"
    | "walkInCreate"
    | "partySizeAdjust";
  /**
   * Client-declared action time folded into the idempotency key and journal ordering.
   */
  occurredAtMillis: number;
  /**
   * Door device identifier for audit; null when the device supplies none.
   */
  deviceId: string | null;
  /**
   * Attending party size set by walkInCreate or partySizeAdjust; null on every other action.
   */
  partySize: number | null;
  /**
   * Optional door note such as a late-arrival explanation.
   */
  note: string | null;
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
