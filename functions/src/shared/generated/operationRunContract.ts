/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OperationRun {
  schemaVersion: 1;
  runId: string;
  workflowId: string;
  revision: number;
  mode: "shadow" | "assisted" | "autonomous";
  status:
    | "planned"
    | "queued"
    | "running"
    | "paused"
    | "completed"
    | "failed"
    | "cancelled";
  scope: {
    [k: string]: unknown;
  };
  rulesetVersion: string;
  policyVersion: string;
  inputHash: string;
  budgets: {
    maxWorkItems: number;
    maxModelCalls: number;
    maxModelTokens: number;
    maxCostMicros: number;
    deadlineAt: string | null;
  };
  counters: {
    discovered: number;
    processed: number;
    modelCalls: number;
    modelTokens: number;
    costMicros: number;
    escalated: number;
    published: number;
    failed: number;
  };
  checkpoint: {
    lastSequence: number;
    cursor: string | null;
  };
  createdAt: string;
  updatedAt: string;
  startedAt: string | null;
  finishedAt: string | null;
  failure: {
    code: string;
    message: string;
    retryable: boolean;
  } | null;
  metadata: {
    [k: string]: unknown;
  };
}
