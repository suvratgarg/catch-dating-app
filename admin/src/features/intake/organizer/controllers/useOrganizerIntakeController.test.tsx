import {act, renderHook} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../../shared/test/queryHarness";
import {useOrganizerIntakeController} from "./useOrganizerIntakeController";

describe("useOrganizerIntakeController", () => {
  it("derives the intake metrics and retains explicit review notes", () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useOrganizerIntakeController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});

    expect(result.current.bridge.items.length).toBeGreaterThan(0);
    expect(result.current.bridge.summary.reviewItems).toBe(result.current.bridge.items.length);
    expect(result.current.metrics.length).toBeGreaterThan(10);
    act(() => result.current.setDecisionNotes({"organizer-1": "Reviewed evidence."}));
    expect(result.current.decisionNotes["organizer-1"]).toBe("Reviewed evidence.");
  });
});
