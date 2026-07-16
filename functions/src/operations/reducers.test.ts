import assert from "node:assert/strict";
import test from "node:test";
import {OperationDomainError} from "./errors";
import {
  reduceRunTransition,
  reduceWorkItemLifecycle,
  reduceWorkItemTransition,
  WorkItemTransitionCommand,
} from "./reducers";
import {supplyIntakeStagePolicy} from
  "./workflows/supplyIntakePolicy";
import {hashes, operationRun, operationWorkItem} from "./testFixtures";

function transition(
  overrides: Partial<WorkItemTransitionCommand> = {}
): WorkItemTransitionCommand {
  return {
    actionId: "action:transition:1",
    sequence: 1,
    expectedRevision: 0,
    targetStage: "verify",
    operation: "verify_candidate",
    actor: {actorType: "agent", actorId: "worker:1"},
    idempotencyKey: "transition:1",
    inputHash: hashes.input,
    outputHash: hashes.output,
    rulesetVersion: "rules-v1",
    modelVersion: null,
    reasonCodes: ["source_capture_complete"],
    occurredAt: "2026-07-14T08:01:00.000Z",
    ...overrides,
  };
}

test("work-item reducer emits exclusive stage state and append receipt", () => {
  const result = reduceWorkItemTransition(
    operationWorkItem({taskFlags: ["source_capture_required"]}),
    transition({
      addTaskFlags: ["date_review_required"],
      removeTaskFlags: ["source_capture_required"],
    }),
    supplyIntakeStagePolicy
  );
  assert.equal(result.workItem.primaryStage, "verify");
  assert.equal(result.workItem.lifecycleStatus, "in_progress");
  assert.equal(result.workItem.revision, 1);
  assert.deepEqual(result.workItem.taskFlags, ["date_review_required"]);
  assert.equal(result.receipt.fromRevision, 0);
  assert.equal(result.receipt.toRevision, 1);
  assert.equal(result.receipt.status, "succeeded");
});

test("ready stage requires accepted decision and no blockers", () => {
  assert.throws(() => reduceWorkItemTransition(
    operationWorkItem({
      primaryStage: "verify",
      lifecycleStatus: "in_progress",
      blockerCodes: ["location_unresolved"],
    }),
    transition({targetStage: "ready"}),
    supplyIntakeStagePolicy
  ), (error: unknown) => {
    assert.ok(error instanceof OperationDomainError);
    assert.equal(error.code, "ready_gates_not_met");
    return true;
  });
});

test("custom workflow stage gates are policy-driven", () => {
  const policy = {
    workflowId: "custom-workflow",
    stages: {
      review: {lifecycleStatus: "in_progress" as const},
      approved: {
        lifecycleStatus: "ready" as const,
        requiresDecision: true,
        requiresNoBlockers: true,
      },
    },
    transitions: {review: ["approved"], approved: []},
    publication: null,
  };
  const current = operationWorkItem({
    workflowId: "custom-workflow",
    primaryStage: "review",
    lifecycleStatus: "in_progress",
    blockerCodes: ["custom_blocker"],
  });
  assert.throws(() => reduceWorkItemTransition(
    current,
    transition({targetStage: "approved"}),
    policy
  ), (error: unknown) => {
    assert.ok(error instanceof OperationDomainError);
    assert.equal(error.code, "stage_gates_not_met");
    return true;
  });
  const result = reduceWorkItemTransition(
    current,
    transition({
      targetStage: "approved",
      blockerCodes: [],
      decisionId: "decision:custom",
    }),
    policy
  );
  assert.equal(result.workItem.primaryStage, "approved");
  assert.equal(result.workItem.lifecycleStatus, "ready");
});

test("published work can be reconciled to taken down but not reopened", () => {
  const published = operationWorkItem({
    primaryStage: "ready",
    lifecycleStatus: "published",
    outcome: "published",
    revision: 4,
    decisionId: "decision:1",
    publicationPlanId: "publication:1",
  });
  const result = reduceWorkItemLifecycle(
    published,
    {
      actionId: "action:takedown:1",
      sequence: 5,
      expectedRevision: 4,
      targetOutcome: "taken_down",
      operation: "reconcile_takedown",
      actor: {actorType: "system", actorId: "reconciler:1"},
      idempotencyKey: "takedown:1",
      inputHash: hashes.input,
      outputHash: hashes.output,
      rulesetVersion: "rules-v1",
      modelVersion: null,
      reasonCodes: ["source_takedown_received"],
      occurredAt: "2026-07-14T08:05:00.000Z",
    },
    supplyIntakeStagePolicy
  );
  assert.equal(result.workItem.lifecycleStatus, "terminal");
  assert.equal(result.workItem.outcome, "taken_down");
  assert.throws(() => reduceWorkItemLifecycle(
    result.workItem,
    {
      actionId: "action:retry:1",
      sequence: 6,
      expectedRevision: 5,
      targetOutcome: "cancelled",
      operation: "retry_terminal",
      actor: {actorType: "system", actorId: "reconciler:1"},
      idempotencyKey: "retry-terminal:1",
      inputHash: hashes.input,
      outputHash: hashes.output,
      rulesetVersion: "rules-v1",
      modelVersion: null,
      reasonCodes: ["retry"],
      occurredAt: "2026-07-14T08:06:00.000Z",
    },
    supplyIntakeStagePolicy
  ));
});

test("run reducer freezes terminal runs and records failure evidence", () => {
  const queued = reduceRunTransition(operationRun(), {
    expectedRevision: 0,
    targetStatus: "queued",
    occurredAt: "2026-07-14T08:01:00.000Z",
  });
  const running = reduceRunTransition(queued, {
    expectedRevision: 1,
    targetStatus: "running",
    occurredAt: "2026-07-14T08:02:00.000Z",
  });
  const failed = reduceRunTransition(running, {
    expectedRevision: 2,
    targetStatus: "failed",
    occurredAt: "2026-07-14T08:03:00.000Z",
    failure: {
      code: "source_unavailable",
      message: "Timed out",
      retryable: true,
    },
  });
  assert.equal(failed.finishedAt, "2026-07-14T08:03:00.000Z");
  assert.equal(failed.failure?.retryable, true);
  assert.throws(() => reduceRunTransition(failed, {
    expectedRevision: 3,
    targetStatus: "running",
    occurredAt: "2026-07-14T08:04:00.000Z",
  }));
});
