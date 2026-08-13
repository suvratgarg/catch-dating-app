/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-fenced Host payload that replaces one complete unit-outcome round.
 */
export interface RecordEventSuccessUnitOutcomesCallablePayload {
  eventId: string;
  expectedRevision: number;
  roundIndex: number;
  /**
   * @minItems 1
   * @maxItems 200
   */
  entries: (
    | {
        unitId: string;
        unitLabel: string;
        completed: boolean;
      }
    | {
        unitId: string;
        unitLabel: string;
        score: number;
      }
    | {
        unitId: string;
        unitLabel: string;
        rank: number;
      }
  )[];
}
