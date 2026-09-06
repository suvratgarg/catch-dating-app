import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, fireEvent, render, renderHook, screen, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({get: vi.fn(), withdraw: vi.fn()}));
vi.mock("../../firebase", () => ({getEventAssistanceSmsWithdrawal: api.get,
  withdrawEventAssistanceSms: api.withdraw}));
import {useEventSmsWithdrawalController} from "./useEventSmsWithdrawalController";
import {EventSmsWithdrawalPanel, EventSmsWithdrawalCard} from "./EventSmsWithdrawalPanel";
import type {EventAssistanceSmsWithdrawalCallableResponse as Response} from "../../shared/contracts/generated/eventAssistanceSmsWithdrawalCallableResponse";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";
const credential = {linkId: "a".repeat(32), secret: "b".repeat(43)};
const enabled: Response = {outcome: "read", view: {serverTime: 1000, expiresAt: 100_000,
  revision: 1, preference: "enabled"}};
const disabled: Response = {outcome: "applied", view: {...enabled.view,
  revision: 2, serverTime: 1001, preference: "disabled"}};
function setup() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {client, wrapper};
}
function harness(input: typeof credential | null = credential) {
  const h = setup();
  return {...renderHook(() => useEventSmsWithdrawalController(input), h), ...h};
}
function deferred() {
  let resolve: (value: Response) => void = () => undefined;
  const promise = new Promise<Response>((done) => { resolve = done; });
  return {promise, resolve};
}
beforeEach(() => {
  vi.clearAllMocks(); api.get.mockResolvedValue(enabled); api.withdraw.mockResolvedValue(disabled);
});
afterEach(() => { cleanup(); vi.restoreAllMocks(); });

it("requires a link, locks repeated taps and keeps secrets out of cache and mutation state", async () => {
  const empty = harness(null);
  expect(empty.result.current.state.kind).toBe("hidden");
  expect(api.get).not.toHaveBeenCalled(); empty.unmount();
  const h = harness();
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
  act(() => { h.result.current.withdraw(); h.result.current.withdraw(); });
  await waitFor(() => expect(h.result.current.state).toMatchObject({view: {preference: "disabled"}}));
  expect(api.withdraw).toHaveBeenCalledOnce();
  expect(api.withdraw).toHaveBeenCalledWith({...credential,
    expectedRevision: 1, requestId: expect.any(String)});
  const states = [h.client.getQueryCache().getAll().map((q) => [q.queryKey, q.state]),
    h.client.getMutationCache().getAll().map((m) => [m.options.mutationKey, m.state])];
  expect(JSON.stringify(states)).not.toContain(credential.secret);
  expect(JSON.stringify(states)).not.toContain(credential.linkId);
  h.unmount();
});
it("retries the same withdrawal after a lost response", async () => {
  api.withdraw.mockRejectedValueOnce(new Error("Timeout"));
  const h = harness();
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
  act(() => h.result.current.withdraw());
  await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: true}));
  act(() => h.result.current.withdraw());
  await waitFor(() => expect(api.withdraw).toHaveBeenCalledTimes(2));
  expect(api.withdraw.mock.calls[1][0]).toEqual(api.withdraw.mock.calls[0][0]);
  await waitFor(() => expect(h.result.current.state).toMatchObject({uncertain: false,
    view: {preference: "disabled"}}));
  h.unmount();
});
it("a replay that finds later consent asks for a new explicit choice", async () => {
  const latest = {...enabled, outcome: "replayed" as const,
    view: {...enabled.view, revision: 3, serverTime: 1003}};
  api.withdraw.mockResolvedValueOnce(latest);
  const h = harness();
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
  act(() => h.result.current.withdraw());
  await waitFor(() => expect(h.result.current.state).toMatchObject({pending: false,
    uncertain: false, notice: copy.withdrawalChanged}));
  act(() => h.result.current.withdraw());
  await waitFor(() => expect(api.withdraw).toHaveBeenCalledTimes(2));
  expect(api.withdraw.mock.calls[1][0].expectedRevision).toBe(3);
  expect(api.withdraw.mock.calls[1][0].requestId).not.toBe(api.withdraw.mock.calls[0][0].requestId);
  h.unmount();
});
it("ignores stale reads and disables changes when a refresh fails", async () => {
  const h = harness();
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
  act(() => h.result.current.withdraw());
  await waitFor(() => expect(h.result.current.state).toMatchObject({view: {revision: 2}}));
  act(() => h.result.current.refresh());
  await waitFor(() => expect(api.get.mock.calls.length).toBeGreaterThan(1));
  expect(h.result.current.state).toMatchObject({view: {preference: "disabled"}});
  api.get.mockRejectedValue(new Error("Offline"));
  act(() => h.result.current.refresh());
  await waitFor(() => expect(h.result.current.state.kind).toBe("error"));
  act(() => h.result.current.withdraw());
  expect(api.withdraw).toHaveBeenCalledOnce();
  h.unmount();
});
it("revoked or unissued withdrawal grants hide the optional control", async () => {
  const invalid = Object.assign(new Error("Unavailable"), {code: "functions/not-found"});
  api.get.mockRejectedValueOnce(invalid);
  const first = harness();
  await waitFor(() => expect(first.result.current.state.kind).toBe("hidden"));
  first.unmount();
  const second = harness();
  await waitFor(() => expect(second.result.current.state.kind).toBe("ready"));
  api.withdraw.mockRejectedValueOnce(invalid);
  act(() => second.result.current.withdraw());
  await waitFor(() => expect(second.result.current.state.kind).toBe("hidden"));
  second.unmount();
});
it("changing a secret remounts the scope and ignores the old pending result", async () => {
  const result = deferred(); api.withdraw.mockReturnValueOnce(result.promise);
  const h = setup();
  const page = render(<EventSmsWithdrawalPanel credential={credential} />, h);
  fireEvent.click(await screen.findByRole("button", {name: copy.turnOff}));
  await waitFor(() => expect(api.withdraw).toHaveBeenCalledOnce());
  const nextCredential = {...credential, secret: "c".repeat(43)};
  page.rerender(<EventSmsWithdrawalPanel credential={nextCredential} />);
  await waitFor(() => expect(api.get).toHaveBeenLastCalledWith(nextCredential));
  await act(async () => result.resolve(disabled));
  fireEvent.click(await screen.findByRole("button", {name: copy.turnOff}));
  await waitFor(() => expect(api.withdraw).toHaveBeenCalledTimes(2));
  expect(api.withdraw.mock.calls[1][0].secret).toBe(nextCredential.secret);
  page.unmount();
});
it("leaving the page does not let a delayed result recreate its private cache", async () => {
  const result = deferred(); api.withdraw.mockReturnValueOnce(result.promise);
  const h = harness();
  await waitFor(() => expect(h.result.current.state.kind).toBe("ready"));
  act(() => h.result.current.withdraw());
  await waitFor(() => expect(api.withdraw).toHaveBeenCalledOnce());
  h.unmount();
  await waitFor(() => expect(h.client.getQueryCache().getAll()).toHaveLength(0));
  await act(async () => result.resolve(disabled));
  expect(h.client.getQueryCache().getAll()).toHaveLength(0);
});
it("shows confirmed withdrawal without any way to grant consent from the bearer link", () => {
  render(<EventSmsWithdrawalCard state={{kind: "ready", view: disabled.view,
    pending: false, uncertain: false, notice: ""}} withdraw={vi.fn()} refresh={vi.fn()} />);
  expect(screen.getByText(copy.withdrawalSaved)).toBeTruthy();
  expect(screen.queryByRole("button")).toBeNull();
});
