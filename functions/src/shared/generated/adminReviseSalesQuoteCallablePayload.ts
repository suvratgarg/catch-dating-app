/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Strict private Sales commercial request; current role, scope, revision and evidence policy are transactional.
 */
export interface AdminReviseSalesQuoteCallablePayload {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedRevision: number;
  terms: {
    currency: string;
    amountMinor: number;
    billingCadence: "one_time" | "monthly" | "annual" | "usage_based";
    scope: string;
    validUntil: string;
    /**
     * @minItems 1
     * @maxItems 20
     */
    sourceFactRefs: string[];
  };
}
