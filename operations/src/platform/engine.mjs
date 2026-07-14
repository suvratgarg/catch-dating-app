import crypto from "node:crypto";
import {BudgetLedger} from "./budget.mjs";
import {hashValue, shortHash} from "./canonical-json.mjs";
import {assertRun, assertWorkItem, safeId, transitionWorkItem, uniqueSorted} from "./contracts.mjs";
import {OperationsError, invariant} from "./errors.mjs";

const LEASE_TTL_MS = 60_000;

export class OperationsEngine {
  constructor({store, workflow, clock = () => new Date(), workerId = defaultWorkerId()} = {}) {
    invariant(store, "INVALID_ENGINE", "Operations store is required.");
    invariant(workflow?.workflowId, "INVALID_ENGINE", "Workflow is required.");
    this.store = store;
    this.workflow = workflow;
    this.clock = clock;
    this.workerId = safeId(workerId);
  }

  async start(plan, {requestedRunId} = {}) {
    this.workflow.assertPlan(plan);
    const idempotencyKey = `run:${this.workflow.workflowId}:${plan.planId}`;
    const existing = await this.store.getIdempotency(idempotencyKey);
    if (existing) {
      invariant(existing.planHash === planHashFor(plan), "IDEMPOTENCY_CONFLICT", "A run exists for this plan id with a different content hash.", {
        runId: existing.runId,
        expected: existing.planHash,
        actual: planHashFor(plan),
      });
      return {run: await this.store.requireRun(existing.runId), idempotentReplay: true};
    }
    const now = this.now();
    const runId = requestedRunId ? safeId(requestedRunId) : `run-${plan.planId}`;
    const run = assertRun({
      schemaVersion: 1,
      runId,
      workflowId: this.workflow.workflowId,
      workflowVersion: this.workflow.version,
      planId: plan.planId,
      planHash: planHashFor(plan),
      plan,
      mode: "shadow",
      status: "planned",
      createdAt: now,
      updatedAt: now,
      startedAt: null,
      completedAt: null,
      budget: new BudgetLedger({limits: plan.budgets}).snapshot(),
      counters: {workItems: 0, actions: 0},
      capabilities: {...plan.capabilities},
    });
    await this.store.createRun(run);
    const idempotency = await this.store.recordIdempotency(idempotencyKey, {
      runId,
      planId: plan.planId,
      planHash: run.planHash,
      createdAt: now,
    });
    if (!idempotency.created && idempotency.record.runId !== runId) {
      throw new OperationsError("IDEMPOTENCY_CONFLICT", "Run idempotency record changed concurrently.");
    }
    return {run: await this.execute(runId, plan), idempotentReplay: false};
  }

  async resume(runId, plan) {
    const run = await this.store.requireRun(runId);
    if (run.status === "completed") return {run, idempotentReplay: true};
    invariant(run.planHash === planHashFor(plan), "PLAN_HASH_MISMATCH", "Resume plan does not match the original run.", {
      runId,
      expected: run.planHash,
      actual: planHashFor(plan),
    });
    return {run: await this.execute(runId, plan), idempotentReplay: false};
  }

  async execute(runId, plan) {
    let lease = await this.store.acquireLease(`run:${runId}`, {
      owner: this.workerId,
      ttlMs: LEASE_TTL_MS,
      now: this.now(),
    });
    try {
      let run = await this.store.updateRun(runId, (current) => ({
        ...current,
        status: "running",
        startedAt: current.startedAt ?? this.now(),
        updatedAt: this.now(),
      }));
      await this.recordAction(runId, "run.started", {planId: plan.planId, mode: run.mode});
      const budget = new BudgetLedger({limits: run.budget.limits, consumed: run.budget.consumed});

      const importCheckpoint = await this.store.getCheckpoint(runId, "project-artifacts");
      if (!importCheckpoint?.completed) {
        const candidates = await this.workflow.project(plan, {runId, now: this.now()});
        for (const candidate of candidates) {
          budget.consume({workItems: 1}, {reason: "project legacy candidate"});
          const result = await this.store.putWorkItem(candidate, {ifAbsent: true});
          await this.recordAction(runId, result.created ? "work_item.created" : "work_item.reused", {
            workItemId: candidate.workItemId,
            entityKind: candidate.entityKind,
            primaryStage: candidate.primaryStage,
            sourceEntityId: candidate.sourceEntity.id,
          });
        }
        await this.store.putCheckpoint(runId, "project-artifacts", {
          completed: true,
          completedAt: this.now(),
          itemCount: candidates.length,
          outputHash: hashValue(candidates),
        });
      }
      lease = await this.store.renewLease(lease, {ttlMs: LEASE_TTL_MS, now: this.now()});

      const decisionCheckpoint = await this.store.getCheckpoint(runId, "deterministic-review");
      if (!decisionCheckpoint?.completed) {
        const items = await this.store.listWorkItems({runId});
        for (const item of items) {
          const outcome = this.workflow.review(item, {now: this.now()});
          const updated = transitionWorkItem(item, outcome.primaryStage, {
            at: this.now(),
            reason: outcome.reason,
            taskFlags: outcome.taskFlags,
            blockers: outcome.blockers,
          });
          updated.owner = outcome.owner;
          updated.confidence = outcome.confidence;
          updated.decisionProvenance = outcome.decisionProvenance;
          updated.lifecycleStatus = outcome.lifecycleStatus ?? item.lifecycleStatus;
          updated.expiresAt = outcome.expiresAt ?? item.expiresAt;
          await this.store.putWorkItem(updated);
          await this.recordAction(runId, "work_item.reviewed", {
            workItemId: item.workItemId,
            from: item.primaryStage,
            to: updated.primaryStage,
            lifecycleStatus: updated.lifecycleStatus,
            blockers: updated.blockers,
            reason: outcome.reason,
          });
        }
        await this.store.putCheckpoint(runId, "deterministic-review", {
          completed: true,
          completedAt: this.now(),
          itemCount: items.length,
        });
      }

      const items = await this.store.listWorkItems({runId});
      const actions = await this.store.listActions(runId);
      run = await this.store.updateRun(runId, (current) => ({
        ...current,
        status: "completed",
        updatedAt: this.now(),
        completedAt: this.now(),
        budget: budget.snapshot(),
        counters: {workItems: items.length, actions: actions.length + 1},
      }));
      await this.recordAction(runId, "run.completed", {workItems: items.length, status: run.status});
      return this.store.requireRun(runId);
    } catch (error) {
      await this.failRun(runId, error);
      throw error;
    } finally {
      await this.store.releaseLease(lease).catch(() => false);
    }
  }

  async promotionReceipt(runId) {
    const run = await this.store.requireRun(runId);
    const items = (await this.store.listWorkItems({runId}))
      .filter((item) => item.primaryStage === "ready" && item.lifecycleStatus === "active")
      .sort((left, right) => left.workItemId.localeCompare(right.workItemId));
    const body = {
      schemaVersion: 1,
      runId,
      runPlanHash: run.planHash,
      workflowId: run.workflowId,
      workflowVersion: run.workflowVersion,
      mode: run.mode,
      itemBindings: items.map((item) => ({
        workItemId: item.workItemId,
        revision: item.revision,
        evidenceHash: item.evidence.artifactHash,
        decisionHash: hashValue(item.decisionProvenance),
      })),
      capabilities: run.capabilities,
    };
    const receiptId = `promotion-${shortHash(body)}`;
    const existingReceipt = await this.store.getPromotion(receiptId);
    if (existingReceipt) return existingReceipt;
    const receipt = {
      ...body,
      receiptId,
      createdAt: this.now(),
      status: "blocked",
      applyAllowed: false,
      blockedBy: uniqueSorted([
        "shadow_mode",
        "publisher_not_configured",
        ...(!run.capabilities.publicWrites ? ["public_writes_disabled"] : []),
      ]),
      guardrails: [
        "This receipt is decision support only and cannot write public data.",
        "A trusted publisher must revalidate item revisions, evidence hashes, policy, and freshness.",
      ],
      receiptHash: hashValue(body),
    };
    await this.store.putPromotion(receipt);
    await this.recordAction(runId, "promotion.receipt_created", {
      receiptId,
      eligibleItems: items.length,
      applyAllowed: false,
    });
    return receipt;
  }

  async reconcile(runId) {
    await this.store.requireRun(runId);
    const now = this.now();
    const items = await this.store.listWorkItems({runId});
    const summary = {examined: items.length, expired: 0, staleEvidence: 0, unchanged: 0};
    for (const item of items) {
      const outcome = this.workflow.reconcile(item, {now});
      if (!outcome.changed) {
        summary.unchanged += 1;
        continue;
      }
      const updated = {
        ...item,
        lifecycleStatus: outcome.lifecycleStatus,
        taskFlags: uniqueSorted([...item.taskFlags, ...outcome.taskFlags]),
        blockers: uniqueSorted([...item.blockers, ...outcome.blockers]),
        updatedAt: now,
      };
      await this.store.putWorkItem(updated);
      if (outcome.lifecycleStatus === "expired") summary.expired += 1;
      if (outcome.taskFlags.includes("stale_evidence")) summary.staleEvidence += 1;
      await this.recordAction(runId, "work_item.reconciled", {
        workItemId: item.workItemId,
        lifecycleStatus: outcome.lifecycleStatus,
        reasons: outcome.reasons,
      });
    }
    return {...summary, runId, reconciledAt: now};
  }

  async recordAction(runId, type, payload = {}) {
    const at = this.now();
    const actionId = `action-${at.replace(/[^0-9]/g, "")}-${shortHash({runId, type, payload, at, nonce: crypto.randomUUID()})}`;
    return this.store.appendAction({
      schemaVersion: 1,
      actionId,
      runId,
      type,
      at,
      actor: {kind: "operations_worker", id: this.workerId},
      payload,
    });
  }

  async failRun(runId, error) {
    const run = await this.store.getRun(runId);
    if (!run) return;
    await this.store.updateRun(runId, (current) => ({
      ...current,
      status: "failed",
      updatedAt: this.now(),
      failure: {
        code: error?.code ?? "INTERNAL_ERROR",
        message: error instanceof Error ? error.message : String(error),
      },
    })).catch(() => undefined);
    await this.recordAction(runId, "run.failed", {
      code: error?.code ?? "INTERNAL_ERROR",
      message: error instanceof Error ? error.message : String(error),
    }).catch(() => undefined);
  }

  now() {
    const value = this.clock();
    const date = value instanceof Date ? value : new Date(value);
    invariant(!Number.isNaN(date.valueOf()), "INVALID_CLOCK", "Clock returned an invalid timestamp.");
    return date.toISOString();
  }
}

function defaultWorkerId() {
  return `local-${process.pid}-${crypto.randomUUID().slice(0, 8)}`;
}

function planHashFor(plan) {
  return plan.planContentHash ?? hashValue(plan);
}
