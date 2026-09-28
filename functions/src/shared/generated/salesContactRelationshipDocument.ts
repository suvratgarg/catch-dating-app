/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-scoped role, endpoints, and human draft review. Draft review never grants send authority.
 */
export type SalesContactRelationshipDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  relationshipId: string;
  contactId: string;
  organizerId: string;
  revision: number;
  role: string;
  decisionInfluence: "unknown" | "decision_maker" | "influencer" | "operator";
  primary: boolean;
  contactabilityStatus: "unknown" | "draft_reviewed" | "held" | "suppressed";
  contactabilityReason: string | null;
  contactabilityAt: string | null;
  contactabilityBy: string | null;
  draftReviewEvidenceId: string | null;
  sendAuthority: false;
  /**
   * @minItems 0
   * @maxItems 3
   */
  endpoints: {
    kind: "email" | "phone";
    value: string;
    verificationStatus: "unverified" | "verified";
    evidenceId?: string | null;
  }[];
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
};
