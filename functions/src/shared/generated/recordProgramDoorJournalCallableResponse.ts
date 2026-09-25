/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Per-operation outcomes for one door journal batch. Duplicates and rule rejections report per operation so a device can reconcile its outbox; a partially rejected batch still reports the appended entries it committed.
 */
export interface RecordProgramDoorJournalCallableResponse {
  /**
   * The functionId the batch targeted.
   */
  entityId: string;
  /**
   * Function document revision after the write.
   */
  revision: number;
  results: {
    guestId: string;
    action:
      | "checkIn"
      | "undoCheckIn"
      | "markNoShow"
      | "walkInCreate"
      | "partySizeAdjust";
    outcome: "appended" | "duplicate" | "rejected";
    /**
     * Appended entry id, or the colliding id for duplicates; null on rule rejections.
     */
    journalId: string | null;
    reason:
      | "alreadyCheckedIn"
      | "notCheckedIn"
      | "functionCheckInDisabled"
      | "duplicateJournalId"
      | "invalidTransition"
      | null;
  }[];
  appendedCount: number;
  duplicateCount: number;
  rejectedCount: number;
  /**
   * True when the entire batch replayed as duplicates and nothing new was written.
   */
  alreadyApplied: boolean;
}
