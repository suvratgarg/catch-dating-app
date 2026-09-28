/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable exact commercial terms with reviewed source fact references.
 */
export interface SalesQuoteVersionsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  opportunityId: string;
  quoteId: string;
  termVersion: number;
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
  termsHash: string;
  createdAt: string;
  createdBy: string;
}
