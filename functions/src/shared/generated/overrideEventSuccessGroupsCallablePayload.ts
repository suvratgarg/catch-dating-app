/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by overrideEventSuccessGroups.
 */
export interface OverrideEventSuccessGroupsCallablePayload {
  eventId: string;
  /**
   * @minItems 1
   * @maxItems 32
   */
  rounds: {
    roundIndex: number;
    /**
     * @minItems 1
     * @maxItems 100
     */
    groups: {
      label: string;
      /**
       * @minItems 1
       * @maxItems 24
       */
      participantUids: string[];
    }[];
  }[];
}
