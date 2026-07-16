import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "../organizers/data";
import type {HostListing} from "../organizers/types";

const reviewConfig = vi.hoisted(() => ({enabled: false}));
const createPublicClubReview = vi.hoisted(() => vi.fn());
const listPublicClubReviews = vi.hoisted(() => vi.fn());
const trackMarketingEvent = vi.hoisted(() => vi.fn());

vi.mock("../../analytics", () => ({trackMarketingEvent}));
vi.mock("../../firebase", () => ({
  createPublicClubReview,
  listPublicClubReviews,
}));
vi.mock("../../firebaseConfig", () => ({
  get publicReviewsFirebaseConfigured() {
    return reviewConfig.enabled;
  },
}));

import {useListingReviewsController} from "./useListingReviewsController";

function queryHarness() {
  const client = new QueryClient({
    defaultOptions: {
      mutations: {retry: false},
      queries: {retry: false},
    },
  });
  return {
    client,
    wrapper({children}: PropsWithChildren) {
      return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
    },
  };
}

function enabledListing(): HostListing {
  return {
    ...hostListings[0],
    publicApi: {
      ...hostListings[0].publicApi,
      state: "enabled",
      reason: "",
    },
  };
}

function submitEvent() {
  return {
    currentTarget: document.createElement("form"),
    preventDefault: vi.fn(),
  } as never;
}

describe("useListingReviewsController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    reviewConfig.enabled = false;
    listPublicClubReviews.mockResolvedValue({reviews: []});
  });

  it("keeps disabled listing routes read-only", async () => {
    const listing = hostListings[0];
    const {wrapper} = queryHarness();
    const {result} = renderHook(() => useListingReviewsController(listing), {wrapper});

    act(() => {
      result.current.setComment("A thoughtful evening.");
      result.current.setReviewerName("Guest");
    });
    await act(async () => result.current.submitReview(submitEvent()));

    expect(result.current.status).toEqual({
      message: listing.publicApi.reason,
      tone: "is-error",
    });
    expect(createPublicClubReview).not.toHaveBeenCalled();
  });

  it("surfaces listing-review query failures without hiding seeded content", async () => {
    reviewConfig.enabled = true;
    listPublicClubReviews.mockRejectedValue(new Error("Reviews are temporarily unavailable."));
    const listing = enabledListing();
    const {wrapper} = queryHarness();
    const {result} = renderHook(() => useListingReviewsController(listing), {wrapper});

    await waitFor(() => expect(result.current.status).toEqual({
      message: "Reviews are temporarily unavailable.",
      tone: "is-error",
    }));
    expect(result.current.reviews).toEqual(listing.reviews);
  });

  it("validates review identity before creating a mutation", async () => {
    const {wrapper} = queryHarness();
    const {result} = renderHook(() => useListingReviewsController(enabledListing()), {wrapper});

    act(() => result.current.setComment("A thoughtful evening."));
    await act(async () => result.current.submitReview(submitEvent()));

    expect(result.current.status).toEqual({
      message: "Add your name, or choose anonymous.",
      tone: "is-error",
    });
    expect(createPublicClubReview).not.toHaveBeenCalled();
  });

  it("adds an unconfigured review locally and exposes it in the summary", async () => {
    const listing = enabledListing();
    const {wrapper} = queryHarness();
    const {result} = renderHook(() => useListingReviewsController(listing), {wrapper});

    act(() => {
      result.current.setComment("  Warm hosts and clear facilitation.  ");
      result.current.setReviewerName("  Guest  ");
      result.current.setRating(4);
    });
    await act(async () => result.current.submitReview(submitEvent()));

    expect(result.current.status).toEqual({
      message: "Preview review added locally. Configure website App Check to write it to Firestore.",
      tone: "is-success",
    });
    expect(result.current.reviews[0]).toMatchObject({
      comment: "Warm hosts and clear facilitation.",
      rating: 4,
      reviewerName: "Guest",
      source: "publicListing",
    });
    expect(result.current.summary.publicReviews).toHaveLength(1);
    expect(trackMarketingEvent).toHaveBeenCalledWith(
      "listing_public_review_submitted",
      expect.objectContaining({club_id: listing.id, configured: false})
    );
  });

  it("publishes configured reviews and refreshes the listing review query", async () => {
    reviewConfig.enabled = true;
    const listing = enabledListing();
    const remoteReview = {
      id: "review-1",
      reviewerName: "Guest",
      rating: 5,
      comment: "Would attend again.",
      createdAt: "2026-07-13T08:00:00.000Z",
      verificationStatus: "unverified" as const,
      source: "publicListing" as const,
      isAnonymous: false,
      ownerResponse: null,
    };
    createPublicClubReview.mockResolvedValue({reviewId: remoteReview.id, review: remoteReview});
    const {client, wrapper} = queryHarness();
    const invalidateQueries = vi.spyOn(client, "invalidateQueries");
    const {result} = renderHook(() => useListingReviewsController(listing), {wrapper});

    await waitFor(() => expect(listPublicClubReviews).toHaveBeenCalledWith({clubId: listing.id}));
    act(() => {
      result.current.setComment("Would attend again.");
      result.current.setReviewerName("Guest");
    });
    await act(async () => result.current.submitReview(submitEvent()));

    expect(createPublicClubReview).toHaveBeenCalledWith(expect.objectContaining({
      clubId: listing.id,
      comment: "Would attend again.",
      isAnonymous: false,
      rating: 5,
      reviewerName: "Guest",
    }));
    expect(invalidateQueries).toHaveBeenCalledWith({
      queryKey: ["website", "reviews", "listing", listing.id],
    });
    expect(result.current.status).toEqual({
      message: "Review published as an unverified public review.",
      tone: "is-success",
    });
    expect(result.current.reviews[0]).toMatchObject({id: "review-1"});
  });
});
