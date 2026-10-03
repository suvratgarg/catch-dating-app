import {act, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";
import {expect, it, vi} from "vitest";
import {AdminPendingOperationProvider} from "../../../shared/pendingOperation";
import type {CatchTrialApi, CatchTrialScope} from "../api/catchWhatsappTrialRepository";
import {useCatchWhatsappTrialController} from "./useCatchWhatsappTrialController";
const eventId = "cwhe_" + "a".repeat(64);
function setup(enabled = true) {
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
  const wrapper = ({children}: {children: ReactNode}) =>
    <QueryClientProvider client={client}>
      <AdminPendingOperationProvider>{children}</AdminPendingOperationProvider>
    </QueryClientProvider>;
  const hook = renderHook(({value}) => useCatchWhatsappTrialController({
    scope: value, enabled, api}), {initialProps: {value: scope}, wrapper});
  return {hook, api, scope, client};
}
async function review(f: ReturnType<typeof setup>) {
  act(() => f.hook.result.current.setEventId(eventId));
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
      purpose: "serviceSupport", inboundEventId: eventId,
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
    f.hook.rerender({value: {...f.scope, sessionKey: "next", actorUid: "other"}});
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
