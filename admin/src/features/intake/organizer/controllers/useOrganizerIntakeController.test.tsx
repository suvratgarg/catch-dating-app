import {act, renderHook, waitFor} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../../shared/test/queryHarness";
import {useOrganizerIntakeController} from "./useOrganizerIntakeController";

describe("useOrganizerIntakeController", () => {
  it("derives the intake metrics and retains explicit review notes", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useOrganizerIntakeController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});

    await waitFor(() => expect(result.current).toBeTruthy());
    expect(result.current.source).toBe("sample");
    expect(result.current.bridge.searchCandidates.candidates).toHaveLength(2);
    expect(result.current.bridge.summary.searchResultCandidates).toBe(2);
    expect(result.current.metrics.length).toBeGreaterThan(5);
    act(() => result.current.setDecisionNotes({"organizer-1": "Reviewed evidence."}));
    expect(result.current.decisionNotes["organizer-1"]).toBe("Reviewed evidence.");
  });
});
