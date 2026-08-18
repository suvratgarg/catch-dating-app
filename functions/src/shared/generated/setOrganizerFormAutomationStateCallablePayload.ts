/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Enables or disables one form automation revision.
 */
export interface SetOrganizerFormAutomationStateCallablePayload {
  organizerId: string;
  ruleId: string;
  expectedRevision: number;
  enabled: boolean;
}
