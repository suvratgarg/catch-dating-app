import {afterEach, describe, expect, it, vi} from "vitest";

const mocks = vi.hoisted(() => ({
  loadEventIntakeDashboard: vi.fn(),
}));

vi.mock("../../../../shared/api/adminApi", () => ({
  loadEventIntakeDashboard: mocks.loadEventIntakeDashboard,
  recordEventIntakeReviewDecision: vi.fn(),
}));

import {loadEventIntakeBridge} from "./eventIntakeRepository";

afterEach(() => {
  mocks.loadEventIntakeDashboard.mockReset();
});

describe("loadEventIntakeBridge", () => {
  it("uses the server-side Operations projection without a second data path",
    async () => {
      const response = {
        bridge: {
          schemaVersion: 1,
          program: "catch-event-intake",
          generatedAt: "2026-07-27T00:00:00.000Z",
          bridgeSource: "operations",
          city: {
            id: "launch-markets",
            label: "Launch markets",
            timezone: "Asia/Kolkata",
          },
          weekStart: "2026-07-27",
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
          sourceProfiles: [],
          queryTemplates: [],
          runPlan: {
            id: "supply-intake:run-mumbai",
            cityId: "launch-markets",
            weekStart: "2026-07-27",
            status: "ready",
            generatedAt: "2026-07-27T00:00:00.000Z",
            schedule: {
              cadence: "per_source_policy",
              publishDay: "continuous",
              lookaheadDays: 7,
            },
            budgets: {
              maxQueries: 0,
              maxSourceResults: 0,
              maxCandidatePool: 0,
            },
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
        },
      };
      mocks.loadEventIntakeDashboard.mockResolvedValue(response);

      await expect(loadEventIntakeBridge()).resolves.toBe(response);
      expect(mocks.loadEventIntakeDashboard).toHaveBeenCalledTimes(1);
    });
});
