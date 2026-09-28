/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminListSalesOutreachDraftsResponse {
  /**
   * @maxItems 50
   */
  rows: {
    draftId: string;
    contactId: string;
    opportunityId: string;
    subject: string | null;
    status: "pending_review" | "approved";
    contentHash: string;
    createdAt: string;
    reviewedAt: string | null;
  }[];
}
