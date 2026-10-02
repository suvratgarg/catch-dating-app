import {act, cleanup, render, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {AdminQueryProvider} from "../shared/query/queryClient";
import {useMessagingBudgetController} from "../features/finance/controllers/useMessagingBudgetController";
import {useFinanceOpsController} from "../features/finance/controllers/useFinanceOpsController";
import {sampleOverview, sampleHostAnalytics} from "../shared/api/sampleData";

const mocks = vi.hoisted(() => ({
  loadMessagingBudgetReview: vi.fn(), recordMessagingBudgetDecision: vi.fn(),
  stageApprovedMessagingBudget: vi.fn(), loadFinanceOverview: vi.fn(),
  loadFinanceHostAnalytics: vi.fn(),
}));
vi.mock("../features/finance/api/financeOpsRepository", () => mocks);
const baseReview = {
  review: {
    runtime: {sourceHash: "a"}, sender: {reviewHash: "b"},
    budgets: {kind: "reviewed", currency: "INR", sourceHash: "c"},
  },
  decision: null,
};
afterEach(cleanup);
beforeEach(() => {
  mocks.loadMessagingBudgetReview.mockResolvedValue(baseReview);
  mocks.loadFinanceOverview.mockResolvedValue(sampleOverview);
  mocks.loadFinanceHostAnalytics.mockResolvedValue(sampleHostAnalytics);
});

describe("Retired session controller requests", () => {
  it("does not start a follow-up budget review after the old decision completes", async () => {
    let controller!: ReturnType<typeof useMessagingBudgetController>;
    let complete!: (value: unknown) => void;
    mocks.recordMessagingBudgetDecision.mockReturnValue(new Promise((resolve) => { complete = resolve; }));
    function Probe() {
      controller = useMessagingBudgetController({onError: vi.fn(), onNotice: vi.fn()});
      return null;
    }
    const view = render(<AdminQueryProvider sessionKey="owner:1" isCurrentSession={() => true}><Probe /></AdminQueryProvider>);
    act(() => {
      controller.setScope("organizerId", "private-organizer");
      controller.setScope("eventId", "private-event");
      controller.setScope("senderId", "private-sender");
    });
    await act(async () => { await controller.review(); });
    act(() => controller.setDecisionNote("Synthetic hold decision"));
    let save!: Promise<boolean>;
    act(() => { save = controller.decide(); });
    await waitFor(() => expect(mocks.recordMessagingBudgetDecision).toHaveBeenCalledOnce());
    view.rerender(<AdminQueryProvider sessionKey="finance:2" isCurrentSession={() => true}><p>Next session</p></AdminQueryProvider>);
    await act(async () => { complete({}); expect(await save).toBe(false); });
    expect(mocks.loadMessagingBudgetReview).toHaveBeenCalledOnce();
  });

  it("starts no further analytics request when a Finance refresh is cancelled", async () => {
    let controller!: ReturnType<typeof useFinanceOpsController>;
    const onError = vi.fn();
    function Probe() {
      controller = useFinanceOpsController({adminRoles: ["adminOwner"], onError});
      return null;
    }
    const view = render(<AdminQueryProvider sessionKey="owner:1" isCurrentSession={() => true}><Probe /></AdminQueryProvider>);
    await waitFor(() => expect(controller.isLoading).toBe(false));
    mocks.loadFinanceOverview.mockReturnValue(new Promise(() => undefined));
    mocks.loadFinanceHostAnalytics.mockReturnValue(new Promise(() => undefined));
    let refreshing!: Promise<boolean>;
    act(() => { refreshing = controller.refresh(); });
    await waitFor(() => expect(mocks.loadFinanceOverview).toHaveBeenCalledTimes(2));
    expect(mocks.loadFinanceHostAnalytics).toHaveBeenCalledTimes(2);
    view.rerender(<AdminQueryProvider sessionKey="finance:2" isCurrentSession={() => true}><p>Next session</p></AdminQueryProvider>);
    await act(async () => { await refreshing; });
    expect(mocks.loadFinanceOverview).toHaveBeenCalledTimes(2);
    expect(mocks.loadFinanceHostAnalytics).toHaveBeenCalledTimes(2);
  });
});
