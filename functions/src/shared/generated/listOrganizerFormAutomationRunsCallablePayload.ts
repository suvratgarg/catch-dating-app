/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized automation rule and bounded run history query.
 */
export interface ListOrganizerFormAutomationRunsCallablePayload {
  organizerId: string;
  formId: string;
  ruleId: string | null;
  cursor: string | null;
  limit: number;
}
