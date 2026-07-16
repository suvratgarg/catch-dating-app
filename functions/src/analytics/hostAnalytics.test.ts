import assert from "node:assert/strict";
import test from "node:test";
import {
  buildHostAnalyticsFromRecords,
  hostAnalyticsSnapshotId,
  hostAnalyticsSnapshotTtlMs,
  isHostAnalyticsSnapshotFresh,
  readHostAnalyticsSnapshot,
  resolveAnalyticsRange,
  writeHostAnalyticsSnapshot,
} from "./hostAnalytics";

type AnalyticsRecords = Parameters<typeof buildHostAnalyticsFromRecords>[0];

test("resolveAnalyticsRange supports custom weekly ranges", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "custom",
    startDate: "2026-06-01",
    endDate: "2026-06-30",
    granularity: "week",
  }, new Date("2026-06-18T12:00:00.000Z"));

  assert.equal(range.start.toISOString(), "2026-06-01T00:00:00.000Z");
  assert.equal(range.endExclusive.toISOString(), "2026-07-01T00:00:00.000Z");
  assert.equal(range.granularity, "week");
  assert.equal(range.preset, "custom");
  assert.equal(range.timezone, "UTC");
});

test("resolveAnalyticsRange uses IANA-zone midnight and supports 12m", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "12m",
    granularity: "month",
    timezone: "Asia/Kolkata",
  }, new Date("2026-06-17T20:00:00.000Z"));

  assert.equal(range.start.toISOString(), "2025-06-18T18:30:00.000Z");
  assert.equal(range.endExclusive.toISOString(), "2026-06-18T18:30:00.000Z");
  assert.equal(range.granularity, "month");
  assert.equal(range.timezone, "Asia/Kolkata");
});

test("resolveAnalyticsRange keeps 01:00 IST in the new local day", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "30d",
    timezone: "Asia/Kolkata",
  }, new Date("2026-06-17T19:30:00.000Z"));

  assert.equal(range.start.toISOString(), "2026-05-19T18:30:00.000Z");
  assert.equal(range.endExclusive.toISOString(), "2026-06-18T18:30:00.000Z");
});

test("mart dates use local-day buckets", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "custom",
    startDate: "2026-06-18",
    endDate: "2026-06-18",
    granularity: "day",
    timezone: "Asia/Kolkata",
  }, new Date("2026-06-18T12:00:00.000Z"));
  const input = records();
  input.martRows = [martRow({
    date: "2026-06-18",
    bookedCount: 5,
    checkedInCount: 4,
  })];

  const response = buildHostAnalyticsFromRecords(
    input,
    range,
    new Date("2026-06-18T12:00:00.000Z")
  );

  assert.equal(response.trend[0].periodStart, "2026-06-17T18:30:00.000Z");
  assert.equal(response.trend[0].periodEnd, "2026-06-18T18:29:59.999Z");
  assert.equal(response.trend[0].metrics.bookings, 5);
});

test("host snapshot identity pins authorized scope and local-day range", () => {
  const now = new Date("2026-06-17T20:00:00.000Z");
  const payload = {
    clubId: "club-1",
    rangePreset: "30d" as const,
    granularity: "week" as const,
    timezone: "Asia/Kolkata",
  };
  const range = resolveAnalyticsRange(payload, now);
  const clubs = records().clubs;
  const first = hostAnalyticsSnapshotId("host-1", payload, range, clubs);
  const reordered = hostAnalyticsSnapshotId(
    "host-1",
    payload,
    range,
    [...clubs].reverse()
  );
  const utc = hostAnalyticsSnapshotId(
    "host-1",
    {...payload, timezone: "UTC"},
    resolveAnalyticsRange({...payload, timezone: "UTC"}, now),
    clubs
  );

  assert.match(first, /^host-1_[a-f0-9]{64}$/u);
  assert.equal(reordered, first);
  assert.notEqual(utc, first);
});

test("host snapshot freshness uses the ratified 15-minute TTL boundary", () => {
  const now = new Date("2026-06-18T12:00:00.000Z");
  assert.equal(hostAnalyticsSnapshotTtlMs, 15 * 60 * 1000);
  assert.equal(isHostAnalyticsSnapshotFresh({
    toMillis: () => now.getTime() + hostAnalyticsSnapshotTtlMs,
  }, now), true);
  assert.equal(isHostAnalyticsSnapshotFresh({
    toMillis: () => now.getTime(),
  }, now), false);
  assert.equal(isHostAnalyticsSnapshotFresh(undefined, now), false);
});

test("host snapshot store serves valid data until expiry", async () => {
  const now = new Date("2026-06-18T12:00:00.000Z");
  const range = resolveAnalyticsRange({rangePreset: "30d"}, now);
  const response = buildHostAnalyticsFromRecords(records(), range, now);
  const firestore = new FakeSnapshotFirestore();
  const db = firestore as unknown as FirebaseFirestore.Firestore;
  const snapshotId = `host-1_${"a".repeat(64)}`;

  await writeHostAnalyticsSnapshot(
    db,
    snapshotId,
    "host-1",
    response,
    now,
    {
      serverTimestamp: () => fakeTimestamp(now),
      timestampFromDate: (date) => fakeTimestamp(date),
    }
  );

  assert.deepEqual(
    await readHostAnalyticsSnapshot(
      db,
      snapshotId,
      new Date(now.getTime() + 60_000)
    ),
    response
  );
  assert.equal(
    await readHostAnalyticsSnapshot(
      db,
      snapshotId,
      new Date(now.getTime() + hostAnalyticsSnapshotTtlMs)
    ),
    null
  );
});

test("host snapshot store rejects malformed cached responses", async () => {
  const now = new Date("2026-06-18T12:00:00.000Z");
  const firestore = new FakeSnapshotFirestore();
  const snapshotId = `host-1_${"b".repeat(64)}`;
  firestore.documents.set(snapshotId, {
    expiresAt: fakeTimestamp(
      new Date(now.getTime() + hostAnalyticsSnapshotTtlMs)
    ),
    response: {},
  });

  assert.equal(
    await readHostAnalyticsSnapshot(
      firestore as unknown as FirebaseFirestore.Firestore,
      snapshotId,
      now
    ),
    null
  );
});

test("buildHostAnalyticsFromRecords aggregates host-safe metrics", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "custom",
    startDate: "2026-06-01",
    endDate: "2026-06-30",
    granularity: "week",
  }, new Date("2026-06-18T12:00:00.000Z"));

  const input = records();
  input.martRows.push(martRow({
    date: "2026-05-20",
    bookedCount: 4,
    checkedInCount: 2,
    checkoutStartedCount: 5,
    paymentCompletedCount: 4,
    grossRevenueMinor: 200000,
    reviewCount: 2,
    ratingTotal: 8,
    listingViews: 5,
    eventViews: 4,
    mutualMatchCount: 1,
    chatStartedCount: 1,
  }));
  const response = buildHostAnalyticsFromRecords(input, range, new Date(
    "2026-06-18T12:00:00.000Z"
  ));

  assert.equal(response.scope.clubName, "Saket Run Club");
  assert.deepEqual(response.scope.clubIds, ["club-1"]);
  assert.deepEqual(response.scope.eventIds, ["event-1"]);
  assert.equal(metric(response, "listingViews").value, 12);
  assert.equal(metric(response, "eventViews").value, 9);
  assert.equal(metric(response, "bookings").value, 8);
  assert.equal(metric(response, "attendanceRate").value, 75);
  assert.equal(metric(response, "revenue").value, 400000);
  assert.equal(metric(response, "checkoutDropoff").value, 2);
  assert.equal(metric(response, "checkoutConversionRate").value, 66.67);
  assert.equal(metric(response, "connections").value, 3);
  assert.equal(metric(response, "chats").value, 2);
  assert.equal(metric(response, "bookings").previousValue, 4);
  assert.equal(metric(response, "attendanceRate").previousValue, 50);
  assert.equal(metric(response, "listingViews").previousValue, 5);
  assert.equal(metric(response, "revenue").previousValue, 200000);
  assert.equal(response.discoverySummary.organizerSaves, 4);
  assert.equal(response.discoverySummary.eventSaves, 7);
  assert.equal(response.reviewSummary.newReviews, 1);
  assert.equal(response.reviewSummary.ownerResponseCount, 1);

  assert.equal(response.topEvents.length, 1);
  assert.equal(response.topEvents[0].bookedCount, 8);
  assert.equal(response.topEvents[0].checkedInCount, 6);
  assert.equal(response.topEvents[0].fillRate, 80);
  assert.equal(response.topEvents[0].checkInRate, 75);
  assert.equal(response.topEvents[0].checkoutStartedCount, 3);
  assert.equal(response.topEvents[0].checkoutDropoffCount, 2);
  assert.equal(response.topEvents[0].paymentFailedCount, 1);
  assert.equal(response.topEvents[0].inviteOpenCount, 11);
  assert.equal(response.topEvents[0].mutualMatchCount, 3);
  assert.equal(response.topEvents[0].chatStartedCount, 2);
  assert.equal(response.dataQuality.find((row) =>
    row.id === "firestore-cache"
  )?.state, "ok");

  const eventBucket = response.trend.find((point) =>
    point.periodStart === "2026-06-08T00:00:00.000Z"
  );
  assert.ok(eventBucket);
  assert.equal(eventBucket.metrics.bookings, 8);
  assert.equal(eventBucket.metrics.checkedIn, 6);
  assert.equal(eventBucket.metrics.revenueMinor, 400000);
  assert.equal(eventBucket.metrics.checkoutStarted, 3);
  assert.equal(eventBucket.metrics.checkoutDropoff, 2);
  assert.equal(eventBucket.metrics.reviews, 1);
});

test("buildHostAnalyticsFromRecords totals beyond the top event slice", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "custom",
    startDate: "2026-06-01",
    endDate: "2026-06-30",
    granularity: "month",
  }, new Date("2026-06-18T12:00:00.000Z"));
  const events = Array.from({length: 30}, (_, index) => {
    const day = String(index + 1).padStart(2, "0");
    const id = `event-${index + 1}`;
    return {
      id,
      data: {
        clubId: "club-1",
        status: "completed",
        startTime: `2026-06-${day}T01:30:00.000Z`,
        capacityLimit: 10,
        bookedCount: 1,
        checkedInCount: 1,
        waitlistedCount: 0,
        currency: "INR",
        eventFormat: {
          activityKind: "socialRun",
          customActivityLabel: "Social run",
        },
      },
    };
  });
  const eventRows = events.map((event) => martRow({
    date: event.data.startTime.slice(0, 10),
    eventId: event.id,
    eventTitle: `Social run · ${event.data.startTime.slice(0, 10)}`,
    eventStartTime: event.data.startTime,
    bookedCount: 1,
    checkedInCount: 1,
    checkoutStartedCount: 1,
    paymentCompletedCount: 1,
    grossRevenueMinor: 1000,
    mutualMatchCount: 1,
    chatStartedCount: 1,
  }));
  const clubReviewRow = martRow({
    date: "2026-06-15",
    eventId: null,
    eventTitle: null,
    eventStartTime: null,
    eventStatus: null,
    reviewCount: 2,
    ratingTotal: 8,
    verifiedReviewCount: 1,
    publicReviewCount: 2,
    ownerResponseCount: 1,
  });

  const response = buildHostAnalyticsFromRecords({
    clubs: [{
      id: "club-1",
      data: {name: "Saket Run Club"},
    }],
    events,
    martRows: [...eventRows, clubReviewRow],
  } as unknown as AnalyticsRecords, range, new Date(
    "2026-06-18T12:00:00.000Z"
  ));

  assert.equal(response.topEvents.length, 25);
  assert.equal(metric(response, "bookings").value, 30);
  assert.equal(metric(response, "revenue").value, 30000);
  assert.equal(metric(response, "checkoutConversionRate").value, 100);
  assert.equal(metric(response, "connections").value, 30);
  assert.equal(metric(response, "chats").value, 30);
  assert.equal(metric(response, "newReviews").value, 2);
  assert.equal(response.reviewSummary.newReviews, 2);
  assert.equal(response.reviewSummary.averageRating, 4);
  assert.equal(response.reviewSummary.ownerResponseCount, 1);
});

test("mixed currencies never produce a combined revenue value or delta", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "custom",
    startDate: "2026-06-01",
    endDate: "2026-06-30",
  }, new Date("2026-06-18T12:00:00.000Z"));
  const input = records();
  input.martRows.push(martRow({
    eventId: "event-2",
    currency: "USD",
    grossRevenueMinor: 5000,
  }));

  const response = buildHostAnalyticsFromRecords(
    input,
    range,
    new Date("2026-06-18T12:00:00.000Z")
  );
  const revenue = metric(response, "revenue");

  assert.equal(revenue.value, 0);
  assert.equal(revenue.previousValue, null);
  assert.equal(revenue.status, "partial");
});

function metric(
  response: ReturnType<typeof buildHostAnalyticsFromRecords>,
  id: string
) {
  const item = response.summaryCards.find((card) => card.id === id);
  assert.ok(item, `Missing metric ${id}`);
  return item;
}

function records(): AnalyticsRecords {
  return {
    clubs: [{
      id: "club-1",
      data: {
        name: "Saket Run Club",
      },
    }],
    events: [{
      id: "event-1",
      data: {
        clubId: "club-1",
        status: "completed",
        startTime: "2026-06-12T01:30:00.000Z",
        capacityLimit: 10,
        bookedCount: 5,
        checkedInCount: 4,
        waitlistedCount: 2,
        currency: "INR",
        eventFormat: {
          activityKind: "socialRun",
          customActivityLabel: "Social run",
        },
      },
    }],
    martRows: [{
      date: "2026-06-12",
      clubId: "club-1",
      clubName: "Saket Run Club",
      eventId: "event-1",
      eventTitle: "Social run · 2026-06-12",
      eventStartTime: "2026-06-12T01:30:00.000Z",
      eventStatus: "completed",
      capacityLimit: 10,
      bookedCount: 8,
      checkedInCount: 6,
      waitlistedCount: 2,
      grossRevenueMinor: 400000,
      currency: "INR",
      checkoutStartedCount: 3,
      checkoutDropoffCount: 2,
      paymentCompletedCount: 2,
      paymentFailedCount: 1,
      paymentRefundedCount: 0,
      reviewCount: 1,
      ratingTotal: 5,
      verifiedReviewCount: 1,
      publicReviewCount: 1,
      ownerResponseCount: 1,
      demandCount: 13,
      inviteOpenCount: 11,
      mutualMatchCount: 3,
      chatStartedCount: 2,
      repeatAttendeeCount: 2,
      listingViews: 12,
      searchAppearances: 18,
      eventViews: 9,
      organizerSaves: 4,
      eventSaves: 7,
      contactClicks: 2,
      claimClicks: 1,
      outboundClicks: 3,
    }],
  } as unknown as AnalyticsRecords;
}

class FakeSnapshotFirestore {
  readonly documents = new Map<string, Record<string, unknown>>();

  collection(name: string) {
    assert.equal(name, "hostAnalyticsSnapshots");
    return {
      doc: (id: string) => ({
        get: async () => {
          const value = this.documents.get(id);
          return {
            exists: value !== undefined,
            data: () => value,
          };
        },
        set: async (value: Record<string, unknown>) => {
          this.documents.set(id, value);
        },
      }),
    };
  }
}

function fakeTimestamp(date: Date): FirebaseFirestore.Timestamp {
  return {
    toMillis: () => date.getTime(),
    _seconds: Math.floor(date.getTime() / 1000),
    _nanoseconds: 0,
  } as unknown as FirebaseFirestore.Timestamp;
}

function martRow(overrides: Record<string, unknown> = {}) {
  return {
    date: "2026-06-12",
    clubId: "club-1",
    clubName: "Saket Run Club",
    eventId: "event-1",
    eventTitle: "Social run · 2026-06-12",
    eventStartTime: "2026-06-12T01:30:00.000Z",
    eventStatus: "completed",
    capacityLimit: 10,
    bookedCount: 0,
    checkedInCount: 0,
    waitlistedCount: 0,
    grossRevenueMinor: 0,
    currency: "INR",
    checkoutStartedCount: 0,
    checkoutDropoffCount: 0,
    paymentCompletedCount: 0,
    paymentFailedCount: 0,
    paymentRefundedCount: 0,
    reviewCount: 0,
    ratingTotal: 0,
    verifiedReviewCount: 0,
    publicReviewCount: 0,
    ownerResponseCount: 0,
    demandCount: 0,
    inviteOpenCount: 0,
    mutualMatchCount: 0,
    chatStartedCount: 0,
    repeatAttendeeCount: 0,
    listingViews: 0,
    searchAppearances: 0,
    eventViews: 0,
    organizerSaves: 0,
    eventSaves: 0,
    contactClicks: 0,
    claimClicks: 0,
    outboundClicks: 0,
    ...overrides,
  };
}
