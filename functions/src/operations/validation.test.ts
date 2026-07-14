import assert from "node:assert/strict";
import test from "node:test";
import {
  hashes,
  operationActionReceipt,
  operationDecision,
  operationPublicationPlan,
  operationRuleEvaluation,
  operationRuleProposal,
  operationRun,
  operationWorkItem,
} from "./testFixtures";
import {
  validateOperationActionReceipt,
  validateOperationDecision,
  validateOperationLease,
  validateOperationPublicationPlan,
  validateOperationRuleEvaluation,
  validateOperationRuleProposal,
  validateOperationRun,
  validateOperationWorkItem,
} from "./validation";

test("operation validators accept complete portable records", () => {
  const lease = {
    schemaVersion: 1,
    leaseId: "lease:1",
    resourceType: "work_item",
    resourceId: "work:event:1",
    ownerId: "worker:1",
    fencingToken: 1,
    status: "active",
    idempotencyKey: "lease-attempt:1",
    acquiredAt: "2026-07-14T08:00:00.000Z",
    heartbeatAt: "2026-07-14T08:00:30.000Z",
    expiresAt: "2026-07-14T08:05:30.000Z",
    releasedAt: null,
  };
  const results = [
    validateOperationRun(operationRun()),
    validateOperationWorkItem(operationWorkItem()),
    validateOperationActionReceipt(operationActionReceipt()),
    validateOperationDecision(operationDecision()),
    validateOperationLease(lease),
    validateOperationPublicationPlan(operationPublicationPlan()),
    validateOperationRuleProposal(operationRuleProposal()),
    validateOperationRuleEvaluation(operationRuleEvaluation()),
  ];
  results.forEach((result) => assert.equal(
    result.ok,
    true,
    result.ok ? "" : JSON.stringify(result.issues)
  ));
});

test("terminal work items require an explicit outcome", () => {
  const result = validateOperationWorkItem(operationWorkItem({
    primaryStage: "resolve",
    lifecycleStatus: "terminal",
    outcome: null,
  }));
  assert.equal(result.ok, false);
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.code === "work_item_terminal_outcome"));
});

test("failed actions require durable failure evidence", () => {
  const result = validateOperationActionReceipt(operationActionReceipt({
    status: "failed",
    failure: null,
  }));
  assert.equal(result.ok, false);
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.code === "action_failure_required"));
});

test("applied publication plans require a preflight and apply mode", () => {
  const result = validateOperationPublicationPlan(operationPublicationPlan({
    environment: "production",
    mode: "dry_run",
    status: "applied",
    preflightAt: null,
    appliedAt: null,
  }));
  assert.equal(result.ok, false);
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.code === "publication_preflight_required"));
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.code === "publication_apply_required"));
});

test("rule proposals cannot remove the human approval boundary", () => {
  const proposal = {
    ...operationRuleProposal(),
    requiresHumanApproval: false,
  };
  const result = validateOperationRuleProposal(proposal);
  assert.equal(result.ok, false);
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.code === "rule_human_approval_required"));
});

test("passed rule evaluations must meet asymmetric quality thresholds", () => {
  const result = validateOperationRuleEvaluation(operationRuleEvaluation({
    candidateMetrics: {
      fieldExactness: 0.95,
      eventPrecision: 1,
      duplicatePrecision: 1,
      duplicateRecall: 0.99,
      correctionRate: 0.02,
      escalationRate: 0.005,
    },
  }));
  assert.equal(result.ok, false);
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.code === "rule_thresholds_not_met"));
});

test("hash fields reject model-friendly but unverifiable labels", () => {
  const result = validateOperationRun(operationRun({inputHash: "looks-good"}));
  assert.equal(result.ok, false);
  assert.ok(!result.ok && result.issues.some((issue) =>
    issue.path === "inputHash"));
  assert.equal(hashes.input.length, 64);
});
