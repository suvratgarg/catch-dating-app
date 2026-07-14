import type {
  AdminListIntakeOperationsPayload,
  AdminListIntakeOperationsResponse,
  OperationWorkItem,
} from "./operationsTypes";
import {operationNeedsHumanReview, operationStageCounts} from
  "./operationSelectors";

const generatedAt = "2026-07-14T08:30:00.000Z";
const hashA = "a".repeat(64);
const hashB = "b".repeat(64);
const hashC = "c".repeat(64);
const hashD = "d".repeat(64);

const sampleItems: OperationWorkItem[] = [
  sampleItem({
    workItemId: "source-result-cntraveller-mumbai-weekend",
    entityKind: "source_result",
    externalKey: "cntraveller:mumbai-weekend",
    candidateHash: hashA,
    primaryStage: "incoming",
    lifecycleStatus: "queued",
    taskFlags: ["extract_mentions"],
    normalizedPayload: {
      title: "CN Traveller Mumbai weekend guide",
      city: "Mumbai",
      sourceProfileId: "cntraveller",
    },
  }),
  sampleItem({
    workItemId: "organizer-afterfly-indore",
    entityKind: "organizer",
    externalKey: "afterfly-run-club-indore",
    candidateHash: hashB,
    primaryStage: "verify",
    lifecycleStatus: "in_progress",
    taskFlags: ["identity_verification", "source_verification"],
    normalizedPayload: {
      displayName: "Afterfly Run Club",
      city: "Indore",
      sourceProfileId: "luma",
    },
  }),
  sampleItem({
    workItemId: "event-rooftop-singles-mixer",
    entityKind: "event",
    externalKey: "rooftop-singles-mixer-2026-07-18",
    candidateHash: hashC,
    primaryStage: "resolve",
    lifecycleStatus: "waiting",
    taskFlags: ["possible_duplicate", "human_review_required"],
    blockerCodes: ["official_source_required", "human_review_required"],
    warningCodes: ["editorial_source_only"],
    normalizedPayload: {
      title: "Rooftop Singles Mixer",
      city: "Mumbai",
      sourceProfileId: "cntraveller",
    },
  }),
  sampleItem({
    workItemId: "event-saturday-social-run",
    entityKind: "event",
    externalKey: "luma:saturday-social-run",
    candidateHash: hashD,
    primaryStage: "ready",
    lifecycleStatus: "ready",
    taskFlags: ["publication_preflight"],
    normalizedPayload: {
      title: "Saturday Social Run",
      city: "Mumbai",
      sourceProfileId: "luma",
    },
    decisionId: "decision-saturday-social-run",
  }),
];

export function sampleIntakeOperations(
  payload: AdminListIntakeOperationsPayload = {}
): AdminListIntakeOperationsResponse {
  const workItemLimit = Math.max(1, Math.min(payload.workItemLimit ?? 100, 200));
  const workItems = sampleItems
    .filter((item) => !payload.runId || item.runId === payload.runId)
    .filter((item) => !payload.primaryStage ||
      item.primaryStage === payload.primaryStage)
    .filter((item) => !payload.entityKind ||
      item.entityKind === payload.entityKind)
    .filter((item) => !payload.lifecycleStatus ||
      item.lifecycleStatus === payload.lifecycleStatus)
    .filter((item) => !payload.humanReviewRequired ||
      operationNeedsHumanReview(item))
    .slice(0, workItemLimit);
  const runs = payload.runStatus && payload.runStatus !== "completed" ? [] : [{
    schemaVersion: 1 as const,
    runId: "supply-intake-shadow-2026-07-14",
    workflowId: "supply-intake",
    revision: 4,
    mode: "shadow" as const,
    status: "completed" as const,
    scope: {market: "mumbai", through: "2026-07-28"},
    rulesetVersion: "supply-intake-rules-v1",
    policyVersion: "shadow-disabled-v1",
    inputHash: hashA,
    budgets: {
      maxWorkItems: 250,
      maxModelCalls: 0,
      maxModelTokens: 0,
      maxCostMicros: 0,
      deadlineAt: null,
    },
    counters: {
      discovered: 4,
      processed: 4,
      modelCalls: 0,
      modelTokens: 0,
      costMicros: 0,
      escalated: 1,
      published: 0,
      failed: 0,
    },
    checkpoint: {lastSequence: 12, cursor: null},
    createdAt: "2026-07-14T08:00:00.000Z",
    updatedAt: generatedAt,
    startedAt: "2026-07-14T08:00:01.000Z",
    finishedAt: "2026-07-14T08:01:12.000Z",
    failure: null,
    metadata: {adapter: "legacy_artifacts", publicationReceiptOnly: true},
  }].slice(0, Math.max(1, Math.min(payload.runLimit ?? 10, 25)));
  return {
    schemaVersion: 1,
    generatedAt,
    workflowId: "supply-intake",
    executionMode: "shadow",
    source: "sample",
    capabilities: {
      requestRuns: false,
      networkFetches: false,
      modelCalls: false,
      publicWrites: false,
      ruleDeployment: false,
    },
    summary: {
      loadedRunCount: runs.length,
      workItemCount: workItems.length,
      humanReviewCount: workItems.filter(operationNeedsHumanReview).length,
      stages: operationStageCounts(workItems),
    },
    runs,
    workItems,
    nextRunCursor: null,
    nextWorkItemCursor: null,
  };
}

function sampleItem(
  value: Partial<OperationWorkItem> & Pick<
    OperationWorkItem,
    | "workItemId"
    | "entityKind"
    | "externalKey"
    | "candidateHash"
    | "primaryStage"
    | "lifecycleStatus"
    | "taskFlags"
    | "normalizedPayload"
  >
): OperationWorkItem {
  return {
    schemaVersion: 1,
    workflowId: "supply-intake",
    runId: "supply-intake-shadow-2026-07-14",
    revision: 1,
    outcome: null,
    blockerCodes: [],
    warningCodes: [],
    priority: 50,
    attemptCount: 1,
    evidenceRefs: [{
      artifactId: `artifact-${value.workItemId}`,
      contentHash: value.candidateHash,
      observedAt: generatedAt,
      locator: null,
    }],
    fieldProvenance: [],
    decisionId: null,
    publicationPlanId: null,
    createdAt: "2026-07-14T08:00:00.000Z",
    updatedAt: generatedAt,
    staleAt: null,
    expiresAt: null,
    ...value,
  };
}
