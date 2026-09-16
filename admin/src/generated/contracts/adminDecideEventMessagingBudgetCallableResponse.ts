/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Result of recording a finance review decision. The response explicitly grants no spending authority.
 */
export interface AdminDecideEventMessagingBudgetCallableResponse {
  schemaVersion: 1;
  applied: boolean;
  replayed: boolean;
  decisionId: string;
  revision: number;
  decisionStatus: "approved" | "held" | "rejected";
  decisionPath: string;
  effect: "decision_only_no_spending_authority";
  grantsSpendingAuthority: false;
}
