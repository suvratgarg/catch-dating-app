import {describe, expect, it} from "vitest";
import {
  hostApplicationCompleteness,
  hostApplicationIsComplete,
  hostApplicationStepError,
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
      eventLocation: "Delhi",
      hostGoals: "Create thoughtful introductions",
    };
    expect(hostApplicationIsComplete(complete)).toBe(true);
    expect(hostApplicationCompleteness(complete)).toBe(100);
  });
});
