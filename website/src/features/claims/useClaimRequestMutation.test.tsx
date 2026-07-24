import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "../organizers/data";
import type {HostListing} from "../organizers/types";

const requestOrganizerClaim = vi.hoisted(() => vi.fn());
const trackMarketingEvent = vi.hoisted(() => vi.fn());
const signOutClaimUser = vi.hoisted(() => vi.fn());
const claimRuntime = vi.hoisted(() => ({
  configured: false,
  user: null as null | {
    displayName: string;
    email: string;
    uid: string;
  },
}));
const watchClaimAuthState = vi.hoisted(() => vi.fn((callback: (user: typeof claimRuntime.user) => void) => {
  callback(claimRuntime.user);
  return vi.fn();
}));

vi.mock("../../analytics", () => ({trackMarketingEvent}));
vi.mock("../../firebase", () => ({
  requestOrganizerClaim,
  signInForClaim: vi.fn(),
  signOutClaimUser,
  watchClaimAuthState,
}));
vi.mock("../../firebaseConfig", () => ({
  get claimFirebaseConfigured() {
    return claimRuntime.configured;
  },
}));

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

function enabledListing(): HostListing {
  return {
    ...hostListings[0],
    authority: {
      ...hostListings[0].authority,
      claimState: "unclaimed",
      ownershipState: "programmatic",
      publishStatus: "published",
    },
    capabilities: {
      ...hostListings[0].capabilities,
      claimRequest: {state: "enabled", reason: ""},
    },
  };
}

function claimForm() {
  const form = document.createElement("form");
  const values = {
    requesterName: "A Host",
    requesterRole: "owner",
    businessEmail: "host@example.com",
    businessPhone: "",
    proofUrls: "",
    message: "I run this organizer.",
  };
  for (const [name, value] of Object.entries(values)) {
    const input = document.createElement("input");
    input.name = name;
    input.value = value;
    form.appendChild(input);
  }
  return form;
}

describe("useClaimRequestMutation", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    claimRuntime.configured = false;
    claimRuntime.user = null;
  });

  it("submits the typed claim packet and refreshes both claim query families", async () => {
    requestOrganizerClaim.mockResolvedValue({claimId: "claim-1", status: "pending"});
    const {client, wrapper} = queryHarness();
    const invalidateQueries = vi.spyOn(client, "invalidateQueries");
    const {result} = renderHook(() => useClaimRequestMutation("afterfly"), {wrapper});
    const payload = {
      organizerId: "afterfly",
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

    expect(requestOrganizerClaim).toHaveBeenCalledWith(payload);
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
    expect(requestOrganizerClaim).not.toHaveBeenCalled();
    expect(trackMarketingEvent).not.toHaveBeenCalledWith(
      "listing_claim_submit_attempt",
      expect.anything()
    );
  });

  it("keeps listing claim submission and auth single-flight while pending", async () => {
    let resolveClaim!: (value: {requestId: string}) => void;
    requestOrganizerClaim.mockReturnValue(new Promise((resolve) => {
      resolveClaim = resolve;
    }));
    claimRuntime.configured = true;
    claimRuntime.user = {
      displayName: "A Host",
      email: "host@example.com",
      uid: "user-1",
    };
    const listing = enabledListing();
    const {wrapper} = queryHarness();
    const {result} = renderHook(
      () => useListingClaimController(listing),
      {wrapper}
    );
    const form = claimForm();
    const event = {currentTarget: form, preventDefault: vi.fn()} as never;
    let firstSubmit!: Promise<void>;

    await waitFor(() => expect(result.current.authReady).toBe(true));
    act(() => {
      firstSubmit = result.current.handleSubmit(event);
    });
    await waitFor(() => expect(result.current.isSubmitting).toBe(true));

    act(() => {
      void result.current.handleSignOut();
      void result.current.handleSubmit(event);
    });

    expect(requestOrganizerClaim).toHaveBeenCalledTimes(1);
    expect(signOutClaimUser).not.toHaveBeenCalled();

    resolveClaim({requestId: "claim-1"});
    await act(async () => firstSubmit);
    expect(result.current.status.tone).toBe("is-success");
  });
});
