import {describe, expect, it} from "vitest";
import {
  eventRuntimeStageForParticipant,
  normalizeRuntimePhone,
  resolveEventRuntimeQuestionnaire,
  type EventRuntimeParticipant,
} from "./eventRuntimeModel";

describe("eventRuntimeModel", () => {
  it("keeps unknown questionnaire templates on the safe balanced pack", () => {
    const questionnaire = resolveEventRuntimeQuestionnaire({
      templateId: "unknown-template",
    });
    expect(questionnaire.questions[0]?.id).toBe("event_energy");
  });

  it("routes pending access to Host approval", () => {
    expect(eventRuntimeStageForParticipant({
      accessStatus: "pendingApproval",
    } as EventRuntimeParticipant)).toBe("approval");
  });

  it("normalizes display-formatted E.164 phone numbers", () => {
    expect(normalizeRuntimePhone("+91 (98765) 43210")).toBe("+919876543210");
  });
});
