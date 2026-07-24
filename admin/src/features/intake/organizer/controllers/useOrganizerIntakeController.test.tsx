import {act, renderHook, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../../shared/test/queryHarness";
import organizerIntakeBridgeJson from
  "../generated/organizerIntakeBridge.json";
import {useOrganizerIntakeController} from "./useOrganizerIntakeController";

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
    json: async () => organizerIntakeBridgeJson,
    ok: true,
    status: 200,
  }));
});
afterEach(() => vi.unstubAllGlobals());

describe("useOrganizerIntakeController", () => {
  it("derives the intake metrics and retains explicit review notes", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useOrganizerIntakeController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});

    await waitFor(() => expect(result.current).toBeTruthy());
    expect(result.current.bridge.items.length).toBeGreaterThan(0);
    expect(result.current.bridge.summary.reviewItems).toBe(result.current.bridge.items.length);
    expect(result.current.metrics.length).toBeGreaterThan(10);
    act(() => result.current.setDecisionNotes({"organizer-1": "Reviewed evidence."}));
    expect(result.current.decisionNotes["organizer-1"]).toBe("Reviewed evidence.");
  });
});
