import crypto from "node:crypto";
import {BudgetLedger} from "./budget.mjs";
import {hashValue, shortHash} from "./canonical-json.mjs";
import {
  assertRun,
  assertWorkItem,
  MAX_WORK_ITEMS_PER_RUN,
  safeId,
  transitionWorkItem,
  uniqueSorted,
  validId,
} from "./contracts.mjs";
import {OperationsError, invariant} from "./errors.mjs";

const LEASE_TTL_MS = 60_000;

export class OperationsEngine {
  constructor({
    store,
    workflow,
    clock = () => new Date(),
    leaseClock = () => new Date(),
    workerId = defaultWorkerId(),
  } = {}) {
    invariant(store, "INVALID_ENGINE", "Operations store is required.");
    invariant(workflow?.workflowId, "INVALID_ENGINE", "Workflow is required.");
    assertWorkflowLifecycleSemantics(workflow);
    this.store = store;
    this.workflow = workflow;
    this.clock = clock;
    this.leaseClock = leaseClock;
    this.workerId = safeId(workerId);
  }

  async start(plan, {requestedRunId} = {}) {
    this.workflow.assertPlan(plan);
    invariant(
      !plan.reconciliation,
      "RECONCILIATION_ENTRYPOINT_REQUIRED",
      "Reconciliation plans can only be executed through reconcile/resume."
    );
    const idempotencyKey = `run:${this.workflow.workflowId}:${plan.planId}`;
    const now = this.now();
    const planHash = planHashFor(plan);
    const desiredRunId = requestedRunId ? safeId(requestedRunId) : `run-${plan.planId}`;
    const preexistingRun = await this.store.getRun(desiredRunId);
    if (preexistingRun) assertRunMatchesPlan(preexistingRun, plan, this.workflow);
    const idempotency = await this.store.recordIdempotency(idempotencyKey, {
      runId: desiredRunId,
      planId: plan.planId,
      planHash,
      createdAt: now,
    });
    const record = idempotency.record;
    invariant(record?.planHash === planHash && record.planId === plan.planId, "IDEMPOTENCY_CONFLICT", "A run exists for this plan id with different content.", {
      runId: record?.runId ?? null,
      expected: {planId: plan.planId, planHash},
      actual: record ? {planId: record.planId, planHash: record.planHash} : null,
    });
    if (requestedRunId) {
      invariant(record.runId === desiredRunId, "IDEMPOTENCY_CONFLICT", "The plan is already bound to another requested run id.", {
        expectedRunId: record.runId,
        requestedRunId: desiredRunId,
      });
    }

    let run = await this.store.getRun(record.runId);
    if (!run) {
      const plannedRun = buildPlannedRun({
        runId: record.runId,
        workflow: this.workflow,
        plan,
        planHash,
        createdAt: record.createdAt ?? now,
      });
      try {
        run = await this.store.createRun(plannedRun);
      } catch (error) {
        if (error?.code !== "RUN_EXISTS") throw error;
        run = await this.store.requireRun(record.runId);
      }
    }
    try {
      assertRunMatchesPlan(run, plan, this.workflow);
      assertPersistedRunPlan(run, this.workflow);
    } catch (error) {
      await this.store.deleteIdempotency(idempotencyKey, record);
      throw error;
    }
    if (run.status === "completed") {
      assertPersistedInventory(run, await this.store.listWorkItems({runId: run.runId}));
      return {
        run: await this.repairCompletedRun(run.runId),
        idempotentReplay: true,
      };
    }
    return {run: await this.execute(run.runId, plan), idempotentReplay: false};
  }

  async resume(runId, plan) {
    const run = await this.store.requireRun(runId);
    assertPersistedRunPlan(run, this.workflow);
    this.workflow.assertPlan(plan);
    assertRunMatchesPlan(run, plan, this.workflow);
    if (plan.reconciliation) {
      const result = await this.reconcile(
        plan.reconciliation.sourceRunId,
        {requestedRunId: runId}
      );
      return {run: result.run, idempotentReplay: result.idempotentReplay};
    }
    if (run.status === "completed") {
      assertPersistedInventory(run, await this.store.listWorkItems({runId: run.runId}));
      return {
        run: await this.repairCompletedRun(run.runId),
        idempotentReplay: true,
      };
    }
    return {run: await this.execute(runId, plan), idempotentReplay: false};
  }

  async execute(runId, plan) {
    return this.withRunLease(runId, async (leaseSession) => {
      try {
      let run = await this.store.requireRun(runId);
      assertPersistedRunPlan(run, this.workflow);
      assertRunMatchesPlan(run, plan, this.workflow);
      run = await this.store.updateRun(runId, (current) => ({
        ...current,
        status: "running",
        startedAt: current.startedAt ?? this.now(),
        updatedAt: this.now(),
        failure: null,
      }), await leaseSession.writeOptions());
      await this.recordAction(runId, "run.started", {planId: plan.planId, mode: run.mode}, leaseSession);
      const persistedItems = await this.store.listWorkItems({runId});
      assertPersistedInventory(run, persistedItems, {
        requireCompletionSnapshot: false,
      });
      assertWorkflowInventory(this.workflow, persistedItems);
      const budget = new BudgetLedger({
        limits: run.budget.limits,
        consumed: {
          ...run.budget.consumed,
          workItems: Math.max(run.budget.consumed.workItems, persistedItems.length),
        },
      });

      const importCheckpoint = await this.store.getCheckpoint(runId, "project-artifacts");
      if (!importCheckpoint?.completed) {
        const candidates = await this.workflow.project(plan, {runId, now: run.startedAt});
        const persistedIds = new Set(persistedItems.map((item) => item.workItemId));
        for (const candidate of candidates) {
          this.workflow.assertWorkItem(candidate);
          if (!persistedIds.has(candidate.workItemId)) {
            budget.consume({workItems: 1}, {reason: "project legacy candidate"});
          }
          const result = await this.store.putWorkItem(candidate, {
            ifAbsent: true,
            ...await leaseSession.writeOptions(),
          });
          if (result.created) persistedIds.add(candidate.workItemId);
          await this.recordAction(runId, result.created ? "work_item.created" : "work_item.reused", {
            workItemId: candidate.workItemId,
            entityKind: candidate.entityKind,
            primaryStage: candidate.primaryStage,
            sourceEntityId: candidate.sourceEntity.id,
          }, leaseSession);
        }
        await this.store.putCheckpoint(runId, "project-artifacts", {
          completed: true,
          completedAt: this.now(),
          itemCount: candidates.length,
          outputHash: hashValue(candidates),
        }, await leaseSession.writeOptions());
      }

      const decisionCheckpoint = await this.store.getCheckpoint(runId, "deterministic-review");
      if (!decisionCheckpoint?.completed) {
        const items = await this.store.listWorkItems({runId});
        assertWorkflowInventory(this.workflow, items);
        for (const item of items) {
          const outcome = this.workflow.review(item, {now: this.now()});
          const updated = transitionWorkItem(item, outcome.primaryStage, {
            at: this.now(),
            reason: outcome.reason,
            taskFlags: outcome.taskFlags,
            blockers: outcome.blockers,
            allowedTransitions: this.workflow.allowedTransitions,
          });
          updated.owner = outcome.owner;
          updated.confidence = outcome.confidence;
          updated.decisionProvenance = outcome.decisionProvenance;
          updated.lifecycleStatus = outcome.lifecycleStatus ?? item.lifecycleStatus;
          updated.expiresAt = outcome.expiresAt ?? item.expiresAt;
          this.workflow.assertWorkItem(updated);
          await this.store.putWorkItem(updated, await leaseSession.writeOptions());
          await this.recordAction(runId, "work_item.reviewed", {
            workItemId: item.workItemId,
            from: item.primaryStage,
            to: updated.primaryStage,
            lifecycleStatus: updated.lifecycleStatus,
            blockers: updated.blockers,
            reason: outcome.reason,
          }, leaseSession);
        }
        await this.store.putCheckpoint(runId, "deterministic-review", {
          completed: true,
          completedAt: this.now(),
          itemCount: items.length,
        }, await leaseSession.writeOptions());
      }

      const items = await this.store.listWorkItems({runId});
      assertPersistedInventory(run, items, {requireCompletionSnapshot: false});
      assertWorkflowInventory(this.workflow, items);
      const actions = await this.store.listActions(runId);
      const completedAt = this.now();
      run = await this.store.updateRun(runId, (current) => ({
        ...current,
        status: "completed",
        updatedAt: completedAt,
        completedAt,
        budget: budget.snapshot(),
        counters: {workItems: items.length, actions: actions.length},
        inventoryHash: inventoryContentHash(items),
      }), await leaseSession.writeOptions());
      await this.ensureRunCompletedAction(run, leaseSession);
      const completedActions = await this.store.listActions(runId);
      if (run.counters.actions !== completedActions.length) {
        run = await this.store.updateRun(runId, (current) => ({
          ...current,
          counters: {...current.counters, actions: completedActions.length},
        }), await leaseSession.writeOptions());
      }
      return run;
      } catch (error) {
        await this.failRun(runId, error, leaseSession);
        throw error;
      }
    });
  }

  async repairCompletedRun(runId) {
    return this.withRunLease(runId, async (leaseSession) => {
      let run = await this.store.requireRun(runId);
      assertPersistedRunPlan(run, this.workflow);
      invariant(run.status === "completed", "RUN_NOT_COMPLETED",
        `Run ${runId} is not completed.`);
      const inventory = await this.store.listWorkItems({runId});
      assertPersistedInventory(run, inventory);
      assertWorkflowInventory(this.workflow, inventory);
      await this.ensureRunCompletedAction(run, leaseSession);
      const actions = await this.store.listActions(runId);
      const actionCount = runSnapshotActionCount(actions);
      if (run.counters.actions !== actionCount) {
        run = await this.store.updateRun(runId, (current) => ({
          ...current,
          counters: {...current.counters, actions: actionCount},
        }), await leaseSession.writeOptions());
      }
      return run;
    });
  }

  async ensureRunCompletedAction(run, leaseSession) {
    const payload = {
      workItems: run.counters.workItems,
      inventoryHash: run.inventoryHash,
      status: "completed",
    };
    const actionId = `action-run-completed-${shortHash({runId: run.runId})}`;
    const existing = (await this.store.listActions(run.runId))
      .filter((action) => action.type === "run.completed");
    invariant(existing.length <= 1, "ACTION_CONFLICT",
      `Run ${run.runId} has multiple completion actions.`);
    if (existing.length === 1) {
      const [action] = existing;
      invariant(
        action.schemaVersion === 1 &&
          action.actionId === actionId &&
          action.runId === run.runId &&
          action.at === run.completedAt &&
          action.actor?.kind === "operations_worker" &&
          validId(action.actor?.id) &&
          hashValue(action.payload) === hashValue(payload),
        "ACTION_CONFLICT",
        `Run ${run.runId} completion action does not match durable state.`
      );
      return action;
    }
    return this.recordAction(
      run.runId,
      "run.completed",
      payload,
      leaseSession,
      {
        actionId,
        at: run.completedAt,
      }
    );
  }

  async promotionReceipt(runId) {
    return this.withRunLease(runId, async (leaseSession) => {
      const run = await this.store.requireRun(runId);
      assertPersistedRunPlan(run, this.workflow);
      invariant(run.status === "completed", "RUN_NOT_COMPLETED",
        "Promotion receipts require an immutable completed run snapshot.");
      const inventory = await this.store.listWorkItems({runId});
      assertPersistedInventory(run, inventory);
      assertWorkflowInventory(this.workflow, inventory);
      invariant(
        typeof run.plan?.promotionPolicyHash === "string",
        "PROMOTION_POLICY_SNAPSHOT_MISSING",
        "The run does not contain a frozen promotion policy snapshot."
      );
      invariant(typeof this.workflow.promotionCandidates === "function",
        "INVALID_WORKFLOW", "Workflow promotion candidate policy is required.");
      const candidates = assertPromotionCandidateSelection(
        inventory,
        this.workflow.promotionCandidates(inventory)
      )
        .sort((left, right) => left.workItemId.localeCompare(right.workItemId));
      const evaluated = await Promise.all(candidates.map(async (item) => {
        const eligibility = await this.workflow.promotionEligibility(item, {
          run,
        });
        invariant(
          typeof eligibility?.eligible === "boolean" &&
            Array.isArray(eligibility.blockers),
          "INVALID_WORKFLOW",
          "Workflow promotion eligibility must return a boolean and blockers."
        );
        return {item, eligibility};
      }));
      const items = evaluated
        .filter(({eligibility}) => eligibility.eligible)
        .map(({item}) => item);
      const body = {
        schemaVersion: 1,
        runId,
        runPlanHash: run.planHash,
        workflowId: run.workflowId,
        workflowVersion: run.workflowVersion,
        mode: run.mode,
        policyEvidence: {
          promotionPolicyHash: run.plan.promotionPolicyHash,
          workflowPolicy: run.plan.policy,
          sourceProfiles: run.plan.sourceProfiles,
        },
        itemBindings: items.map((item) => ({
          workItemId: item.workItemId,
          revision: item.revision,
          evidenceHash: item.evidence.artifactHash,
          decisionHash: hashValue(item.decisionProvenance),
        })),
        exclusions: evaluated
          .filter(({eligibility}) => !eligibility.eligible)
          .map(({item, eligibility}) => ({
            workItemId: item.workItemId,
            blockerCodes: eligibility.blockers,
          })),
        capabilities: run.capabilities,
      };
      const receiptContent = {
        ...body,
        createdAt: run.completedAt ?? run.updatedAt ?? run.createdAt,
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
      };
      const receiptId = `promotion-${shortHash(receiptContent)}`;
      const receiptHash = hashValue(receiptContent);
      const existingReceipt = await this.store.getPromotion(receiptId);
      if (existingReceipt) {
        assertPromotionReceiptMatches(existingReceipt, receiptContent, receiptId, receiptHash);
        await this.ensurePromotionReceiptAction(existingReceipt, leaseSession);
        return existingReceipt;
      }
      const receipt = {
        ...receiptContent,
        receiptId,
        receiptHash,
      };
      let storedReceipt;
      try {
        storedReceipt = await this.store.putPromotion(
          receipt,
          await leaseSession.writeOptions()
        );
      } catch (error) {
        if (error?.code !== "PROMOTION_CONFLICT") throw error;
        storedReceipt = await this.store.getPromotion(receiptId);
        assertPromotionReceiptMatches(storedReceipt, receiptContent, receiptId, receiptHash);
      }
      await this.ensurePromotionReceiptAction(storedReceipt, leaseSession);
      return storedReceipt;
    });
  }

  async ensurePromotionReceiptAction(receipt, leaseSession) {
    const actionId = `action-promotion-${shortHash({runId: receipt.runId, receiptId: receipt.receiptId})}`;
    const payload = {
      receiptId: receipt.receiptId,
      candidateItems: receipt.itemBindings.length + receipt.exclusions.length,
      eligibleItems: receipt.itemBindings.length,
      excludedItems: receipt.exclusions.length,
      applyAllowed: receipt.applyAllowed,
    };
    const existing = (await this.store.listActions(receipt.runId))
      .find((action) => action.actionId === actionId);
    if (existing) {
      invariant(
        existing.schemaVersion === 1 &&
          existing.actionId === actionId &&
          existing.runId === receipt.runId &&
          existing.type === "promotion.receipt_created" &&
          existing.at === receipt.createdAt &&
          existing.actor?.kind === "operations_worker" &&
          validId(existing.actor?.id) &&
          hashValue(existing.payload) === hashValue(payload),
        "ACTION_CONFLICT",
        `Promotion action ${actionId} does not match receipt ${receipt.receiptId}.`
      );
      return existing;
    }
    return this.recordAction(
      receipt.runId,
      "promotion.receipt_created",
      payload,
      leaseSession,
      {actionId, at: receipt.createdAt}
    );
  }

  async reconcile(sourceRunId, {requestedRunId} = {}) {
    invariant(typeof this.workflow.createReconciliationPlan === "function",
      "INVALID_WORKFLOW",
      "Workflow reconciliation plan factory is required.");
    let sourceRun = await this.store.requireRun(sourceRunId);
    assertPersistedRunPlan(sourceRun, this.workflow);
    invariant(sourceRun.status === "completed", "RUN_NOT_COMPLETED",
      "Reconciliation requires a completed source run.");
    sourceRun = await this.repairCompletedRun(sourceRunId);
    const sourceItems = await this.store.listWorkItems({runId: sourceRunId});
    assertPersistedInventory(sourceRun, sourceItems);
    assertWorkflowInventory(this.workflow, sourceItems);

    const target = requestedRunId ?
      await this.store.requireRun(requestedRunId) :
      await this.findOrCreateReconciliationRun(sourceRun);
    assertPersistedRunPlan(target, this.workflow);
    invariant(
      target.plan?.reconciliation?.sourceRunId === sourceRun.runId &&
        target.plan.reconciliation.sourcePlanHash === sourceRun.planHash &&
        target.plan.reconciliation.sourceInventoryHash ===
          sourceRun.inventoryHash,
      "RECONCILIATION_LINEAGE_CONFLICT",
      `Reconciliation run ${target.runId} does not match source ${sourceRun.runId}.`
    );

    return this.withRunLease(target.runId, async (leaseSession) => {
      try {
        let run = await this.store.requireRun(target.runId);
        assertPersistedRunPlan(run, this.workflow);
        const at = run.plan.generatedAt;
        if (run.status === "completed") {
          const inventory = await this.store.listWorkItems({runId: run.runId});
          assertPersistedInventory(run, inventory);
          assertWorkflowInventory(this.workflow, inventory);
          await this.ensureReconciliationStartedAction(
            run,
            sourceRun,
            leaseSession
          );
          for (const item of inventory) {
            await this.ensureReconciliationAction(
              item,
              item.reconciliationReceipt,
              leaseSession
            );
          }
          await this.ensureRunCompletedAction(run, leaseSession);
          run = await this.syncActionCounter(run, leaseSession);
          return reconciliationResult({
            run,
            sourceRun,
            items: inventory,
            workflow: this.workflow,
            idempotentReplay: true,
          });
        }

        run = await this.store.updateRun(run.runId, (current) => ({
          ...current,
          status: "running",
          startedAt: current.startedAt ?? at,
          updatedAt: at,
          failure: null,
        }), await leaseSession.writeOptions());
        await this.ensureReconciliationStartedAction(
          run,
          sourceRun,
          leaseSession
        );
        for (const sourceItem of sourceItems) {
          const item = buildReconciliationSnapshotItem({
            sourceItem,
            runId: run.runId,
            workflow: this.workflow,
            at,
          });
          this.workflow.assertWorkItem(item);
          const stored = await this.store.putWorkItem(item, {
            ifAbsent: true,
            ...await leaseSession.writeOptions(),
          });
          await this.ensureReconciliationAction(
            stored.item,
            stored.item.reconciliationReceipt,
            leaseSession
          );
        }

        const inventory = await this.store.listWorkItems({runId: run.runId});
        invariant(inventory.length === sourceItems.length,
          "INVENTORY_INTEGRITY_VIOLATION",
          "Reconciliation snapshot cardinality differs from its source run.");
        assertPersistedInventory(run, inventory, {
          requireCompletionSnapshot: false,
        });
        assertWorkflowInventory(this.workflow, inventory);
        const budget = new BudgetLedger({limits: run.plan.budgets});
        budget.consume({workItems: inventory.length}, {
          reason: "reconciliation snapshot inventory",
        });
        const actions = await this.store.listActions(run.runId);
        run = await this.store.updateRun(run.runId, (current) => ({
          ...current,
          status: "completed",
          updatedAt: at,
          completedAt: at,
          budget: budget.snapshot(),
          counters: {workItems: inventory.length, actions: actions.length},
          inventoryHash: inventoryContentHash(inventory),
        }), await leaseSession.writeOptions());
        await this.ensureRunCompletedAction(run, leaseSession);
        run = await this.syncActionCounter(run, leaseSession);
        return reconciliationResult({
          run,
          sourceRun,
          items: inventory,
          workflow: this.workflow,
          idempotentReplay: false,
        });
      } catch (error) {
        await this.failRun(target.runId, error, leaseSession);
        throw error;
      }
    });
  }

  async findOrCreateReconciliationRun(sourceRun) {
    const incomplete = (await this.store.listRuns()).filter((run) =>
      run.workflowId === this.workflow.workflowId &&
      run.plan?.reconciliation?.sourceRunId === sourceRun.runId &&
      run.status !== "completed" &&
      !["cancelled"].includes(run.status));
    invariant(incomplete.length <= 1, "RECONCILIATION_RUN_CONFLICT",
      `Source run ${sourceRun.runId} has multiple incomplete reconciliation snapshots.`);
    if (incomplete.length === 1) return incomplete[0];

    const now = this.now();
    const plan = this.workflow.createReconciliationPlan(sourceRun, {now});
    this.workflow.assertPlan(plan);
    const planHash = planHashFor(plan);
    const desiredRunId = `run-${plan.planId}`;
    const idempotencyKey = `run:${this.workflow.workflowId}:${plan.planId}`;
    const idempotency = await this.store.recordIdempotency(idempotencyKey, {
      runId: desiredRunId,
      planId: plan.planId,
      planHash,
      sourceRunId: sourceRun.runId,
      createdAt: now,
    });
    const record = idempotency.record;
    invariant(
      record.runId === desiredRunId &&
        record.planId === plan.planId &&
        record.planHash === planHash &&
        record.sourceRunId === sourceRun.runId,
      "IDEMPOTENCY_CONFLICT",
      "Reconciliation plan idempotency mapping has conflicting content."
    );
    let run = await this.store.getRun(record.runId);
    if (!run) {
      try {
        run = await this.store.createRun(buildPlannedRun({
          runId: record.runId,
          workflow: this.workflow,
          plan,
          planHash,
          createdAt: record.createdAt,
        }));
      } catch (error) {
        if (error?.code !== "RUN_EXISTS") throw error;
        run = await this.store.requireRun(record.runId);
      }
    }
    assertRunMatchesPlan(run, plan, this.workflow);
    return run;
  }

  async ensureReconciliationStartedAction(run, sourceRun, leaseSession) {
    const actionId = `action-reconciliation-started-${shortHash({
      runId: run.runId,
      sourceRunId: sourceRun.runId,
    })}`;
    const payload = {
      sourceRunId: sourceRun.runId,
      sourcePlanHash: sourceRun.planHash,
      sourceInventoryHash: sourceRun.inventoryHash,
    };
    const existing = (await this.store.listActions(run.runId))
      .find((action) => action.actionId === actionId);
    if (existing) {
      invariant(
        existing.schemaVersion === 1 &&
          existing.type === "run.reconciliation_started" &&
          existing.runId === run.runId &&
          existing.at === run.plan.generatedAt &&
          existing.actor?.kind === "operations_worker" &&
          validId(existing.actor?.id) &&
          hashValue(existing.payload) === hashValue(payload),
        "ACTION_CONFLICT",
        `Reconciliation start action ${actionId} does not match durable lineage.`
      );
      return existing;
    }
    return this.recordAction(
      run.runId,
      "run.reconciliation_started",
      payload,
      leaseSession,
      {actionId, at: run.plan.generatedAt}
    );
  }

  async syncActionCounter(run, leaseSession) {
    const actions = await this.store.listActions(run.runId);
    const actionCount = runSnapshotActionCount(actions);
    if (run.counters.actions === actionCount) return run;
    return this.store.updateRun(run.runId, (current) => ({
      ...current,
      counters: {...current.counters, actions: actionCount},
    }), await leaseSession.writeOptions());
  }

  async ensureReconciliationAction(item, receipt, leaseSession) {
    const expectedActionId = `action-reconcile-${shortHash({
      runId: item.runId,
      workItemId: item.workItemId,
      at: item.updatedAt,
      stateHash: reconciliationStateHash(item),
    })}`;
    invariant(
      receipt?.schemaVersion === 1 &&
        receipt.actionId === expectedActionId &&
        receipt.at === item.updatedAt &&
        receipt.stateHash === reconciliationStateHash(item) &&
        receipt.payload?.workItemId === item.workItemId &&
        receipt.payload?.lifecycleStatus === item.lifecycleStatus,
      "RECONCILIATION_RECEIPT_CONFLICT",
      `Work item ${item.workItemId} has invalid reconciliation evidence.`
    );
    const existing = (await this.store.listActions(item.runId))
      .find((action) => action.actionId === receipt.actionId);
    if (existing) {
      invariant(
        existing.schemaVersion === 1 &&
          existing.runId === item.runId &&
          existing.type === "work_item.reconciled" &&
          existing.at === receipt.at &&
          existing.actor?.kind === "operations_worker" &&
          validId(existing.actor?.id) &&
          hashValue(existing.payload) === hashValue(receipt.payload),
        "ACTION_CONFLICT",
        `Reconciliation action ${receipt.actionId} does not match its receipt.`
      );
      return existing;
    }
    return this.recordAction(
      item.runId,
      "work_item.reconciled",
      receipt.payload,
      leaseSession,
      {actionId: receipt.actionId, at: receipt.at}
    );
  }

  async recordAction(runId, type, payload = {}, leaseSession = null, {actionId: requestedActionId, at: requestedAt} = {}) {
    const at = requestedAt ?? this.now();
    const actionId = requestedActionId ??
      `action-${at.replace(/[^0-9]/g, "")}-${shortHash({runId, type, payload, at, nonce: crypto.randomUUID()})}`;
    const action = {
      schemaVersion: 1,
      actionId,
      runId,
      type,
      at,
      actor: {kind: "operations_worker", id: this.workerId},
      payload,
    };
    return this.store.appendAction(
      action,
      leaseSession ? await leaseSession.writeOptions() : {}
    );
  }

  async failRun(runId, error, leaseSession = null) {
    if (["LEASE_LOST", "LEASE_EXPIRED"].includes(error?.code)) return;
    const run = await this.store.getRun(runId);
    if (!run) return;
    if (run.status === "completed") return;
    const options = leaseSession ? await leaseSession.writeOptions().catch(() => null) : {};
    if (options === null) return;
    await this.store.updateRun(runId, (current) => ({
      ...current,
      status: "failed",
      updatedAt: this.now(),
      failure: {
        code: error?.code ?? "INTERNAL_ERROR",
        message: error instanceof Error ? error.message : String(error),
      },
    }), options).catch(() => undefined);
    await this.recordAction(runId, "run.failed", {
      code: error?.code ?? "INTERNAL_ERROR",
      message: error instanceof Error ? error.message : String(error),
    }, leaseSession).catch(() => undefined);
  }

  async withRunLease(runId, work) {
    const lease = await this.store.acquireLease(`run:${runId}`, {
      owner: this.workerId,
      ttlMs: LEASE_TTL_MS,
      now: this.leaseNow(),
    });
    const session = new LeaseSession({
      store: this.store,
      lease,
      ttlMs: LEASE_TTL_MS,
      clock: this.leaseClock,
    });
    session.start();
    try {
      return await work(session);
    } finally {
      await session.stop();
      await this.store.releaseLease(session.lease).catch(() => false);
    }
  }

  now() {
    return timestampFromClock(this.clock);
  }

  leaseNow() {
    return timestampFromClock(this.leaseClock);
  }
}

export function assertPersistedInventory(run, items, {
  requireCompletionSnapshot = run?.status === "completed",
} = {}) {
  assertRun(run);
  invariant(Array.isArray(items), "INVENTORY_INTEGRITY_VIOLATION",
    "Run inventory must be an array.");
  const ids = new Set();
  for (const item of items) {
    assertWorkItem(item);
    invariant(
      item.runId === run.runId && item.workflowId === run.workflowId,
      "INVENTORY_INTEGRITY_VIOLATION",
      `Work item ${item.workItemId} does not belong to run ${run.runId}.`,
      {runId: run.runId, workItemId: item.workItemId}
    );
    invariant(
      !ids.has(item.workItemId),
      "INVENTORY_INTEGRITY_VIOLATION",
      `Run ${run.runId} repeats work item ${item.workItemId}.`,
      {runId: run.runId, workItemId: item.workItemId}
    );
    ids.add(item.workItemId);
  }
  const frozenLimit = run.plan?.budgets?.workItems ??
    run.budget?.limits?.workItems;
  invariant(
    Number.isSafeInteger(frozenLimit) &&
      items.length <= frozenLimit &&
      items.length <= MAX_WORK_ITEMS_PER_RUN,
    "INVENTORY_INTEGRITY_VIOLATION",
    `Run ${run.runId} inventory exceeds its frozen work-item capacity.`,
    {runId: run.runId, itemCount: items.length, frozenLimit}
  );
  if (requireCompletionSnapshot) {
    invariant(
      run.counters?.workItems === items.length &&
        run.budget?.consumed?.workItems === items.length &&
        typeof run.inventoryHash === "string" &&
        run.inventoryHash === inventoryContentHash(items),
      "INVENTORY_INTEGRITY_VIOLATION",
      `Completed run ${run.runId} inventory no longer matches its durable counters.`,
      {
        runId: run.runId,
        itemCount: items.length,
        counter: run.counters?.workItems ?? null,
        consumed: run.budget?.consumed?.workItems ?? null,
        expectedInventoryHash: run.inventoryHash ?? null,
        actualInventoryHash: inventoryContentHash(items),
      }
    );
  }
  return items;
}

export function inventoryContentHash(items) {
  return hashValue([...items]
    .sort((left, right) => left.workItemId.localeCompare(right.workItemId))
    .map((item) => {
      const comparable = {...item};
      delete comparable.leaseFencingToken;
      return comparable;
    }));
}

function assertWorkflowInventory(workflow, items) {
  invariant(typeof workflow?.assertWorkItem === "function",
    "INVALID_WORKFLOW", "Workflow item validator is required.");
  for (const item of items) workflow.assertWorkItem(item);
}

function assertPromotionCandidateSelection(inventory, candidates) {
  invariant(Array.isArray(candidates), "INVALID_WORKFLOW",
    "Workflow promotion candidate selection must return an array.");
  const byId = new Map(inventory.map((item) => [item.workItemId, item]));
  const ids = new Set();
  for (const candidate of candidates) {
    invariant(
      candidate &&
        !ids.has(candidate.workItemId) &&
        byId.has(candidate.workItemId) &&
        hashValue(candidate) === hashValue(byId.get(candidate.workItemId)),
      "INVALID_WORKFLOW",
      "Workflow promotion candidates must be unique members of the durable inventory."
    );
    ids.add(candidate.workItemId);
  }
  return candidates;
}

function runSnapshotActionCount(actions) {
  return actions.filter((action) =>
    action.type !== "promotion.receipt_created").length;
}

function terminalReviewState(lifecycleStatus, workflow) {
  return !workflow.lifecycleSemantics.activeStatuses.includes(
    lifecycleStatus
  );
}

function buildReconciliationSnapshotItem({sourceItem, runId, workflow, at}) {
  const outcome = workflow.reconcile(sourceItem, {now: at});
  const nextStage = outcome.primaryStage ?? sourceItem.primaryStage;
  const transitioned = transitionWorkItem(sourceItem, nextStage, {
    at,
    reason: outcome.reasons?.[0] ?? "reconciliation_snapshot",
    taskFlags: sourceItem.taskFlags,
    blockers: sourceItem.blockers,
    allowedTransitions: workflow.allowedTransitions,
  });
  const lifecycleStatus = outcome.lifecycleStatus ??
    sourceItem.lifecycleStatus;
  const terminal = terminalReviewState(lifecycleStatus, workflow);
  const taskFlags = uniqueSorted([
    ...sourceItem.taskFlags,
    ...(outcome.taskFlags ?? []),
  ]).filter((flag) => !terminal || flag !== "human_review_required");
  const blockers = uniqueSorted([
    ...sourceItem.blockers,
    ...(outcome.blockers ?? []),
  ]).filter((code) => !terminal || code !== "human_review_required");
  const owner = terminal ? "system" :
    (outcome.owner ?? sourceItem.owner);
  const changed = sourceItem.primaryStage !== nextStage ||
    sourceItem.lifecycleStatus !== lifecycleStatus ||
    sourceItem.owner !== owner ||
    hashValue(sourceItem.taskFlags) !== hashValue(taskFlags) ||
    hashValue(sourceItem.blockers) !== hashValue(blockers);
  const reasons = uniqueSorted([
    ...(outcome.reasons ?? []),
    ...(terminal && sourceItem.owner === "human" ?
      ["terminal_review_cleanup"] : []),
    ...(hashValue(sourceItem.blockers) !== hashValue(blockers) ?
      ["blocker_projection_repair"] : []),
  ]);
  const workItemId = safeId(
    `wi-${shortHash({runId, sourceWorkItemId: sourceItem.workItemId})}` +
      `-${sourceItem.entityKind}-${sourceItem.sourceEntity.id}`
  );
  const item = {
    ...transitioned,
    workItemId,
    runId,
    primaryStage: nextStage,
    lifecycleStatus,
    taskFlags,
    blockers,
    owner,
    createdAt: at,
    updatedAt: at,
    timestamps: {
      ...sourceItem.timestamps,
      createdAt: at,
      updatedAt: at,
    },
    reconciliationOf: {
      runId: sourceItem.runId,
      workItemId: sourceItem.workItemId,
      revision: sourceItem.revision ?? 0,
      stateHash: reconciliationStateHash(sourceItem),
    },
  };
  delete item.revision;
  delete item.leaseFencingToken;
  delete item.reconciliationReceipt;
  const stateHash = reconciliationStateHash(item);
  const payload = {
    workItemId,
    sourceWorkItemId: sourceItem.workItemId,
    lifecycleStatus,
    changed,
    reasons,
  };
  item.reconciliationReceipt = {
    schemaVersion: 1,
    actionId: `action-reconcile-${shortHash({
      runId,
      workItemId,
      at,
      stateHash,
    })}`,
    at,
    stateHash,
    payload,
  };
  return item;
}

function reconciliationResult({
  run,
  sourceRun,
  items,
  workflow,
  idempotentReplay,
}) {
  const receipts = items.map((item) => item.reconciliationReceipt?.payload);
  invariant(receipts.every(Boolean), "RECONCILIATION_RECEIPT_CONFLICT",
    "Every reconciliation snapshot item requires immutable lineage evidence.");
  return {
    schemaVersion: 1,
    run,
    runId: run.runId,
    sourceRunId: sourceRun.runId,
    reconciledAt: run.completedAt,
    idempotentReplay,
    examined: items.length,
    expired: receipts.filter((receipt) =>
      workflow.lifecycleSemantics.expiredStatuses.includes(
        receipt.lifecycleStatus
      )).length,
    staleEvidence: receipts.filter((receipt) =>
      receipt.reasons.includes("evidence_stale")).length,
    unchanged: receipts.filter((receipt) => !receipt.changed).length,
  };
}

function assertWorkflowLifecycleSemantics(workflow) {
  const statuses = new Set(Array.isArray(workflow.lifecycleStatuses) ?
    workflow.lifecycleStatuses : []);
  const semantics = workflow.lifecycleSemantics;
  const groups = [
    semantics?.activeStatuses,
    semantics?.publishedStatuses,
    semantics?.expiredStatuses,
  ];
  invariant(
    groups.every((group) => Array.isArray(group) &&
      group.every((status) => statuses.has(status))) &&
      semantics.activeStatuses.length > 0,
    "INVALID_WORKFLOW",
    "Workflow lifecycle semantics must reference its declared statuses."
  );
  const active = new Set(semantics.activeStatuses);
  const published = new Set(semantics.publishedStatuses);
  invariant(
    semantics.publishedStatuses.every((status) => !active.has(status)) &&
      semantics.expiredStatuses.every((status) =>
        !active.has(status) && !published.has(status)),
    "INVALID_WORKFLOW",
    "Workflow lifecycle semantic categories must be disjoint."
  );
  return semantics;
}

function reconciliationStateHash(item) {
  return hashValue({
    runId: item.runId,
    workItemId: item.workItemId,
    lifecycleStatus: item.lifecycleStatus,
    taskFlags: uniqueSorted(item.taskFlags),
    blockers: uniqueSorted(item.blockers),
    owner: item.owner,
    updatedAt: item.updatedAt,
  });
}

function timestampFromClock(clock) {
  const value = clock();
  const date = value instanceof Date ? value : new Date(value);
  invariant(!Number.isNaN(date.valueOf()), "INVALID_CLOCK", "Clock returned an invalid timestamp.");
  return date.toISOString();
}

class LeaseSession {
  constructor({store, lease, ttlMs, clock}) {
    this.store = store;
    this.lease = lease;
    this.ttlMs = ttlMs;
    this.clock = clock;
    this.timer = null;
    this.renewing = Promise.resolve();
    this.lost = null;
  }

  start() {
    this.timer = setInterval(() => {
      this.heartbeat({force: true}).catch((error) => {
        this.lost = error;
      });
    }, Math.max(1_000, Math.floor(this.ttlMs / 3)));
    this.timer.unref?.();
  }

  async heartbeat({force = false} = {}) {
    if (this.lost) throw this.lost;
    this.renewing = this.renewing.then(async () => {
      if (this.lost) throw this.lost;
      const now = this.now();
      const remaining = Date.parse(this.lease.expiresAt) - Date.parse(now);
      if (force || remaining <= Math.floor(this.ttlMs / 2)) {
        this.lease = await this.store.renewLease(this.lease, {ttlMs: this.ttlMs, now});
      }
    }).catch((error) => {
      this.lost = error;
      throw error;
    });
    return this.renewing;
  }

  async writeOptions() {
    await this.heartbeat();
    if (this.lost) throw this.lost;
    return {lease: this.lease, now: this.now()};
  }

  async stop() {
    if (this.timer) clearInterval(this.timer);
    await this.renewing.catch(() => undefined);
  }

  now() {
    const value = this.clock();
    const date = value instanceof Date ? value : new Date(value);
    invariant(!Number.isNaN(date.valueOf()), "INVALID_CLOCK", "Clock returned an invalid timestamp.");
    return date.toISOString();
  }
}

function buildPlannedRun({runId, workflow, plan, planHash, createdAt}) {
  return assertRun({
    schemaVersion: 1,
    runId,
    workflowId: workflow.workflowId,
    workflowVersion: workflow.version,
    planId: plan.planId,
    planHash,
    plan,
    mode: "shadow",
    status: "planned",
    createdAt,
    updatedAt: createdAt,
    startedAt: null,
    completedAt: null,
    budget: new BudgetLedger({limits: plan.budgets}).snapshot(),
    counters: {workItems: 0, actions: 0},
    capabilities: {...plan.capabilities},
  });
}

function assertRunMatchesPlan(run, plan, workflow) {
  invariant(
    run.workflowId === workflow.workflowId &&
      run.workflowVersion === workflow.version &&
      run.planId === plan.planId &&
      run.planHash === planHashFor(plan),
    "IDEMPOTENCY_CONFLICT",
    "The idempotency mapping points to a run with different workflow or plan content.",
    {
      runId: run.runId,
      expected: {
        workflowId: workflow.workflowId,
        workflowVersion: workflow.version,
        planId: plan.planId,
        planHash: planHashFor(plan),
      },
      actual: {
        workflowId: run.workflowId,
        workflowVersion: run.workflowVersion,
        planId: run.planId,
        planHash: run.planHash,
      },
    }
  );
}

function assertPersistedRunPlan(run, workflow) {
  assertRun(run);
  workflow.assertPlan(run.plan);
  const canonicalBudget = new BudgetLedger({
    limits: run.plan.budgets,
    consumed: run.budget?.consumed ?? {},
  }).snapshot();
  invariant(
    run.workflowId === workflow.workflowId &&
      run.workflowVersion === workflow.version &&
      run.planId === run.plan.planId &&
      run.planHash === planHashFor(run.plan) &&
      run.mode === run.plan.mode &&
      hashValue(run.capabilities) === hashValue(run.plan.capabilities) &&
      hashValue(run.budget) === hashValue(canonicalBudget),
    "RUN_PLAN_CORRUPT",
    `Run ${run.runId} no longer matches its frozen plan, capabilities, or budget.`,
    {runId: run.runId}
  );
}

function assertPromotionReceiptMatches(receipt, content, receiptId, receiptHash) {
  invariant(
    receipt && typeof receipt === "object",
    "PROMOTION_RECEIPT_CONFLICT",
    "Promotion receipt is missing."
  );
  const comparable = {...receipt};
  delete comparable.leaseFencingToken;
  const expected = {...content, receiptId, receiptHash};
  invariant(
    hashValue(comparable) === hashValue(expected),
    "PROMOTION_RECEIPT_CONFLICT",
    `Promotion receipt ${receiptId} does not match its hash-bound safety evidence.`
  );
}

function defaultWorkerId() {
  return `local-${process.pid}-${crypto.randomUUID().slice(0, 8)}`;
}

function planHashFor(plan) {
  return plan.planContentHash ?? hashValue(plan);
}
