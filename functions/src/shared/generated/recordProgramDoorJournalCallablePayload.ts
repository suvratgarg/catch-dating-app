/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Batch of door actions one function-scoped staff device recorded. The server derives journal ids, so retries and offline outbox replays are idempotent; every operation reports its own outcome.
 */
export interface RecordProgramDoorJournalCallablePayload {
  programId: string;
  functionId: string;
  /**
   * @minItems 1
   * @maxItems 50
   */
  operations: {
    guestId: string;
    action:
      | "checkIn"
      | "undoCheckIn"
      | "markNoShow"
      | "walkInCreate"
      | "partySizeAdjust";
    occurredAtMillis: number;
    deviceId?: string | null;
    /**
     * Optional initial party size for walkInCreate; required for partySizeAdjust; must be null or omitted on every other action.
     */
    partySize?: number | null;
    note?: string | null;
  }[];
}
