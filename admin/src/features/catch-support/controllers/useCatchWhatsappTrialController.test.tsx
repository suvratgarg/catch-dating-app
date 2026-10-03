import {act, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {StrictMode, type ReactNode} from "react";
import {expect, it, vi} from "vitest";
import {AdminPendingOperationProvider} from "../../../shared/pendingOperation";
import type {CatchTrialApi, CatchTrialScope} from "../api/catchWhatsappTrialRepository";
import {useCatchWhatsappTrialController} from "./useCatchWhatsappTrialController";
let eventSequence = 0;
function setup(enabled = true, strict = false) {
  // Production attempt markers intentionally outlive each mounted controller.
  const eventId = "cwhe_" + (++eventSequence).toString(16).padStart(64, "0");
  const api: CatchTrialApi = {
    prepare: vi.fn().mockResolvedValue(() => undefined),
    review: vi.fn().mockResolvedValue({purpose: "serviceSupport",
      inboundEventId: eventId, inboundText: "Private request",
      reviewedInboundTextHash: "b".repeat(64), deadlineMillis: Date.now() + 60000}),
    send: vi.fn().mockResolvedValue({operationId: "cwreply_" + "c".repeat(64),
      providerMessageId: "wamid.test", deliveryStatus: "accepted", replayed: false}),
  };
  const scope: CatchTrialScope = {actorUid: "staff", projectId: "catchdates-dev",
    sessionKey: "first", isCurrent: () => true};
  const client = new QueryClient({defaultOptions: {mutations: {retry: false}}});
  const wrapper = ({children}: {children: ReactNode}) => {
    const providers = <QueryClientProvider client={client}>
      <AdminPendingOperationProvider>{children}</AdminPendingOperationProvider>
    </QueryClientProvider>;
    return strict ? <StrictMode>{providers}</StrictMode> : providers;
  };
  const mount = (value = scope) => renderHook(({value, active}) =>
    useCatchWhatsappTrialController({scope: value, enabled: active, api}),
  {initialProps: {value, active: enabled}, wrapper});
  const hook = mount();
  return {hook, api, scope, client, eventId, mount};
}
async function review(f: ReturnType<typeof setup>) {
  act(() => f.hook.result.current.setEventId(f.eventId));
  await act(async () => {await f.hook.result.current.review();});
  act(() => f.hook.result.current.editReply("Exact reply"));
  act(() => f.hook.result.current.confirm(true));
}
it("never reads or sends while disabled", async () => {
  const f = setup(false);
  await act(async () => {
    await f.hook.result.current.review(); await f.hook.result.current.send();
  });
  expect(f.api.prepare).not.toHaveBeenCalled();
  expect(f.api.review).not.toHaveBeenCalled();
  expect(f.api.send).not.toHaveBeenCalled();
});
it("sends only an explicitly confirmed exact command and clears mutation cache data",
  async () => {
    const f = setup();
    await review(f);
    await act(async () => {await f.hook.result.current.send();});
    expect(f.api.send).toHaveBeenCalledOnce();
    expect(vi.mocked(f.api.send).mock.calls[0][0]).toEqual({
      purpose: "serviceSupport", inboundEventId: f.eventId,
      reviewedInboundTextHash: "b".repeat(64), body: "Exact reply",
      confirmSupportRequest: true,
    });
    expect(f.hook.result.current.phase).toBe("sent");
    await waitFor(() => expect(f.client.getMutationCache().getAll()).toHaveLength(0));
  });
it("edits and expired review prevent dispatch", async () => {
  const f = setup();
  await review(f);
  act(() => f.hook.result.current.editReply("Changed"));
  await act(async () => {await f.hook.result.current.send();});
  expect(f.api.send).not.toHaveBeenCalled();
  expect(f.hook.result.current.phase).toBe("reviewed");
});
it("an uncertain call is consumed without automatic or manual resend", async () => {
  const f = setup();
  await review(f);
  const observed: string[] = [];
  f.client.getMutationCache().subscribe((event) => {
    if ("mutation" in event && event.mutation) {
      const state = event.mutation.state;
      for (const error of [state.error, state.failureReason]) {
        observed.push(String(error), JSON.stringify(error));
      }
    }
  });
  vi.mocked(f.api.send).mockRejectedValue(Object.assign(
    new Error("PRIVATE_SENTINEL"), {details: "PRIVATE_SENTINEL",
      cause: new Error("PRIVATE_SENTINEL")}));
  await act(async () => {await f.hook.result.current.send();});
  expect(f.hook.result.current.phase).toBe("unknown");
  expect(f.hook.result.current.error).not.toContain("PRIVATE_SENTINEL");
  expect(observed.join(" ")).not.toContain("PRIVATE_SENTINEL");
  await act(async () => {await f.hook.result.current.send();});
  expect(f.api.send).toHaveBeenCalledOnce();
});
it("account rotation during preparation prevents dispatch and clears private text",
  async () => {
    const f = setup();
    await review(f);
    let release!: (guard: () => void) => void;
    vi.mocked(f.api.prepare).mockImplementationOnce(() =>
      new Promise((resolve) => {release = resolve;}));
    let pending!: Promise<void>;
    act(() => {pending = f.hook.result.current.send();});
    await waitFor(() => expect(release).toBeDefined());
    f.hook.rerender({value: {...f.scope, sessionKey: "next", actorUid: "other"},
      active: true});
    await act(async () => {release(() => undefined); await pending;});
    expect(f.api.send).not.toHaveBeenCalled();
    expect(f.hook.result.current.inbound).toBeNull();
    expect(f.hook.result.current.replyBody).toBe("");
  });
it("double clicks hold one console lease and dispatch at most once", async () => {
  const f = setup();
  await review(f);
  await act(async () => {
    await Promise.all([f.hook.result.current.send(), f.hook.result.current.send()]);
  });
  expect(f.api.send).toHaveBeenCalledOnce();
});

function expectPrivateStateCleared(f: ReturnType<typeof setup>) {
  expect(f.hook.result.current.inbound).toBeNull();
  expect(f.hook.result.current.replyBody).toBe("");
  expect(f.hook.result.current.result).toBeNull();
  expect(f.hook.result.current.eventId).toBe("");
  expect(f.hook.result.current.error).toBe("");
}
async function attemptSameInbound(f: ReturnType<typeof setup>) {
  act(() => f.hook.result.current.setEventId(f.eventId));
  await act(async () => {await f.hook.result.current.review();});
  if (f.hook.result.current.phase === "reviewed") {
    act(() => f.hook.result.current.editReply("A second reply"));
    act(() => f.hook.result.current.confirm(true));
  }
  await act(async () => {await f.hook.result.current.send();});
}
it.each(["session", "actor", "enabled", "remount"] as const)(
  "retains an uncertain attempt across %s retirement without private state",
  async (change) => {
    const f = setup();
    await review(f);
    vi.mocked(f.api.send).mockRejectedValue(new Error("Uncertain private failure"));
    await act(async () => {await f.hook.result.current.send();});
    expect(f.hook.result.current.phase).toBe("unknown");
    if (change === "remount") {
      // Retire both the hook and its Query/PendingOperation providers, as the
      // keyed App shell does. The same page/module instance is retained.
      f.hook.unmount();
      f.hook = f.mount({...f.scope, sessionKey: "remounted"});
    } else {
      f.hook.rerender({value: {...f.scope,
        sessionKey: change === "session" ? "rotated" : f.scope.sessionKey,
        actorUid: change === "actor" ? "other" : f.scope.actorUid},
      active: change !== "enabled"});
      expectPrivateStateCleared(f);
      f.hook.rerender({value: {...f.scope, sessionKey: "returned"}, active: true});
    }
    expectPrivateStateCleared(f);
    await attemptSameInbound(f);
    expect(f.api.send).toHaveBeenCalledOnce();
    expect(f.api.review).toHaveBeenCalledOnce();
    expect(f.hook.result.current.inbound).toBeNull();
  });
it("isolates project attempts and remembers them after returning to the project",
  async () => {
    const f = setup();
    await review(f);
    await act(async () => {await f.hook.result.current.send();});
    f.hook.rerender({value: {...f.scope, projectId: "synthetic-other-project"},
      active: true});
    expectPrivateStateCleared(f);
    await review(f);
    await act(async () => {await f.hook.result.current.send();});
    expect(f.api.send).toHaveBeenCalledTimes(2);
    f.hook.rerender({value: {...f.scope, sessionKey: "returned"}, active: true});
    expectPrivateStateCleared(f);
    await attemptSameInbound(f);
    expect(f.api.send).toHaveBeenCalledTimes(2);
    expect(f.api.review).toHaveBeenCalledTimes(2);
  });
it.each([
  ["rotation", "success"], ["rotation", "failure"],
  ["remount", "success"], ["remount", "failure"],
] as const)("ignores late send %s/%s without restoring private state or errors",
  async (lifecycle, outcome) => {
    const f = setup();
    await review(f);
    let settle!: () => void;
    vi.mocked(f.api.send).mockImplementationOnce(() => new Promise((resolve, reject) => {
      settle = () => outcome === "success" ? resolve({
        operationId: "cwreply_" + "d".repeat(64), providerMessageId: "wamid.private",
        deliveryStatus: "accepted", replayed: false,
      }) : reject(new Error("PRIVATE_LATE_FAILURE"));
    }));
    let pending!: Promise<void>;
    act(() => {pending = f.hook.result.current.send();});
    await waitFor(() => expect(settle).toBeDefined());
    if (lifecycle === "remount") {
      f.hook.unmount();
      f.hook = f.mount({...f.scope, sessionKey: "remounted"});
    } else {
      f.hook.rerender({value: {...f.scope, sessionKey: "rotated"}, active: true});
    }
    expectPrivateStateCleared(f);
    await act(async () => {settle(); await pending;});
    expectPrivateStateCleared(f);
    await attemptSameInbound(f);
    expect(f.api.send).toHaveBeenCalledOnce();
    expect(f.api.review).toHaveBeenCalledOnce();
    await waitFor(() => expect(f.client.getMutationCache().getAll()).toHaveLength(0));
  });

it("restores the enabled context after StrictMode effect replay without clearing attempts",
  async () => {
    const f = setup(true, true);
    await review(f);
    expect(f.hook.result.current.phase).toBe("confirmed");
    await act(async () => {await f.hook.result.current.send();});
    expect(f.api.send).toHaveBeenCalledOnce();
    f.hook.unmount();
    f.hook = f.mount({...f.scope, sessionKey: "strict-remount"});
    expectPrivateStateCleared(f);
    await attemptSameInbound(f);
    expect(f.api.send).toHaveBeenCalledOnce();
    expect(f.api.review).toHaveBeenCalledOnce();
  });
