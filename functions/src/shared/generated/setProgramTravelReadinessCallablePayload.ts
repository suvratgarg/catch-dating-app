/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Greeter/dispatcher leg observation: claim, unclaim, mark ready at curb, or flag disruption. clientOperationId makes offline replays safe.
 */
export interface SetProgramTravelReadinessCallablePayload {
  programId: string;
  legId: string;
  action: "markReady" | "claim" | "unclaim" | "markDisrupted";
  expectedRevision: number;
  /**
   * Reviewed curb estimate set alongside markDisrupted or planner correction.
   */
  manualCurbAtMillis?: number | null;
  manualCurbNote?: string | null;
  clientOperationId: string;
  /**
   * A preceding observation by the same actor on the same journey. Its receipt result revision must still equal the current leg revision.
   */
  afterObservation?: {
    clientOperationId: string;
    action: "claim" | "unclaim" | "markReady" | "markDisrupted";
  };
  /**
   * Immutable device observation time; accepted up to seven days late with five minutes of clock skew.
   */
  observedAtMillis: number;
}
