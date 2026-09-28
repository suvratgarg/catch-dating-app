/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminSetSalesCustomFieldValueCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  fieldId: string;
  value: string | number | boolean | null;
}
