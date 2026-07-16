export const supplyIntakePrimaryStages = [
  "incoming",
  "verify",
  "resolve",
  "ready",
] as const;

export type SupplyIntakePrimaryStage =
  typeof supplyIntakePrimaryStages[number];

export type OperationEntityKind =
  | "event"
  | "organizer"
  | "source_result"
  | "source_profile";

export type OperationRunStatus =
  | "planned"
  | "queued"
  | "running"
  | "paused"
  | "completed"
  | "failed"
  | "cancelled";

export type OperationWorkItemLifecycleStatus =
  | "queued"
  | "in_progress"
  | "waiting"
  | "ready"
  | "published"
  | "terminal";

export interface OperationFailure {
  code: string;
  message: string;
  retryable: boolean;
}

export interface OperationRun {
  schemaVersion: 1;
  runId: string;
  workflowId: string;
  revision: number;
  mode: "shadow" | "assisted" | "autonomous";
  status: OperationRunStatus;
  scope: Record<string, unknown>;
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
  failure: OperationFailure | null;
  metadata: Record<string, unknown>;
}

export interface OperationEvidenceRef {
  artifactId: string;
  contentHash: string;
  observedAt: string;
  locator: string | null;
}

export interface OperationFieldProvenance {
  field: string;
  artifactId: string;
  contentHash: string;
  locator: string | null;
  extractedBy: "deterministic" | "model" | "human";
  extractorVersion: string;
  confidence: number | null;
}

export interface OperationWorkItem {
  schemaVersion: 1;
  workItemId: string;
  workflowId: string;
  runId: string;
  entityKind: OperationEntityKind;
  externalKey: string | null;
  revision: number;
  candidateHash: string;
  primaryStage: SupplyIntakePrimaryStage;
  lifecycleStatus: OperationWorkItemLifecycleStatus;
  outcome:
    | "published"
    | "rejected"
    | "expired"
    | "cancelled"
    | "taken_down"
    | null;
  taskFlags: string[];
  blockerCodes: string[];
  warningCodes: string[];
  priority: number;
  attemptCount: number;
  evidenceRefs: OperationEvidenceRef[];
  fieldProvenance: OperationFieldProvenance[];
  normalizedPayload: Record<string, unknown>;
  decisionId: string | null;
  publicationPlanId: string | null;
  createdAt: string;
  updatedAt: string;
  staleAt: string | null;
  expiresAt: string | null;
}

export interface AdminListIntakeOperationsPayload {
  workflowId?: "supply-intake";
  runId?: string | null;
  primaryStage?: SupplyIntakePrimaryStage | null;
  entityKind?: OperationEntityKind | null;
  lifecycleStatus?: OperationWorkItemLifecycleStatus | null;
  runStatus?: OperationRunStatus | null;
  humanReviewRequired?: boolean;
  runLimit?: number;
  workItemLimit?: number;
  runCursor?: string | null;
  workItemCursor?: string | null;
}

export interface AdminListIntakeOperationsResponse {
  schemaVersion: 1;
  generatedAt: string;
  workflowId: "supply-intake";
  executionMode: "shadow";
  source: "firestore" | "sample";
  capabilities: {
    requestRuns: false;
    networkFetches: false;
    modelCalls: false;
    publicWrites: false;
    ruleDeployment: false;
  };
  summary: {
    loadedRunCount: number;
    workItemCount: number;
    humanReviewCount: number;
    stages: Record<SupplyIntakePrimaryStage, number>;
  };
  runs: OperationRun[];
  workItems: OperationWorkItem[];
  nextRunCursor: string | null;
  nextWorkItemCursor: string | null;
}
