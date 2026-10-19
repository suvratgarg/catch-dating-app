import {act, cleanup, render, screen} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {PublicProviders} from "./PublicProviders";
import {usePublicHostListings} from "../../features/organizers/usePublicEventListingsController";
import {hostListings} from "../../features/organizers/data";
function Probe() {
  const {listings, phase} = usePublicHostListings();
  return <output>{phase}:{listings[0]?.reviews[0]?.comment ?? "none"}</output>;
}
afterEach(() => {cleanup(); vi.useRealTimers(); vi.unstubAllGlobals();});
it("refreshes the current detail route and replaces withdrawn reviews without stale merging", async () => {
  vi.useFakeTimers();
  vi.spyOn(document, "hidden", "get").mockReturnValue(false);
  const review = {id: "review", eventId: "earlier", reviewerName: "Guest", rating: 5,
    comment: "Published feedback", createdAt: "2026-01-01", verificationStatus: "verified" as const,
    source: "catchEvent" as const, isAnonymous: false, ownerResponse: null};
  const listing = {...hostListings[0], reviews: [review]};
  const fetcher = vi.fn().mockImplementation(async () => ({ok: true, json: async () => ({listings: [{...listing, reviews: []}], readAt: Date.now()})}));
  vi.stubGlobal("fetch", fetcher);
  render(<PublicProviders catalog={{listings: [listing], readAt: Date.now()}} pathname="/events/detail/">
    <Probe />
  </PublicProviders>);
  expect(screen.getByText("ready:Published feedback")).toBeTruthy();
  await act(async () => {await vi.advanceTimersByTimeAsync(25_000);});
  expect(fetcher.mock.calls[0][0]).toBe("/api/public-catalog?path=%2Fevents%2Fdetail%2F");
  expect(screen.getByText("ready:none")).toBeTruthy();
});
