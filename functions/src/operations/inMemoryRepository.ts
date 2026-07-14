import {
  OperationConflictError,
  OperationDomainError,
  OperationNotFoundError,
} from "./errors";
import {
  OperationActionReceipt,
  OperationDecision,
  OperationLease,
  OperationPublicationPlan,
  OperationRuleEvaluation,
  OperationRuleProposal,
  OperationRun,
  OperationWorkItem,
} from "./models";
import {
  AcquireLeaseInput,
  ActionReceiptListQuery,
  DecisionListQuery,
  HeartbeatLeaseInput,
  ListPage,
  OperationsRepository,
  ReleaseLeaseInput,
  RunListQuery,
  WorkItemListQuery,
} from "./repositories";
import {
  validateOperationActionReceipt,
  validateOperationDecision,
  validateOperationLease,
  validateOperationPublicationPlan,
  validateOperationRuleEvaluation,
  validateOperationRuleProposal,
  validateOperationRun,
  validateOperationWorkItem,
  ValidationResult,
} from "./validation";

function clone<T>(value: T): T {
  return structuredClone(value);
}

function assertValid<T>(
  result: ValidationResult<T>,
  entity: string
): asserts result is {ok: true; value: T; issues: []} {
  if (!result.ok) {
    throw new OperationDomainError(
      "invalid_entity",
      `${entity} is invalid: ${result.issues.map((issue) =>
        `${issue.path}:${issue.code}`).join(", ")}`
    );
  }
}

function assertPageLimit(limit: number): void {
  if (!Number.isInteger(limit) || limit < 1 || limit > 200) {
    throw new OperationDomainError(
      "invalid_page_limit",
      "Page limit must be an integer between 1 and 200"
    );
  }
}

function pageById<T>(
  values: T[],
  getId: (value: T) => string,
  limit: number,
  cursor?: string | null
): ListPage<T> {
  assertPageLimit(limit);
  const sorted = values
    .filter((value) => !cursor || getId(value) > cursor)
    .sort((left, right) => getId(left).localeCompare(getId(right)));
  const items = sorted.slice(0, limit).map(clone);
  return {
    items,
    nextCursor: sorted.length > limit ? getId(items[items.length - 1]) : null,
  };
}

function assertCreateRevision(revision: number): void {
  if (revision !== 0) {
    throw new OperationDomainError(
      "invalid_initial_revision",
      "New versioned records must start at revision 0"
    );
  }
}

function assertSaveRevision(
  entity: string,
  id: string,
  storedRevision: number,
  expectedRevision: number,
  nextRevision: number
): void {
  if (storedRevision !== expectedRevision) {
    throw new OperationConflictError(
      "revision_conflict",
      `${entity} ${id} expected revision ${expectedRevision}; ` +
        `found ${storedRevision}`
    );
  }
  if (nextRevision !== expectedRevision + 1) {
    throw new OperationDomainError(
      "revision_not_incremented",
      `${entity} ${id} must increment revision exactly once`
    );
  }
}

export class InMemoryOperationsRepository implements OperationsRepository {
  private readonly runs = new Map<string, OperationRun>();
  private readonly workItems = new Map<string, OperationWorkItem>();
  private readonly actions = new Map<string, OperationActionReceipt>();
  private readonly actionIdempotency = new Map<string, string>();
  private readonly decisions = new Map<string, OperationDecision>();
  private readonly leases = new Map<string, OperationLease>();
  private readonly leaseIdempotency = new Map<string, string>();
  private readonly publicationPlans =
    new Map<string, OperationPublicationPlan>();
  private readonly ruleProposals = new Map<string, OperationRuleProposal>();
  private readonly ruleEvaluations =
    new Map<string, OperationRuleEvaluation>();

  async createRun(run: OperationRun): Promise<OperationRun> {
    assertValid(validateOperationRun(run), "run");
    assertCreateRevision(run.revision);
    this.assertAbsent(this.runs, "run", run.runId);
    this.runs.set(run.runId, clone(run));
    return clone(run);
  }

  async getRun(runId: string): Promise<OperationRun | null> {
    return this.cloneOrNull(this.runs.get(runId));
  }

  async saveRun(run: OperationRun, expectedRevision: number):
    Promise<OperationRun> {
    assertValid(validateOperationRun(run), "run");
    const stored = this.required(this.runs, "run", run.runId);
    assertSaveRevision(
      "run", run.runId, stored.revision, expectedRevision, run.revision
    );
    this.runs.set(run.runId, clone(run));
    return clone(run);
  }

  async listRuns(query: RunListQuery): Promise<ListPage<OperationRun>> {
    const values = [...this.runs.values()].filter((run) =>
      (!query.workflowId || run.workflowId === query.workflowId) &&
      (!query.status || run.status === query.status)
    );
    return pageById(values, (run) => run.runId, query.limit, query.cursor);
  }

  async createWorkItem(workItem: OperationWorkItem):
    Promise<OperationWorkItem> {
    assertValid(validateOperationWorkItem(workItem), "work item");
    assertCreateRevision(workItem.revision);
    this.assertAbsent(this.workItems, "work item", workItem.workItemId);
    this.workItems.set(workItem.workItemId, clone(workItem));
    return clone(workItem);
  }

  async getWorkItem(workItemId: string): Promise<OperationWorkItem | null> {
    return this.cloneOrNull(this.workItems.get(workItemId));
  }

  async saveWorkItem(
    workItem: OperationWorkItem,
    expectedRevision: number
  ): Promise<OperationWorkItem> {
    assertValid(validateOperationWorkItem(workItem), "work item");
    const stored = this.required(
      this.workItems,
      "work item",
      workItem.workItemId
    );
    assertSaveRevision(
      "work item",
      workItem.workItemId,
      stored.revision,
      expectedRevision,
      workItem.revision
    );
    this.workItems.set(workItem.workItemId, clone(workItem));
    return clone(workItem);
  }

  async listWorkItems(query: WorkItemListQuery):
    Promise<ListPage<OperationWorkItem>> {
    const values = [...this.workItems.values()].filter((item) =>
      (!query.workflowId || item.workflowId === query.workflowId) &&
      (!query.runId || item.runId === query.runId) &&
      (!query.primaryStage || item.primaryStage === query.primaryStage) &&
      (!query.entityKind || item.entityKind === query.entityKind) &&
      (!query.lifecycleStatus ||
        item.lifecycleStatus === query.lifecycleStatus)
    );
    return pageById(
      values,
      (item) => item.workItemId,
      query.limit,
      query.cursor
    );
  }

  async appendActionReceipt(receipt: OperationActionReceipt):
    Promise<OperationActionReceipt> {
    assertValid(validateOperationActionReceipt(receipt), "action receipt");
    const idempotencyScope = this.actionIdempotencyScope(receipt);
    const idempotentActionId = this.actionIdempotency.get(idempotencyScope);
    if (idempotentActionId) {
      const existing = this.required(
        this.actions,
        "action receipt",
        idempotentActionId
      );
      if (existing.operation !== receipt.operation ||
          existing.inputHash !== receipt.inputHash) {
        throw new OperationConflictError(
          "idempotency_conflict",
          "An idempotency key cannot be reused for different action input"
        );
      }
      return clone(existing);
    }
    this.assertAbsent(this.actions, "action receipt", receipt.actionId);
    const sequence = Math.max(0, ...[...this.actions.values()]
      .filter((action) => action.workItemId === receipt.workItemId)
      .map((action) => action.sequence));
    if (receipt.sequence !== sequence + 1) {
      throw new OperationConflictError(
        "action_sequence_conflict",
        `Expected action sequence ${sequence + 1}; found ${receipt.sequence}`
      );
    }
    this.actions.set(receipt.actionId, clone(receipt));
    this.actionIdempotency.set(idempotencyScope, receipt.actionId);
    return clone(receipt);
  }

  async getActionReceipt(actionId: string):
    Promise<OperationActionReceipt | null> {
    return this.cloneOrNull(this.actions.get(actionId));
  }

  async findActionReceiptByIdempotencyKey(
    runId: string,
    workItemId: string,
    idempotencyKey: string
  ): Promise<OperationActionReceipt | null> {
    const id = this.actionIdempotency.get(
      `${runId}:${workItemId}:${idempotencyKey}`
    );
    return id ? this.cloneOrNull(this.actions.get(id)) : null;
  }

  async listActionReceipts(query: ActionReceiptListQuery):
    Promise<ListPage<OperationActionReceipt>> {
    const values = [...this.actions.values()].filter((receipt) =>
      (!query.runId || receipt.runId === query.runId) &&
      (!query.workItemId || receipt.workItemId === query.workItemId)
    );
    return pageById(
      values,
      (receipt) => receipt.actionId,
      query.limit,
      query.cursor
    );
  }

  async appendDecision(decision: OperationDecision):
    Promise<OperationDecision> {
    assertValid(validateOperationDecision(decision), "decision");
    const existing = this.decisions.get(decision.decisionId);
    if (existing) {
      if (JSON.stringify(existing) !== JSON.stringify(decision)) {
        throw new OperationConflictError(
          "immutable_decision_conflict",
          `Decision ${decision.decisionId} is immutable`
        );
      }
      return clone(existing);
    }
    this.decisions.set(decision.decisionId, clone(decision));
    return clone(decision);
  }

  async getDecision(decisionId: string): Promise<OperationDecision | null> {
    return this.cloneOrNull(this.decisions.get(decisionId));
  }

  async listDecisions(query: DecisionListQuery):
    Promise<ListPage<OperationDecision>> {
    const values = [...this.decisions.values()].filter((decision) =>
      (!query.runId || decision.runId === query.runId) &&
      (!query.workItemId || decision.workItemId === query.workItemId) &&
      (!query.status || decision.status === query.status)
    );
    return pageById(
      values,
      (decision) => decision.decisionId,
      query.limit,
      query.cursor
    );
  }

  async acquireLease(input: AcquireLeaseInput): Promise<OperationLease> {
    const idempotencyScope =
      `${input.resourceType}:${input.resourceId}:${input.idempotencyKey}`;
    const idempotentLeaseId = this.leaseIdempotency.get(idempotencyScope);
    if (idempotentLeaseId) {
      const existing = this.required(
        this.leases,
        "lease",
        idempotentLeaseId
      );
      if (existing.ownerId !== input.ownerId) {
        throw new OperationConflictError(
          "idempotency_conflict",
          "Lease idempotency key is owned by another worker"
        );
      }
      return clone(existing);
    }
    const resourceLeases = [...this.leases.values()].filter((lease) =>
      lease.resourceType === input.resourceType &&
      lease.resourceId === input.resourceId
    );
    const active = resourceLeases.find((lease) =>
      lease.status === "active" &&
      Date.parse(lease.expiresAt) > Date.parse(input.acquiredAt)
    );
    if (active) {
      throw new OperationConflictError(
        "lease_conflict",
        `Resource is leased by ${active.ownerId}`
      );
    }
    for (const expired of resourceLeases.filter((lease) =>
      lease.status === "active" &&
      Date.parse(lease.expiresAt) <= Date.parse(input.acquiredAt))) {
      this.leases.set(expired.leaseId, {...expired, status: "expired"});
    }
    this.assertAbsent(this.leases, "lease", input.leaseId);
    const fencingToken = Math.max(0, ...resourceLeases.map((lease) =>
      lease.fencingToken)) + 1;
    const lease: OperationLease = {
      schemaVersion: 1,
      leaseId: input.leaseId,
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      ownerId: input.ownerId,
      fencingToken,
      status: "active",
      idempotencyKey: input.idempotencyKey,
      acquiredAt: input.acquiredAt,
      heartbeatAt: input.acquiredAt,
      expiresAt: input.expiresAt,
      releasedAt: null,
    };
    assertValid(validateOperationLease(lease), "lease");
    this.leases.set(lease.leaseId, clone(lease));
    this.leaseIdempotency.set(idempotencyScope, lease.leaseId);
    return clone(lease);
  }

  async heartbeatLease(input: HeartbeatLeaseInput):
    Promise<OperationLease> {
    const lease = this.required(this.leases, "lease", input.leaseId);
    this.assertLeaseOwner(lease, input.ownerId, input.fencingToken);
    if (lease.status !== "active" ||
        Date.parse(lease.expiresAt) <= Date.parse(input.heartbeatAt)) {
      throw new OperationConflictError(
        "lease_expired",
        `Lease ${lease.leaseId} is no longer active`
      );
    }
    const next = {
      ...lease,
      heartbeatAt: input.heartbeatAt,
      expiresAt: input.expiresAt,
    };
    assertValid(validateOperationLease(next), "lease");
    this.leases.set(next.leaseId, clone(next));
    return clone(next);
  }

  async releaseLease(input: ReleaseLeaseInput): Promise<OperationLease> {
    const lease = this.required(this.leases, "lease", input.leaseId);
    this.assertLeaseOwner(lease, input.ownerId, input.fencingToken);
    if (lease.status !== "active") {
      throw new OperationConflictError(
        "lease_not_active",
        `Lease ${lease.leaseId} is not active`
      );
    }
    const next: OperationLease = {
      ...lease,
      status: "released",
      releasedAt: input.releasedAt,
    };
    assertValid(validateOperationLease(next), "lease");
    this.leases.set(next.leaseId, clone(next));
    return clone(next);
  }

  async getLease(leaseId: string): Promise<OperationLease | null> {
    return this.cloneOrNull(this.leases.get(leaseId));
  }

  async createPublicationPlan(plan: OperationPublicationPlan):
    Promise<OperationPublicationPlan> {
    assertValid(validateOperationPublicationPlan(plan), "publication plan");
    assertCreateRevision(plan.revision);
    this.assertAbsent(
      this.publicationPlans,
      "publication plan",
      plan.publicationPlanId
    );
    this.publicationPlans.set(plan.publicationPlanId, clone(plan));
    return clone(plan);
  }

  async getPublicationPlan(publicationPlanId: string):
    Promise<OperationPublicationPlan | null> {
    return this.cloneOrNull(this.publicationPlans.get(publicationPlanId));
  }

  async savePublicationPlan(
    plan: OperationPublicationPlan,
    expectedRevision: number
  ): Promise<OperationPublicationPlan> {
    assertValid(validateOperationPublicationPlan(plan), "publication plan");
    const stored = this.required(
      this.publicationPlans,
      "publication plan",
      plan.publicationPlanId
    );
    assertSaveRevision(
      "publication plan",
      plan.publicationPlanId,
      stored.revision,
      expectedRevision,
      plan.revision
    );
    if (stored.status === "applied") {
      throw new OperationDomainError(
        "applied_plan_immutable",
        "Applied publication plans cannot be changed"
      );
    }
    this.publicationPlans.set(plan.publicationPlanId, clone(plan));
    return clone(plan);
  }

  async createRuleProposal(proposal: OperationRuleProposal):
    Promise<OperationRuleProposal> {
    assertValid(validateOperationRuleProposal(proposal), "rule proposal");
    assertCreateRevision(proposal.revision);
    this.assertAbsent(
      this.ruleProposals,
      "rule proposal",
      proposal.ruleProposalId
    );
    this.ruleProposals.set(proposal.ruleProposalId, clone(proposal));
    return clone(proposal);
  }

  async getRuleProposal(ruleProposalId: string):
    Promise<OperationRuleProposal | null> {
    return this.cloneOrNull(this.ruleProposals.get(ruleProposalId));
  }

  async saveRuleProposal(
    proposal: OperationRuleProposal,
    expectedRevision: number
  ): Promise<OperationRuleProposal> {
    assertValid(validateOperationRuleProposal(proposal), "rule proposal");
    const stored = this.required(
      this.ruleProposals,
      "rule proposal",
      proposal.ruleProposalId
    );
    assertSaveRevision(
      "rule proposal",
      proposal.ruleProposalId,
      stored.revision,
      expectedRevision,
      proposal.revision
    );
    this.ruleProposals.set(proposal.ruleProposalId, clone(proposal));
    return clone(proposal);
  }

  async appendRuleEvaluation(evaluation: OperationRuleEvaluation):
    Promise<OperationRuleEvaluation> {
    assertValid(
      validateOperationRuleEvaluation(evaluation),
      "rule evaluation"
    );
    const proposal = this.required(
      this.ruleProposals,
      "rule proposal",
      evaluation.ruleProposalId
    );
    if (proposal.proposedBy.actorId === evaluation.evaluatedBy.actorId) {
      throw new OperationDomainError(
        "rule_evaluator_not_independent",
        "The proposing actor cannot independently evaluate its own rule"
      );
    }
    const existing = this.ruleEvaluations.get(evaluation.ruleEvaluationId);
    if (existing) {
      if (JSON.stringify(existing) !== JSON.stringify(evaluation)) {
        throw new OperationConflictError(
          "immutable_rule_evaluation_conflict",
          `Rule evaluation ${evaluation.ruleEvaluationId} is immutable`
        );
      }
      return clone(existing);
    }
    this.ruleEvaluations.set(evaluation.ruleEvaluationId, clone(evaluation));
    return clone(evaluation);
  }

  async listRuleEvaluations(ruleProposalId: string):
    Promise<OperationRuleEvaluation[]> {
    return [...this.ruleEvaluations.values()]
      .filter((evaluation) =>
        evaluation.ruleProposalId === ruleProposalId)
      .sort((left, right) =>
        left.evaluatedAt.localeCompare(right.evaluatedAt))
      .map(clone);
  }

  private actionIdempotencyScope(receipt: OperationActionReceipt): string {
    return `${receipt.runId}:${receipt.workItemId}:${receipt.idempotencyKey}`;
  }

  private assertLeaseOwner(
    lease: OperationLease,
    ownerId: string,
    fencingToken: number
  ): void {
    if (lease.ownerId !== ownerId || lease.fencingToken !== fencingToken) {
      throw new OperationConflictError(
        "lease_fencing_conflict",
        "Lease owner or fencing token is stale"
      );
    }
  }

  private assertAbsent<T>(
    values: Map<string, T>,
    entity: string,
    id: string
  ): void {
    if (values.has(id)) {
      throw new OperationConflictError(
        "already_exists",
        `${entity} ${id} already exists`
      );
    }
  }

  private required<T>(
    values: Map<string, T>,
    entity: string,
    id: string
  ): T {
    const value = values.get(id);
    if (!value) throw new OperationNotFoundError(entity, id);
    return value;
  }

  private cloneOrNull<T>(value: T | undefined): T | null {
    return value === undefined ? null : clone(value);
  }
}
