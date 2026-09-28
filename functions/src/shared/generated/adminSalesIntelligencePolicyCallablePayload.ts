/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Admin Owner exact-retry mutation of a private seven-factor runtime policy; no policy values are published in source.
 */
export interface AdminSalesIntelligencePolicyCallablePayload {
  requestId: string;
  expectedRevision: number;
  policy: {
    policyId: string;
    version: string;
    status: "active" | "paused";
    /**
     * @minItems 7
     * @maxItems 7
     */
    factors: {
      id: string;
      weight: number;
      /**
       * @minItems 1
       * @maxItems 5
       */
      claimKeys: (
        | "identity"
        | "recurrence"
        | "operation"
        | "stack"
        | "other"
      )[];
      maxAgeDays: number;
    }[];
    priorityBands: {
      high: number;
      medium: number;
    };
    promptVersion: string;
    playbookVersion: string;
  };
}
