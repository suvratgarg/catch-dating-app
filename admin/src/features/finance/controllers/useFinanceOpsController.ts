import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminQueueItem,
  HostAnalyticsEventRow,
} from "../../../shared/types/adminTypes";
import {loadFinanceOpsSnapshot} from "../api/financeOpsRepository";

export type FinanceIssueKind =
  | "all"
  | "payment"
  | "event"
  | "payout";

export interface FinanceIssueRow {
  id: string;
  kind: Exclude<FinanceIssueKind, "all">;
  title: string;
  detail: string;
  status: string;
  targetPath: string;
  createdAt: string | null;
  amountMinor: number | null;
  currency: string;
  severity: "high" | "medium" | "watch";
  nextAction: string;
}

export type FinanceIssueActionStatus =
  | "manual_provider_review"
  | "aggregate_only"
  | "needs_finance_contract";

export interface FinanceIssueReview {
  provider: string;
  sourceModel: string;
  sourceOfTruth: string;
  reconciliationStatus: string;
  actionStatus: FinanceIssueActionStatus;
  statusLabel: string;
  statusDetail: string;
  mutationBoundary: string;
  requiredEvidence: string[];
  blockedActions: string[];
}

export interface FinanceMetrics {
  completedPayments: number;
  failedPayments: number;
  signupFailedPayments: number;
  payoutRestrictedHosts: number;
  revenueMinor: number;
}

export function useFinanceOpsController({
  onError,
}: {
  onError: (message: string | null) => void;
}) {
  const [rows, setRows] = useState<FinanceIssueRow[]>([]);
  const [metrics, setMetrics] = useState<FinanceMetrics>({
    completedPayments: 0,
    failedPayments: 0,
    signupFailedPayments: 0,
    payoutRestrictedHosts: 0,
    revenueMinor: 0,
  });
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [kindFilter, setKindFilter] = useState<FinanceIssueKind>("all");
  const [query, setQuery] = useState("");
  const [loadedAt, setLoadedAt] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    try {
      const snapshot = await loadFinanceOpsSnapshot();
      const nextRows = buildFinanceRows(snapshot);
      setRows(nextRows);
      setMetrics(buildFinanceMetrics(snapshot));
      setLoadedAt(snapshot.loadedAt);
      setSelectedId((current) => {
        if (current && nextRows.some((row) => row.id === current)) {
          return current;
        }
        return null;
      });
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load finance signals."));
    } finally {
      setIsLoading(false);
    }
  }, [onError]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const filteredRows = useMemo(
    () => filterRows(rows, kindFilter, query),
    [kindFilter, query, rows]
  );
  const selected = useMemo(
    () => rows.find((row) => row.id === selectedId) ?? null,
    [rows, selectedId]
  );
  const selectedReview = useMemo(
    () => selected ? buildFinanceIssueReview(selected) : null,
    [selected]
  );

  const select = useCallback((row: FinanceIssueRow) => {
    setSelectedId(row.id);
    onError(null);
  }, [onError]);

  return {
    filteredRows,
    isLoading,
    kindFilter,
    loadedAt,
    metrics,
    query,
    rows,
    selected,
    selectedReview,
    refresh,
    select,
    setKindFilter,
    setQuery,
  };
}

function buildFinanceRows(snapshot: Awaited<
  ReturnType<typeof loadFinanceOpsSnapshot>
>): FinanceIssueRow[] {
  const paymentRows = snapshot.overview.queues.paymentIssues.map(paymentIssue);
  const eventRows = snapshot.hostAnalytics.topEvents
    .filter((event) => event.paymentFailedCount > 0 ||
      event.paymentRefundedCount > 0 ||
      event.checkoutDropoffCount > 0)
    .map(eventPaymentIssue);
  const payoutRows = metricValue(snapshot, "payoutRestrictedHosts") > 0 ? [{
    id: "payout-restricted-hosts",
    kind: "payout" as const,
    title: "Payout restricted hosts",
    detail: `${metricValue(snapshot, "payoutRestrictedHosts")} host accounts need provider review.`,
    status: "restricted",
    targetPath: "metrics/payoutRestrictedHosts",
    createdAt: snapshot.loadedAt,
    amountMinor: null,
    currency: "INR",
    severity: "medium" as const,
    nextAction:
      "Inspect provider authority before changing payout or settlement state.",
  }] : [];
  return [...paymentRows, ...eventRows, ...payoutRows]
    .sort((a, b) => severityRank(b.severity) - severityRank(a.severity) ||
      a.title.localeCompare(b.title));
}

export function buildFinanceIssueReview(
  row: FinanceIssueRow
): FinanceIssueReview {
  if (row.kind === "payout") {
    return {
      provider: "stripe",
      sourceModel: "Overview payout restriction count",
      sourceOfTruth:
        "hostPaymentAccounts/{uid} plus Stripe connected account state",
      reconciliationStatus: "Needs host-level provider account list",
      actionStatus: "needs_finance_contract",
      statusLabel: "Payout lifecycle unavailable",
      statusDetail:
        "This row is an aggregate count. Operators need hostPaymentAccounts rows, Stripe requirements, and an audited payout workflow before release or settlement actions can be exposed.",
      mutationBoundary:
        "No finance callable currently releases payouts, edits settlements, or clears Stripe restrictions.",
      requiredEvidence: [
        "hostPaymentAccounts/{uid}.onboardingStatus and payoutsEnabled",
        "Stripe account requirements currently_due, past_due, and disabled_reason",
        "Host ownership and settlement eligibility",
        "Audit note and finance role approval for any future payout action",
      ],
      blockedActions: [
        "Release payout",
        "Clear restriction",
        "Edit settlement",
      ],
    };
  }

  if (row.kind === "event") {
    return {
      provider: providerForCurrency(row.currency, "mixed payment provider"),
      sourceModel: "Host analytics event aggregate",
      sourceOfTruth:
        "payments/{paymentId}, eventParticipations, provider dashboard, and future ledger",
      reconciliationStatus: "Aggregate signal only",
      actionStatus: "aggregate_only",
      statusLabel: "Reconcile individual payments first",
      statusDetail:
        "The event row comes from analytics counts, so it can flag a problem but cannot prove which payment, refund, attendee, or settlement should change.",
      mutationBoundary:
        "No event-level refund, settlement correction, or payout action should run from this aggregate row.",
      requiredEvidence: [
        `All payments where eventId matches ${eventIdFromTarget(row.targetPath)}`,
        "Provider payment/refund records for every affected payment",
        "eventParticipations paymentId and booking status",
        "Host analytics generatedAt and provider reconciliation timestamp",
      ],
      blockedActions: [
        "Bulk refund event payments",
        "Mark event settled",
        "Change attendance or booking state",
      ],
    };
  }

  const normalizedStatus = normalizeStatus(row.status);
  const refundFailed = normalizedStatus === "refundfailed";
  const refunded = normalizedStatus === "refunded";
  return {
    provider: providerForCurrency(row.currency, "provider from payment doc"),
    sourceModel: "Overview payment issue row",
    sourceOfTruth:
      "payments/{paymentId}, provider order/payment/refund object, and pending-order reconciliation state",
    reconciliationStatus: refundFailed ?
      "Manual refund required" :
      refunded ?
        "Refund needs provider verification" :
        "Provider record required",
    actionStatus: "manual_provider_review",
    statusLabel: refundFailed ?
      "Manual refund escalation" :
      refunded ?
        "Verify refund settlement" :
        "Verify payment outcome",
    statusDetail: refundFailed ?
      "The payment schema treats refundFailed as a charged booking whose automatic refund failed. That requires provider evidence and a manual reconciliation path before user-facing closure." :
      refunded ?
        "The admin row says the payment has been refunded; verify the provider refund object and participation state before closing support follow-up." :
        "The admin row says payment failed or signup failed. Confirm whether the provider captured funds, whether a pending Razorpay order exists, and whether fulfillment/refund already ran.",
    mutationBoundary:
      "No admin finance callable currently retries payment, issues a manual refund, edits payment status, or marks settlement complete.",
    requiredEvidence: [
      `${row.targetPath} status, provider, orderId, paymentId, amount, and signUpFailed`,
      "Provider order/payment/refund object",
      "razorpayPendingOrders/{orderId} when provider is Razorpay",
      "eventParticipations paymentId and booking state",
    ],
    blockedActions: [
      "Retry payment",
      "Issue manual refund",
      "Edit payment status",
      "Send final support resolution",
    ],
  };
}

function paymentIssue(row: AdminQueueItem): FinanceIssueRow {
  return {
    id: row.id,
    kind: "payment",
    title: row.title,
    detail: row.detail,
    status: row.status,
    targetPath: row.targetPath,
    createdAt: row.createdAt,
    amountMinor: amountFromTitle(row.title),
    currency: "INR",
    severity: row.status === "failed" ? "high" : "medium",
    nextAction:
      "Open the provider record before retry, refund, or manual follow-up.",
  };
}

function eventPaymentIssue(event: HostAnalyticsEventRow): FinanceIssueRow {
  const failed = event.paymentFailedCount;
  const refunded = event.paymentRefundedCount;
  const dropoff = event.checkoutDropoffCount;
  return {
    id: `event-${event.eventId}-payments`,
    kind: "event",
    title: event.title,
    detail:
      `${failed} failed, ${refunded} refunded, ${dropoff} checkout drop-off.`,
    status: failed > 0 ? "failed" : refunded > 0 ? "refunded" : "dropoff",
    targetPath: `events/${event.eventId}`,
    createdAt: event.startTime,
    amountMinor: event.grossRevenueMinor,
    currency: event.currency,
    severity: failed > 0 ? "high" : "watch",
    nextAction:
      "Use event and provider records to reconcile payment state before action.",
  };
}

function buildFinanceMetrics(snapshot: Awaited<
  ReturnType<typeof loadFinanceOpsSnapshot>
>): FinanceMetrics {
  const revenue = snapshot.hostAnalytics.summaryCards.find((item) =>
    item.id === "revenue"
  )?.value ?? 0;
  return {
    completedPayments: metricValue(snapshot, "completedPayments"),
    failedPayments: metricValue(snapshot, "failedPayments"),
    signupFailedPayments: metricValue(snapshot, "signupFailedPayments"),
    payoutRestrictedHosts: metricValue(snapshot, "payoutRestrictedHosts"),
    revenueMinor: revenue,
  };
}

function metricValue(
  snapshot: Awaited<ReturnType<typeof loadFinanceOpsSnapshot>>,
  id: string
): number {
  return snapshot.overview.metrics.find((item) => item.id === id)?.value ?? 0;
}

function filterRows(
  rows: FinanceIssueRow[],
  kindFilter: FinanceIssueKind,
  query: string
): FinanceIssueRow[] {
  const tokens = query.trim().toLowerCase().split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    if (kindFilter !== "all" && row.kind !== kindFilter) return false;
    if (tokens.length === 0) return true;
    const haystack = [
      row.id,
      row.kind,
      row.title,
      row.detail,
      row.status,
      row.targetPath,
      row.nextAction,
    ].join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function amountFromTitle(title: string): number | null {
  const match = title.match(/\bINR\s*(\d+)\b/u);
  if (!match) return null;
  return Number.parseInt(match[1], 10);
}

function severityRank(severity: FinanceIssueRow["severity"]): number {
  if (severity === "high") return 3;
  if (severity === "medium") return 2;
  return 1;
}

function providerForCurrency(currency: string, fallback: string): string {
  if (currency.toUpperCase() === "INR") return "razorpay";
  if (currency.trim()) return fallback;
  return "unknown";
}

function eventIdFromTarget(targetPath: string): string {
  return targetPath.startsWith("events/") ?
    targetPath.slice("events/".length) :
    "the selected event";
}

function normalizeStatus(status: string): string {
  return status.replace(/[_\s-]+/gu, "").toLowerCase();
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
