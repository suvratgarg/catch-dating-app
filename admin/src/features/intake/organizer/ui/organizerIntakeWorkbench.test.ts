import {describe, expect, it} from "vitest";

import type * as Intake from "../types/organizerIntakeTypes";
import {
  organizerEntityEntryId,
  organizerEntityQueueItem,
} from "./organizerIntakeWorkbench";

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
