import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
const getView = vi.hoisted(() => vi.fn());
const submitRsvp = vi.hoisted(() => vi.fn());
vi.mock("../../firebase", () => ({
  getProgramHouseholdRsvpView: getView,
  submitProgramHouseholdRsvp: submitRsvp,
}));
import {useHouseholdRsvpController} from "./useHouseholdRsvpController";
import {householdRsvpViewFixture} from "../../content/householdRsvp";
import {draftFor, draftsFromView, householdRsvpCredential} from "./householdRsvpModel";
import type {ProgramHouseholdRsvpViewCallableResponse} from "../../shared/contracts/generated/programHouseholdRsvpViewCallableResponse";
const view: ProgramHouseholdRsvpViewCallableResponse = householdRsvpViewFixture;

const token = "cHJvZ3JhbUlkLXBhY2thZ2UtcGF5bG9hZA.c2lnbmF0dXJlLXBhcnQ";
const credential = {token};

function harness(input: typeof credential | null = credential) {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {...renderHook(() => useHouseholdRsvpController(input), {wrapper}),
    client};
}

describe("household RSVP controller", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    getView.mockResolvedValue(view);
    submitRsvp.mockResolvedValue({
      entityId: "fixture-household", revision: 2, appliedCount: 2,
      messagingConsentGranted: true, alreadyApplied: false,
    });
  });
  afterEach(() => vi.restoreAllMocks());

  it("accepts only well-formed path tokens as credentials", () => {
    expect(householdRsvpCredential(token)).toEqual(credential);
    expect(householdRsvpCredential(undefined)).toBeNull();
    expect(householdRsvpCredential("short")).toBeNull();
    expect(householdRsvpCredential("no-dot-but-long-enough-value")).toBeNull();
    expect(householdRsvpCredential("has space.init")).toBeNull();
  });

  it("does not call an endpoint for a missing credential", () => {
    const h = harness(null);
    expect(h.result.current.screen)
      .toEqual({kind: "unavailable", reason: "invalid"});
    expect(getView).not.toHaveBeenCalled();
    h.unmount();
  });

  it("seeds drafts from the view and stays clean until edited", async () => {
    const h = harness();
    await waitFor(() =>
      expect(h.result.current.screen.kind).toBe("ready"));
    const screen = h.result.current.screen;
    if (screen.kind !== "ready") throw new Error("expected ready");
    expect(screen.dirty).toBe(false);
    expect(draftFor(screen.drafts, "fixture-guest-1", "fixture-sangeet"))
      .toMatchObject({rsvpStatus: "pending"});
    expect(draftFor(screen.drafts, "fixture-guest-1", "fixture-reception"))
      .toMatchObject({rsvpStatus: "attending", partySize: 2});
    expect(getView).toHaveBeenCalledWith(credential);
    h.unmount();
  });

  it("submits the full draft map with the explicit consent flag", async () => {
    const h = harness();
    await waitFor(() =>
      expect(h.result.current.screen.kind).toBe("ready"));
    // Refetches after submit echo the confirmed edits.
    getView.mockResolvedValue({
      ...view,
      messagingConsentGranted: true,
      members: view.members.map((member) => ({
        ...member,
        functions: member.functions.map((fn) =>
          member.guestId === "fixture-guest-1" &&
            fn.functionId === "fixture-sangeet" ?
            {...fn, rsvpStatus: "attending" as const, partySize: 3} : fn),
      })),
    });
    act(() => {
      h.result.current.setResponse(
        "fixture-guest-1", "fixture-sangeet", {rsvpStatus: "attending",
          partySize: 3});
      h.result.current.setConsent(true);
    });
    let screen = h.result.current.screen;
    if (screen.kind !== "ready") throw new Error("expected ready");
    expect(screen.dirty).toBe(true);
    act(() => { h.result.current.submit(); h.result.current.submit(); });
    await waitFor(() => {
      const next = h.result.current.screen;
      expect(next.kind === "ready" && next.submitted).toBe(true);
    });
    expect(submitRsvp).toHaveBeenCalledTimes(1);
    expect(submitRsvp).toHaveBeenCalledWith({
      token,
      messagingConsent: true,
      responses: expect.arrayContaining([
        expect.objectContaining({
          guestId: "fixture-guest-1", functionId: "fixture-sangeet",
          rsvpStatus: "attending", partySize: 3}),
      ]),
    });
    screen = h.result.current.screen;
    if (screen.kind !== "ready") throw new Error("expected ready");
    expect(screen.dirty).toBe(false);
    h.unmount();
  });

  it("does not submit when nothing changed", async () => {
    const h = harness();
    await waitFor(() =>
      expect(h.result.current.screen.kind).toBe("ready"));
    act(() => { h.result.current.submit(); });
    expect(submitRsvp).not.toHaveBeenCalled();
    h.unmount();
  });

  it("re-seeds drafts after a manual refresh", async () => {
    const h = harness();
    await waitFor(() =>
      expect(h.result.current.screen.kind).toBe("ready"));
    act(() => {
      h.result.current.setResponse(
        "fixture-guest-1", "fixture-sangeet", {rsvpStatus: "declined"});
    });
    let screen = h.result.current.screen;
    if (screen.kind !== "ready") throw new Error("expected ready");
    expect(screen.dirty).toBe(true);
    act(() => { h.result.current.refresh(); });
    await waitFor(() => {
      const next = h.result.current.screen;
      expect(next.kind === "ready" && !next.dirty).toBe(true);
    });
    screen = h.result.current.screen;
    if (screen.kind !== "ready") throw new Error("expected ready");
    expect(draftFor(screen.drafts, "fixture-guest-1", "fixture-sangeet"))
      .toMatchObject({rsvpStatus: "pending"});
    h.unmount();
  });

  it("maps unauthenticated errors to the unavailable state", async () => {
    getView.mockRejectedValueOnce(
      Object.assign(new Error("nope"), {code: "functions/unauthenticated"}));
    const h = harness();
    await waitFor(() =>
      expect(h.result.current.screen)
        .toEqual({kind: "unavailable", reason: "invalid"}));
    h.unmount();
  });
});
