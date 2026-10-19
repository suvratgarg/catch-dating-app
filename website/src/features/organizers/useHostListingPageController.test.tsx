import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {PropsWithChildren} from "react";
import {waitFor} from "@testing-library/react";
const accountApi = vi.hoisted(() => ({watch: vi.fn(), read: vi.fn(), follow: vi.fn()}));
vi.mock("../../firebase", async (original) => ({...await original<object>(), watchWebsiteAccountAuthState: accountApi.watch,
  manageWebsiteAccount: accountApi.read, setWebsiteOrganizerFollow: accountApi.follow}));
const wrapper = ({children}: PropsWithChildren) => <QueryClientProvider client={new QueryClient({defaultOptions: {queries: {retry: false}}})}>{children}</QueryClientProvider>;
import {act, renderHook} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "./data";

const trackMarketingEvent = vi.hoisted(() => vi.fn());
const trackOrganizerAnalytics = vi.hoisted(() => vi.fn());

vi.mock("../../analytics", () => ({trackMarketingEvent, getMarketingConsent: () => null, marketingConsentChangedEvent: "catch:marketing-consent-changed"}));
vi.mock("./analytics", () => ({trackOrganizerAnalytics, observeOrganizerPageView: vi.fn(() => () => undefined)}));

import {useHostListingPageController} from "./useHostListingPageController";

describe("useHostListingPageController", () => {
  beforeEach(() => {
    window.localStorage.clear();
    vi.clearAllMocks();
    accountApi.watch.mockImplementation((callback) => {callback({uid: "one", phoneNumber: "+919876543210"}); return vi.fn();});
    accountApi.read.mockResolvedValue({uid: "one", accountReady: true, following: false, displayName: "Ada", profileRevision: 1, eventAge: null});
    accountApi.follow.mockImplementation(async (_id, following) => {
      accountApi.read.mockResolvedValue({uid: "one", accountReady: true, following, displayName: "Ada", profileRevision: 1, eventAge: null});
      return {following};
    });
  });

  it("persists account-backed follows and exposes event-aware navigation", async () => {
    const listing = hostListings[0];
    const {result} = renderHook(() => useHostListingPageController(listing), {wrapper});

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
    await waitFor(() => expect(result.current.account.ready).toBe(true));
    act(() => result.current.handleFollowListing());
    await waitFor(() => expect(result.current.isFollowing).toBe(true));
    expect(accountApi.follow).toHaveBeenCalledWith(listing.id, true, "one");
    expect(window.localStorage.getItem("catch_saved_organizers_v1")).toBeNull();
    act(() => result.current.handleFollowListing());
    await waitFor(() => expect(result.current.isFollowing).toBe(false));

  });

  it("keeps following state unchanged when persistence fails", async () => {
    accountApi.follow.mockRejectedValueOnce(new Error("unavailable"));
    const {result} = renderHook(() => useHostListingPageController(hostListings[0]), {wrapper});
    await waitFor(() => expect(result.current.account.ready).toBe(true));
    act(() => result.current.handleFollowListing());
    await waitFor(() => expect(result.current.followError).not.toBe(""));
    expect(result.current.isFollowing).toBe(false);
  });

  it("resumes the requested follow after account completion", async () => {
    accountApi.read.mockResolvedValue({uid: "one", accountReady: false, following: false, displayName: "", profileRevision: 0, eventAge: null});
    const {result} = renderHook(() => useHostListingPageController(hostListings[0]), {wrapper});
    await waitFor(() => expect(result.current.account.loading).toBe(false));
    act(() => result.current.handleFollowListing());
    expect(result.current.followRequested).toBe(true);
    expect(accountApi.follow).not.toHaveBeenCalled();
    accountApi.read.mockResolvedValue({uid: "one", accountReady: true, following: false, displayName: "Ada", profileRevision: 1, eventAge: null});
    await act(async () => {await result.current.account.refresh();});
    await waitFor(() => expect(result.current.isFollowing).toBe(true));
    expect(accountApi.follow).toHaveBeenCalledTimes(1);
  });

  it("reads an existing follow on a new page mount", async () => {
    accountApi.read.mockResolvedValue({uid: "one", accountReady: true, following: true, displayName: "Ada", profileRevision: 1, eventAge: null});
    const {result} = renderHook(() => useHostListingPageController(hostListings[0]), {wrapper});
    await waitFor(() => expect(result.current.isFollowing).toBe(true));
    expect(accountApi.follow).not.toHaveBeenCalled();
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
    const {result} = renderHook(() => useHostListingPageController(listing), {wrapper});
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
    const {result} = renderHook(() => useHostListingPageController(listing), {wrapper});

    await act(async () => result.current.handleShareListing());

    expect(writeText).toHaveBeenCalledWith(expect.stringContaining(listing.path));
    expect(result.current.shareStatus).toBe("Listing link copied.");
    expect(trackMarketingEvent).toHaveBeenCalledWith("listing_share_completed", {
      club_id: listing.id,
      method: "clipboard",
    });
  });
});
