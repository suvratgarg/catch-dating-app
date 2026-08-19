import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const getEventRehearsalGuestBootstrap = vi.hoisted(() => vi.fn());
const submitEventRehearsalGuestAction = vi.hoisted(() => vi.fn());

vi.mock("../../firebase", () => ({
  getEventRehearsalGuestBootstrap,
  submitEventRehearsalGuestAction,
}));

import {useEventRehearsalController} from "./useEventRehearsalController";

const bootstrap = {
  slotToken: "slot_1234567890123456_token_12345678901234567890",
  practiceBanner: "Practice",
  session: {
    title: "Practice",
    locationName: "Studio",
    status: "running",
    activeStepIndex: 1,
    virtualNowMillis: 1,
    attendeePrompt: "Say hello",
    moduleIds: ["arrival"],
    runtimeRevision: 1,
    faultId: "none",
  },
  actor: {
    actorId: "actor-01",
    displayName: "Rhea",
    status: "expected",
    guestMoment: "checkIn",
    optedOut: false,
    helpRequested: false,
    promptCompleted: false,
  },
} as const;

function wrapper() {
  const client = new QueryClient({
    defaultOptions: {queries: {retry: false}, mutations: {retry: false}},
  });
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  };
}

describe("useEventRehearsalController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    window.sessionStorage.clear();
    getEventRehearsalGuestBootstrap.mockResolvedValue(bootstrap);
    submitEventRehearsalGuestAction.mockResolvedValue({
      ...bootstrap,
      session: {...bootstrap.session, runtimeRevision: 2},
      actor: {...bootstrap.actor, status: "present"},
    });
  });

  it("redeems one anonymous browser slot without auth or OTP", async () => {
    const {result, unmount} = renderHook(
      () => useEventRehearsalController("practice_12345678901234567890"),
      {wrapper: wrapper()}
    );
    await waitFor(() => expect(result.current.bootstrap?.actor.actorId)
      .toBe("actor-01"));
    expect(getEventRehearsalGuestBootstrap).toHaveBeenCalledWith(
      expect.objectContaining({
        publicRehearsalId: "practice_12345678901234567890",
        clientInstanceId: expect.any(String),
        viewerToken: null,
        slotToken: null,
      })
    );
    expect(window.sessionStorage.getItem(
      "catch:event-rehearsal:slot:practice_12345678901234567890"
    )).toBe(bootstrap.slotToken);
    unmount();
  });

  it("applies a guest action to the cached synthetic projection", async () => {
    const {result, unmount} = renderHook(
      () => useEventRehearsalController("practice_12345678901234567890"),
      {wrapper: wrapper()}
    );
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    act(() => result.current.submit("checkIn"));
    await waitFor(() => expect(result.current.bootstrap?.actor.status)
      .toBe("present"));
    expect(submitEventRehearsalGuestAction).toHaveBeenCalledWith(
      expect.objectContaining({
        publicRehearsalId: "practice_12345678901234567890",
        slotToken: bootstrap.slotToken,
        action: "checkIn",
        clientActionId: expect.stringMatching(/^guest_/u),
      })
    );
    unmount();
  });
});
