import {
  OperationActionReceipt,
  OperationDecision,
  OperationLease,
  OperationPublicationPlan,
  OperationRuleEvaluation,
  OperationRuleProposal,
  OperationRun,
  OperationWorkItem,
  WorkItemLifecycleStatus,
  WorkItemPrimaryStage,
} from "./models";

export interface ListPage<T> {
  items: T[];
  nextCursor: string | null;
}

export interface RunListQuery {
  workflowId?: string;
  status?: OperationRun["status"];
  limit: number;
  cursor?: string | null;
}

export interface WorkItemListQuery {
  workflowId?: string;
  runId?: string;
  primaryStage?: WorkItemPrimaryStage;
  entityKind?: string;
  lifecycleStatus?: WorkItemLifecycleStatus;
  limit: number;
  cursor?: string | null;
}

export interface ActionReceiptListQuery {
  runId?: string;
  workItemId?: string;
  limit: number;
  cursor?: string | null;
}

export interface DecisionListQuery {
  runId?: string;
  workItemId?: string;
  status?: OperationDecision["status"];
  limit: number;
  cursor?: string | null;
}

export interface OperationRunRepository {
  createRun(run: OperationRun): Promise<OperationRun>;
  getRun(runId: string): Promise<OperationRun | null>;
  saveRun(run: OperationRun, expectedRevision: number):
    Promise<OperationRun>;
  listRuns(query: RunListQuery): Promise<ListPage<OperationRun>>;
}

export interface OperationWorkItemRepository {
  createWorkItem(workItem: OperationWorkItem): Promise<OperationWorkItem>;
  getWorkItem(workItemId: string): Promise<OperationWorkItem | null>;
  saveWorkItem(workItem: OperationWorkItem, expectedRevision: number):
    Promise<OperationWorkItem>;
  listWorkItems(query: WorkItemListQuery):
    Promise<ListPage<OperationWorkItem>>;
}

export interface OperationActionReceiptRepository {
  appendActionReceipt(receipt: OperationActionReceipt):
    Promise<OperationActionReceipt>;
  getActionReceipt(actionId: string): Promise<OperationActionReceipt | null>;
  findActionReceiptByIdempotencyKey(
    runId: string,
    workItemId: string,
    idempotencyKey: string
  ): Promise<OperationActionReceipt | null>;
  listActionReceipts(query: ActionReceiptListQuery):
    Promise<ListPage<OperationActionReceipt>>;
}

export interface OperationDecisionRepository {
  appendDecision(decision: OperationDecision): Promise<OperationDecision>;
  getDecision(decisionId: string): Promise<OperationDecision | null>;
  listDecisions(query: DecisionListQuery):
    Promise<ListPage<OperationDecision>>;
}

export interface AcquireLeaseInput {
  leaseId: string;
  resourceType: OperationLease["resourceType"];
  resourceId: string;
  ownerId: string;
  idempotencyKey: string;
  acquiredAt: string;
  expiresAt: string;
}

export interface HeartbeatLeaseInput {
  leaseId: string;
  ownerId: string;
  fencingToken: number;
  heartbeatAt: string;
  expiresAt: string;
}

export interface ReleaseLeaseInput {
  leaseId: string;
  ownerId: string;
  fencingToken: number;
  releasedAt: string;
}

export interface OperationLeaseRepository {
  acquireLease(input: AcquireLeaseInput): Promise<OperationLease>;
  heartbeatLease(input: HeartbeatLeaseInput): Promise<OperationLease>;
  releaseLease(input: ReleaseLeaseInput): Promise<OperationLease>;
  getLease(leaseId: string): Promise<OperationLease | null>;
}

export interface OperationPublicationPlanRepository {
  createPublicationPlan(plan: OperationPublicationPlan):
    Promise<OperationPublicationPlan>;
  getPublicationPlan(publicationPlanId: string):
    Promise<OperationPublicationPlan | null>;
  savePublicationPlan(
    plan: OperationPublicationPlan,
    expectedRevision: number
  ): Promise<OperationPublicationPlan>;
}

export interface OperationLearningRepository {
  createRuleProposal(proposal: OperationRuleProposal):
    Promise<OperationRuleProposal>;
  getRuleProposal(ruleProposalId: string):
    Promise<OperationRuleProposal | null>;
  saveRuleProposal(proposal: OperationRuleProposal, expectedRevision: number):
    Promise<OperationRuleProposal>;
  appendRuleEvaluation(evaluation: OperationRuleEvaluation):
    Promise<OperationRuleEvaluation>;
  listRuleEvaluations(ruleProposalId: string):
    Promise<OperationRuleEvaluation[]>;
}

export interface OperationsRepository extends
  OperationRunRepository,
  OperationWorkItemRepository,
  OperationActionReceiptRepository,
  OperationDecisionRepository,
  OperationLeaseRepository,
  OperationPublicationPlanRepository,
  OperationLearningRepository {}
