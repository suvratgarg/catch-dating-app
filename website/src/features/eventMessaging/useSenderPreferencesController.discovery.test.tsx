import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, describe, expect, it, vi} from "vitest";
vi.mock("../../firebase", () => ({
  watchEventRuntimeAuthState: (listener: (user: {uid: string} | null) => void) => {
    listener({uid: "guest"}); return () => undefined;
  },
}));
import {useSenderPreferencesController} from "./useSenderPreferencesController";
import {senderPreferenceOptions} from "./senderPreferenceParsing";
import type {PreferenceChannel, SenderPreferencePort, SenderPreferenceResponse,
  SenderPreferenceSubmission} from "./senderPreferencePort";

const page = {eventId: "event", attendeeId: "attendee", serverTime: 1000,
  configuredSenderId: "current", previousSenderIds: [] as string[], nextCursor: null as string | null};

function harness(channel: PreferenceChannel, previousSenderIds: string[] = []) {
  const cursor = {sms: "sms", whatsapp: "wa", rcs: "rcs"}[channel] + "-permission:" + "a".repeat(64);
  const list = vi.fn().mockResolvedValue({...page, previousSenderIds, nextCursor: cursor});
  const read = vi.fn(async (scope) => ({outcome: "read" as const, view: {...scope,
    serverTime: 1000, revision: null, preference: "notSet" as const, canEnable: true}}));
  const write = vi.fn(async (submission) => ({outcome: "applied" as const, view: {
    eventId: submission.eventId, attendeeId: submission.attendeeId, senderId: submission.senderId,
    serverTime: 1001, revision: 1, preference: "enabled" as const, canEnable: true}}));
  const port: SenderPreferencePort<SenderPreferenceResponse, SenderPreferenceSubmission> = {
    channel, copy: {changed: "Changed", savedOn: "Enabled", savedOff: "Disabled",
      rejected: "Rejected", uncertain: "Uncertain"},
    list: async (scope) => senderPreferenceOptions(await list(scope), scope, scope.cursor, channel),
    read, write, reviewKey: (view) => String(view.serverTime),
    submission: (scope, requestId, view, decision) => ({...scope, requestId,
      expectedRevision: view.revision, decision: {kind: decision}}),
  };
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  const hook = renderHook(() => useSenderPreferencesController(port, "event", "attendee"), {wrapper});
  return {...hook, list, read, write};
}

afterEach(cleanup);

describe.each<PreferenceChannel>(["sms", "whatsapp", "rcs"])("%s sender history", (channel) => {
  it.each([
    {configuredSenderId: "replacement", serverTime: 1001},
    {configuredSenderId: "current", serverTime: 999},
  ])("requires a fresh discovery after inconsistent pages: %j", async (patch) => {
    const h = harness(channel);
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    const oldEnable = h.result.current.enable;
    h.list.mockResolvedValue({...page, ...patch, previousSenderIds: ["earlier"]});
    await act(async () => h.result.current.next());
    await waitFor(() => expect(h.result.current.state.kind).toBe("error"));
    act(() => {oldEnable(); h.result.current.enable(); h.result.current.manageEarlier();});
    expect(h.write).not.toHaveBeenCalled();
    expect(h.read).toHaveBeenCalledOnce();

    h.list.mockResolvedValue({...page, configuredSenderId: "replacement", serverTime: 2000});
    act(() => h.result.current.refresh());
    await waitFor(() => expect(h.result.current.state).toMatchObject({
      kind: "ready", earlier: false, view: {senderId: "replacement"}}));
    act(() => oldEnable());
    expect(h.write).not.toHaveBeenCalled();
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.write).toHaveBeenCalledOnce());
    expect(h.write.mock.calls[0][0]).toMatchObject({senderId: "replacement"});
    h.unmount();
  });

  it("does not retain a sender that disappeared when discovery was restarted", async () => {
    const h = harness(channel, ["earlier"]);
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    act(() => h.result.current.manageEarlier());
    await waitFor(() => expect(h.result.current.state).toMatchObject({view: {senderId: "earlier"}}));
    h.list.mockResolvedValue({...page, configuredSenderId: "replacement"});
    await act(async () => h.result.current.next());
    await waitFor(() => expect(h.result.current.state.kind).toBe("error"));
    act(() => h.result.current.refresh());
    await waitFor(() => expect(h.result.current.state).toMatchObject({
      kind: "ready", earlier: false, view: {senderId: "replacement"}}));
    expect(h.result.current.navigation.showEarlier).toBe(false);
    h.unmount();
  });

  it("withholds a stale consent action while another discovery page is in flight", async () => {
    const h = harness(channel);
    await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
    const oldEnable = h.result.current.enable;
    let resolve!: (value: typeof page) => void;
    h.list.mockReturnValue(new Promise<typeof page>((done) => {resolve = done;}));
    let next!: Promise<void>;
    act(() => {next = h.result.current.next(); oldEnable();});
    expect(h.write).not.toHaveBeenCalled();
    await act(async () => {resolve({...page, serverTime: 1001}); await next;});
    await waitFor(() => expect(h.result.current.navigation.busy).toBe(false));
    act(() => oldEnable());
    expect(h.write).not.toHaveBeenCalled();
    act(() => h.result.current.enable());
    await waitFor(() => expect(h.write).toHaveBeenCalledOnce());
    h.unmount();
  });
});
