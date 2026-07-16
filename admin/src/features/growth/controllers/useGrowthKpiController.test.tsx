import {act, renderHook, waitFor} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {useGrowthKpiController} from "./useGrowthKpiController";

describe("useGrowthKpiController", () => {
  it("loads growth signals and composes stage and search filters", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useGrowthKpiController({onError: vi.fn()}), {wrapper});

    await waitFor(() => expect(result.current.rows.length).toBeGreaterThan(0));
    const row = result.current.rows[0];
    act(() => {
      result.current.setStageFilter(row.stage);
      result.current.setQuery(row.label);
    });

    expect(result.current.metrics.signupsThisWeek).toBeGreaterThan(0);
    expect(result.current.selected).toBeNull();
    expect(result.current.rows.every((item) =>
      Boolean(item.source && item.metricBasis && item.range && item.timezone)
    )).toBe(true);
    expect(result.current.filteredRows.length).toBeGreaterThan(0);
    expect(result.current.filteredRows.every((item) => item.stage === row.stage)).toBe(true);
  });

  it("keeps signal selection URL-owned without falling back to another row", async () => {
    const onSelectSignalId = vi.fn();
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useGrowthKpiController({
      onError: vi.fn(),
      onSelectSignalId,
      selectedSignalId: "missing-signal",
    }), {wrapper});

    await waitFor(() => expect(result.current.rows.length).toBeGreaterThan(0));
    expect(result.current.selectedSignalId).toBe("missing-signal");
    expect(result.current.selected).toBeNull();
    act(() => result.current.select(result.current.rows[0]!));
    expect(onSelectSignalId).toHaveBeenCalledWith(result.current.rows[0]!.id);
  });
});
