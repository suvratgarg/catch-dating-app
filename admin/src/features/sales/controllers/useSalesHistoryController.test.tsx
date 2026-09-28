import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {afterEach, expect, it, vi} from "vitest";
import {useSalesHistoryController} from "./useSalesHistoryController";
import type {SalesHistoryApi} from "../api/salesHistoryTypes";

const api: SalesHistoryApi = {listRecords: vi.fn(), listRows: vi.fn()};
afterEach(() => {
  cleanup(); vi.mocked(api.listRecords).mockReset();
  vi.mocked(api.listRows).mockReset();
});

it("pages independently and resets host and actor cursors before querying", async () => {
  vi.mocked(api.listRecords).mockImplementation(async ({cursor}) =>
    ({records: [], nextCursor: cursor ? null : "record-cursor"}));
  vi.mocked(api.listRows).mockImplementation(async ({cursor}) =>
    ({rows: [], nextCursor: cursor ? null : "row-cursor"}));
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: {children: React.ReactNode}) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  const view = renderHook(({organizerId, actorUid}) =>
    useSalesHistoryController({organizerId, actorUid, api}),
  {initialProps: {organizerId: "org-1", actorUid: "actor-1"}, wrapper});
  await waitFor(() => expect(view.result.current.records.isSuccess).toBe(true));
  act(() => {
    view.result.current.nextRecords();
    view.result.current.nextRows();
  });
  await waitFor(() => expect(api.listRecords).toHaveBeenCalledWith({
    organizerId: "org-1", cursor: "record-cursor", limit: 25,
  }));
  await waitFor(() => expect(api.listRows).toHaveBeenCalledWith({
    organizerId: "org-1", cursor: "row-cursor", limit: 25,
  }));
  view.rerender({organizerId: "org-2", actorUid: "actor-1"});
  await waitFor(() => expect(api.listRecords).toHaveBeenCalledWith({
    organizerId: "org-2", cursor: undefined, limit: 25,
  }));
  expect(view.result.current.recordBack).toEqual([]);
  expect(view.result.current.rowBack).toEqual([]);
  view.rerender({organizerId: "org-2", actorUid: "actor-2"});
  await waitFor(() => expect(api.listRows).toHaveBeenCalledWith({
    organizerId: "org-2", cursor: undefined, limit: 25,
  }));
});
