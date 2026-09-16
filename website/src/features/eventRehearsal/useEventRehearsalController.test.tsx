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

function wrapper(client = new QueryClient({
    defaultOptions: {queries: {retry: false}, mutations: {retry: false}},
  })) {
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

const instruction = {
  messageId: `outbox:${"a".repeat(64)}`, intentId: `message:${"b".repeat(64)}`,
  intentRevision: 1, text: "We have left the meetup. Join us at the first stop.",
  choices: [{choiceId: "on-my-way", label: "On my way"},
    {choiceId: "not-coming", label: "Not coming"}],
  lifecycle: "active", expiresAt: 60000, canRespond: true,
  responseChoiceId: null,
} as const;
const waiting = {...bootstrap, actor: {...bootstrap.actor, assistanceMessage: instruction}};
const saved = {...waiting, session: {...bootstrap.session, runtimeRevision: 2},
  actor: {...waiting.actor, assistanceMessage: {...instruction,
    lifecycle: "responded", canRespond: false, responseChoiceId: "on-my-way"}}};
const choice = {messageId: instruction.messageId, intentRevision: 1, choiceId: "on-my-way"};
function deferred<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((done) => { resolve = done; });
  return {promise, resolve};
}

describe("rehearsal assistance replies", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    window.sessionStorage.clear();
    getEventRehearsalGuestBootstrap.mockResolvedValue(waiting);
    submitEventRehearsalGuestAction.mockResolvedValue(saved);
  });
  it("submits the displayed message once and leaves attendance unchanged", async () => {
    const response = deferred<typeof saved>();
    submitEventRehearsalGuestAction.mockReturnValue(response.promise);
    const {result, unmount} = renderHook(() => useEventRehearsalController("practice-replies"),
      {wrapper: wrapper()});
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    act(() => {
      result.current.reply(choice);
      result.current.reply({...choice, choiceId: "not-coming"});
      result.current.submit("checkIn");
    });
    await waitFor(() => expect(submitEventRehearsalGuestAction).toHaveBeenCalledTimes(1));
    expect(submitEventRehearsalGuestAction).toHaveBeenCalledWith({
      ...choice, publicRehearsalId: "practice-replies", slotToken: waiting.slotToken,
      clientActionId: expect.stringMatching(/^guest_/u), action: "respondToAssistance",
    });
    expect(result.current.bootstrap?.actor.assistanceMessage?.responseChoiceId).toBeNull();
    await act(async () => response.resolve(saved));
    await waitFor(() => expect(result.current.bootstrap?.actor.assistanceMessage?.responseChoiceId)
      .toBe("on-my-way"));
    expect(result.current.bootstrap?.actor.status).toBe("expected");
    unmount();
  });
  it("keeps an uncertain reply frozen and retries the exact same request", async () => {
    submitEventRehearsalGuestAction.mockRejectedValueOnce(new Error("connection lost"));
    const {result, unmount} = renderHook(() => useEventRehearsalController("practice-retry"),
      {wrapper: wrapper()});
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    act(() => result.current.reply(choice));
    await waitFor(() => expect(result.current.replyState.notice).toMatch(/could not confirm/));
    const first = submitEventRehearsalGuestAction.mock.calls[0][0];
    act(() => {
      result.current.reply({...choice, choiceId: "not-coming"});
      result.current.submit("checkIn");
    });
    expect(submitEventRehearsalGuestAction).toHaveBeenCalledTimes(1);
    act(() => result.current.reply(choice));
    await waitFor(() => expect(submitEventRehearsalGuestAction).toHaveBeenCalledTimes(2));
    expect(submitEventRehearsalGuestAction.mock.calls[1][0]).toEqual(first);
    await waitFor(() => expect(result.current.bootstrap?.actor.assistanceMessage?.responseChoiceId)
      .toBe("on-my-way"));
    unmount();
  });
  it("discards an in-flight poll that predates the committed reply", async () => {
    const read = deferred<typeof waiting>();
    const {result, unmount} = renderHook(() => useEventRehearsalController("practice-poll"),
      {wrapper: wrapper()});
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    getEventRehearsalGuestBootstrap.mockReturnValueOnce(read.promise);
    act(() => result.current.refresh());
    await waitFor(() => expect(getEventRehearsalGuestBootstrap).toHaveBeenCalledTimes(2));
    act(() => result.current.reply(choice));
    await waitFor(() => expect(result.current.bootstrap?.actor.assistanceMessage?.responseChoiceId)
      .toBe("on-my-way"));
    await act(async () => read.resolve(waiting));
    expect(result.current.bootstrap?.actor.assistanceMessage?.responseChoiceId).toBe("on-my-way");
    unmount();
  });
  it("rejects stale choices and releases a retry when the Host replaces the instruction", async () => {
    submitEventRehearsalGuestAction.mockRejectedValueOnce(new Error("connection lost"));
    const {result, unmount} = renderHook(() => useEventRehearsalController("practice-replaced"),
      {wrapper: wrapper()});
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    act(() => result.current.reply(choice));
    await waitFor(() => expect(result.current.replyState.notice).toMatch(/could not confirm/));
    const next = {...waiting, session: {...waiting.session, runtimeRevision: 3},
      actor: {...waiting.actor, assistanceMessage: {...instruction,
        messageId: `outbox:${"c".repeat(64)}`}}};
    getEventRehearsalGuestBootstrap.mockResolvedValue(next);
    act(() => result.current.refresh());
    await waitFor(() => expect(result.current.bootstrap?.session.runtimeRevision).toBe(3));
    act(() => result.current.reply(choice));
    expect(submitEventRehearsalGuestAction).toHaveBeenCalledTimes(1);
    expect(result.current.replyState.retryChoice).toBeNull();
    expect(result.current.replyState.notice).toBe("");
    unmount();
  });
  it("closes choices when refresh fails or the virtual instruction expires", async () => {
    const {result, unmount} = renderHook(() => useEventRehearsalController("practice-stale"),
      {wrapper: wrapper()});
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    getEventRehearsalGuestBootstrap.mockRejectedValueOnce(new Error("offline"));
    act(() => result.current.refresh());
    await waitFor(() => expect(result.current.replyState.fresh).toBe(false));
    act(() => result.current.reply(choice));
    expect(submitEventRehearsalGuestAction).not.toHaveBeenCalled();
    getEventRehearsalGuestBootstrap.mockResolvedValue({...waiting,
      session: {...waiting.session, virtualNowMillis: instruction.expiresAt}});
    act(() => result.current.refresh());
    await waitFor(() => expect(result.current.replyState.fresh).toBe(true));
    act(() => result.current.reply(choice));
    expect(submitEventRehearsalGuestAction).not.toHaveBeenCalled();
    unmount();
  });
  it("keeps a closed phone's pending reply out of a newly opened guest view", async () => {
    const client = new QueryClient();
    const shared = wrapper(client);
    const response = deferred<typeof saved>();
    submitEventRehearsalGuestAction.mockReturnValue(response.promise);
    const first = renderHook(() => useEventRehearsalController("practice-scope"),
      {wrapper: shared});
    await waitFor(() => expect(first.result.current.bootstrap).not.toBeNull());
    act(() => first.result.current.reply(choice));
    await waitFor(() => expect(submitEventRehearsalGuestAction).toHaveBeenCalled());
    first.unmount();
    getEventRehearsalGuestBootstrap.mockResolvedValue({...waiting,
      actor: {...waiting.actor, actorId: "actor-02", assistanceMessage: null}});
    const second = renderHook(() => useEventRehearsalController("practice-scope"),
      {wrapper: shared});
    await waitFor(() => expect(second.result.current.bootstrap?.actor.actorId).toBe("actor-02"));
    await act(async () => response.resolve(saved));
    expect(second.result.current.bootstrap?.actor.actorId).toBe("actor-02");
    expect(second.result.current.bootstrap?.actor.assistanceMessage).toBeNull();
    second.unmount();
    client.clear();
  });
  it("withholds new responses from a suspended tab even before polling fails", async () => {
    const clock = vi.spyOn(performance, "now").mockReturnValue(1000);
    const {result, unmount} = renderHook(() => useEventRehearsalController("practice-suspended"),
      {wrapper: wrapper()});
    await waitFor(() => expect(result.current.bootstrap).not.toBeNull());
    clock.mockReturnValue(20_000);
    act(() => {
      result.current.reply(choice);
      result.current.submit("checkIn");
    });
    expect(submitEventRehearsalGuestAction).not.toHaveBeenCalled();
    act(() => result.current.refresh());
    await waitFor(() => expect(getEventRehearsalGuestBootstrap).toHaveBeenCalledTimes(2));
    act(() => result.current.reply(choice));
    await waitFor(() => expect(submitEventRehearsalGuestAction).toHaveBeenCalledTimes(1));
    unmount();
    clock.mockRestore();
  });
});
