import assert from "node:assert/strict";
import test from "node:test";

import {
  detectRosterAdapter,
  normalizeRosterMatrix,
  prepareCsvRosterImport,
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

test("prepares bounded normalized rows for the shared importer", () => {
  const prepared = prepareCsvRosterImport(
    "First Name,Last Name,Email,Order ID,Attendee ID,Ticket Type," +
      "Attendee Status\n" +
      "Asha,Shah,asha@example.com,order-1,attendee-1,General,Attending",
    "eventbrite"
  );
  assert.equal(prepared.adapter.adapterId, "eventbrite-v1");
  assert.deepEqual(prepared.rows[0], {
    rowId: "2",
    displayName: "Asha Shah",
    phone: null,
    email: "asha@example.com",
    externalReference: "attendee-1",
    arrivalGroup: "order-1",
    ticketType: "General",
    status: "registered",
  });
});

test(
  "keeps Eventbrite group-ticket guests distinct with one arrival group",
  () => {
    const prepared = prepareCsvRosterImport(
      "First Name,Last Name,Email,Order ID,Attendee ID,Ticket Type," +
      "Attendee Status\n" +
      "Asha,Shah,buyer@example.com,order-7,attendee-7a,General,Attending\n" +
      "Ravi,Rao,buyer@example.com,order-7,attendee-7b,General,Attending",
      "eventbrite"
    );

    assert.deepEqual(prepared.rows, [
      {
        rowId: "2",
        displayName: "Asha Shah",
        phone: null,
        email: "buyer@example.com",
        externalReference: "attendee-7a",
        arrivalGroup: "order-7",
        ticketType: "General",
        status: "registered",
      },
      {
        rowId: "3",
        displayName: "Ravi Rao",
        phone: null,
        email: "buyer@example.com",
        externalReference: "attendee-7b",
        arrivalGroup: "order-7",
        ticketType: "General",
        status: "registered",
      },
    ]);
  }
);
