import assert from "node:assert/strict";
import test from "node:test";
import {OperationConflictError, OperationDomainError} from "./errors";
import {InMemoryOperationsRepository} from "./inMemoryRepository";
import {
  operationActionReceipt,
  operationRuleEvaluation,
  operationRuleProposal,
  operationRun,
  operationWorkItem,
} from "./testFixtures";

test("run and work-item lists are filtered and cursor paginated", async () => {
  const repository = new InMemoryOperationsRepository();
  await repository.createRun(operationRun());
  const primaryStages = ["incoming", "verify", "incoming"] as const;
  for (const [index, primaryStage] of primaryStages.entries()) {
    await repository.createWorkItem(operationWorkItem({
      workItemId: `work:event:${index}`,
      primaryStage,
      lifecycleStatus: primaryStage === "verify" ? "in_progress" : "queued",
      entityKind: index === 2 ? "organizer" : "event",
    }));
  }

  const first = await repository.listWorkItems({
    workflowId: "supply-intake",
    primaryStage: "incoming",
    limit: 1,
  });
  assert.deepEqual(
    first.items.map((item) => item.workItemId),
    ["work:event:0"]
  );
  assert.equal(first.nextCursor, "work:event:0");
  const second = await repository.listWorkItems({
    workflowId: "supply-intake",
    primaryStage: "incoming",
    entityKind: "organizer",
    limit: 1,
    cursor: first.nextCursor,
  });
  assert.deepEqual(
    second.items.map((item) => item.workItemId),
    ["work:event:2"]
  );
  assert.equal(second.nextCursor, null);

  await repository.createWorkItem(operationWorkItem({
    workItemId: "work:event:human",
    taskFlags: ["human_review_required"],
    normalizedPayload: {owner: "human"},
  }));
  const humanReview = await repository.listWorkItems({
    workflowId: "supply-intake",
    humanReviewRequired: true,
    limit: 200,
  });
  assert.deepEqual(humanReview.items.map((item) => item.workItemId), [
    "work:event:human",
  ]);
});

test("run pagination is newest-first instead of lexical-id order", async () => {
  const repository = new InMemoryOperationsRepository();
  await repository.createRun(operationRun({
    runId: "run:z-old",
    updatedAt: "2026-07-01T08:00:00.000Z",
  }));
  await repository.createRun(operationRun({
    runId: "run:a-new",
    updatedAt: "2026-07-14T08:00:00.000Z",
  }));
  await repository.createRun(operationRun({
    runId: "run:m-middle",
    updatedAt: "2026-07-07T08:00:00.000Z",
  }));
  const first = await repository.listRuns({limit: 2});
  assert.deepEqual(first.items.map((run) => run.runId), [
    "run:a-new",
    "run:m-middle",
  ]);
  assert.ok(first.nextCursor);
  const second = await repository.listRuns({
    limit: 2,
    cursor: first.nextCursor,
  });
  assert.deepEqual(second.items.map((run) => run.runId), ["run:z-old"]);
});

test("versioned writes reject stale or skipped revisions", async () => {
  const repository = new InMemoryOperationsRepository();
  await repository.createWorkItem(operationWorkItem());
  await repository.saveWorkItem(operationWorkItem({
    revision: 1,
    primaryStage: "verify",
    lifecycleStatus: "in_progress",
    updatedAt: "2026-07-14T08:01:00.000Z",
  }), 0);
  await assert.rejects(repository.saveWorkItem(operationWorkItem({
    revision: 2,
    primaryStage: "resolve",
    lifecycleStatus: "waiting",
  }), 0), (error: unknown) => {
    assert.ok(error instanceof OperationConflictError);
    assert.equal(error.code, "revision_conflict");
    return true;
  });
});

test("action receipts are append-only and input-idempotent", async () => {
  const repository = new InMemoryOperationsRepository();
  const receipt = operationActionReceipt();
  assert.deepEqual(await repository.appendActionReceipt(receipt), receipt);
  assert.deepEqual(await repository.appendActionReceipt({
    ...receipt,
    actionId: "retry-action:1",
  }), receipt);
  await assert.rejects(repository.appendActionReceipt({
    ...receipt,
    actionId: "retry-action:2",
    operation: "different_operation",
  }), (error: unknown) => {
    assert.ok(error instanceof OperationConflictError);
    assert.equal(error.code, "idempotency_conflict");
    return true;
  });
});

test("lease fencing prevents overlap and stale worker mutation", async () => {
  const repository = new InMemoryOperationsRepository();
  const first = await repository.acquireLease({
    leaseId: "lease:1",
    resourceType: "work_item",
    resourceId: "work:event:1",
    ownerId: "worker:1",
    idempotencyKey: "lease-attempt:1",
    acquiredAt: "2026-07-14T08:00:00.000Z",
    expiresAt: "2026-07-14T08:01:00.000Z",
  });
  await assert.rejects(repository.acquireLease({
    leaseId: "lease:2",
    resourceType: "work_item",
    resourceId: "work:event:1",
    ownerId: "worker:2",
    idempotencyKey: "lease-attempt:2",
    acquiredAt: "2026-07-14T08:00:30.000Z",
    expiresAt: "2026-07-14T08:02:00.000Z",
  }), OperationConflictError);
  const second = await repository.acquireLease({
    leaseId: "lease:2",
    resourceType: "work_item",
    resourceId: "work:event:1",
    ownerId: "worker:2",
    idempotencyKey: "lease-attempt:2",
    acquiredAt: "2026-07-14T08:01:01.000Z",
    expiresAt: "2026-07-14T08:02:00.000Z",
  });
  assert.equal(second.fencingToken, first.fencingToken + 1);
  await assert.rejects(repository.releaseLease({
    leaseId: "lease:2",
    ownerId: "worker:1",
    fencingToken: first.fencingToken,
    releasedAt: "2026-07-14T08:01:10.000Z",
  }), (error: unknown) => {
    assert.ok(error instanceof OperationConflictError);
    assert.equal(error.code, "lease_fencing_conflict");
    return true;
  });
});

test("learning store enforces independent evaluation", async () => {
  const repository = new InMemoryOperationsRepository();
  await repository.createRuleProposal(operationRuleProposal());
  await assert.rejects(repository.appendRuleEvaluation(operationRuleEvaluation({
    evaluatedBy: {actorType: "agent", actorId: "learner:1"},
  })), (error: unknown) => {
    assert.ok(error instanceof OperationDomainError);
    assert.equal(error.code, "rule_evaluator_not_independent");
    return true;
  });
  await repository.appendRuleEvaluation(operationRuleEvaluation());
  assert.equal((await repository.listRuleEvaluations(
    "rule-proposal:1"
  )).length, 1);
});
