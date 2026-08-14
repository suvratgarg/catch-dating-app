/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-recomputed Event Success runtime profile readiness.
 */
export interface SubmitEventRuntimeProfileCallableResponse {
  status: "needsInput" | "ready";
  /**
   * @maxItems 10
   */
  requiredFieldIds: string[];
  /**
   * @maxItems 10
   */
  completedFieldIds: string[];
}
