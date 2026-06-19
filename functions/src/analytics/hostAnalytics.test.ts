import assert from "node:assert/strict";
import test from "node:test";
import {
  buildHostAnalyticsFromRecords,
  resolveAnalyticsRange,
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
});

test("buildHostAnalyticsFromRecords aggregates host-safe metrics", () => {
  const range = resolveAnalyticsRange({
    rangePreset: "custom",
    startDate: "2026-06-01",
    endDate: "2026-06-30",
    granularity: "week",
  }, new Date("2026-06-18T12:00:00.000Z"));

  const response = buildHostAnalyticsFromRecords(records(), range, new Date(
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
