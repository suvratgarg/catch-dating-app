import {describe, expect, it, vi} from "vitest";
import type {EventIntakeBridge} from "../../../../shared/types/adminTypes";
import {
  applyLocalEventIntakeDecision,
  checklistForEventIntakeDecision,
  eventIntakePublishabilityLabel,
  eventIntakeSourceStatusLabel,
} from "./eventIntakeReviewDecisionHelpers";

describe("event intake review decision helpers", () => {
  it("requires the relevant evidence for approved event candidates", () => {
    expect(checklistForEventIntakeDecision("event_candidate", "approve")).toEqual({
      sourceReviewed: true,
      dateReviewed: true,
      venueReviewed: true,
      copyReviewed: true,
      rightsReviewed: false,
      noCatchHostingImplied: true,
    });
    expect(checklistForEventIntakeDecision("event_candidate", "reject")).toEqual({
      sourceReviewed: false,
      dateReviewed: false,
      venueReviewed: false,
      copyReviewed: false,
      rightsReviewed: false,
      noCatchHostingImplied: false,
    });
  });

  it("updates only the matching local bridge row", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-07-12T10:00:00.000Z"));
    const bridge = {
      sourceResults: [
        {id: "source-1", status: "pending"},
        {id: "source-2", status: "pending"},
      ],
      eventCandidates: [],
    } as unknown as EventIntakeBridge;

    const updated = applyLocalEventIntakeDecision(bridge, {
      decisionId: "decision-1",
      targetType: "source_result",
      targetId: "source-1",
      decision: "hold",
      decisionStatus: "held",
      decisionPath: "eventIntakeReviewDecisions/decision-1",
    }, "Needs official source");

    expect(updated.sourceResults[0]).toMatchObject({
      id: "source-1",
      status: "held",
      latestDecision: {
        decision: "hold",
        note: "Needs official source",
        reviewer: "local-admin",
        reviewedAt: "2026-07-12T10:00:00.000Z",
      },
    });
    expect(updated.sourceResults[1]).toBe(bridge.sourceResults[1]);
    vi.useRealTimers();
  });

  it("normalizes candidate readiness labels", () => {
    expect(eventIntakePublishabilityLabel("publishable_after_approval")).toBe(
      "publishable after approval"
    );
    expect(eventIntakeSourceStatusLabel("source_backed")).toBe("source-backed");
  });
});
