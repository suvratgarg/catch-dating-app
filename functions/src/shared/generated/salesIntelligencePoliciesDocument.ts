/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private, owner-reviewed, versioned fit and priority policy. No production weights are checked into source.
 */
export interface SalesIntelligencePoliciesDocument {
  schemaVersion: 1;
  classification: "sales_private";
  policyRecordId: "current";
  policyId: string;
  revision: number;
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
    claimKeys: ("identity" | "recurrence" | "operation" | "stack" | "other")[];
    maxAgeDays: number;
  }[];
  priorityBands: {
    high: number;
    medium: number;
  };
  promptVersion: string;
  playbookVersion: string;
  updatedAt: string;
  updatedBy: string;
}
