import assert from "node:assert/strict";
import test from "node:test";
import {eligibleHomeCatchEvents} from "../src/features/organizers/homeEventEligibility.ts";

const market = {
  cities: [
    {id: "in-mumbai", label: "Mumbai", aliases: [], status: "live"},
    {id: "in-delhi", label: "Delhi", aliases: ["Delhi NCR", "New Delhi"], status: "live"},
    {id: "in-bangalore", label: "Bangalore", aliases: ["Bengaluru"], status: "live"},
    {id: "in-jaipur", label: "Jaipur", aliases: [], status: "waitlist"},
  ],
};

test("home eligibility keeps only future Catch events in configured live cities", () => {
  const result = eligibleHomeCatchEvents([
    listing("delhi", "Delhi NCR", [
      event("future-delhi", "2026-07-13T12:00:00.000Z"),
      event("past-delhi", "2026-07-11T12:00:00.000Z"),
    ]),
    listing("bangalore", "Bengaluru", [
      event("future-bangalore", "2026-07-13T10:00:00.000Z"),
    ]),
    listing("new-york", "New York", [
      event("future-new-york", "2026-07-13T09:00:00.000Z"),
    ]),
    listing("jaipur", "Jaipur", [
      event("future-waitlist-city", "2026-07-13T08:00:00.000Z"),
    ]),
  ], {
    ...market,
    now: Date.parse("2026-07-12T00:00:00.000Z"),
  });

  assert.deepEqual(
    result.map(({event: candidate}) => candidate.id),
    ["future-bangalore", "future-delhi"]
  );
});

test("home eligibility rejects invalid and exactly-now event times", () => {
  const now = Date.parse("2026-07-12T00:00:00.000Z");
  const result = eligibleHomeCatchEvents([
    listing("mumbai", "Mumbai", [
      event("invalid", "not-a-date"),
      event("now", "2026-07-12T00:00:00.000Z"),
    ]),
  ], {...market, now});

  assert.deepEqual(result, []);
});

function listing(id, city, catchEvents) {
  return {id, city, catchEvents, externalEvents: [event("external", "2099-01-01T00:00:00Z")]};
}

function event(id, startTime) {
  return {id, startTime};
}
