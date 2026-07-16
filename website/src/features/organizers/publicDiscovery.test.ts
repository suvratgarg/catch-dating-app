import {describe, expect, it} from "vitest";
import {activeFeaturedCity, activeMarket} from "../../content/markets";
import {hostListings} from "./data";
import type {HostListingCatchEvent} from "./types";
import {
  activityForKind,
  buildPublicEventSummaries,
  buildPublicSearchSuggestions,
} from "./publicDiscovery";

describe("public discovery models", () => {
  it("builds eligible event cards with stable deep links", () => {
    const events = buildPublicEventSummaries([{
      ...hostListings[0],
      city: activeFeaturedCity.label,
      catchEvents: [{
        id: "future-event",
        title: hostListings[0].name,
        startTime: "2099-01-01T10:00:00.000Z",
        activityKind: "dinner",
        date: "1 January 2099",
        location: "Delhi",
        priceLabel: "₹1,500",
        bookedCount: 12,
        capacityLimit: 20,
        waitlistedCount: 2,
        summary: "A future dinner",
      } as HostListingCatchEvent],
    }], {
      now: Date.parse("2026-01-01T00:00:00.000Z"),
      cities: activeMarket.cities,
    });
    expect(events.length).toBeGreaterThan(0);
    expect(events[0]).toMatchObject({
      hostName: expect.any(String),
      href: expect.stringMatching(/^\/organizers\/.+#event-/u),
      activityToken: expect.any(String),
    });
  });

  it("deduplicates format suggestions and normalizes activity kinds", () => {
    const suggestions = buildPublicSearchSuggestions(hostListings, []);
    const formatIds = suggestions.filter((item) => item.type === "format").map((item) => item.id);
    expect(new Set(formatIds).size).toBe(formatIds.length);
    expect(activityForKind("social-run").token).toContain("social-run");
  });
});
