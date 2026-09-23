/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current exact-purpose participant decision, including replay status.
 */
export interface SetEventAssignmentFeatureConsentCallableResponse {
  eventId: string;
  featureId: string;
  status: "granted" | "withdrawn";
  revision: number;
  receiptId: string;
  replayed: boolean;
}
