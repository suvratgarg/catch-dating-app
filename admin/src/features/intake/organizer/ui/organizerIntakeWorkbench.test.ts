import {describe, expect, it} from "vitest";

import type * as Intake from "../types/organizerIntakeTypes";
import {
  organizerEntityEntryId,
  organizerEntityQueueItem,
} from "./organizerIntakeWorkbench";
import {
  organizerIntakeAgeDays,
  organizerIntakeAgeLabel,
} from "./organizerIntakeQueueItems";

describe("organizer intake entity queue identity", () => {
  it("uses the same namespaced ID for staged entities and clickable rows", () => {
    const item = {
      entityId: "afterfly",
      displayName: "AFTER FLY",
      markets: [{
        marketSlug: "indore",
        displayName: "Indore",
        countryCode: "IN",
        eventFilter: {mode: "city", citySlug: "indore"},
      }],
      blockers: [],
      reviewStatus: "ready",
      publishStatus: "draft",
      surfaceSummary: {
        total: 6,
        active: 6,
        ambiguous: 0,
        candidate: 0,
        rejected: 0,
        platforms: {instagram: 1},
      },
    } as unknown as Intake.OrganizerIntakeItem;

    expect(organizerEntityQueueItem(item)).toMatchObject({
      id: organizerEntityEntryId(item.entityId),
      title: "AFTER FLY",
      description: "Organizer · Indore",
    });
    expect(organizerEntityEntryId(item.entityId)).toBe("entity:afterfly");
  });
});

describe("organizer intake age", () => {
  it("uses an injected clock for deterministic queue and visual states", () => {
    const nowMs = Date.parse("2026-07-27T12:00:00.000Z");
    const observedAt = "2026-07-14T12:00:00.000Z";

    expect(organizerIntakeAgeDays(observedAt, nowMs)).toBe(13);
    expect(organizerIntakeAgeLabel(observedAt, nowMs)).toBe("13d");
  });
});
