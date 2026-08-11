import assert from "node:assert/strict";
import test from "node:test";

import {
  detectRosterAdapter,
  normalizeRosterMatrix,
} from "./rosterAdapters";

test("detects a Luma guest export", () => {
  const result = detectRosterAdapter([
    "Name",
    "Approval Status",
    "Registration Date",
    "Ticket Type",
    "Guest Key",
  ]);
  assert.equal(result.adapterId, "luma-v1");
  assert.equal(result.support, "verified");
});

test("normalizes Eventbrite first and last names", () => {
  const detection = detectRosterAdapter([
    "First Name",
    "Last Name",
    "Order ID",
    "Ticket Type",
    "Attendee Status",
  ]);
  const matrix = normalizeRosterMatrix({
    headers: ["First Name", "Last Name"],
    rows: [["Asha", "Shah"]],
  }, detection);
  assert.equal(matrix.headers.at(-1), "Guest name");
  assert.equal(matrix.rows[0]?.at(-1), "Asha Shah");
});

test("flags providers without reviewed export samples", () => {
  const result = detectRosterAdapter(["Customer Name"], "bookmyshow");
  assert.deepEqual(result, {
    adapterId: "sample-required",
    support: "sampleRequired",
    confidence: 1,
  });
});
