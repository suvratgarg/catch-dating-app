import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "../organizers/data";

const requestClubClaim = vi.hoisted(() => vi.fn());
const trackMarketingEvent = vi.hoisted(() => vi.fn());
const watchClaimAuthState = vi.hoisted(() => vi.fn((callback: (user: null) => void) => {
  callback(null);
  return vi.fn();
}));

vi.mock("../../analytics", () => ({trackMarketingEvent}));
vi.mock("../../firebase", () => ({
  requestClubClaim,
  signInForClaim: vi.fn(),
  signOutClaimUser: vi.fn(),
  watchClaimAuthState,
}));
vi.mock("../../firebaseConfig", () => ({claimFirebaseConfigured: false}));

import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {useListingClaimController} from "./useListingClaimController";
import {useClaimRequestMutation} from "./useClaimRequestMutation";

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

describe("useClaimRequestMutation", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("submits the typed claim packet and refreshes both claim query families", async () => {
    requestClubClaim.mockResolvedValue({claimId: "claim-1", status: "pending"});
    const {client, wrapper} = queryHarness();
    const invalidateQueries = vi.spyOn(client, "invalidateQueries");
    const {result} = renderHook(() => useClaimRequestMutation("afterfly"), {wrapper});
    const payload = {
      clubId: "afterfly",
      requesterName: "A Host",
      requesterRole: "owner" as const,
      businessEmail: "host@example.com",
      businessPhone: null,
      proofUrls: ["https://example.com/proof"],
      message: "I run this organizer.",
    };

    await act(async () => {
      await result.current.mutateAsync(payload);
    });

    expect(requestClubClaim).toHaveBeenCalledWith(payload);
    expect(invalidateQueries).toHaveBeenCalledWith({
      queryKey: websiteQueryKeys.claims.lookup("afterfly"),
    });
    expect(invalidateQueries).toHaveBeenCalledWith({
      queryKey: websiteQueryKeys.claims.requests(),
    });
  });

  it("blocks a listing claim before mutation when its public API is disabled", async () => {
    const listing = hostListings[0];
    const {wrapper} = queryHarness();
    const {result} = renderHook(() => useListingClaimController(listing), {wrapper});
    const form = document.createElement("form");

    await waitFor(() => expect(result.current.authReady).toBe(true));
    await act(async () => {
      await result.current.handleSubmit({
        currentTarget: form,
        preventDefault: vi.fn(),
      } as never);
    });

    expect(result.current.status).toEqual({
      message: listing.publicApi.reason,
      tone: "is-error",
    });
    expect(requestClubClaim).not.toHaveBeenCalled();
    expect(trackMarketingEvent).not.toHaveBeenCalledWith(
      "listing_claim_submit_attempt",
      expect.anything()
    );
  });
});
