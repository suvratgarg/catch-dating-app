import {act, renderHook, waitFor} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {useOrganizerClaimReviewController} from "./useOrganizerClaimReviewController";

describe("useOrganizerClaimReviewController", () => {
  it("loads claim evidence and blocks a decision without a review note", async () => {
    const onError = vi.fn();
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useOrganizerClaimReviewController({
      onError,
      onNotice: vi.fn(),
    }), {wrapper});

    await waitFor(() => expect(result.current.rows.length).toBeGreaterThan(0));
    act(() => result.current.select(result.current.rows[0]));
    await waitFor(() => expect(result.current.details).not.toBeNull());
    await act(async () => {
      expect(await result.current.decide("approve")).toBe(false);
    });

    expect(onError).toHaveBeenLastCalledWith("Add a review note before approving or rejecting.");
  });

  it("reports an unavailable direct claim without falling back to the list", async () => {
    const onError = vi.fn();
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useOrganizerClaimReviewController({
      onError,
      onNotice: vi.fn(),
      selectedRequestId: "outside-preview",
    }), {wrapper});

    await waitFor(() => expect(result.current.selectedUnavailable).toBe(true));
    expect(result.current.isDetailLoading).toBe(false);
    expect(result.current.selected).toBeNull();
    expect(result.current.detailError).toContain(
      "Organizer claim request not found."
    );
    expect(onError).toHaveBeenLastCalledWith(
      "Organizer claim request not found."
    );
  });
});
