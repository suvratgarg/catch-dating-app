import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {sampleHostAnalytics, sampleOverview} from "../../../shared/api/sampleData";
import {
  buildFinanceIssueReview,
  buildFinanceRows,
  type FinanceIssueRow,
  useFinanceOpsController,
} from "./useFinanceOpsController";

const mocks = vi.hoisted(() => ({
  loadFinanceHostAnalytics: vi.fn(),
  loadFinanceOverview: vi.fn(),
}));

vi.mock("../api/financeOpsRepository", () => mocks);

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {queries: {retry: false}},
  });
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
  };
}

describe("useFinanceOpsController", () => {
  beforeEach(() => {
    mocks.loadFinanceOverview.mockReset().mockResolvedValue(sampleOverview);
    mocks.loadFinanceHostAnalytics.mockReset().mockResolvedValue(sampleHostAnalytics);
  });

  it("loads independent sources and keeps issue selection route-owned", async () => {
    const onError = vi.fn();
    const onSelectIssueId = vi.fn();
    const selectedIssueId = sampleOverview.queues.paymentIssues[0]?.id ?? null;
    const {result} = renderHook(() => useFinanceOpsController({
      onError,
      onSelectIssueId,
      selectedIssueId,
    }), {wrapper: createWrapper()});

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.sources.map((source) => source.status)).toEqual([
      "ready",
      "ready",
    ]);
    expect(result.current.metrics.paymentPreviewCount).toBe(
      sampleOverview.queues.paymentIssues.length
    );
    expect(result.current.selected?.id).toBe(selectedIssueId);
    expect(result.current.selectedReview?.actionStatus).toBe("manual_provider_review");

    const eventRow = result.current.rows.find((row) => row.kind === "event");
    expect(eventRow).toBeDefined();
    act(() => result.current.select(eventRow!));
    expect(onSelectIssueId).toHaveBeenCalledWith(eventRow?.id);
    expect(result.current.selected?.id).toBe(selectedIssueId);

    act(() => {
      result.current.setKindFilter("payment");
      result.current.setQuery(selectedIssueId ?? "");
    });
    expect(result.current.filteredRows.map((row) => row.id)).toEqual([
      selectedIssueId,
    ]);
  });

  it("retains available source data and reports partial state", async () => {
    mocks.loadFinanceOverview.mockRejectedValue(new Error("overview unavailable"));
    const onError = vi.fn();
    const {result} = renderHook(
      () => useFinanceOpsController({onError}),
      {wrapper: createWrapper()}
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.isPartial).toBe(true);
    expect(result.current.isUnavailable).toBe(false);
    expect(result.current.metrics.paymentPreviewCount).toBeNull();
    expect(result.current.rows.some((row) => row.kind === "event")).toBe(true);
    expect(onError).toHaveBeenLastCalledWith(null);
  });

  it("surfaces complete source failure without synthesizing rows", async () => {
    mocks.loadFinanceOverview.mockRejectedValue(new Error("overview unavailable"));
    mocks.loadFinanceHostAnalytics.mockRejectedValue(new Error("analytics unavailable"));
    const onError = vi.fn();
    const {result} = renderHook(
      () => useFinanceOpsController({onError, selectedIssueId: "missing"}),
      {wrapper: createWrapper()}
    );

    await waitFor(() => expect(result.current.isUnavailable).toBe(true));
    expect(result.current.rows).toEqual([]);
    expect(result.current.selectedUnavailable).toBe(true);
    expect(onError).toHaveBeenCalledWith(
      "Finance sources are unavailable. Retry either source below."
    );
  });

  it("omits malformed source records and reports their count", () => {
    const result = buildFinanceRows({
      overview: {
        ...sampleOverview,
        queues: {
          ...sampleOverview.queues,
          paymentIssues: [
            ...sampleOverview.queues.paymentIssues,
            {id: "broken"} as never,
          ],
        },
      },
    });
    expect(result.malformedCount).toBe(1);
    expect(result.rows.some((row) => row.id === "broken")).toBe(false);
  });
});

describe("buildFinanceIssueReview", () => {
  const baseRow: FinanceIssueRow = {
    id: "issue-1",
    kind: "payment",
    title: "Payment failed",
    detail: "Provider status needs review",
    status: "refund_failed",
    targetPath: "payments/payment-1",
    createdAt: null,
    amountMinor: 120000,
    currency: "INR",
    severity: "high",
    nextAction: "Review provider record",
    sourceScope: "Current capped overview payment preview",
    amountEvidence: "inferred",
    providerEvidence: "inferred",
  };

  it("keeps payment, event, and payout actions behind evidence boundaries", () => {
    expect(buildFinanceIssueReview(baseRow)).toMatchObject({
      actionStatus: "manual_provider_review",
      statusLabel: "Manual refund escalation",
    });
    expect(buildFinanceIssueReview({
      ...baseRow,
      kind: "event",
      targetPath: "events/event-1",
      currency: "USD",
      amountEvidence: "source",
      providerEvidence: "unknown",
    })).toMatchObject({
      actionStatus: "aggregate_only",
      reconciliationStatus: "Aggregate signal only",
    });
    expect(buildFinanceIssueReview({
      ...baseRow,
      kind: "payout",
      amountEvidence: "unknown",
      providerEvidence: "unknown",
    })).toMatchObject({
      actionStatus: "needs_finance_contract",
      provider: "Unknown in aggregate row",
    });
  });
});
