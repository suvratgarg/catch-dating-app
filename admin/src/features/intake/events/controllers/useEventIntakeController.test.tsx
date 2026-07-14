import {act, renderHook, waitFor} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../../shared/test/queryHarness";
import {useEventIntakeController} from "./useEventIntakeController";

describe("useEventIntakeController", () => {
  it("loads the generated bridge and keeps candidate edits in the query cache", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useEventIntakeController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});

    await waitFor(() => expect(result.current.bridge?.eventCandidates.length).toBeGreaterThan(0));
    expect(result.current.activeTab).toBe("candidates");
    const candidate = result.current.bridge!.eventCandidates[0];
    act(() => result.current.updateCandidate(candidate.id, {title: "Reviewed event title"}));

    await waitFor(() => expect(
      result.current.bridge?.eventCandidates.find((item) => item.id === candidate.id)?.title
    ).toBe("Reviewed event title"));
  });
});
