/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private organizer-linked Sales companion; no canonical ownership, payment, or publication authority.
 */
export interface OrganizerSalesAccountDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  revision: number;
  researchStatus:
    | "new"
    | "needs_research"
    | "ready_for_review"
    | "qualified"
    | "benchmark_only"
    | "no_fit"
    | "archived";
  assignedOwnerUid: string | null;
  summary: string | null;
  nextAction: string | null;
  suppressionStatus: "clear" | "held" | "suppressed";
  suppressionReason: string | null;
  suppressionAt: string | null;
  suppressionBy: string | null;
  duplicateReviewRequired: boolean;
  qualificationPolicy: {
    policyId: string;
    version: string;
    policyHash: string;
  } | null;
  name: string;
  city: string | null;
  market: string | null;
  marketLabel: string | null;
  /**
   * @minItems 0
   * @maxItems 30
   */
  eventTypes: string[];
  /**
   * @minItems 0
   * @maxItems 30
   */
  cohortIds: string[];
  /**
   * @minItems 0
   * @maxItems 40
   */
  searchTokens: string[];
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
  cohortMutationId?: string | "initial" | null;
}
