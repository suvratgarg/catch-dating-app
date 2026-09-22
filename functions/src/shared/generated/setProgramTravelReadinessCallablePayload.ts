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
  expectedRevision?: number;
  /**
   * Reviewed curb estimate set alongside markDisrupted or planner correction.
   */
  manualCurbAtMillis?: number | null;
  manualCurbNote?: string | null;
  clientOperationId: string;
}
