import {afterEach, describe, expect, it, vi} from "vitest";

const mocks = vi.hoisted(() => ({
  listIntakeOperations: vi.fn(),
}));

vi.mock("../../../../shared/api/adminApi", () => ({
  listIntakeOperations: mocks.listIntakeOperations,
}));

import {loadOrganizerIntakeBridge} from "./loadOrganizerIntakeBridge";

afterEach(() => {
  vi.unstubAllEnvs();
  mocks.listIntakeOperations.mockReset();
});

describe("loadOrganizerIntakeBridge", () => {
  it("joins the newest persisted organizer run for both launch markets", async () => {
    vi.stubEnv("VITE_ADMIN_DATA_MODE", "live");
    const runs = [
      {
        ...operationRun(
          "newer-general-indore-run",
          "indore",
          "2026-07-24T12:02:00.000Z"
        ),
        scope: {market: "indore", intakeScope: "all"},
      },
      operationRun("mumbai-run", "mumbai", "2026-07-24T12:01:00.000Z"),
      operationRun("indore-run", "indore", "2026-07-24T12:00:00.000Z"),
    ];
    mocks.listIntakeOperations.mockImplementation(async (
      payload: {runId?: string}
    ) => {
      if (!payload.runId) return operationResponse({runs, workItems: []});
      const market = payload.runId === "mumbai-run" ? "mumbai" : "indore";
      return operationResponse({
        runs: [runs.find((run) => run.runId === payload.runId)],
        workItems: Array.from({length: 25}, (_value, index) =>
          organizerWorkItem(market, index + 1)),
        organizerDraftLinks: market === "mumbai" ? [{
          workItemId: "wi-mumbai-candidate-10",
          candidateId: "mumbai-candidate-10",
          organizerId: "courtside",
          curationPath: "organizerIntakeCurationDecisions/create-draft-test",
        }] : [],
      });
    });

    const result = await loadOrganizerIntakeBridge();

    expect(result.source).toBe("firestore");
    expect(result.diagnosticsBridge).toBeNull();
    expect(result.workbench.searchCandidates.summary.candidates).toBe(50);
    expect(new Set(
      result.workbench.searchCandidates.candidates.map((candidate) =>
        candidate.queryIntent.marketSlug)
    )).toEqual(new Set(["indore", "mumbai"]));
    expect(mocks.listIntakeOperations).toHaveBeenCalledTimes(3);
    expect(result.workbench.searchCandidates.candidates.find((candidate) =>
      candidate.candidateId === "mumbai-candidate-10")).toMatchObject({
      workItemId: "wi-mumbai-candidate-10",
      draftLink: {
        organizerId: "courtside",
      },
    });
    expect(mocks.listIntakeOperations).toHaveBeenNthCalledWith(1, {
      workflowId: "supply-intake",
      runStatus: "completed",
      entityKind: "organizer",
      runLimit: 25,
      workItemLimit: 1,
    });
    expect(mocks.listIntakeOperations).not.toHaveBeenCalledWith(
      expect.objectContaining({runId: "newer-general-indore-run"})
    );
  });
});

function operationRun(runId: string, market: string, updatedAt: string) {
  return {
    schemaVersion: 1,
    runId,
    workflowId: "supply-intake",
    revision: 0,
    mode: "shadow",
    status: "completed",
    scope: {market, intakeScope: "organizer"},
    rulesetVersion: "supply-intake-v0.1.0",
    policyVersion: "supply-intake-shadow-policy-v1",
    inputHash: "a".repeat(64),
    budgets: {
      maxWorkItems: 1000,
      maxModelCalls: 0,
      maxModelTokens: 0,
      maxCostMicros: 0,
      deadlineAt: null,
    },
    counters: {
      discovered: 25,
      processed: 0,
      modelCalls: 0,
      modelTokens: 0,
      costMicros: 0,
      escalated: 25,
      published: 0,
      failed: 0,
    },
    checkpoint: {lastSequence: 1, cursor: null},
    createdAt: updatedAt,
    updatedAt,
    startedAt: updatedAt,
    finishedAt: updatedAt,
    failure: null,
    metadata: {},
  };
}

function organizerWorkItem(market: string, rank: number) {
  const candidateId = `${market}-candidate-${rank}`;
  return {
    schemaVersion: 1,
    workItemId: `wi-${candidateId}`,
    workflowId: "supply-intake",
    runId: `${market}-run`,
    entityKind: "organizer",
    externalKey: candidateId,
    revision: 0,
    candidateHash: "b".repeat(64),
    primaryStage: "incoming",
    lifecycleStatus: "queued",
    outcome: null,
    taskFlags: ["human_review_required"],
    blockerCodes: [],
    warningCodes: [],
    priority: 400000,
    attemptCount: 1,
    evidenceRefs: [],
    fieldProvenance: [],
    normalizedPayload: {
      intake: {
        recordType: "organizer_search_candidate",
        candidate: {
          candidateId,
          batchId: `batch-${market}`,
          resultId: candidateId,
          rank,
          query: `${market} organizers`,
          queryIntent: {
            activityKind: "organizer-discovery",
            entityHint: null,
            marketSlug: market,
          },
          observedAt: "2026-07-24",
          title: `${market} candidate ${rank}`,
          snippet: "Evidence.",
          url: `https://${candidateId}.example/`,
          canonicalUrl: `https://${candidateId}.example/`,
          platform: "officialWebsite",
          surfaceKind: "website",
          normalizedKey: `domain:${candidateId}.example`,
          suggestedSurface: {
            confidence: {city: "high", entityMatch: "medium", ownership: "low"},
          },
          existingEntityMatches: [],
          reviewAction: "verify_ownership_before_attach",
          diagnostics: [],
        },
      },
    },
    decisionId: null,
    publicationPlanId: null,
    createdAt: "2026-07-24T12:00:00.000Z",
    updatedAt: "2026-07-24T12:00:00.000Z",
    staleAt: null,
    expiresAt: null,
  };
}

function operationResponse({
  runs,
  workItems,
  organizerDraftLinks = [],
}: {
  runs: unknown[];
  workItems: unknown[];
  organizerDraftLinks?: unknown[];
}) {
  return {
    schemaVersion: 1,
    generatedAt: "2026-07-24T12:02:00.000Z",
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
      stages: {
        incoming: workItems.length,
        verify: 0,
        resolve: 0,
        ready: 0,
      },
    },
    runs,
    workItems,
    organizerDraftLinks,
    nextRunCursor: null,
    nextWorkItemCursor: null,
  };
}
