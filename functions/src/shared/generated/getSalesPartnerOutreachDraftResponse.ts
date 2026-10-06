/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OutreachDraft} from "./outreachDraft";

export interface GetSalesPartnerOutreachDraftResponse {
  draftId: string;
  draft: OutreachDraft;
  status: "pending_review" | "approved";
  reviewedAt: string | null;
  sendAuthority: false;
  composition?: null | {
    revision: number;
    baseContentHash: string;
    style: {
      greeting: "none" | "hello" | "hi";
      closing: "none" | "thanks" | "best";
      subjectStyle: "original" | "question" | "idea";
      paragraphStyle: "spaced" | "compact";
    };
  };
}
