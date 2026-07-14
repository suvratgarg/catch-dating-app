import {act, renderHook, waitFor} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {useOverviewController} from "./useOverviewController";

describe("useOverviewController", () => {
  it("loads the sample overview and clears a scoped analytics query", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useOverviewController({
      adminRoles: [],
      isSessionReady: true,
      mode: "sample",
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.overview.metrics.length).toBeGreaterThan(0);
    expect(result.current.hostAnalytics.summaryCards.length).toBeGreaterThan(0);

    act(() => {
      result.current.setAnalyticsClubId("club-1");
      result.current.setAnalyticsEventId("event-1");
    });
    expect(result.current.analyticsClubId).toBe("club-1");
    act(() => result.current.clearAnalyticsScope());
    expect(result.current.analyticsClubId).toBe("");
    expect(result.current.analyticsEventId).toBe("");
  });
});
