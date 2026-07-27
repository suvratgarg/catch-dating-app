import {cleanup, render, screen} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";

import {sampleIntakeOperations} from
  "../../../../shared/operations/sampleIntakeOperations";
import {IntakeOperationsPreviewWorkspace} from
  "./IntakeOperationsWorkspace";

afterEach(() => cleanup());

describe("IntakeOperationsPreviewWorkspace", () => {
  it("opens on the persisted exception stage without exposing execution", () => {
    render(<IntakeOperationsPreviewWorkspace controller={{
      data: sampleIntakeOperations(),
      errorMessage: null,
      isError: false,
      isLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      loadMore: vi.fn(),
      refresh: vi.fn(),
    }} />);

    expect(screen.getByRole("navigation", {
      name: "Supply Intake operation stages",
    })).toBeTruthy();
    expect(screen.getAllByText("Rooftop Singles Mixer")).toHaveLength(2);
    expect(screen.queryByRole("button", {name: /run|publish|deploy/iu})).toBeNull();
    expect(screen.getByText("Read-only projection")).toBeTruthy();
    expect(screen.getAllByText("human review required", {exact: true})).toHaveLength(2);
  });

  it("labels run inventory as loaded pages when more runs are available", () => {
    const loadMore = vi.fn();
    render(<IntakeOperationsPreviewWorkspace controller={{
      data: {...sampleIntakeOperations(), nextRunCursor: "next-run-page"},
      errorMessage: null,
      isError: false,
      isLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      loadMore,
      refresh: vi.fn(),
    }} />);

    expect(screen.getByText(/1 run · 1 exception · 4\/4/iu))
      .toBeTruthy();
    expect(screen.queryByText(/persisted shadow run/iu)).toBeNull();
  });

  it("offers lazy ordinary-page loading without changing read-only scope", () => {
    const loadMore = vi.fn();
    render(<IntakeOperationsPreviewWorkspace controller={{
      data: {...sampleIntakeOperations(), nextWorkItemCursor: "next-item-page"},
      errorMessage: null,
      isError: false,
      isLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      loadMore,
      refresh: vi.fn(),
    }} />);

    screen.getByRole("button", {name: "Load 200 more"}).click();
    expect(loadMore).toHaveBeenCalledTimes(1);
  });
});
