/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetSalesPartnerDemoReviewsResponse {
  organizerId: string;
  assignmentRevision: number;
  /**
   * @maxItems 20
   */
  rows: {
    organizerId: string;
    assignmentRevision: number;
    blueprintId: string;
    blueprintRevision: number;
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
    previewHash: string;
    validUntil: string;
    evaluatedAt: string;
    synthetic: true;
    interactiveAvailable: false;
    sendAuthority: false;
    capabilityApprovalAuthority: false;
    organizerControlAuthority: false;
    proposalRevision: number;
    proposedWording: {
      headline: string;
      scenario: string;
      cta: string;
    } | null;
  }[];
  evaluatedAt: string;
  sendAuthority: false;
  capabilityApprovalAuthority: false;
  organizerControlAuthority: false;
}
