/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesIntelligenceAssessmentDocument} from "./salesIntelligenceAssessmentsDocument";
import type {SalesIntelligencePolicyDocument} from "./salesIntelligencePoliciesDocument";

/**
 * Private current catalog projects reviewed clause records with bounded, transient safe-public citation options; options are not persisted sharing grants.
 */
export interface AdminGetSalesIntelligenceCatalogResponse {
  policy: SalesIntelligencePolicyDocument | null;
  /**
   * @maxItems 7
   */
  assessments: SalesIntelligenceAssessmentDocument[];
  /**
   * @maxItems 50
   */
  clauses: {
    schemaVersion: 1;
    classification: "sales_private";
    clauseId: string;
    organizerId: string;
    revision: number;
    kind: "observation" | "capability" | "reference" | "cta";
    text: string;
    state: "draft" | "approved" | "withdrawn";
    /**
     * @maxItems 8
     */
    evidenceIds: string[];
    validUntil: string;
    permission: "not_required" | "private_mention" | "withdrawn";
    reviewedAt: string | null;
    reviewedBy: string | null;
    updatedAt: string;
    updatedBy: string;
    /**
     * @maxItems 8
     */
    partnerCitations?: {
      evidenceId: string;
      sourceHash: string;
    }[];
    /**
     * @maxItems 8
     */
    partnerCitationOptions?: {
      evidenceId: string;
      sourceRef: string;
      observedAt: string;
      validThrough: string | null;
      excerpt: string | null;
      confidence: "high" | "medium" | "low";
      sourceHash: string;
    }[];
  }[];
  evaluatedAt: string;
}
