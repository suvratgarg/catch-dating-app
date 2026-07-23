import {describe, expect, it} from "vitest";
import {
  AdminCallableValidationError,
  adminCallableValidationCoverage,
  validateAdminCallableRequest,
  validateAdminCallableResponse,
} from "./adminCallableValidators";
import {sampleOverview} from "../../shared/api/sampleData";

describe("generated admin callable validators", () => {
  it("covers every callable used by adminApi", () => {
    expect(adminCallableValidationCoverage.callables).toHaveLength(35);
    expect(adminCallableValidationCoverage.strictRequests).toContain(
      "adminGetHostAnalytics"
    );
    expect(adminCallableValidationCoverage.strictRequests).toEqual(
      expect.arrayContaining([
        "adminGetOverview",
        "adminDecideAccessApplication",
        "adminSetAdminUserRoles",
        "adminAssignSafetyTriageItem",
        "adminDecideSafetyTriageItem",
        "adminCreateMarketingContentDraft",
        "adminRecordMarketingReviewDecision",
      ])
    );
    expect(adminCallableValidationCoverage.strictResponses).toHaveLength(10);
    expect(adminCallableValidationCoverage.strictResponses).toEqual(
      expect.arrayContaining([
        "adminGetOverview",
        "adminDecideAccessApplication",
        "adminSetAdminUserRoles",
        "adminAssignSafetyTriageItem",
        "adminDecideSafetyTriageItem",
        "adminCreateMarketingContentDraft",
        "adminRecordMarketingReviewDecision",
      ])
    );
  });

  it.each([
    ["analytics", "adminGetHostAnalytics", {
      rangePreset: "30d",
      granularity: "week",
    }],
    ["organizer claim", "adminDecideClubClaim", {
      requestId: "claim-1",
      decision: "approve",
    }],
    ["event publishing", "adminGetEventDetails", {eventId: "event-1"}],
  ])("accepts a known-good %s request", (_family, callable, payload) => {
    expect(() => validateAdminCallableRequest(callable, payload)).not.toThrow();
  });

  it.each([
    ["analytics", "adminGetHostAnalytics", {unexpected: true}],
    ["organizer claim", "adminDecideClubClaim", {decision: "approve"}],
    ["event publishing", "adminGetEventDetails", {}],
  ])("rejects a known-bad %s request", (_family, callable, payload) => {
    expect(() => validateAdminCallableRequest(callable, payload)).toThrow(
      AdminCallableValidationError
    );
  });

  it.each([
    ["overview", "adminGetOverview", {}],
    ["access decision", "adminDecideAccessApplication", {
      applicationUid: "applicant-1",
      decision: "approve",
      note: "Approved for the first cohort.",
      cohortId: "mumbai-pilot",
    }],
    ["role mutation", "adminSetAdminUserRoles", {
      targetUid: "support-ops",
      roles: ["support"],
      note: "Support coverage approved.",
    }],
    ["safety assignment", "adminAssignSafetyTriageItem", {
      targetPath: "reports/report-1",
      assigneeUid: "reviewer-1",
      note: "Assigned for review.",
    }],
    ["safety decision", "adminDecideSafetyTriageItem", {
      targetPath: "moderationFlags/flag-1",
      decision: "dismiss",
      note: "No policy violation found.",
    }],
    ["marketing draft", "adminCreateMarketingContentDraft", {
      draftType: "event_highlights",
      cityId: "mumbai",
      weekStart: "2026-07-20",
    }],
    ["marketing decision", "adminRecordMarketingReviewDecision", {
      targetType: "content_draft",
      targetId: "draft-1",
      decision: "export_ready",
      note: "Copy and rights review complete.",
      checklist: {
        copyReviewed: true,
        rightsReviewed: true,
        noCatchHostingImplied: true,
      },
    }],
  ])("accepts a strict high-risk %s request", (_family, callable, payload) => {
    expect(() => validateAdminCallableRequest(callable, payload)).not.toThrow();
  });

  it.each([
    ["overview extra field", "adminGetOverview", {scope: "all"}],
    ["access without note", "adminDecideAccessApplication", {
      applicationUid: "applicant-1",
      decision: "approve",
    }],
    ["duplicate roles", "adminSetAdminUserRoles", {
      targetUid: "support-ops",
      roles: ["support", "support"],
      note: "Duplicate input must not cross the boundary.",
    }],
    ["invalid safety path", "adminAssignSafetyTriageItem", {
      targetPath: "users/user-1",
      assigneeUid: null,
      note: "Invalid queue.",
    }],
    ["unknown marketing draft", "adminCreateMarketingContentDraft", {
      draftType: "publish_now",
    }],
  ])("rejects a strict high-risk %s request", (_family, callable, payload) => {
    expect(() => validateAdminCallableRequest(callable, payload)).toThrow(
      AdminCallableValidationError
    );
  });

  it("accepts strict high-risk response fixtures", () => {
    const fixtures: Array<[string, unknown]> = [
      ["adminGetOverview", sampleOverview],
      ["adminDecideAccessApplication", {
        applicationUid: "applicant-1",
        decision: "approve",
        status: "approvedForProfile",
      }],
      ["adminSetAdminUserRoles", {
        user: {
          targetUid: "support-ops",
          email: "support@catch.local",
          displayName: "Support Ops",
          disabled: false,
          roles: ["support"],
          assignmentPath: "adminRoleAssignments/support-ops",
        },
        beforeRoles: [],
        afterRoles: ["support"],
      }],
      ["adminAssignSafetyTriageItem", {
        targetPath: "reports/report-1",
        assignment: {
          ownerTeam: "Safety",
          assigneeUid: "reviewer-1",
          queue: "reports",
          severity: "high",
        },
      }],
      ["adminDecideSafetyTriageItem", {
        targetPath: "moderationFlags/flag-1",
        decision: "dismiss",
        status: "dismissed",
      }],
      ["adminCreateMarketingContentDraft", {
        draft: {id: "draft-1"},
        bridge: {schemaVersion: 1},
        dashboardPath: "marketingOpsDashboards/current",
      }],
      ["adminRecordMarketingReviewDecision", {
        decisionId: "marketing-content-draft-draft-1",
        targetType: "content_draft",
        targetId: "draft-1",
        decision: "export_ready",
        decisionStatus: "export_ready",
        decisionPath:
          "marketingReviewDecisions/marketing-content-draft-draft-1",
      }],
    ];
    for (const [callable, response] of fixtures) {
      expect(() =>
        validateAdminCallableResponse(callable, response)
      ).not.toThrow();
    }
  });

  it("rejects a malformed strict mutation response", () => {
    expect(() => validateAdminCallableResponse(
      "adminDecideAccessApplication",
      {
        applicationUid: "applicant-1",
        decision: "approve",
        status: "published",
      }
    )).toThrow(AdminCallableValidationError);
  });
});
