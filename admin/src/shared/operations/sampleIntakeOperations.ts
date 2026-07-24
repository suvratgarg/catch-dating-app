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

const sampleOrganizerItems: OperationWorkItem[] = [
  sampleOrganizerItem({
    candidateId: "sample-afterfly-indore",
    market: "indore",
    title: "AFTER FLY",
    url: "https://afterfly.in/",
  }),
  sampleOrganizerItem({
    candidateId: "sample-small-world-mumbai",
    market: "mumbai",
    title: "Small World",
    url: "https://smallworld.example/",
  }),
];

export function sampleIntakeOperations(
  payload: AdminListIntakeOperationsPayload = {}
): AdminListIntakeOperationsResponse {
  if (payload.entityKind === "organizer") {
    return sampleOrganizerOperations(payload);
  }
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
  const allRuns = [sampleRun({
    runId: "supply-intake-shadow-2026-07-14",
    scope: {market: "mumbai", through: "2026-07-28"},
  })];
  const runs = payload.runStatus && payload.runStatus !== "completed" ? [] :
    allRuns
      .filter((run) => !payload.runId || run.runId === payload.runId)
      .slice(0, Math.max(1, Math.min(payload.runLimit ?? 10, 25)));
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

function sampleOrganizerOperations(
  payload: AdminListIntakeOperationsPayload
): AdminListIntakeOperationsResponse {
  const workItemLimit = Math.max(1, Math.min(payload.workItemLimit ?? 100, 200));
  const workItems = sampleOrganizerItems
    .filter((item) => !payload.runId || item.runId === payload.runId)
    .slice(0, workItemLimit);
  const runs = [
    sampleRun({
      runId: "supply-intake-organizer-indore-sample",
      scope: {
        market: "indore",
        intakeScope: "organizer",
        through: "2026-07-28",
      },
      items: sampleOrganizerItems,
    }),
    sampleRun({
      runId: "supply-intake-organizer-mumbai-sample",
      scope: {
        market: "mumbai",
        intakeScope: "organizer",
        through: "2026-07-28",
      },
      items: sampleOrganizerItems,
    }),
  ]
    .filter((run) => !payload.runId || run.runId === payload.runId)
    .slice(0, Math.max(1, Math.min(payload.runLimit ?? 10, 25)));
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
      humanReviewCount: workItems.length,
      stages: operationStageCounts(workItems),
    },
    runs,
    workItems,
    nextRunCursor: null,
    nextWorkItemCursor: null,
  };
}

function sampleRun({
  runId,
  scope,
  items = sampleItems,
}: {
  runId: string;
  scope: Record<string, unknown>;
  items?: OperationWorkItem[];
}) {
  return {
    schemaVersion: 1 as const,
    runId,
    workflowId: "supply-intake",
    revision: 4,
    mode: "shadow" as const,
    status: "completed" as const,
    scope,
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
      discovered: items.filter((item) => item.runId === runId).length,
      processed: items.filter((item) => item.runId === runId).length,
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
  };
}

function sampleOrganizerItem({
  candidateId,
  market,
  title,
  url,
}: {
  candidateId: string;
  market: "indore" | "mumbai";
  title: string;
  url: string;
}) {
  return sampleItem({
    workItemId: `organizer-${candidateId}`,
    runId: `supply-intake-organizer-${market}-sample`,
    entityKind: "organizer",
    externalKey: candidateId,
    candidateHash: market === "indore" ? hashB : hashC,
    primaryStage: "incoming",
    lifecycleStatus: "queued",
    taskFlags: ["human_review_required"],
    normalizedPayload: {
      intake: {
        recordType: "organizer_search_candidate",
        candidate: sampleOrganizerCandidate({
          candidateId,
          market,
          rank: 1,
          title,
          url,
        }),
      },
    },
  });
}

function sampleOrganizerCandidate({
  candidateId,
  market,
  rank,
  title,
  url,
}: {
  candidateId: string;
  market: "indore" | "mumbai";
  rank: number;
  title: string;
  url: string;
}) {
  return {
    candidateId,
    batchId: `sample-${market}`,
    resultId: candidateId,
    rank,
    query: `${market} event organizers`,
    queryIntent: {
      activityKind: "organizer-discovery",
      entityHint: null,
      marketSlug: market,
    },
    observedAt: "2026-07-14",
    title,
    snippet: "Synthetic Admin preview candidate.",
    url,
    canonicalUrl: url,
    platform: "officialWebsite",
    surfaceKind: "website",
    normalizedKey: `domain:${new URL(url).hostname}`,
    suggestedSurface: {
      confidence: {city: "high", entityMatch: "medium", ownership: "low"},
    },
    existingEntityMatches: candidateId === "sample-afterfly-indore" ? [{
      entityId: "afterfly",
      strength: "strong",
      reason: "Synthetic preview match.",
    }] : [],
    reviewAction: "verify_ownership_before_attach",
    diagnostics: [],
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
