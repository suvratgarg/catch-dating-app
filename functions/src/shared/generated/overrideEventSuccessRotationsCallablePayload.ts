/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by overrideEventSuccessRotations.
 */
export interface OverrideEventSuccessRotationsCallablePayload {
  eventId: string;
  /**
   * @minItems 1
   * @maxItems 32
   */
  rounds: {
    roundIndex: number;
    /**
     * @minItems 0
     * @maxItems 100
     */
    pairings: {
      uidA: string;
      uidB: string;
    }[];
  }[];
}
