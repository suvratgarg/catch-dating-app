import {cleanup, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";
import {afterEach, expect, it, vi} from "vitest";
import {getSalesFunnelReport} from "../api/salesFunnelRepository";
import {useSalesFunnelController} from "./useSalesFunnelController";
vi.mock("../api/salesFunnelRepository", () => ({getSalesFunnelReport: vi.fn()}));
afterEach(() => {cleanup(); vi.clearAllMocks();});
function fixture() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: {children: ReactNode}) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  return {wrapper};
}
it("withholds previous employee totals when the current employee changes", async () => {
  vi.mocked(getSalesFunnelReport).mockResolvedValueOnce({activeHosts: 40} as never)
    .mockImplementationOnce(() => new Promise(() => {}));
  const {wrapper} = fixture();
  const hook = renderHook(({uid}) => useSalesFunnelController(uid),
    {wrapper, initialProps: {uid: "employee-a"}});
  await waitFor(() => expect(hook.result.current.data?.activeHosts).toBe(40));
  hook.rerender({uid: "employee-b"});
  expect(hook.result.current.data).toBeUndefined();
});
it("does not turn overflow or authority errors into partial company counts", async () => {
  vi.mocked(getSalesFunnelReport).mockRejectedValue(new Error("Reviewed report limit exceeded"));
  const {wrapper} = fixture();
  const {result} = renderHook(() => useSalesFunnelController("employee"), {wrapper});
  await waitFor(() => expect(result.current.isError).toBe(true));
  expect(result.current.data).toBeUndefined();
  expect(getSalesFunnelReport).toHaveBeenCalledTimes(1);
});
