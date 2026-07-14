import {describe, expect, it} from "vitest";

import {buildSafetyTriageAnalytics} from "./safetyTriageAnalytics";

const metrics = [
  {id: "openReports", label: "Open reports", value: 14},
  {id: "pendingModerationFlags", label: "Moderation", value: 9},
  {id: "eventSafetyReports", label: "Event reports", value: 3},
];

describe("buildSafetyTriageAnalytics", () => {
  it("keeps aggregate queue totals separate from the returned preview", () => {
    const analytics = buildSafetyTriageAnalytics({
      generatedAt: "2026-07-13T12:00:00.000Z",
      metrics,
      rows: [
        {createdAt: "2026-07-13T11:00:00.000Z", priority: "high", queueKind: "reports"},
        {createdAt: "2026-07-13T10:00:00.000Z", priority: "watch", queueKind: "event"},
      ],
    });

    expect(analytics.openByQueue).toMatchObject({scope: "all-open-aggregate"});
    expect(analytics.openByQueue.points.map((point) => point.value))
      .toEqual([14, 9, 3]);
    expect(analytics.returnedByPriority).toMatchObject({
      returnedRowCount: 2,
      scope: "returned-preview",
    });
  });

  it("uses exact age boundaries and treats invalid or future dates as unknown", () => {
    const analytics = buildSafetyTriageAnalytics({
      generatedAt: "2026-07-13T12:00:00.000Z",
      metrics,
      rows: [
        {createdAt: "2026-07-13T00:00:00.000Z", priority: "watch", queueKind: "reports"},
        {createdAt: "2026-07-12T12:00:00.000Z", priority: "watch", queueKind: "reports"},
        {createdAt: "2026-07-10T12:00:00.000Z", priority: "medium", queueKind: "moderation"},
        {createdAt: "2026-07-06T12:00:00.000Z", priority: "medium", queueKind: "moderation"},
        {createdAt: "2026-06-15T12:00:00.000Z", priority: "high", queueKind: "event"},
        {createdAt: null, priority: "watch", queueKind: "reports"},
        {createdAt: "not-a-date", priority: "watch", queueKind: "reports"},
        {createdAt: "2026-07-13T13:00:00.000Z", priority: "high", queueKind: "event"},
      ],
    });

    expect(analytics.returnedAge.status).toBe("ready");
    expect(analytics.returnedAge.points.map((point) => point.value))
      .toEqual([1, 1, 1, 1, 1]);
    expect(analytics.returnedAge.unknownTimestampCount).toBe(3);
  });

  it("fails age analysis closed when the snapshot time is missing", () => {
    const analytics = buildSafetyTriageAnalytics({
      generatedAt: "invalid",
      metrics,
      rows: [
        {createdAt: "2026-07-13T10:00:00.000Z", priority: "high", queueKind: "reports"},
      ],
    });

    expect(analytics.returnedAge).toEqual({
      scope: "returned-preview",
      status: "missing-reference-time",
      asOf: null,
      unknownTimestampCount: 1,
      points: [],
    });
  });
});
