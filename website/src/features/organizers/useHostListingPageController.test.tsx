import {act, renderHook} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "./data";

const trackMarketingEvent = vi.hoisted(() => vi.fn());
const trackOrganizerAnalytics = vi.hoisted(() => vi.fn());

vi.mock("../../analytics", () => ({trackMarketingEvent}));
vi.mock("./analytics", () => ({trackOrganizerAnalytics}));

import {useHostListingPageController} from "./useHostListingPageController";

describe("useHostListingPageController", () => {
  beforeEach(() => {
    window.localStorage.clear();
    vi.clearAllMocks();
  });

  it("persists organizer saves and exposes event-aware navigation", () => {
    const listing = hostListings[0];
    const {result} = renderHook(() => useHostListingPageController(listing));

    expect(result.current.nav).toContainEqual({href: "#about", label: "About"});
    expect(result.current.nav).toContainEqual({href: "#reviews", label: "Reviews"});
    expect(result.current.nav.some((item) => item.href === "#events")).toBe(
      Boolean(listing.catchEvents?.length || listing.externalEvents?.length)
    );
    expect(result.current.nav.map((item) => item.href)).toEqual(
      result.current.hasEventSupply ? ["#events", "#about", "#reviews"] : listing.eventEvidence?.length ? ["#event-evidence", "#about", "#reviews"] : ["#about", "#reviews"]
    );
    expect(result.current.footerLinks.map((item) => item.href)).toEqual(expect.arrayContaining([
      "/host/", "#profile", "#fit", "/organizers/",
    ]));
    act(() => result.current.handleSaveListing());
    expect(result.current.isSaved).toBe(true);
    expect(JSON.parse(window.localStorage.getItem("catch_saved_organizers_v1") ?? "[]"))
      .toContain(listing.id);
  });

  it("exposes Events for external-only supply without inventing a booking action", () => {
    const listing = {...hostListings[0], catchEvents: [], externalEvents: [{
      id: "external-test", title: "Official-source event", activityKind: "socialRun",
      availability: "read_only_external" as const, startTime: "2099-01-01T10:00:00Z",
      endTime: null, date: "Jan 1, 2099", location: "Mumbai", summary: "Public event",
      priceLabel: "See source", sourceLabel: "Official source",
      sourceHref: "https://example.com/events/official", externalLinkCount: 1,
      dedupeKey: "official-test",
    }]};
    const {result} = renderHook(() => useHostListingPageController(listing));
    expect(result.current.nav).toContainEqual({href: "#events", label: "Events"});
    expect(result.current.hasEventSupply).toBe(true);
  });

  it("uses the clipboard fallback and reports a successful share", async () => {
    const listing = hostListings[0];
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", {
      configurable: true,
      value: {writeText},
    });
    const {result} = renderHook(() => useHostListingPageController(listing));

    await act(async () => result.current.handleShareListing());

    expect(writeText).toHaveBeenCalledWith(expect.stringContaining(listing.path));
    expect(result.current.shareStatus).toBe("Listing link copied.");
    expect(trackMarketingEvent).toHaveBeenCalledWith("listing_share_completed", {
      club_id: listing.id,
      method: "clipboard",
    });
  });
});
