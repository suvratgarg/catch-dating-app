/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private reviewed plan; only its preview object can reach an anonymous invitation view.
 */
export interface SalesDemoBlueprintsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  blueprintId: string;
  revision: number;
  state: "draft" | "reviewed" | "withdrawn";
  organizerId: string | null;
  candidateId: string | null;
  opportunityId: string | null;
  capability: "synthetic_forms_v1";
  capabilityRevision: string;
  evidenceRevision: string;
  seedVersion: 1;
  formCapabilityReview: {
    questionTypes: "exact" | "manual" | "retained" | "unsupported";
    branching: "exact" | "manual" | "retained" | "unsupported";
    requiredFields: "exact" | "manual" | "retained" | "unsupported";
    scoringApproval: "exact" | "manual" | "retained" | "unsupported";
    uploads: "exact" | "manual" | "retained" | "unsupported";
  };
  /**
   * @maxItems 30
   */
  fieldMappings: {
    sourceField: string;
    catchField: string | null;
    disposition: "exact" | "manual" | "retained" | "unsupported";
  }[];
  preview: {
    brandName: string;
    headline: string;
    scenario: string;
    /**
     * @minItems 3
     * @maxItems 3
     */
    steps: string[];
    /**
     * @maxItems 8
     */
    retainedTools: string[];
    /**
     * @minItems 1
     * @maxItems 8
     */
    limitations: string[];
    cta: string;
  };
  reviewedByUid: string | null;
  reviewedAt: string | null;
  updatedAt: string;
  updatedByUid: string;
}
