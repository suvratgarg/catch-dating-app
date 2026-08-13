import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {
  csvCell,
  decodeContactCursor,
  encodeContactCursor,
  summarizeContactRevenue,
} from "./organizerContacts";
import {PaymentDocument} from "../shared/generated/firestoreAdminTypes";

test("contact cursors round trip every query plan", () => {
  for (const cursor of [
    {
      plan: "people" as const,
      value: "1720000000000",
      contactId: "contact-1",
      segmentId: null,
    },
    {
      plan: "search" as const,
      value: "asha",
      contactId: "contact-2",
      segmentId: null,
    },
    {
      plan: "segment" as const,
      value: "contact-3",
      contactId: "contact-3",
      segmentId: "repeat_attendee",
    },
  ]) {
    assert.deepEqual(
      decodeContactCursor(encodeContactCursor(cursor)),
      cursor
    );
  }
});

test("CRM CSV cells neutralize spreadsheet formulas and quote safely", () => {
  assert.equal(csvCell("=HYPERLINK(\"https://bad\")"),
    "\"'=HYPERLINK(\"\"https://bad\"\")\"");
  assert.equal(csvCell("Asha, Rao"), "\"Asha, Rao\"");
  assert.equal(csvCell("ordinary"), "ordinary");
});

test("contact cursor rejects malformed and unrecognized values", () => {
  assert.throws(
    () => decodeContactCursor("not-a-cursor"),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument"
  );
  const unsupported = Buffer.from(JSON.stringify({
    plan: "all",
    value: "x",
    contactId: "contact-1",
    segmentId: null,
  })).toString("base64url");
  assert.throws(() => decodeContactCursor(unsupported));
});

test("customer revenue includes completed organizer payments only", () => {
  const timestamp = {toMillis: () => 1700000000000} as
    FirebaseFirestore.Timestamp;
  const payment = (
    eventId: string,
    status: PaymentDocument["status"],
    amountMinor: number
  ): PaymentDocument => ({
    userId: "user-1",
    orderId: `${eventId}-${status}`,
    paymentId: `${eventId}-${status}`,
    eventId,
    amount: amountMinor,
    amountMinor,
    currency: "INR",
    status,
    signUpFailed: false,
    createdAt: timestamp,
  });
  const revenue = summarizeContactRevenue([
    payment("event-1", "completed", 25000),
    payment("event-1", "refunded", 25000),
    payment("other-event", "completed", 90000),
  ], new Set(["event-1"]), "exact");

  assert.deepEqual(revenue, {
    coverage: "exact",
    amounts: [{currency: "INR", amountMinor: 25000, paidOrderCount: 1}],
  });
});
