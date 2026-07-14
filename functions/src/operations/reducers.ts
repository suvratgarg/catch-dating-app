import {OperationConflictError, OperationDomainError} from "./errors";
import {
  OperationActionReceipt,
  OperationActor,
  OperationFailure,
  OperationRun,
  OperationWorkItem,
  WorkItemLifecycleStatus,
  WorkItemOutcome,
} from "./models";
import {
  validateOperationRun,
  validateOperationWorkItem,
} from "./validation";
import {WorkItemStagePolicy} from "./workflowPolicy";

export interface WorkItemTransitionCommand {
  actionId: string;
  sequence: number;
  expectedRevision: number;
  targetStage: string;
  operation: string;
  actor: OperationActor;
  idempotencyKey: string;
  inputHash: string;
  outputHash: string;
  rulesetVersion: string;
  modelVersion: string | null;
  reasonCodes: string[];
  occurredAt: string;
  addTaskFlags?: string[];
  removeTaskFlags?: string[];
  blockerCodes?: string[];
  warningCodes?: string[];
  decisionId?: string | null;
  publicationPlanId?: string | null;
}

export interface WorkItemTransitionResult {
  workItem: OperationWorkItem;
  receipt: OperationActionReceipt;
}

export function reduceWorkItemTransition(
  current: OperationWorkItem,
  command: WorkItemTransitionCommand,
  policy: WorkItemStagePolicy
): WorkItemTransitionResult {
  const currentValidation = validateOperationWorkItem(current);
  if (!currentValidation.ok) {
    throw new OperationDomainError(
      "invalid_current_work_item",
      currentValidation.issues.map((issue) => issue.code).join(", ")
    );
  }
  if (current.workflowId !== policy.workflowId) {
    throw new OperationDomainError(
      "workflow_policy_mismatch",
      `Policy ${policy.workflowId} cannot reduce ${current.workflowId}`
    );
  }
  if (current.revision !== command.expectedRevision) {
    throw new OperationConflictError(
      "revision_conflict",
      `Expected revision ${command.expectedRevision}; found ${current.revision}`
    );
  }
  if (["published", "terminal"].includes(current.lifecycleStatus)) {
    throw new OperationDomainError(
      "terminal_work_item",
      `Lifecycle ${current.lifecycleStatus} cannot re-enter review`
    );
  }
  const target = policy.stages[command.targetStage];
  if (!target) {
    throw new OperationDomainError(
      "unknown_target_stage",
      `Stage ${command.targetStage} is not defined by the workflow`
    );
  }
  const sameStage = current.primaryStage === command.targetStage;
  const allowed = policy.transitions[current.primaryStage] ?? [];
  if (!sameStage && !allowed.includes(command.targetStage)) {
    throw new OperationDomainError(
      "stage_transition_not_allowed",
      `${current.primaryStage} cannot transition to ${command.targetStage}`
    );
  }
  const additions = new Set(command.addTaskFlags ?? []);
  const removals = new Set(command.removeTaskFlags ?? []);
  for (const flag of additions) {
    if (removals.has(flag)) {
      throw new OperationDomainError(
        "task_flag_conflict",
        `Task flag ${flag} cannot be added and removed together`
      );
    }
  }
  const taskFlags = new Set(current.taskFlags);
  additions.forEach((flag) => taskFlags.add(flag));
  removals.forEach((flag) => taskFlags.delete(flag));
  const blockerCodes = [...new Set(
    command.blockerCodes ?? current.blockerCodes
  )].sort();
  const warningCodes = [...new Set(
    command.warningCodes ?? current.warningCodes
  )].sort();
  const decisionId = command.decisionId === undefined ?
    current.decisionId : command.decisionId;
  const publicationPlanId = command.publicationPlanId === undefined ?
    current.publicationPlanId : command.publicationPlanId;

  const gatesFailed =
    (target.requiresNoBlockers && blockerCodes.length > 0) ||
    (target.requiresDecision && decisionId === null) ||
    (target.requiresPublicationPlan && publicationPlanId === null);
  if (gatesFailed) {
    throw new OperationDomainError(
      target.gateErrorCode ?? "stage_gates_not_met",
      target.gateErrorMessage ??
        `Stage ${command.targetStage} requirements are not met`
    );
  }

  const workItem: OperationWorkItem = {
    ...current,
    revision: current.revision + 1,
    primaryStage: command.targetStage as OperationWorkItem["primaryStage"],
    lifecycleStatus: target.lifecycleStatus,
    outcome: null,
    taskFlags: [...taskFlags].sort(),
    blockerCodes,
    warningCodes,
    decisionId,
    publicationPlanId,
    updatedAt: command.occurredAt,
  };
  const nextValidation = validateOperationWorkItem(workItem);
  if (!nextValidation.ok) {
    throw new OperationDomainError(
      "invalid_reduced_work_item",
      nextValidation.issues.map((issue) => issue.code).join(", ")
    );
  }
  return {
    workItem,
    receipt: {
      schemaVersion: 1,
      actionId: command.actionId,
      runId: current.runId,
      workItemId: current.workItemId,
      sequence: command.sequence,
      operation: command.operation,
      status: "succeeded",
      fromRevision: current.revision,
      toRevision: workItem.revision,
      actor: command.actor,
      idempotencyKey: command.idempotencyKey,
      inputHash: command.inputHash,
      outputHash: command.outputHash,
      rulesetVersion: command.rulesetVersion,
      modelVersion: command.modelVersion,
      reasonCodes: [...new Set(command.reasonCodes)].sort(),
      occurredAt: command.occurredAt,
      completedAt: command.occurredAt,
      failure: null,
    },
  };
}

export interface WorkItemLifecycleCommand {
  actionId: string;
  sequence: number;
  expectedRevision: number;
  targetOutcome: WorkItemOutcome;
  operation: string;
  actor: OperationActor;
  idempotencyKey: string;
  inputHash: string;
  outputHash: string;
  rulesetVersion: string;
  modelVersion: string | null;
  reasonCodes: string[];
  occurredAt: string;
  decisionId?: string | null;
  publicationPlanId?: string | null;
}

export function reduceWorkItemLifecycle(
  current: OperationWorkItem,
  command: WorkItemLifecycleCommand,
  policy: WorkItemStagePolicy
): WorkItemTransitionResult {
  const currentValidation = validateOperationWorkItem(current);
  if (!currentValidation.ok) {
    throw new OperationDomainError(
      "invalid_current_work_item",
      currentValidation.issues.map((issue) => issue.code).join(", ")
    );
  }
  if (current.revision !== command.expectedRevision) {
    throw new OperationConflictError(
      "revision_conflict",
      `Expected revision ${command.expectedRevision}; found ${current.revision}`
    );
  }
  if (current.workflowId !== policy.workflowId) {
    throw new OperationDomainError(
      "workflow_policy_mismatch",
      `Policy ${policy.workflowId} cannot reduce ${current.workflowId}`
    );
  }
  if (current.lifecycleStatus === "terminal") {
    throw new OperationDomainError(
      "terminal_work_item",
      "Terminal work items are immutable"
    );
  }
  const decisionId = command.decisionId === undefined ?
    current.decisionId : command.decisionId;
  const publicationPlanId = command.publicationPlanId === undefined ?
    current.publicationPlanId : command.publicationPlanId;
  const publication = policy.publication;
  if (publication && command.targetOutcome === publication.outcome) {
    const stage = policy.stages[current.primaryStage];
    if (!publication.readyStages.includes(current.primaryStage) ||
        stage?.lifecycleStatus !== current.lifecycleStatus ||
        (publication.requiresDecision && decisionId === null) ||
        (publication.requiresPublicationPlan && publicationPlanId === null)) {
      throw new OperationDomainError(
        "publication_receipt_required",
        "Publishing requires ready review, decision, and publication receipts"
      );
    }
  } else if (current.lifecycleStatus === "published") {
    if (!publication?.followupOutcomes.includes(command.targetOutcome)) {
      throw new OperationDomainError(
        "lifecycle_transition_not_allowed",
        `Published work cannot transition to ${command.targetOutcome}`
      );
    }
  } else if (publication?.publishedOnlyOutcomes.includes(
    command.targetOutcome
  )) {
    throw new OperationDomainError(
      "lifecycle_transition_not_allowed",
      "Only published work can be taken down"
    );
  }
  const lifecycleStatus: WorkItemLifecycleStatus =
    publication && command.targetOutcome === publication.outcome ?
      "published" : "terminal";
  const workItem: OperationWorkItem = {
    ...current,
    revision: current.revision + 1,
    lifecycleStatus,
    outcome: command.targetOutcome,
    decisionId,
    publicationPlanId,
    updatedAt: command.occurredAt,
  };
  const nextValidation = validateOperationWorkItem(workItem);
  if (!nextValidation.ok) {
    throw new OperationDomainError(
      "invalid_reduced_work_item",
      nextValidation.issues.map((issue) => issue.code).join(", ")
    );
  }
  return {
    workItem,
    receipt: actionReceipt(current, workItem, command),
  };
}

function actionReceipt(
  current: OperationWorkItem,
  workItem: OperationWorkItem,
  command: WorkItemLifecycleCommand
): OperationActionReceipt {
  return {
    schemaVersion: 1,
    actionId: command.actionId,
    runId: current.runId,
    workItemId: current.workItemId,
    sequence: command.sequence,
    operation: command.operation,
    status: "succeeded",
    fromRevision: current.revision,
    toRevision: workItem.revision,
    actor: command.actor,
    idempotencyKey: command.idempotencyKey,
    inputHash: command.inputHash,
    outputHash: command.outputHash,
    rulesetVersion: command.rulesetVersion,
    modelVersion: command.modelVersion,
    reasonCodes: [...new Set(command.reasonCodes)].sort(),
    occurredAt: command.occurredAt,
    completedAt: command.occurredAt,
    failure: null,
  };
}

const RUN_TRANSITIONS: Readonly<
  Record<OperationRun["status"], readonly OperationRun["status"][]>
  > = {
    planned: ["queued", "cancelled"],
    queued: ["running", "cancelled"],
    running: ["paused", "completed", "failed", "cancelled"],
    paused: ["queued", "running", "cancelled"],
    completed: [],
    failed: [],
    cancelled: [],
  };

export interface RunTransitionCommand {
  expectedRevision: number;
  targetStatus: OperationRun["status"];
  occurredAt: string;
  failure?: OperationFailure | null;
}

export function reduceRunTransition(
  current: OperationRun,
  command: RunTransitionCommand
): OperationRun {
  const validation = validateOperationRun(current);
  if (!validation.ok) {
    throw new OperationDomainError(
      "invalid_current_run",
      validation.issues.map((issue) => issue.code).join(", ")
    );
  }
  if (current.revision !== command.expectedRevision) {
    throw new OperationConflictError(
      "revision_conflict",
      `Expected revision ${command.expectedRevision}; found ${current.revision}`
    );
  }
  if (!RUN_TRANSITIONS[current.status].includes(command.targetStatus)) {
    throw new OperationDomainError(
      "run_transition_not_allowed",
      `${current.status} cannot transition to ${command.targetStatus}`
    );
  }
  const isTerminal = ["completed", "failed", "cancelled"].includes(
    command.targetStatus
  );
  const next: OperationRun = {
    ...current,
    revision: current.revision + 1,
    status: command.targetStatus,
    updatedAt: command.occurredAt,
    startedAt: command.targetStatus === "running" && !current.startedAt ?
      command.occurredAt : current.startedAt,
    finishedAt: isTerminal ? command.occurredAt : null,
    failure: command.targetStatus === "failed" ?
      command.failure ?? null : null,
  };
  const nextValidation = validateOperationRun(next);
  if (!nextValidation.ok) {
    throw new OperationDomainError(
      "invalid_reduced_run",
      nextValidation.issues.map((issue) => issue.code).join(", ")
    );
  }
  return next;
}
