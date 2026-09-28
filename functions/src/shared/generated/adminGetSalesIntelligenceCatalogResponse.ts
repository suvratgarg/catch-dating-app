/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesIntelligenceAssessmentDocument} from "./salesIntelligenceAssessmentsDocument";
import type {SalesIntelligenceClauseDocument} from "./salesIntelligenceClausesDocument";
import type {SalesIntelligencePolicyDocument} from "./salesIntelligencePoliciesDocument";

export interface AdminGetSalesIntelligenceCatalogResponse {
  policy: SalesIntelligencePolicyDocument | null;
  /**
   * @maxItems 7
   */
  assessments: SalesIntelligenceAssessmentDocument[];
  /**
   * @maxItems 50
   */
  clauses: SalesIntelligenceClauseDocument[];
  evaluatedAt: string;
}
