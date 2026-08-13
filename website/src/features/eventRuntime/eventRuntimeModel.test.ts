import fs from "node:fs";
import path from "node:path";
import {describe, expect, it} from "vitest";
import {
  eventRuntimeStageForParticipant,
  normalizeEventRuntimeLayoutUnits,
  normalizeRuntimePhone,
  resolveEventRuntimeQuestionnaire,
  shouldRenderEventRuntimeRoomMap,
  type EventRuntimeAssignment,
  type EventRuntimeLayout,
  type EventRuntimeParticipant,
} from "./eventRuntimeModel";

const layoutCatalog = JSON.parse(fs.readFileSync(path.resolve(
  process.cwd(),
  "../contracts/catalogs/event_success_layout.json"
), "utf8")) as {
  shapes: string[];
  parityFixture: EventRuntimeLayout & {
    normalizedUnits: ReturnType<typeof normalizeEventRuntimeLayoutUnits>;
  };
};

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

  it("derives the shared normalized room-map contract for all five shapes", () => {
    expect(new Set(layoutCatalog.parityFixture.units.map((unit) => unit.shape)))
      .toEqual(new Set(layoutCatalog.shapes));
    expect(normalizeEventRuntimeLayoutUnits(layoutCatalog.parityFixture.units))
      .toEqual(layoutCatalog.parityFixture.normalizedUnits);
  });

  it("omits a room map for wholeGroup and missing spatial assignments", () => {
    const spatialAssignment = {
      layoutUnitId: "round",
      unitKind: "pods",
    } as EventRuntimeAssignment;
    expect(shouldRenderEventRuntimeRoomMap(layoutCatalog.parityFixture, spatialAssignment))
      .toBe(true);
    expect(shouldRenderEventRuntimeRoomMap(layoutCatalog.parityFixture, {
      ...spatialAssignment,
      unitKind: "wholeGroup",
    })).toBe(false);
    expect(shouldRenderEventRuntimeRoomMap(null, spatialAssignment)).toBe(false);
    expect(shouldRenderEventRuntimeRoomMap(layoutCatalog.parityFixture, {
      ...spatialAssignment,
      layoutUnitId: undefined,
    })).toBe(false);
  });
});
