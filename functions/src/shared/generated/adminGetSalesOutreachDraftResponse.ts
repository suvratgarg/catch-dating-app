/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OutreachDraft} from "./outreachDraft";

export interface AdminGetSalesOutreachDraftResponse {
  draftId: string;
  draft: OutreachDraft;
  status: "pending_review" | "approved";
  reviewedAt: string | null;
  reviewedBy: string | null;
  sendAuthority: false;
}
