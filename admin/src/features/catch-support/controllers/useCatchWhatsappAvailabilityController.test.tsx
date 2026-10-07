import {act, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";
import {beforeEach, expect, it, vi} from "vitest";
import {useCatchWhatsappAvailabilityController} from "./useCatchWhatsappAvailabilityController";
const f = vi.hoisted(() => ({refresh: vi.fn(), available: false}));
vi.mock("../api/catchWhatsappAvailability", () => ({
  refreshCatchWhatsappAvailability: f.refresh,
  catchWhatsappSupportAvailable: () => f.available,
}));
const scope = {actorUid: "operator", projectId: "catch-prod-synthetic",
  sessionKey: "current", isCurrent: () => true};
beforeEach(() => {f.refresh.mockReset(); f.available = false;});

it("keeps production unavailable until its scoped Remote Config read succeeds", async () => {
  let release!: (value: boolean) => void;
  f.refresh.mockImplementation(() => new Promise<boolean>(resolve => {release = resolve;}));
  const client = new QueryClient();
  const view = renderHook(() => useCatchWhatsappAvailabilityController(scope), {wrapper:
    ({children}: {children: ReactNode}) => <QueryClientProvider client={client}>{children}</QueryClientProvider>});
  expect(view.result.current).toBe(false);
  await waitFor(() => expect(f.refresh).toHaveBeenCalledWith(scope));
  await act(async () => {f.available = true; release(true);});
  await waitFor(() => expect(view.result.current).toBe(true));
  f.refresh.mockImplementation(async () => {f.available = false; return false;});
  await act(async () => {await client.invalidateQueries();});
  await waitFor(() => expect(view.result.current).toBe(false));
  view.unmount(); client.clear();
});
