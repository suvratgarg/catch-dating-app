import {describe, expect, it} from "vitest";
import {
  checklistForDecision,
  publishabilityLabel,
  reviewStateFor,
  sourceStatusLabel,
} from "./marketingReviewDecisionHelpers";

describe("marketing review decision helpers", () => {
  it("requires content and rights review for export-ready drafts", () => {
    expect(checklistForDecision("content_draft", "export_ready", {
      rightsReviewed: true,
    })).toEqual({
      sourceReviewed: false,
      dateReviewed: true,
      venueReviewed: true,
      copyReviewed: true,
      rightsReviewed: true,
      noCatchHostingImplied: true,
    });
    expect(
      checklistForDecision("content_draft", "export_ready")?.rightsReviewed
    ).toBe(false);
  });

  it("keeps non-approval decisions from claiming completed review", () => {
    expect(checklistForDecision("event_candidate", "hold")).toEqual({
      sourceReviewed: false,
      dateReviewed: false,
      venueReviewed: false,
      copyReviewed: false,
      rightsReviewed: false,
      noCatchHostingImplied: false,
    });
    expect(reviewStateFor("hold")).toBe("held");
    expect(reviewStateFor("needs_changes")).toBe("needs_changes");
  });

  it("normalizes public readiness labels", () => {
    expect(publishabilityLabel("publishable_after_approval")).toBe(
      "marketing ready after approval"
    );
    expect(sourceStatusLabel("source_backed")).toBe("source-backed");
  });
});
