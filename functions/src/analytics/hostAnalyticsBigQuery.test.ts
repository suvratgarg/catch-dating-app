import assert from "node:assert/strict";
import test from "node:test";
import {BigQueryHostAnalyticsSource, hostAnalyticsRowsSql} from
  "./hostAnalyticsBigQuery";
import {buildHostAnalyticsFromRecords, resolveAnalyticsRange} from
  "./hostAnalytics";
import type {BigQueryClient} from "../shared/bigQuery";

const range = {startDate: "2026-06-01", endDate: "2026-06-30"};
const scope = {clubIds: ["org"], eventId: null};
function clientFor(rows: Array<Record<string, unknown>>): BigQueryClient {
  return {
    async query<T>() {
      return rows as T[];
    },
    async insertRows() {},
  };
}

test("optional booking clicks remain unknown " +
  "for absent/null warehouse data", async () => {
  for (const value of [null, undefined]) {
    const source = new BigQueryHostAnalyticsSource(clientFor([{
      date: "2026-06-18", clubId: "org", eventId: null,
      outboundBookingClicks: value, bookedCount: null, listingViews: "12",
    }]), "project.dataset.mart");
    const rows = await source.loadRows(range, scope);
    assert.equal(rows[0].outboundBookingClicks, undefined);
    assert.equal(rows[0].bookedCount, 0);
    assert.equal(rows[0].listingViews, 12);
    const now = new Date("2026-06-18T12:00:00Z");
    const report = buildHostAnalyticsFromRecords(
      {clubs: [], events: [], martRows: rows},
      resolveAnalyticsRange({rangePreset: "30d"}, now), now);
    assert.equal(report.summaryCards.find((card) =>
      card.id === "outboundBookingClicks")?.status, "missing");
  }
});

test("known booking-click zero and positive " +
  "values remain measured", async () => {
  const source = new BigQueryHostAnalyticsSource(clientFor([
    {outboundBookingClicks: 0}, {outboundBookingClicks: "17"},
  ]), "project.dataset.mart");
  const rows = await source.loadRows(range, scope);
  assert.equal(rows[0].outboundBookingClicks, 0);
  assert.equal(rows[1].outboundBookingClicks, 17);
});

test("optional-column SQL serializes the row " +
  "and preserves unknown grouped values", () => {
  const sql = hostAnalyticsRowsSql("project.dataset.mart");
  const extraction = "SAFE_CAST(JSON_VALUE(TO_JSON_STRING(martRow), " +
    "'$.outbound_booking_clicks') AS INT64)";
  assert.ok(sql.includes("FROM `project.dataset.mart` AS martRow"));
  assert.ok(sql.includes(`CASE WHEN COUNT(*) = COUNT(${extraction})`));
  assert.ok(sql.includes(`THEN SUM(${extraction})`));
  assert.ok(sql.includes("ELSE NULL END AS outboundBookingClicks"));
  assert.doesNotMatch(sql, /SUM\(outbound_booking_clicks\)/);
  assert.ok(sql.includes("SUM(booked_count) AS bookedCount"));
  assert.ok(sql.includes("club_id IN UNNEST(@clubIds)"));
});
