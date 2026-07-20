import {describe, expect, it} from "vitest";
import {activeFeaturedCity, activeMarket} from "../../content/markets";
import {hostListings} from "./data";
import type {
  HostListing,
  HostListingCatchEvent,
  HostListingExternalEvent,
} from "./types";
import {
  activityForKind,
  buildPublicEventSummaries,
  buildPublicSearchSuggestions,
  eventActionCardForListing,
  externalEventActionCardForListing,
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

  it("labels past Catch-event review links as organizer reviews", () => {
    const event = {
      id: "past-event",
      activityKind: "dinner",
      timeline: "past",
      startTime: "2020-01-01T10:00:00.000Z",
      title: "Past dinner",
      date: "1 January 2020",
      location: "Delhi",
      priceLabel: "₹1,500",
      capacityLimit: 20,
      bookedCount: 12,
      checkedInCount: 10,
      waitlistedCount: 0,
      summary: "A past dinner",
    } as HostListingCatchEvent;

    const card = eventActionCardForListing(hostListings[0], event);

    expect(card.actions[1]).toMatchObject({
      href: "#reviews",
      label: "Read organizer reviews",
      trackingLabel: "listing_organizer_reviews",
    });
  });

  it("offers external-event claiming only for claimable organizers", () => {
    const event = {
      id: "external-event",
      activityKind: "socialRun",
      startTime: "2099-01-01T10:00:00.000Z",
      title: "External run",
      date: "1 January 2099",
      location: "Delhi",
      priceLabel: "External ticketing",
      sourceLabel: "Luma",
      sourceHref: "https://lu.ma/example",
      externalLinkCount: 1,
      summary: "An external run",
    } as HostListingExternalEvent;
    const disabledCard = externalEventActionCardForListing(hostListings[0], event);
    const claimableListing = {
      ...hostListings[0],
      publicApi: {...hostListings[0].publicApi, state: "enabled", reason: ""},
    } as HostListing;
    const enabledCard = externalEventActionCardForListing(claimableListing, event);

    expect(disabledCard.actions).toHaveLength(1);
    expect(disabledCard.actions[0].trackingLabel).toBe("external_event_source");
    expect(enabledCard.actions.map((action) => action.trackingLabel)).toEqual([
      "external_event_source",
      "external_event_claim",
    ]);
  });
});
