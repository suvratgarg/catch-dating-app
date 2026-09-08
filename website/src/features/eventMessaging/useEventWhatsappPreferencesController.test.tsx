import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, fireEvent, render, renderHook, screen, waitFor, within} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({list: vi.fn(), get: vi.fn(), set: vi.fn(),
  rcsList: vi.fn(), rcsGet: vi.fn(), rcsSet: vi.fn(),
  listeners: new Set<(user: {uid: string} | null) => void>()}));
vi.mock("../../firebase", () => ({listEventWhatsappPreferences: api.list,
  getEventWhatsappPreference: api.get, setEventWhatsappPreference: api.set,
  listEventRcsPreferences: api.rcsList, getEventRcsPreference: api.rcsGet,
  setEventRcsPreference: api.rcsSet,
  watchEventRuntimeAuthState: (listener: (user: {uid: string} | null) => void) => {
    api.listeners.add(listener); listener({uid: "guest-a"});
    return () => api.listeners.delete(listener);
  },
}));
import {useEventWhatsappPreferencesController} from "./useEventWhatsappPreferencesController";
import {useSenderPreferencesController} from "./useSenderPreferencesController";
import {whatsappPreferencePort} from "./whatsappPreferencePort";
import {EventWhatsappPreferencesPanel} from "./EventWhatsappPreferencesPanel";
import {EventRcsPreferencesPanel} from "./EventRcsPreferencesPanel";
import {whatsappPreferenceResponse, whatsappPreferenceOptions} from "./whatsappPreferenceModel";
import {whatsappOptionsFixture as options, whatsappPreferenceFixture as initial,
  whatsappEnabledFixture as enabled} from "../../stories/fixtures/whatsappPreferences";
import {rcsOptionsFixture, rcsPreferenceFixture, rcsEnabledFixture} from "../../stories/fixtures/rcsPreferences";
import {eventWhatsappMessagingCopy as copy, eventRcsMessagingCopy as rcsCopy} from "../../content/eventMessaging";
import type {EventWhatsappPreferenceCallableResponse as Response} from "../../shared/contracts/generated/eventWhatsappPreferenceCallableResponse";

function setup() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {client, wrapper};
}
function harness() {
  const context = setup();
  return {...renderHook(() => useEventWhatsappPreferencesController("event", "attendee"), context), ...context};
}
function deferred<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((done) => {resolve = done;});
  return {promise, resolve};
}
function signIn(uid: string | null) {
  act(() => api.listeners.forEach((listener) => listener(uid ? {uid} : null)));
}
async function ready(h: ReturnType<typeof harness>) {
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
}

describe("verified WhatsApp sender preferences", () => {
  beforeEach(() => {
    vi.resetAllMocks(); api.listeners.clear();
    api.list.mockResolvedValue(options);
    api.get.mockImplementation(async (scope) => ({...initial, view: {...initial.view, ...scope}}));
    api.set.mockResolvedValue(enabled);
    api.rcsList.mockResolvedValue(rcsOptionsFixture);
    api.rcsGet.mockResolvedValue(rcsPreferenceFixture);
    api.rcsSet.mockResolvedValue(rcsEnabledFixture);
  });
  afterEach(() => {cleanup(); vi.restoreAllMocks();});

  it("the shared controller captures the exact displayed sender and STOP evidence", async () => {
    const context = setup();
    const h = {...renderHook(() => useSenderPreferencesController(whatsappPreferencePort,
      "event", "attendee"), context), ...context};
    await ready(h);
    act(() => {h.result.current.enable(); h.result.current.enable();});
    await waitFor(() => expect(h.result.current.state).toMatchObject({view: {preference: "enabled"}}));
    expect(api.set).toHaveBeenCalledExactlyOnceWith({eventId: "event", attendeeId: "attendee",
      senderId: "organizer-whatsapp", requestId: expect.any(String), expectedRevision: null,
      decision: {kind: "grant", copyVersion: initial.view.consent.version,
        senderHash: initial.view.sender!.bindingHash, stopRecordHash: null}});
    expect(api.rcsSet).not.toHaveBeenCalled();
    act(() => h.result.current.refresh());
    await waitFor(() => expect(api.get.mock.calls.length).toBeGreaterThan(1));
    expect(h.result.current.state).toMatchObject({view: {revision: 1}}); h.unmount();
  });

  it.each(["sender", "stop"])("rejects a stale click when %s changes at the same revision", async (kind) => {
    const h = harness(); await ready(h); const oldEnable = h.result.current.enable;
    const key = h.client.getQueryCache().getAll().find((q) => q.queryKey.includes("whatsapp-preference"))!.queryKey;
    act(() => {
      h.client.setQueryData(key, {...initial, view: {...initial.view, ...(kind === "stop" ?
        {stopRecordHash: "b".repeat(64)} : {sender: {...initial.view.sender, bindingHash: "c".repeat(64)}})}});
      oldEnable();
    });
    expect(api.set).not.toHaveBeenCalled(); h.unmount();
  });

  it("isolates both channels while an uncertain WhatsApp save remains retryable", async () => {
    api.set.mockRejectedValueOnce(new Error("Lost response"));
    const context = setup();
    const page = render(<><EventWhatsappPreferencesPanel eventId="event" attendeeId="attendee" />
      <EventRcsPreferencesPanel eventId="event" attendeeId="attendee" /></>, context);
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOn}));
    await screen.findByText(copy.uncertain);
    const wa = within(screen.getByRole("heading", {name: copy.title}).parentElement!);
    expect(wa.getByRole("button", {name: copy.manageEarlier}).hasAttribute("disabled")).toBe(true);
    fireEvent.click(await screen.findByRole("button", {name: rcsCopy.turnOn}));
    await screen.findByText(rcsCopy.savedOn);
    expect(api.rcsSet.mock.calls[0][0].decision).toMatchObject({reviewHash: rcsPreferenceFixture.view.reviewHash});
    expect(api.rcsSet.mock.calls[0][0].decision).not.toHaveProperty("senderHash");
    fireEvent.click(wa.getByRole("button", {name: copy.retry}));
    await screen.findByText(copy.savedOn);
    expect(api.set.mock.calls[1][0]).toEqual(api.set.mock.calls[0][0]);
    expect(api.set.mock.calls[1][0].decision).not.toHaveProperty("reviewHash");
    expect(context.client.getQueryCache().getAll().filter((q) => q.queryKey.includes("rcs-preference"))).toHaveLength(1);
    expect(context.client.getQueryCache().getAll().filter((q) => q.queryKey.includes("whatsapp-preference"))).toHaveLength(1);
    page.unmount();
  });

  it("fences delayed saves and old callbacks through A to B to A", async () => {
    const save = deferred<Response>(); api.set.mockReturnValueOnce(save.promise);
    const h = harness(); await ready(h); const oldEnable = h.result.current.enable;
    act(() => oldEnable()); await waitFor(() => expect(api.set).toHaveBeenCalledOnce());
    signIn("guest-b"); signIn("guest-a"); await ready(h);
    await act(async () => save.resolve(enabled));
    expect(h.result.current.state).toMatchObject({view: {preference: "notSet"}, pending: false});
    act(() => oldEnable()); expect(api.set).toHaveBeenCalledOnce(); h.unmount();
  });

  it("discards delayed discovery after an account switch", async () => {
    const discovery = deferred<typeof options>(); api.list.mockReturnValueOnce(discovery.promise);
    const h = harness(); await waitFor(() => expect(api.list).toHaveBeenCalledOnce());
    signIn("guest-b"); await ready(h);
    await act(async () => discovery.resolve({...options, configuredSenderId: "old-account"}));
    expect(h.result.current.state).toMatchObject({view: {senderId: "organizer-whatsapp"}});
    expect(api.get.mock.calls.every(([s]) => s.senderId === "organizer-whatsapp")).toBe(true); h.unmount();
  });

  it("never recreates private cache after sign-out and unmount", async () => {
    const save = deferred<Response>(); api.set.mockReturnValueOnce(save.promise);
    const h = harness(); await ready(h); act(() => h.result.current.enable());
    await waitFor(() => expect(api.set).toHaveBeenCalledOnce()); signIn(null);
    expect(h.result.current.state.kind).toBe("hidden"); h.unmount();
    await waitFor(() => expect(h.client.getQueryCache().getAll()).toHaveLength(0));
    await act(async () => save.resolve(enabled));
    expect(h.client.getQueryCache().getAll()).toHaveLength(0);
  });

  it("shows the organizer and number while earlier preferences remain withdrawal-only", async () => {
    api.get.mockImplementation(async (scope) => ({...initial, view: {...enabled.view, ...scope}}));
    const page = render(<EventWhatsappPreferencesPanel eventId="event" attendeeId="attendee" />, setup());
    expect(await screen.findByText("Courtyard Social Club")).toBeTruthy();
    expect(screen.getByText("+91 88888 88888")).toBeTruthy();
    expect(screen.queryByText("organizer-whatsapp")).toBeNull();
    fireEvent.click(screen.getByRole("button", {name: copy.manageEarlier}));
    await screen.findByRole("heading", {name: copy.earlierTitle});
    expect(screen.queryByRole("button", {name: copy.turnOn})).toBeNull();
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOff}));
    await waitFor(() => expect(api.set).toHaveBeenCalledWith(expect.objectContaining({senderId: "earlier-whatsapp",
      decision: {kind: "revoke"}, expectedRevision: 1})));
    page.unmount();
  });

  it("retains withdrawal when the organizer disconnects", async () => {
    api.get.mockResolvedValue({...initial, view: {...enabled.view, canEnable: false, availability: "senderUnavailable"}});
    const page = render(<EventWhatsappPreferencesPanel eventId="event" attendeeId="attendee" />, setup());
    fireEvent.click(await screen.findByRole("button", {name: copy.turnOff}));
    await waitFor(() => expect(api.set).toHaveBeenCalledWith(expect.objectContaining({decision: {kind: "revoke"}})));
    page.unmount();
  });

  it("requires an exact retry after malformed confirmation and a fresh review after conflict", async () => {
    api.set.mockResolvedValueOnce({...enabled, view: {...enabled.view, senderId: "foreign"}});
    const h = harness(); await ready(h); act(() => h.result.current.enable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: true}));
    api.set.mockResolvedValueOnce({...enabled, outcome: "conflict"});
    act(() => h.result.current.retry());
    await waitFor(() => expect(h.result.current.state).toMatchObject({notice: copy.changed, uncertain: false}));
    expect(api.set.mock.calls[1][0]).toEqual(api.set.mock.calls[0][0]);
    api.set.mockRejectedValueOnce(Object.assign(new Error("No authority"), {code: "functions/permission-denied"}));
    act(() => h.result.current.disable());
    await waitFor(() => expect(h.result.current.state).toMatchObject({notice: copy.rejected, uncertain: false}));
    h.unmount();
  });

  it("continues filtered pages on demand without claiming enrollment", async () => {
    const cursor = "wa-permission:" + "a".repeat(64);
    api.list.mockResolvedValueOnce({...options, configuredSenderId: null, previousSenderIds: [], nextCursor: cursor})
      .mockResolvedValueOnce({...options, configuredSenderId: null, previousSenderIds: ["earlier"]});
    const h = harness(); await waitFor(() => expect(h.result.current.navigation.showNext).toBe(true));
    expect(api.get).not.toHaveBeenCalled(); await act(async () => h.result.current.next()); await ready(h);
    expect(api.list).toHaveBeenLastCalledWith({eventId: "event", attendeeId: "attendee", cursor});
    expect(h.result.current.state).toMatchObject({earlier: true, view: {senderId: "earlier"}});
    act(() => h.result.current.enable()); expect(api.set).not.toHaveBeenCalled(); h.unmount();
  });

  it("rejects cross-channel reads and never caches unexpected private fields", async () => {
    api.get.mockResolvedValueOnce({...rcsPreferenceFixture, view: {...rcsPreferenceFixture.view, senderId: "organizer-whatsapp"}});
    const h = harness(); await waitFor(() => expect(h.result.current.state.kind).toBe("error"));
    act(() => h.result.current.enable()); expect(api.set).not.toHaveBeenCalled();
    expect(h.client.getQueryCache().getAll().filter((q) => q.queryKey.includes("whatsapp-preference"))
      .every((q) => q.state.data === undefined)).toBe(true); h.unmount();
  });
});

it("validates WhatsApp scope, sender number and both proof hashes before caching", () => {
  expect(whatsappPreferenceResponse(initial, initial.view, "read")).toEqual(initial);
  for (const patch of [{eventId: "foreign"}, {attendeeId: "foreign"}, {senderId: "foreign"},
    {serverTime: NaN}, {revision: 0}, {expiresAt: -1}, {phoneLastFour: "12345"},
    {availability: "subscriptionUnavailable"}, {stopRecordHash: "invalid"}, {phone: "private"},
    {sender: {...initial.view.sender, displayPhoneNumber: "123"}},
    {sender: {...initial.view.sender, displayPhoneNumber: "1".repeat(33)}},
    {sender: {...initial.view.sender, bindingHash: "invalid"}},
    {sender: {...initial.view.sender, credential: "private"}},
    {consent: {...initial.view.consent, version: "catch-event-service-rcs-v1"}},
    {consent: {...initial.view.consent, extra: true}}, {sender: null}]) {
    expect(() => whatsappPreferenceResponse({...initial, view: {...initial.view, ...patch}}, initial.view, "read")).toThrow();
  }
  expect(() => whatsappPreferenceResponse(initial, initial.view, "mutation")).toThrow();
  expect(() => whatsappPreferenceResponse(enabled, initial.view, "read")).toThrow();
  const cursor = "wa-permission:" + "a".repeat(64);
  expect(whatsappPreferenceOptions(options, initial.view, null)).toEqual(options);
  for (const patch of [{nextCursor: cursor}, {nextCursor: "rcs-permission:" + "b".repeat(64)},
    {previousSenderIds: ["duplicate", "duplicate"]}, {uid: "foreign"}, {eventId: "other"}]) {
    expect(() => whatsappPreferenceOptions({...options, ...patch}, initial.view, cursor)).toThrow();
  }
});
