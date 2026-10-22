import {describe, expect, it} from "vitest";
import {
  hostApplicationCompleteness,
  hostApplicationIsComplete,
  hostApplicationStepError,
  hostApplicationStepIsComplete,
  initialHostApplicationDraft,
} from "./applicationModel";

describe("host application model", () => {
  it("reports incomplete defaults and step-specific guidance", () => {
    expect(hostApplicationIsComplete(initialHostApplicationDraft)).toBe(false);
    expect(hostApplicationCompleteness(initialHostApplicationDraft)).toBe(25);
    expect(hostApplicationStepError("event")).toContain("first event");
  });

  it("recognizes a complete operating packet", () => {
    const complete = {
      ...initialHostApplicationDraft,
      fullName: "A Host",
      email: "host@example.com",
      organizationName: "Sunday Club",
      communityLink: "https://example.com",
      nextEventName: "Sunday Dinner",
      eventPricing: "paid" as const,
      eventLocation: "Delhi",
      hostGoals: "Create thoughtful introductions",
    };
    expect(hostApplicationIsComplete(complete)).toBe(true);
    expect(hostApplicationCompleteness(complete)).toBe(100);
  });

  it("requires an explicit pricing answer without treating free or undecided as paid", () => {
    const event = {...initialHostApplicationDraft, nextEventName: "Planned event", eventLocation: "Mumbai"};
    expect(hostApplicationStepIsComplete("event", event)).toBe(false);
    for (const eventPricing of ["paid", "free", "mixed", "undecided"] as const) {
      expect(hostApplicationStepIsComplete("event", {...event, eventPricing})).toBe(true);
    }
  });
});
