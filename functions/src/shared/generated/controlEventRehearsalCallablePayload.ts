/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-fenced Host lifecycle or virtual-clock control.
 */
export interface ControlEventRehearsalCallablePayload {
  sessionId: string;
  expectedRevision: number;
  clientActionId: string;
  action:
    | "markReady"
    | "start"
    | "pause"
    | "resume"
    | "advance"
    | "previous"
    | "advanceClock"
    | "complete";
  minutes?: number;
}
