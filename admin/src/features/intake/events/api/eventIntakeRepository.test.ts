import {afterEach, describe, expect, it, vi} from "vitest";

const mocks = vi.hoisted(() => ({
  listIntakeOperations: vi.fn(),
  loadEventIntakeDashboard: vi.fn(),
}));

vi.mock("../../../../shared/api/adminApi", () => ({
  listIntakeOperations: mocks.listIntakeOperations,
  loadEventIntakeDashboard: mocks.loadEventIntakeDashboard,
  recordEventIntakeReviewDecision: vi.fn(),
}));

import {loadEventIntakeBridge} from "./eventIntakeRepository";

afterEach(() => {
  mocks.listIntakeOperations.mockReset();
  mocks.loadEventIntakeDashboard.mockReset();
});

describe("loadEventIntakeBridge", () => {
  it("merges source-backed orphan work into the human queue", async () => {
    mocks.loadEventIntakeDashboard.mockResolvedValue({
      bridge: emptyBridge(),
    });
    const run = operationRun("run-mumbai", "mumbai");
    mocks.listIntakeOperations.mockImplementation(async (
      payload: {runId?: string}
    ) => payload.runId ?
      operationResponse([run], [orphanWorkItem()]) :
      operationResponse([run], []));

    const result = await loadEventIntakeBridge();
    const candidate = result.bridge.eventCandidates[0];

    expect(result.bridge.bridgeSource).toBe("operations");
    expect(result.bridge.summary.orphanCandidates).toBe(1);
    expect(candidate).toMatchObject({
      id: "orphan-courtside",
      title: "Courtside Friday",
      publicationEligibility: "blocked_orphan",
      attribution: {
        state: "orphan",
        organizerEvidence: {name: "Courtside"},
      },
    });
    expect(candidate.blockerCodes).toContain(
      "organizer_not_in_inventory"
    );
    expect(mocks.listIntakeOperations).toHaveBeenCalledTimes(2);
  });

  it("fails closed on an invalid orphan projection", async () => {
    mocks.loadEventIntakeDashboard.mockResolvedValue({
      bridge: emptyBridge(),
    });
    const run = operationRun("run-mumbai", "mumbai");
    const invalid = orphanWorkItem();
    (invalid as {normalizedPayload: Record<string, unknown>})
      .normalizedPayload = {
      intake: {
        recordType: "orphan_event_candidate",
        candidate: {id: "invalid"},
      },
    };
    mocks.listIntakeOperations.mockImplementation(async (
      payload: {runId?: string}
    ) => payload.runId ?
      operationResponse([run], [invalid]) :
      operationResponse([run], []));

    await expect(loadEventIntakeBridge()).rejects.toThrow(
      "invalid orphan projection"
    );
  });
});

function emptyBridge() {
  return {
    schemaVersion: 1,
    program: "catch-event-intake",
    generatedAt: "2026-07-27T00:00:00.000Z",
    bridgeSource: "event_intake",
    city: {id: "mumbai", label: "Mumbai", timezone: "Asia/Kolkata"},
    weekStart: "2026-07-27",
    weekEnd: "2026-08-03",
    timezone: "Asia/Kolkata",
    summary: {
      status: "ready",
      sourceProfiles: 0,
      queryTemplates: 0,
      sourceResults: 0,
      sourceResultsNeedingReview: 0,
      eventCandidates: 0,
      approvedCandidates: 0,
      candidatesNeedingReview: 0,
      recommendationSets: 0,
      contentDrafts: 0,
      exportReadyDrafts: 0,
    },
    guardrails: [],
    sourceProfiles: [],
    queryTemplates: [],
    runPlan: {
      id: "event-intake",
      status: "ready",
      generatedAt: "2026-07-27T00:00:00.000Z",
      schedule: {cadence: "daily", publishDay: "daily", lookaheadDays: 7},
      budgets: {maxQueries: 0, maxSourceResults: 0, maxCandidatePool: 0},
      automationPolicy: {
        searchProvider: "operations",
        networkFetchesEnabled: false,
        instagramScrapingEnabled: false,
        requiresHumanApprovalBeforePublish: true,
      },
      queryIds: [],
      sourceProfileIds: [],
    },
    sourceResults: [],
    eventCandidates: [],
    dedupeGroups: [],
    auditTrail: [],
    commands: {},
  };
}

function operationRun(runId: string, market: string) {
  return {
    schemaVersion: 1,
    runId,
    workflowId: "supply-intake",
    revision: 0,
    mode: "shadow",
    status: "completed",
    scope: {market, intakeScope: "all"},
    rulesetVersion: "supply-intake-v0.4.0",
    policyVersion: "supply-intake-shadow-policy-v1",
    inputHash: "a".repeat(64),
    budgets: {
      maxWorkItems: 10,
      maxModelCalls: 0,
      maxModelTokens: 0,
      maxCostMicros: 0,
      deadlineAt: null,
    },
    counters: {
      discovered: 1,
      processed: 1,
      modelCalls: 0,
      modelTokens: 0,
      costMicros: 0,
      escalated: 1,
      published: 0,
      failed: 0,
    },
    checkpoint: {lastSequence: 1, cursor: null},
    createdAt: "2026-07-27T00:00:00.000Z",
    updatedAt: "2026-07-27T00:00:00.000Z",
    startedAt: "2026-07-27T00:00:00.000Z",
    finishedAt: "2026-07-27T00:00:00.000Z",
    failure: null,
    metadata: {},
  };
}

function operationResponse(runs: unknown[], workItems: unknown[]) {
  return {
    schemaVersion: 1,
    generatedAt: "2026-07-27T00:00:00.000Z",
    workflowId: "supply-intake",
    executionMode: "shadow",
    source: "firestore",
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
      stages: {incoming: 0, verify: 0, resolve: workItems.length, ready: 0},
    },
    runs,
    workItems,
    organizerDraftLinks: [],
    nextRunCursor: null,
    nextWorkItemCursor: null,
  };
}

function orphanWorkItem() {
  return {
    schemaVersion: 1,
    workItemId: "wi-orphan-courtside",
    workflowId: "supply-intake",
    runId: "run-mumbai",
    entityKind: "event",
    externalKey: "orphan-courtside",
    revision: 0,
    candidateHash: "b".repeat(64),
    primaryStage: "resolve",
    lifecycleStatus: "waiting",
    outcome: null,
    taskFlags: ["event_crawl_todo", "human_review_required"],
    blockerCodes: ["organizer_not_in_inventory"],
    warningCodes: [],
    priority: 500000,
    attemptCount: 1,
    evidenceRefs: [],
    fieldProvenance: [],
    normalizedPayload: {
      intake: {
        recordType: "orphan_event_candidate",
        candidate: {
          id: "orphan-courtside",
          candidateId: "orphan-courtside",
          title: "Courtside Friday",
          category: "external_event",
          neighborhood: "Mumbai",
          venue: "Courtside",
          startDate: "2026-08-01",
          endDate: "2026-08-01",
          time: "12:30",
          price: "Free",
          sourceResultIds: [],
          sourceUrl: "https://lu.ma/courtside-friday",
          sourceLabel: "luma",
          reviewState: "needs_changes",
          requiresVerification: true,
          explicitSinglesEvent: false,
          whySinglesFriendly: "",
          publicDescription: "Source-backed event candidate.",
          scores: {},
          sourceCoverage: {
            sourceResultIds: [],
            matchedSourceResults: 0,
            hasSourceUrl: true,
            hasManualInstagramReference: false,
          },
          sourceStatus: "source_backed",
          publishability: "lead_needs_source",
          score: 0,
          warnings: ["organizer_not_in_inventory"],
          blockerCodes: ["organizer_not_in_inventory"],
          publicationEligibility: "blocked_orphan",
          attribution: {
            state: "orphan",
            organizerEvidence: {
              name: "Courtside",
              url: "https://courtside.club/",
            },
            match: {
              decision: "needs_review",
              policyId: "source-mention-resolution-v1",
              threshold: 0.9,
              rationale: "No unique match cleared the threshold.",
              matchedEntityId: null,
              score: 0.82,
              matchingSignals: ["exact_organizer_name"],
              blockingKeys: ["organizer-name:courtside"],
            },
          },
        },
      },
    },
    decisionId: null,
    publicationPlanId: null,
    createdAt: "2026-07-27T00:00:00.000Z",
    updatedAt: "2026-07-27T00:00:00.000Z",
    staleAt: null,
    expiresAt: "2026-08-01T15:00:00.000Z",
  };
}
