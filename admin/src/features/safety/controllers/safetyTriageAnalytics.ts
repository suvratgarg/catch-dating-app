import type {AdminOverviewMetric} from "../../../shared/types/adminTypes";

export type SafetyQueueAnalyticsId = "reports" | "moderation" | "event";
export type SafetyPriorityAnalyticsId = "high" | "medium" | "watch";
export type SafetyAgeAnalyticsId =
  | "under24h"
  | "oneToThreeDays"
  | "threeToSevenDays"
  | "oneToFourWeeks"
  | "fourWeeksPlus";

export interface SafetyChartPoint<Id extends string> {
  id: Id;
  label: string;
  value: number;
}

export interface SafetyAnalyticsRow {
  createdAt: string | null;
  priority: SafetyPriorityAnalyticsId;
  queueKind: SafetyQueueAnalyticsId;
}

export interface SafetyTriageAnalytics {
  openByQueue: {
    scope: "all-open-aggregate";
    points: Array<SafetyChartPoint<SafetyQueueAnalyticsId>>;
  };
  returnedByPriority: {
    scope: "returned-preview";
    returnedRowCount: number;
    points: Array<SafetyChartPoint<SafetyPriorityAnalyticsId>>;
  };
  returnedAge: {
    scope: "returned-preview";
    status: "ready" | "missing-reference-time";
    asOf: string | null;
    unknownTimestampCount: number;
    points: Array<SafetyChartPoint<SafetyAgeAnalyticsId>>;
  };
}

export function buildSafetyTriageAnalytics({
  generatedAt,
  metrics,
  rows,
}: {
  generatedAt: string | null;
  metrics: readonly AdminOverviewMetric[];
  rows: readonly SafetyAnalyticsRow[];
}): SafetyTriageAnalytics {
  const openByQueue: SafetyTriageAnalytics["openByQueue"] = {
    scope: "all-open-aggregate",
    points: [
      {
        id: "reports",
        label: "User reports",
        value: metricValue(metrics, "openReports"),
      },
      {
        id: "moderation",
        label: "Moderation",
        value: metricValue(metrics, "pendingModerationFlags"),
      },
      {
        id: "event",
        label: "Event reports",
        value: metricValue(metrics, "eventSafetyReports"),
      },
    ],
  };
  const returnedByPriority: SafetyTriageAnalytics["returnedByPriority"] = {
    scope: "returned-preview",
    returnedRowCount: rows.length,
    points: [
      {
        id: "high",
        label: "High",
        value: rows.filter((row) => row.priority === "high").length,
      },
      {
        id: "medium",
        label: "Medium",
        value: rows.filter((row) => row.priority === "medium").length,
      },
      {
        id: "watch",
        label: "Watch",
        value: rows.filter((row) => row.priority === "watch").length,
      },
    ],
  };
  const asOfMs = generatedAt ? Date.parse(generatedAt) : Number.NaN;
  if (!Number.isFinite(asOfMs)) {
    return {
      openByQueue,
      returnedByPriority,
      returnedAge: {
        scope: "returned-preview",
        status: "missing-reference-time",
        asOf: null,
        unknownTimestampCount: rows.length,
        points: [],
      },
    };
  }

  const ageCounts: Record<SafetyAgeAnalyticsId, number> = {
    under24h: 0,
    oneToThreeDays: 0,
    threeToSevenDays: 0,
    oneToFourWeeks: 0,
    fourWeeksPlus: 0,
  };
  let unknownTimestampCount = 0;
  rows.forEach((row) => {
    const createdAtMs = row.createdAt ? Date.parse(row.createdAt) : Number.NaN;
    if (!Number.isFinite(createdAtMs) || createdAtMs > asOfMs) {
      unknownTimestampCount += 1;
      return;
    }
    const ageHours = (asOfMs - createdAtMs) / 3_600_000;
    if (ageHours < 24) ageCounts.under24h += 1;
    else if (ageHours < 72) ageCounts.oneToThreeDays += 1;
    else if (ageHours < 168) ageCounts.threeToSevenDays += 1;
    else if (ageHours < 672) ageCounts.oneToFourWeeks += 1;
    else ageCounts.fourWeeksPlus += 1;
  });

  return {
    openByQueue,
    returnedByPriority,
    returnedAge: {
      scope: "returned-preview",
      status: "ready",
      asOf: new Date(asOfMs).toISOString(),
      unknownTimestampCount,
      points: [
        {id: "under24h", label: "< 24h", value: ageCounts.under24h},
        {id: "oneToThreeDays", label: "1–3d", value: ageCounts.oneToThreeDays},
        {id: "threeToSevenDays", label: "3–7d", value: ageCounts.threeToSevenDays},
        {id: "oneToFourWeeks", label: "1–4w", value: ageCounts.oneToFourWeeks},
        {id: "fourWeeksPlus", label: "4w+", value: ageCounts.fourWeeksPlus},
      ],
    },
  };
}

function metricValue(
  metrics: readonly AdminOverviewMetric[],
  id: string
): number {
  const value = metrics.find((metric) => metric.id === id)?.value ?? 0;
  return Number.isFinite(value) ? Math.max(0, Math.round(value)) : 0;
}
