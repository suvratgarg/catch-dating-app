/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Explicitly rechecks current communication routes for active manual work without mutating, dispatching, or completing it.
 */
export interface ReplanOrganizerManualSendTasksCallablePayload {
  organizerId: string;
  /**
   * @minItems 1
   * @maxItems 50
   */
  taskIds: string[];
}
