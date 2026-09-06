import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, fireEvent, render, renderHook, screen, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({get: vi.fn(), set: vi.fn(),
  listeners: new Set<(user: {uid: string} | null) => void>()}));
vi.mock("../../firebase", () => ({
  getEventAssistanceSmsPreference: api.get,
  setEventAssistanceSmsPreference: api.set,
  watchEventRuntimeAuthState: (listener: (user: {uid: string} | null) => void) => {
    api.listeners.add(listener); listener({uid: "guest-a"});
    return () => api.listeners.delete(listener);
  },
}));
import {useEventSmsPreferenceController} from "./useEventSmsPreferenceController";
import {EventSmsPreferencePanel, EventSmsPreferenceCard} from "./EventSmsPreferencePanel";
import {newerSmsPreference, type SmsPreferenceView} from "./eventMessagingModel";
import type {EventAssistanceSmsPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventAssistanceSmsPreferenceCallableResponse";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";

const view: SmsPreferenceView = {eventId: "event", attendeeId: "attendee", serverTime: 1000,
  revision: null, preference: "notSet", canEnable: true, availability: "ready",
  phoneLastFour: "9999", expiresAt: null,
  consent: {version: "catch-event-service-sms-v1", text: "Fixture event text consent."}};
const initial: Response = {outcome: "read", view};
const enabled: Response = {outcome: "applied", view: {...view, revision: 1,
  preference: "enabled", serverTime: 1001, expiresAt: 2000}};
function setup() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {client, wrapper};
}
function harness() {
  const context = setup();
  return {...renderHook(() => useEventSmsPreferenceController("event", "attendee"), context), ...context};
}
function deferred<T>() {
  let resolve: (value: T) => void = () => undefined;
  const promise = new Promise<T>((done) => { resolve = done; });
  return {promise, resolve};
}
function signIn(uid: string | null) {
  act(() => api.listeners.forEach((listener) => listener(uid ? {uid} : null)));
}

describe("verified event SMS controller", () => {
  beforeEach(() => {
    vi.clearAllMocks(); api.listeners.clear();
    api.get.mockResolvedValue(initial); api.set.mockResolvedValue(enabled);
  });
  afterEach(() => { cleanup(); vi.restoreAllMocks(); });

  it("locks rapid taps and ignores a stale read after confirmation", async () => {
    const h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    act(() => { h.result.current.enable(); h.result.current.enable(); });
    await waitFor(() => expect(h.result.current.state).toMatchObject({view: {preference: "enabled"}}));
    act(() => h.result.current.refresh());
    await waitFor(() => expect(api.get.mock.calls.length).toBeGreaterThan(1));
    expect(h.result.current.state).toMatchObject({view: {preference: "enabled", revision: 1}});
    expect(api.set).toHaveBeenCalledOnce();
    expect(api.set).toHaveBeenCalledWith({eventId: "event", attendeeId: "attendee",
      expectedRevision: null, requestId: expect.any(String),
      decision: {kind: "grant", copyVersion: "catch-event-service-sms-v1"}});
    h.unmount();
  });

  it("retries the identical uncertain write and withholds another decision", async () => {
    api.set.mockRejectedValueOnce(new Error("Lost response"));
    const h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: true}));
    act(() => h.result.current.disable());
    expect(api.set).toHaveBeenCalledOnce();
    act(() => h.result.current.retry());
    await waitFor(() => expect(api.set).toHaveBeenCalledTimes(2));
    expect(api.set.mock.calls[1][0]).toEqual(api.set.mock.calls[0][0]);
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: false}));
    h.unmount();
  });

  it("a definite rejection can refresh instead of being stuck on the same invalid request", async () => {
    api.set.mockRejectedValueOnce(Object.assign(new Error("No longer available"),
      {code: "functions/failed-precondition"}));
    const h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({
      pending: false, uncertain: false, notice: copy.rejected,
    }));
    act(() => h.result.current.enable());
    await waitFor(() => expect(api.set).toHaveBeenCalledTimes(2));
    expect(api.set.mock.calls[1][0].requestId).not.toBe(api.set.mock.calls[0][0].requestId);
    h.unmount();
  });

  it("fences delayed replies and old handlers across A to B to A auth changes", async () => {
    const result = deferred<Response>(); api.set.mockReturnValueOnce(result.promise);
    const h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    const oldEnable = h.result.current.enable;
    act(() => oldEnable());
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    signIn("guest-b"); signIn("guest-a");
    await waitFor(() => expect(h.result.current.state).toMatchObject({pending: false}));
    await act(async () => result.resolve(enabled));
    expect(h.result.current.state).toMatchObject({view: {preference: "notSet"}});
    act(() => oldEnable());
    expect(api.set).toHaveBeenCalledOnce();
    h.unmount();
  });

  it("unmounting prevents a late mutation from recreating private query data", async () => {
    const result = deferred<Response>(); api.set.mockReturnValueOnce(result.promise);
    const h = harness();
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    act(() => h.result.current.enable());
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    h.unmount();
    await waitFor(() => expect(h.client.getQueryCache().getAll()).toHaveLength(0));
    await act(async () => result.resolve(enabled));
    expect(h.client.getQueryCache().getAll()).toHaveLength(0);
  });

  it("a new event scope stays usable while the previous event write is pending", async () => {
    const result = deferred<Response>(); api.set.mockReturnValueOnce(result.promise);
    const h = setup();
    const page = render(<EventSmsPreferencePanel eventId="event" attendeeId="attendee" />, h);
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOn}));
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    api.get.mockResolvedValue({...initial, view: {...view, eventId: "other"}});
    page.rerender(<EventSmsPreferencePanel eventId="other" attendeeId="attendee" />);
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOn}));
    await waitFor(() => expect(api.set).toHaveBeenCalledTimes(2));
    expect(api.set.mock.calls[1][0].eventId).toBe("other");
    page.unmount(); await act(async () => result.resolve(enabled));
  });

  it("hides optional enrollment until sender activation, but preserves withdrawal", async () => {
    api.get.mockResolvedValue({...initial, view: {...view, canEnable: false,
      availability: "senderUnavailable"}});
    const h = harness();
    await waitFor(() => expect(api.get).toHaveBeenCalled());
    await waitFor(() => expect(h.result.current.state.kind).toBe("hidden"));
    h.unmount();
    const disable = vi.fn();
    render(<EventSmsPreferenceCard state={{kind: "ready", view: {...enabled.view,
      canEnable: false, availability: "senderUnavailable"}, pending: false,
      uncertain: false, notice: ""}} disable={disable} enable={vi.fn()}
      retry={vi.fn()} refresh={vi.fn()} />);
    fireEvent.click(screen.getByRole("button", {name: copy.turnOff}));
    expect(disable).toHaveBeenCalledOnce();
  });
});

it("prefers current revisions and then server time when reads arrive out of order", () => {
  expect(newerSmsPreference(enabled, initial)).toBe(enabled);
  const stopped: Response = {...enabled, view: {...enabled.view, revision: 2, preference: "disabled"}};
  expect(newerSmsPreference(stopped, enabled)).toBe(stopped);
  expect(newerSmsPreference(stopped, {...stopped,
    view: {...stopped.view, serverTime: 1}})).toBe(stopped);
});
