/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Result of staging an approved event-messaging budget decision as two paused ceilings. Staging grants no spending or dispatch authority and cannot activate a worker.
 */
export interface AdminApplyEventMessagingBudgetCallableResponse {
  schemaVersion: 1;
  applied: boolean;
  replayed: boolean;
  decisionId: string;
  decisionRevision: number;
  receiptId: string;
  receiptPath: string;
  routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
  eventBudget: {
    budgetId: string;
    revision: number;
    path: string;
    status: "paused";
  };
  senderDayBudget: {
    budgetId: string;
    revision: number;
    path: string;
    status: "paused";
  };
  effect: "budgets_staged_paused_no_spending_or_dispatch_authority";
  stagesSpendingCeilings: true;
  grantsSpendingAuthority: false;
  grantsDispatchAuthority: false;
  providerContacted: false;
  workerActivated: false;
}
