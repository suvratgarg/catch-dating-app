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

    expect(result.current.nav.some((item) => item.href === "#reviews")).toBe(true);
    act(() => result.current.handleSaveListing());
    expect(result.current.isSaved).toBe(true);
    expect(JSON.parse(window.localStorage.getItem("catch_saved_organizers_v1") ?? "[]"))
      .toContain(listing.id);
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
