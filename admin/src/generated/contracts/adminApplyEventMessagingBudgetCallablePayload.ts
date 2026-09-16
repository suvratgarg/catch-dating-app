/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Stages one still-current approved event-messaging budget decision as paused event and sender-day ceilings. The operation grants no spending or dispatch authority and cannot activate a worker.
 */
export interface AdminApplyEventMessagingBudgetCallablePayload {
  requestId: string;
  decisionId: string;
  expectedDecisionRevision: number;
  note: string;
}
