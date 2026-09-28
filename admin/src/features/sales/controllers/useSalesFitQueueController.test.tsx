import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";
import {afterEach, expect, it, vi} from "vitest";
import type {FitQueueApi, FitQueuePage} from
  "../api/salesFitQueueTypes";
import {useSalesFitQueueController} from "./useSalesFitQueueController";

afterEach(cleanup);
const page: FitQueuePage = {rows: [], nextCursor: "next-rank-page",
  generation: 4, policyRevision: 2, qualificationPolicyHash: null,
  omittedExpiredInPage: 0};
function fixture() {
  const api: FitQueueApi = {
    list: vi.fn(async () => page), refresh: vi.fn(), refreshBatch: vi.fn(),
  };
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: {children: ReactNode}) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {api, client, wrapper};
}

it("uses server cursors and restarts when ranking generation changes", async () => {
  const {api, wrapper} = fixture();
  vi.mocked(api.list).mockResolvedValueOnce(page)
    .mockRejectedValueOnce(Object.assign(new Error("rank changed"),
      {code: "functions/aborted"}))
    .mockResolvedValueOnce({...page, nextCursor: null});
  const {result} = renderHook(() => useSalesFitQueueController({
    actorUid: "employee", api}), {wrapper});
  await waitFor(() => expect(result.current.page.data?.nextCursor)
    .toBe("next-rank-page"));
  act(() => result.current.nextPage());
  await waitFor(() => expect(api.list).toHaveBeenCalledWith(
    "ranked", "next-rank-page"));
  await waitFor(() => expect(result.current.cursor).toBeUndefined());
  await waitFor(() => expect(result.current.notice).toContain("restarted"));
  expect(api.list).toHaveBeenCalledWith("ranked", undefined);
});

it("keeps exact refresh request after an uncertain response", async () => {
  const {api, wrapper} = fixture();
  vi.mocked(api.refresh).mockRejectedValueOnce(new Error("network lost"))
    .mockResolvedValueOnce({entry: {score: null} as never,
      receipt: {requestId: "same", sourceHash: "a".repeat(64)}});
  const {result} = renderHook(() => useSalesFitQueueController({
    actorUid: "employee", api}), {wrapper});
  await act(async () => {
    expect(await result.current.refreshHost("org-a")).toBe(false);
  });
  expect(result.current.pending?.kind).toBe("host");
  await act(async () => {
    expect(await result.current.retryPending()).toBe(true);
  });
  expect(api.refresh).toHaveBeenCalledTimes(2);
  expect(vi.mocked(api.refresh).mock.calls[1][0])
    .toEqual(vi.mocked(api.refresh).mock.calls[0][0]);
  expect(result.current.pending).toBeNull();
});

it("continues a bounded batch with the same sweep identity and cursor", async () => {
  const {api, wrapper} = fixture();
  vi.mocked(api.refreshBatch).mockResolvedValueOnce({rows: [{organizerId: "org-a",
    result: "refreshed", sourceHash: "a".repeat(64), reason: null}],
  nextCursor: "next-batch"}).mockResolvedValueOnce({rows: [], nextCursor: null});
  const {result} = renderHook(() => useSalesFitQueueController({
    actorUid: "employee", api}), {wrapper});
  await act(async () => {await result.current.startBatch();});
  expect(result.current.nextBatchCursor).toBe("next-batch");
  await act(async () => {await result.current.continueBatch();});
  const calls = vi.mocked(api.refreshBatch).mock.calls;
  expect(calls[0][0]).toMatchObject({limit: 10});
  expect(calls[1][0]).toMatchObject({requestId: calls[0][0].requestId,
    cursor: "next-batch", limit: 10});
  expect(result.current.nextBatchCursor).toBeNull();
});
