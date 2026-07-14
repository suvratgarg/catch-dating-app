import {act, renderHook, waitFor} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import marketingFixture from "../../../generated/marketingOpsBridge.json";
import type {
  MarketingOpsBridge,
  MarketingOpsTargetType,
} from "../../../shared/types/adminTypes";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {
  marketingEditSizeLimit,
  serializedEditLength,
  useMarketingOpsController,
} from "./useMarketingOpsController";

const mocks = vi.hoisted(() => ({
  createMarketingContentDraft: vi.fn(),
  loadMarketingOpsBridge: vi.fn(),
  recordMarketingReviewDecision: vi.fn(),
}));

vi.mock("../api/marketingRepository", () => mocks);

function bridge(): MarketingOpsBridge {
  return structuredClone(marketingFixture) as unknown as MarketingOpsBridge;
}

function decisionResponse(
  targetType: MarketingOpsTargetType,
  targetId: string
) {
  return {
    decisionId: `decision-${targetId}`,
    targetType,
    targetId,
    decision: "export_ready" as const,
    decisionStatus: "export_ready" as const,
    decisionPath: `marketingReviewDecisions/decision-${targetId}`,
  };
}

describe("useMarketingOpsController", () => {
  beforeEach(() => {
    mocks.loadMarketingOpsBridge.mockReset().mockResolvedValue({bridge: bridge()});
    mocks.recordMarketingReviewDecision.mockReset().mockImplementation(
      ({targetType, targetId}: {targetType: MarketingOpsTargetType; targetId: string}) =>
        Promise.resolve(decisionResponse(targetType, targetId))
    );
    mocks.createMarketingContentDraft.mockReset();
  });

  it("keeps the saved snapshot immutable and registers unload protection only while dirty", async () => {
    const addListener = vi.spyOn(window, "addEventListener");
    const removeListener = vi.spyOn(window, "removeEventListener");
    const {wrapper} = createQueryHarness();
    const {result, unmount} = renderHook(() => useMarketingOpsController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});
    await waitFor(() => expect(result.current.bridge?.contentDrafts.length).toBeGreaterThan(0));
    const draft = result.current.bridge!.contentDrafts[0]!;
    const savedCaption = result.current.savedBridge!.contentDrafts[0]!.caption;

    act(() => result.current.updateDraft(draft.id, {caption: "Unsaved session caption"}));
    await waitFor(() => expect(result.current.hasUnsavedChanges).toBe(true));
    expect(result.current.bridge?.contentDrafts[0]?.caption).toBe("Unsaved session caption");
    expect(result.current.savedBridge?.contentDrafts[0]?.caption).toBe(savedCaption);
    expect(addListener).toHaveBeenCalledWith("beforeunload", expect.any(Function));
    unmount();
    expect(removeListener).toHaveBeenCalledWith("beforeunload", expect.any(Function));
  });

  it("does not substitute another draft for an unavailable deep link", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useMarketingOpsController({
      activeTab: "draft",
      selectedDraftId: "missing-draft",
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});
    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.selectedDraft).toBeNull();
    expect(result.current.selectedDraftUnavailable).toBe(true);
  });

  it("requires explicit rights confirmation and sends its true value", async () => {
    const initialBridge = bridge();
    const draft = initialBridge.contentDrafts[0]!;
    mocks.loadMarketingOpsBridge.mockResolvedValue({bridge: initialBridge});
    const onError = vi.fn();
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useMarketingOpsController({
      activeTab: "draft",
      selectedDraftId: draft.id,
      composerStep: "export",
      onError,
      onNotice: vi.fn(),
    }), {wrapper});
    await waitFor(() => expect(result.current.selectedDraft?.id).toBe(draft.id));

    await act(async () => {
      await result.current.targetDecision({
        targetType: "content_draft",
        targetId: draft.id,
        decision: "export_ready",
        edits: draft as unknown as Record<string, unknown>,
        defaultNote: "Export review",
      });
    });
    expect(mocks.recordMarketingReviewDecision).not.toHaveBeenCalled();
    expect(onError).toHaveBeenLastCalledWith(expect.stringContaining("Confirm image and media rights"));

    act(() => result.current.setRightsConfirmed(true));
    await act(async () => {
      await result.current.targetDecision({
        targetType: "content_draft",
        targetId: draft.id,
        decision: "export_ready",
        edits: draft as unknown as Record<string, unknown>,
        defaultNote: "Export review",
      });
    });
    expect(mocks.recordMarketingReviewDecision.mock.calls[0]?.[0]).toEqual(
      expect.objectContaining({
        checklist: expect.objectContaining({rightsReviewed: true}),
      })
    );
    expect(result.current.reviewReceiptRecorded).toBe(true);
  });

  it("accepts 50,000 serialized characters and blocks 50,001 before mutation", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useMarketingOpsController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper});
    await waitFor(() => expect(result.current.bridge).not.toBeNull());
    const accepted = {text: "x".repeat(marketingEditSizeLimit - 11)};
    const blocked = {text: "x".repeat(marketingEditSizeLimit - 10)};
    expect(serializedEditLength(accepted)).toBe(marketingEditSizeLimit);
    expect(serializedEditLength(blocked)).toBe(marketingEditSizeLimit + 1);

    await act(async () => {
      await result.current.targetDecision({
        targetType: "source_result",
        targetId: "source-1",
        decision: "hold",
        edits: accepted,
        defaultNote: "Hold",
      });
      await result.current.targetDecision({
        targetType: "source_result",
        targetId: "source-2",
        decision: "hold",
        edits: blocked,
        defaultNote: "Hold",
      });
    });
    expect(mocks.recordMarketingReviewDecision).toHaveBeenCalledTimes(1);
  });
});
