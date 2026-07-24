import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "../organizers/data";
import type {HostListing} from "../organizers/types";
import {websiteCopy} from "@content/generated";

const trackMarketingEvent = vi.hoisted(() => vi.fn());
const requestOrganizerClaim = vi.hoisted(() => vi.fn());
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

import {useClaimFlowController} from "./useClaimFlowController";

function wrapper() {
  const client = new QueryClient({defaultOptions: {mutations: {retry: false}}});
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
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

describe("useClaimFlowController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    claimRuntime.configured = false;
    claimRuntime.user = null;
  });

  it("returns an empty claim route to listing selection on submit", async () => {
    const {result} = renderHook(() => useClaimFlowController(), {wrapper: wrapper()});

    await act(async () => result.current.handleClaimSubmit({preventDefault: vi.fn()} as never));

    expect(result.current.step).toBe("listing");
    expect(result.current.status).toEqual({
      message: websiteCopy["useclaimflowcontroller_0102"],
      tone: "is-error",
    });
  });

  it("validates a preselected route before attempting an unconfigured write", async () => {
    const listing = enabledListing();
    const {result} = renderHook(() => useClaimFlowController({
      listing,
      lookup: listing.id,
      requestId: null,
      urlState: null,
    }), {wrapper: wrapper()});

    await waitFor(() => expect(result.current.authReady).toBe(true));
    act(() => {
      result.current.setRequesterName("A Host");
      result.current.setBusinessEmail("host@example.com");
    });
    expect(result.current.canContinueRole).toBe(true);
    await act(async () => result.current.handleClaimSubmit({preventDefault: vi.fn()} as never));

    expect(result.current.status).toEqual({
      message: websiteCopy["useclaimflowcontroller_0104"],
      tone: "is-error",
    });
    expect(trackMarketingEvent).not.toHaveBeenCalledWith(
      "claim_flow_submit_attempt",
      expect.anything()
    );
  });

  it("freezes claim fields, steps, auth, and duplicate submits while pending", async () => {
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
    const {result} = renderHook(() => useClaimFlowController({
      listing,
      lookup: listing.id,
      requestId: null,
      urlState: null,
    }), {wrapper: wrapper()});

    await waitFor(() => expect(result.current.authReady).toBe(true));
    act(() => {
      result.current.setRequesterName("A Host");
      result.current.setBusinessEmail("host@example.com");
      result.current.setMessage("Original review message");
      result.current.setStep("verify");
    });
    const event = {preventDefault: vi.fn()} as never;
    let firstSubmit!: Promise<void>;

    act(() => {
      firstSubmit = result.current.handleClaimSubmit(event);
    });
    await waitFor(() => expect(result.current.isSubmitting).toBe(true));

    act(() => {
      result.current.setMessage("Changed message");
      result.current.setVerificationMethod("email");
      result.current.setStep("role");
      void result.current.handleSignOut();
      void result.current.handleClaimSubmit(event);
    });

    expect(requestOrganizerClaim).toHaveBeenCalledTimes(1);
    expect(signOutClaimUser).not.toHaveBeenCalled();
    expect(result.current.message).toBe("Original review message");
    expect(result.current.verificationMethod).toBe("publicProof");
    expect(result.current.step).toBe("verify");

    resolveClaim({requestId: "claim-1"});
    await act(async () => firstSubmit);
    expect(result.current.step).toBe("submitted");
    expect(result.current.activeRequestId).toBe("claim-1");
  });
});
