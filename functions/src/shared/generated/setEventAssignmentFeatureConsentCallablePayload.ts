/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Verified participant grants or withdraws assignment-only use of one exact submitted answer.
 */
export interface SetEventAssignmentFeatureConsentCallablePayload {
  eventId: string;
  featureId: string;
  responseId: string;
  decision: "grant" | "withdraw";
  expectedRevision: number;
  requestId: string;
}
