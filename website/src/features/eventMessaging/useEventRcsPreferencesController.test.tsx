import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, fireEvent, render, renderHook, screen, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({list: vi.fn(), get: vi.fn(), set: vi.fn(),
  listeners: new Set<(user: {uid: string} | null) => void>()}));
vi.mock("../../firebase", () => ({listEventRcsPreferences: api.list,
  getEventRcsPreference: api.get, setEventRcsPreference: api.set,
  watchEventRuntimeAuthState: (listener: (user: {uid: string} | null) => void) => {
    api.listeners.add(listener); listener({uid: "guest-a"});
    return () => api.listeners.delete(listener);
  },
}));
import {useEventRcsPreferencesController} from "./useEventRcsPreferencesController";
import {EventRcsPreferencesPanel} from "./EventRcsPreferencesPanel";
import {rcsPreferenceOptions, rcsPreferenceResponse, newerRcsPreference} from "./rcsPreferenceModel";
import {rcsOptionsFixture as options, rcsPreferenceFixture as initial,
  rcsEnabledFixture as enabled} from "../../stories/fixtures/rcsPreferences";
import {eventRcsMessagingCopy as copy} from "../../content/eventMessaging";
import type {EventRcsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventRcsPreferenceOutput";

function setup() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {client, wrapper};
}
function harness() {
  const context = setup();
  return {...renderHook(() => useEventRcsPreferencesController("event", "attendee"), context), ...context};
}
function deferred<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((done) => { resolve = done; });
  return {promise, resolve};
}
function signIn(uid: string | null) {
  act(() => api.listeners.forEach((listener) => listener(uid ? {uid} : null)));
}
async function ready(h: ReturnType<typeof harness>) {
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
}

describe("verified RCS preferences", () => {
  beforeEach(() => {
    vi.resetAllMocks(); api.listeners.clear();
    api.list.mockResolvedValue(options);
    api.get.mockImplementation(async (scope) => ({...initial, view: {...initial.view, ...scope}}));
    api.set.mockResolvedValue(enabled);
  });
  afterEach(() => {cleanup(); vi.restoreAllMocks();});

  it("discovers only the current sender and sends the exact displayed review hash", async () => {
    const h = harness(); await ready(h);
    expect(api.list).toHaveBeenCalledWith({eventId: "event", attendeeId: "attendee", cursor: null});
    expect(api.get).toHaveBeenCalledOnce();
    act(() => { h.result.current.enable(); h.result.current.enable(); });
    await waitFor(() => expect(h.result.current.state).toMatchObject({view: {preference: "enabled"}}));
    expect(api.set).toHaveBeenCalledExactlyOnceWith({eventId: "event", attendeeId: "attendee",
      senderId: "catch-events", requestId: expect.any(String), expectedRevision: null,
      decision: {kind: "grant", copyVersion: initial.view.consent.version, reviewHash: initial.view.reviewHash}});
    act(() => h.result.current.refresh());
    await waitFor(() => expect(api.get.mock.calls.length).toBeGreaterThan(1));
    expect(h.result.current.state).toMatchObject({view: {preference: "enabled", revision: 1}});
    h.unmount();
  });

  it("rejects a stale click after STOP changes the review hash without changing revision", async () => {
    const h = harness(); await ready(h);
    const oldEnable = h.result.current.enable;
    const key = h.client.getQueryCache().getAll().find((q) => q.queryKey.includes("rcs-preference"))!.queryKey;
    act(() => {
      h.client.setQueryData(key, {...initial, view: {...initial.view,
        reviewHash: "b".repeat(64), canEnable: false, availability: "subscriptionUnavailable"}});
      oldEnable();
    });
    expect(api.set).not.toHaveBeenCalled();
    h.unmount();
  });

  it("keeps an uncertain save on the same sender and retries the identical request", async () => {
    api.set.mockRejectedValueOnce(new Error("Lost response"));
    const h = harness(); await ready(h);
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: true}));
    const reads = api.get.mock.calls.length;
    act(() => { h.result.current.manageEarlier(); h.result.current.disable(); h.result.current.refresh(); });
    expect(h.result.current.state).toMatchObject({view: {senderId: "catch-events"}});
    expect(api.get).toHaveBeenCalledTimes(reads);
    expect(api.set).toHaveBeenCalledOnce();
    act(() => h.result.current.retry());
    await waitFor(() => expect(api.set).toHaveBeenCalledTimes(2));
    expect(api.set.mock.calls[1][0]).toEqual(api.set.mock.calls[0][0]);
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: false}));
    h.unmount();
  });

  it("fences old callbacks and delayed results through A to B to A", async () => {
    const write = deferred<Response>(); api.set.mockReturnValueOnce(write.promise);
    const h = harness(); await ready(h);
    const oldEnable = h.result.current.enable;
    act(() => oldEnable());
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    signIn("guest-b"); signIn("guest-a");
    await ready(h);
    await act(async () => write.resolve(enabled));
    expect(h.result.current.state).toMatchObject({view: {preference: "notSet"}, pending: false});
    act(() => oldEnable());
    expect(api.set).toHaveBeenCalledOnce();
    h.unmount();
  });

  it("hides on sign-out and never restores private cache after unmount", async () => {
    const write = deferred<Response>(); api.set.mockReturnValueOnce(write.promise);
    const h = harness(); await ready(h);
    act(() => h.result.current.enable());
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    signIn(null);
    expect(h.result.current.state.kind).toBe("hidden");
    h.unmount();
    await waitFor(() => expect(h.client.getQueryCache().getAll()).toHaveLength(0));
    await act(async () => write.resolve(enabled));
    expect(h.client.getQueryCache().getAll()).toHaveLength(0);
  });

  it("keeps a new event usable while an old event save is unresolved", async () => {
    const write = deferred<Response>(); api.set.mockReturnValueOnce(write.promise);
    const context = setup();
    const page = render(<EventRcsPreferencesPanel eventId="event" attendeeId="attendee" />, context);
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOn}));
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    api.list.mockResolvedValue({...options, eventId: "other"});
    page.rerender(<EventRcsPreferencesPanel eventId="other" attendeeId="attendee" />);
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOn}));
    await waitFor(() => expect(api.set).toHaveBeenCalledTimes(2));
    expect(api.set.mock.calls[1][0].eventId).toBe("other");
    page.unmount(); await act(async () => write.resolve(enabled));
  });

  it("loads earlier senders on demand, permits withdrawal, and never offers re-enrollment", async () => {
    api.get.mockImplementation(async (scope) => ({...initial, view: {...enabled.view, ...scope,
      sender: {displayName: scope.senderId === "catch-events" ? "Catch Events" : "Earlier Events"}}}));
    api.set.mockImplementation(async (request) => ({outcome: "applied", view: {...enabled.view,
      senderId: request.senderId, preference: "disabled", revision: 2, serverTime: 1002}}));
    const page = render(<EventRcsPreferencesPanel eventId="event" attendeeId="attendee" />, setup());
    expect(await screen.findByText("Catch Events")).toBeTruthy();
    expect(screen.queryByText("Earlier Events")).toBeNull();
    fireEvent.click(screen.getByRole("button", {name: copy.manageEarlier}));
    expect(await screen.findByText("Earlier Events")).toBeTruthy();
    expect(screen.queryByRole("button", {name: copy.turnOn})).toBeNull();
    fireEvent.click(screen.getByRole("button", {name: copy.turnOff}));
    await waitFor(() => expect(api.set).toHaveBeenCalledWith(expect.objectContaining({
      senderId: "earlier-sender", decision: {kind: "revoke"}, expectedRevision: 1})));
    expect(screen.queryByText("earlier-sender")).toBeNull();
    page.unmount();
  });

  it("keeps withdrawal available when the selected sender is paused", async () => {
    api.get.mockResolvedValue({...initial, view: {...enabled.view,
      canEnable: false, availability: "senderUnavailable"}});
    const page = render(<EventRcsPreferencesPanel eventId="event" attendeeId="attendee" />, setup());
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOff}));
    await waitFor(() => expect(api.set).toHaveBeenCalledWith(expect.objectContaining({decision: {kind: "revoke"}})));
    page.unmount();
  });

  it("can page past filtered history without pretending no preferences exist", async () => {
    const cursor = "rcs-permission:" + "a".repeat(64);
    api.list.mockResolvedValueOnce({...options, configuredSenderId: null, previousSenderIds: [], nextCursor: cursor})
      .mockResolvedValueOnce({...options, configuredSenderId: null, previousSenderIds: ["old"]});
    const h = harness();
    await waitFor(() => expect(h.result.current.navigation.showNext).toBe(true));
    expect(api.get).not.toHaveBeenCalled();
    await act(async () => h.result.current.next());
    await ready(h);
    expect(api.list).toHaveBeenLastCalledWith({eventId: "event", attendeeId: "attendee", cursor});
    expect(h.result.current.state).toMatchObject({earlier: true, view: {senderId: "old"}});
    act(() => h.result.current.enable());
    expect(api.set).not.toHaveBeenCalled();
    h.unmount();
  });

  it("hides an unconfigured event and rejects forged discovery scope", async () => {
    api.list.mockResolvedValueOnce({...options, configuredSenderId: null, previousSenderIds: []});
    let h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("hidden"));
    expect(api.get).not.toHaveBeenCalled(); h.unmount();
    api.list.mockResolvedValueOnce({...options, eventId: "foreign"}); h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("error"));
    expect(api.get).not.toHaveBeenCalled(); h.unmount();
  });

  it("discards delayed sender discovery from the previous signed-in account", async () => {
    const discovery = deferred<typeof options>();
    api.list.mockReturnValueOnce(discovery.promise)
      .mockResolvedValueOnce({...options, configuredSenderId: "account-b-sender"});
    const h = harness();
    await waitFor(() => expect(api.list).toHaveBeenCalledOnce());
    signIn("guest-b");
    await ready(h);
    await act(async () => discovery.resolve({...options, configuredSenderId: "account-a-sender"}));
    expect(h.result.current.state).toMatchObject({view: {senderId: "account-b-sender"}});
    expect(api.get.mock.calls.every(([scope]) => scope.senderId === "account-b-sender")).toBe(true);
    h.unmount();
  });

  it("does not cache an unexpected private field or offer consent after a malformed read", async () => {
    api.get.mockResolvedValue({...initial, view: {...initial.view, phone: "+919999999999"}});
    const h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("error"));
    act(() => h.result.current.enable());
    expect(api.set).not.toHaveBeenCalled();
    expect(h.client.getQueryCache().getAll().filter((q) => q.queryKey.includes("rcs-preference"))
      .every((q) => q.state.data === undefined)).toBe(true);
    h.unmount();
  });

  it("treats malformed save responses as uncertain and keeps their exact retry identity", async () => {
    api.set.mockResolvedValueOnce({...enabled, view: {...enabled.view, senderId: "foreign"}});
    const h = harness(); await ready(h);
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: true, notice: copy.uncertain}));
    act(() => h.result.current.retry());
    await waitFor(() => expect(api.set).toHaveBeenCalledTimes(2));
    expect(api.set.mock.calls[0][0]).toEqual(api.set.mock.calls[1][0]);
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: false})); h.unmount();
  });

  it("surfaces conflict for a fresh review and releases definite rejections", async () => {
    api.set.mockResolvedValueOnce({...enabled, outcome: "conflict"});
    const h = harness(); await ready(h);
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({notice: copy.changed, uncertain: false}));
    api.set.mockRejectedValueOnce(Object.assign(new Error("Expired"), {code: "functions/failed-precondition"}));
    act(() => h.result.current.disable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({notice: copy.rejected, uncertain: false}));
    h.unmount();
  });
});

it("validates the closed preference projection and request scope before caching", () => {
  expect(rcsPreferenceResponse(initial, initial.view, "read")).toEqual(initial);
  const bad = [null, {...initial, extra: true}, {...initial, outcome: "applied"},
    ...[{senderId: "foreign"}, {eventId: "foreign"}, {attendeeId: "foreign"}, {serverTime: Infinity},
      {revision: 0}, {expiresAt: -1}, {reviewHash: "wrong"}, {phoneLastFour: "12345"},
      {preference: "unknown"}, {availability: "unknown"}, {sender: null},
      {sender: {displayName: "Catch", credential: "secret"}}, {consent: {version: "unknown", text: "copy"}},
      {consent: {version: initial.view.consent.version, text: "copy", extra: true}},
      {contact: "private"}].map((patch) => ({...initial, view: {...initial.view, ...patch}}))];
  for (const value of bad) expect(() => rcsPreferenceResponse(value, initial.view, "read")).toThrow();
  expect(() => rcsPreferenceResponse(initial, initial.view, "mutation")).toThrow();
  expect(newerRcsPreference(enabled, initial)).toBe(enabled);
  expect(newerRcsPreference(initial, {...initial, view: {...initial.view, serverTime: 999}})).toBe(initial);
});

it("validates bounded discovery pages, duplicate IDs and forward-only cursors", () => {
  expect(rcsPreferenceOptions(options, initial.view, null)).toEqual(options);
  const cursor = "rcs-permission:" + "a".repeat(64);
  for (const patch of [{previousSenderIds: ["a", "a"]}, {previousSenderIds: [options.configuredSenderId]},
    {nextCursor: cursor}, {serverTime: NaN}, {uid: "private"}, {configuredSenderId: "../bad"},
    {previousSenderIds: Array.from({length: 51}, (_, i) => `sender-${i}`)}]) {
    expect(() => rcsPreferenceOptions({...options, ...patch}, initial.view, cursor)).toThrow();
  }
});
