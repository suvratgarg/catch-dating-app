import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
const getView = vi.hoisted(() => vi.fn());
const submitReply = vi.hoisted(() => vi.fn());
vi.mock("../../firebase", () => ({
  getEventAssistanceGuestView: getView, submitEventAssistanceGuestChoice: submitReply,
}));
import {useEventAssistanceController} from "./useEventAssistanceController";
import {guestUpdateFixture as view} from "../../content/eventAssistance";
import {assistanceCredential, guestSnapshot, newerGuestSnapshot} from "./eventAssistanceModel";

const credential = {linkId: "a".repeat(32), secret: "b".repeat(43)};
function harness(input: typeof credential | null = credential) {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {...renderHook(() => useEventAssistanceController(input), {wrapper}), client};
}
function answered() {
  return {...view, serverTime: view.serverTime + 1, guestRevision: 1,
    response: {label: "I’m on my way", receivedAt: view.serverTime + 1}, choices: []};
}

describe("scoped guest response controller", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    getView.mockResolvedValue(view);
    submitReply.mockResolvedValue({result: {kind: "accepted"}, view: answered()});
  });
  afterEach(() => vi.restoreAllMocks());

  it("does not call an endpoint for a missing credential", () => {
    const h = harness(null);
    expect(h.result.current.screen).toEqual({kind: "unavailable", reason: "invalid"});
    expect(getView).not.toHaveBeenCalled();
    h.unmount();
  });

  it("locks rapid taps and keeps credentials out of query and mutation state", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.screen.kind).toBe("ready"));
    act(() => { h.result.current.submit("on-my-way"); h.result.current.submit("help"); });
    await waitFor(() => expect(h.result.current.screen).toMatchObject({
      kind: "ready", view: {response: {label: "I’m on my way"}},
    }));
    expect(submitReply).toHaveBeenCalledTimes(1);
    expect(submitReply).toHaveBeenCalledWith({...credential,
      intentId: view.intentId, intentRevision: view.intentRevision,
      expectedGuestRevision: view.guestRevision, choiceId: "on-my-way",
      requestId: expect.any(String)});
    const states = [h.client.getQueryCache().getAll().map((q) => [q.queryKey, q.state]),
      h.client.getMutationCache().getAll().map((m) => [m.options.mutationKey, m.state])];
    expect(JSON.stringify(states)).not.toContain(credential.secret);
    expect(JSON.stringify(states)).not.toContain(credential.linkId);
    h.unmount();
  });

  it("reuses the request after uncertainty and withholds a different choice", async () => {
    submitReply.mockRejectedValueOnce(new Error("Network timeout"));
    const h = harness();
    await waitFor(() => expect(h.result.current.screen.kind).toBe("ready"));
    act(() => h.result.current.submit("on-my-way"));
    await waitFor(() => expect(h.result.current.screen).toMatchObject({
      kind: "ready", retryChoice: "on-my-way", pending: false,
    }));
    act(() => h.result.current.submit("not-coming"));
    expect(submitReply).toHaveBeenCalledTimes(1);
    act(() => h.result.current.submit("on-my-way"));
    await waitFor(() => expect(submitReply).toHaveBeenCalledTimes(2));
    expect(submitReply.mock.calls[1][0]).toEqual(submitReply.mock.calls[0][0]);
    await waitFor(() => expect(h.result.current.screen).toMatchObject({
      kind: "ready", view: {response: {label: "I’m on my way"}},
    }));
    h.unmount();
  });

  it("a late reply cannot recreate a private cache after leaving the page", async () => {
    let resolve: (value: unknown) => void = () => undefined;
    submitReply.mockReturnValue(new Promise((done) => { resolve = done; }));
    const h = harness();
    await waitFor(() => expect(h.result.current.screen.kind).toBe("ready"));
    act(() => h.result.current.submit("on-my-way"));
    await waitFor(() => expect(submitReply).toHaveBeenCalledOnce());
    h.unmount();
    await waitFor(() => expect(h.client.getQueryCache().getAll()).toHaveLength(0));
    await act(async () => resolve({result: {kind: "accepted"}, view: answered()}));
    expect(h.client.getQueryCache().getAll()).toHaveLength(0);
  });

  it("old rendered handlers cannot reply to replacement instructions", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.screen.kind).toBe("ready"));
    const oldSubmit = h.result.current.submit;
    getView.mockResolvedValue({...view, intentId: "new-message", intentRevision: 2,
      serverTime: view.serverTime + 1});
    act(() => h.result.current.refresh());
    await waitFor(() => expect(h.result.current.screen).toMatchObject({
      kind: "ready", view: {intentId: "new-message"},
    }));
    act(() => oldSubmit("on-my-way"));
    expect(submitReply).not.toHaveBeenCalled();
    act(() => h.result.current.submit("on-my-way"));
    await waitFor(() => expect(submitReply).toHaveBeenCalledTimes(1));
    expect(submitReply.mock.calls[0][0].intentId).toBe("new-message");
    h.unmount();
  });

  it("rechecks expiry at the tap even before a timer repaint", async () => {
    const clock = vi.spyOn(performance, "now").mockReturnValue(100);
    getView.mockResolvedValue({...view, expiresAt: view.serverTime + 5_000});
    const h = harness();
    await waitFor(() => expect(h.result.current.screen.kind).toBe("ready"));
    clock.mockReturnValue(5_101);
    act(() => h.result.current.submit("on-my-way"));
    expect(submitReply).not.toHaveBeenCalled();
    h.unmount();
  });

  it("a failed refresh disables replies; revoked access clears the view", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.screen.kind).toBe("ready"));
    getView.mockRejectedValue(new Error("Offline"));
    act(() => h.result.current.refresh());
    await waitFor(() => expect(h.result.current.screen).toMatchObject({kind: "ready", fresh: false}));
    act(() => h.result.current.submit("help"));
    expect(submitReply).not.toHaveBeenCalled();
    getView.mockRejectedValue(Object.assign(new Error("Unavailable"), {code: "functions/not-found"}));
    act(() => h.result.current.refresh());
    await waitFor(() => expect(h.result.current.screen).toEqual({kind: "unavailable", reason: "invalid"}));
    h.unmount();
  });
});

it("uses only a correctly scoped fragment and conservative server validity", () => {
  expect(assistanceCredential(credential.linkId, "#" + credential.secret)).toEqual(credential);
  expect(assistanceCredential(credential.linkId, "?secret=" + credential.secret)).toBeNull();
  expect(assistanceCredential("../other", "#" + credential.secret)).toBeNull();
  const snapshot = guestSnapshot({...view, expiresAt: view.serverTime + 20}, 10);
  expect(snapshot.freshUntil).toBe(30);
  const confirmed = guestSnapshot(answered(), 20);
  expect(newerGuestSnapshot(confirmed, guestSnapshot(view, 50))).toBe(confirmed);
  expect(newerGuestSnapshot(confirmed, guestSnapshot({...view, serverTime: answered().serverTime}, 50)))
    .toBe(confirmed);
});
