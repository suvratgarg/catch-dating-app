/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private aggregate provider run/month accounting. Limits are immutable for each bucket; unknown attempts retain ceilings. Reserved cost is not actual billed cost. Retained hashes/counters contain no prompt, output, actor/contact/organizer identifiers.
 */
export interface SalesProviderBudgetDocument {
  schemaVersion: 1;
  classification: "sales_private";
  bucketId: string;
  kind: "run" | "month";
  scopeHash: string;
  month: string | null;
  limitsHash: string;
  limits: {
    modelCalls: number;
    networkRequests: number;
    modelInputTokens: number;
    modelOutputTokens: number;
    modelCostMicros: number;
  };
  consumed: {
    modelCalls: number;
    networkRequests: number;
    modelInputTokens: number;
    modelOutputTokens: number;
    modelCostMicros: number;
  };
  updatedAt: string;
}
