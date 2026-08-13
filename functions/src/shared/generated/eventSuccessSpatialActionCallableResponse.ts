/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current revision and optional destination validation for a Host spatial action.
 */
export interface EventSuccessSpatialActionCallableResponse {
  revision: number;
  /**
   * @maxItems 200
   */
  destinations: {
    unitId: string;
    valid: boolean;
    reason: "capacity" | "safetyKeepApart" | "declaredConstraint" | null;
    recommendedScope: "thisRound" | "pinned" | null;
  }[];
}
