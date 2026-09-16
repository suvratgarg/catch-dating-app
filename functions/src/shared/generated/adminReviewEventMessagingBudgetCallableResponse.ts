/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventMessagingSetupReview} from "./eventMessagingSetupReview";

/**
 * Read-only Finance review of one current messaging setup and its current revision-fenced decision. The response grants no spending or dispatch authority.
 */
export interface AdminReviewEventMessagingBudgetCallableResponse {
  schemaVersion: 1;
  review: EventMessagingSetupReview;
  decision: {
    decisionId: string;
    revision: number;
    decisionStatus: "approved" | "held" | "rejected";
    decisionKind: "approve" | "hold" | "reject";
    reviewedByUid: string;
    note: string;
    effect: "decision_only_no_spending_authority";
    grantsSpendingAuthority: false;
  } | null;
  grantsSpendingAuthority: false;
  grantsDispatchAuthority: false;
}
