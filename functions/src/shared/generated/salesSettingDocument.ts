/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private runtime configuration; qualification rule values are not embedded in public source.
 */
export type SalesSettingDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  status?: "active";
  policyId?: string;
  version?: string;
  policyHash?: string;
  /**
   * @minItems 1
   * @maxItems 8
   */
  rules?: {
    ruleId: string;
    claimKey: "identity" | "recurrence" | "operation" | "stack" | "other";
    /**
     * @minItems 1
     * @maxItems 4
     */
    sourceTypes: (
      | "first_party"
      | "public_web"
      | "human_note"
      | "import_artifact"
    )[];
    /**
     * @minItems 1
     * @maxItems 3
     */
    confidence: ("high" | "medium" | "low")[];
    minimumCount: number;
    distinctSignalIds: boolean;
    distinctSourceRoots: boolean;
    maxAgeDays: number | null;
  }[];
  /**
   * @maxItems 50
   */
  normalizedLabels?: string[];
  updatedAt?: string;
};
