import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {describe, expect, it, vi} from "vitest";
import {hostListings} from "../organizers/data";
import type {HostListing} from "../organizers/types";
import {websiteCopy} from "@content/generated";

const trackMarketingEvent = vi.hoisted(() => vi.fn());
const watchClaimAuthState = vi.hoisted(() => vi.fn((callback: (user: null) => void) => {
  callback(null);
  return vi.fn();
}));

vi.mock("../../analytics", () => ({trackMarketingEvent}));
vi.mock("../../firebase", () => ({
  requestClubClaim: vi.fn(),
  signInForClaim: vi.fn(),
  signOutClaimUser: vi.fn(),
  watchClaimAuthState,
}));
vi.mock("../../firebaseConfig", () => ({claimFirebaseConfigured: false}));

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
    publicApi: {...hostListings[0].publicApi, state: "enabled", reason: ""},
  };
}

describe("useClaimFlowController", () => {
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
});
