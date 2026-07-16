import {describe, expect, it} from "vitest";
import {
  AdminCallableValidationError,
  adminCallableValidationCoverage,
  validateAdminCallableRequest,
} from "./adminCallableValidators";

describe("generated admin callable validators", () => {
  it("covers every callable used by adminApi", () => {
    expect(adminCallableValidationCoverage.callables).toHaveLength(35);
    expect(adminCallableValidationCoverage.strictRequests).toContain(
      "adminGetHostAnalytics"
    );
    expect(adminCallableValidationCoverage.strictResponses).toEqual([
      "adminGetHostAnalytics",
      "adminGetUserAnalytics",
      "adminListIntakeOperations",
    ]);
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
});
