import assert from "node:assert/strict";
import test from "node:test";
import {OperationConflictError} from "./errors";
import {OperationRun, OperationWorkItem} from "./models";
import {
  importShadowProjection,
  prepareShadowProjection,
  ProjectionImportWriter,
} from "./projectionImporter";
import {operationRun, operationWorkItem} from "./testFixtures";

class MemoryProjectionWriter implements ProjectionImportWriter {
  readonly runs = new Map<string, OperationRun>();
  readonly items = new Map<string, OperationWorkItem>();
  readonly writes: string[] = [];

  async getRun(runId: string): Promise<OperationRun | null> {
    return structuredClone(this.runs.get(runId) ?? null);
  }

  async getWorkItems(
    workItemIds: string[]
  ): Promise<Map<string, OperationWorkItem>> {
    const found = new Map<string, OperationWorkItem>();
    for (const id of workItemIds) {
      const item = this.items.get(id);
      if (item) found.set(id, structuredClone(item));
    }
    return found;
  }

  async createWorkItems(workItems: OperationWorkItem[]): Promise<void> {
    this.writes.push("items");
    for (const item of workItems) {
      if (this.items.has(item.workItemId)) throw new Error("item exists");
      this.items.set(item.workItemId, structuredClone(item));
    }
  }

  async createRun(run: OperationRun): Promise<void> {
    this.writes.push("run");
    if (this.runs.has(run.runId)) throw new Error("run exists");
    this.runs.set(run.runId, structuredClone(run));
  }
}

test("prepares a fail-closed shadow projection with full aggregates", () => {
  const prepared = prepareShadowProjection(projection());
  assert.equal(prepared.run.revision, 0);
  assert.ok(prepared.artifactHash.match(/^[a-f0-9]{64}$/));
  assert.equal(prepared.summary.totalItems, 2);
  assert.equal(prepared.summary.humanReviewCount, 1);
  assert.deepEqual(prepared.summary.stageCounts, {
    incoming: 1,
    verify: 0,
    resolve: 1,
    ready: 0,
  });
  assert.ok(prepared.workItems.every((item) => item.revision === 0));
  assert.ok(prepared.workItems.every((item) =>
    typeof item.normalizedPayload.__projection === "object"));
});

test("rejects projections that grant a shadow run unsafe authority", () => {
  const input = projection();
  const run = input.run as OperationRun;
  run.metadata = {
    ...run.metadata,
    capabilities: {
      network: true,
      modelCalls: false,
      publicWrites: false,
      ruleDeployment: false,
    },
  };
  assert.throws(
    () => prepareShadowProjection(input),
    {code: "unsafe_projection_capability"}
  );
});

test("rejects mutable non-completed run snapshots", () => {
  const input = projection();
  const run = input.run as OperationRun;
  run.status = "running";
  run.finishedAt = null;
  assert.throws(
    () => prepareShadowProjection(input),
    {code: "unsafe_projection_mode"}
  );
});

test("applies items before the run and replays the same artifact", async () => {
  const writer = new MemoryProjectionWriter();
  const input = projection();
  const first = await importShadowProjection({input, apply: true, writer});
  assert.deepEqual(writer.writes, ["items", "run"]);
  assert.equal(first.createdWorkItems, 2);
  assert.equal(first.idempotent, false);
  const replay = await importShadowProjection({input, apply: true, writer});
  assert.equal(replay.idempotent, true);
  assert.equal(replay.reusedWorkItems, 2);
  assert.deepEqual(writer.writes, ["items", "run"]);
});

test("replay repairs missing items without recreating the run", async () => {
  const writer = new MemoryProjectionWriter();
  const input = projection();
  await importShadowProjection({input, apply: true, writer});
  writer.items.delete("work:event:two");

  const repaired = await importShadowProjection({input, apply: true, writer});
  assert.equal(repaired.createdWorkItems, 1);
  assert.equal(repaired.reusedWorkItems, 1);
  assert.equal(repaired.idempotent, false);
  assert.equal(writer.items.size, 2);
  assert.deepEqual(writer.writes, ["items", "run", "items"]);

  const exactReplay = await importShadowProjection({
    input,
    apply: true,
    writer,
  });
  assert.equal(exactReplay.idempotent, true);
  assert.deepEqual(writer.writes, ["items", "run", "items"]);
});

test("replay rejects tampered items with matching metadata", async () => {
  const writer = new MemoryProjectionWriter();
  const input = projection();
  await importShadowProjection({input, apply: true, writer});
  const stored = writer.items.get("work:event:one");
  assert.ok(stored);
  writer.items.set(stored.workItemId, {
    ...stored,
    priority: stored.priority + 1,
  });

  await assert.rejects(
    importShadowProjection({input, apply: true, writer}),
    (error: unknown) => {
      assert.ok(error instanceof OperationConflictError);
      assert.equal(error.code, "projection_work_item_conflict");
      return true;
    }
  );
});

test("rejects inventory above its frozen work budget", () => {
  const input = projection();
  const run = input.run as OperationRun;
  run.budgets = {...run.budgets, maxWorkItems: 1};
  assert.throws(
    () => prepareShadowProjection(input),
    {code: "projection_work_item_budget_exceeded"}
  );
});

test("rejects a changed artifact for an imported immutable run", async () => {
  const writer = new MemoryProjectionWriter();
  const input = projection();
  await importShadowProjection({input, apply: true, writer});
  const changed = projection();
  (changed.items as OperationWorkItem[])[0].priority += 1;
  await assert.rejects(
    importShadowProjection({input: changed, apply: true, writer}),
    (error: unknown) => {
      assert.ok(error instanceof OperationConflictError);
      assert.equal(error.code, "projection_artifact_conflict");
      return true;
    }
  );
});

function projection(): Record<string, unknown> {
  const items = [
    operationWorkItem({
      workItemId: "work:event:one",
      revision: 4,
      normalizedPayload: {owner: "agent", title: "Event one"},
    }),
    operationWorkItem({
      workItemId: "work:event:two",
      revision: 2,
      primaryStage: "resolve",
      lifecycleStatus: "waiting",
      taskFlags: ["human_review_required"],
      normalizedPayload: {owner: "human", title: "Event two"},
    }),
  ];
  const run = operationRun({
    revision: 7,
    status: "completed",
    startedAt: "2026-07-14T08:00:00.000Z",
    finishedAt: "2026-07-14T08:10:00.000Z",
    counters: {
      discovered: items.length,
      processed: items.length,
      modelCalls: 0,
      modelTokens: 0,
      costMicros: 0,
      escalated: 1,
      published: 0,
      failed: 0,
    },
    metadata: {
      capabilities: {
        network: false,
        modelCalls: false,
        publicWrites: false,
        ruleDeployment: false,
      },
    },
  });
  return {
    schemaVersion: 1,
    program: "catch-operations-admin-projection",
    workflowId: "supply-intake",
    workflowVersion: "0.1.0",
    generatedAt: run.updatedAt,
    run,
    summary: {
      totalItems: 2,
      activeItems: 2,
      terminalItems: 0,
      stageCounts: {incoming: 1, verify: 0, resolve: 1, ready: 0},
    },
    stageOrder: ["incoming", "verify", "resolve", "ready"],
    items,
    guardrails: [],
  };
}
