import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {
  csvCell,
  decodeContactCursor,
  encodeContactCursor,
  listContactsMatchCountResult,
  resolveManualTags,
  summarizeContactRevenue,
} from "./organizerContacts";
import {
  OrganizerContactTagVocabularyDocument,
  PaymentDocument,
} from "../shared/generated/firestoreAdminTypes";

test("contact cursors round trip every query plan", () => {
  for (const cursor of [
    {
      plan: "people" as const,
      value: "1720000000000",
      contactId: "contact-1",
      segmentId: null,
      manualTagId: null,
    },
    {
      plan: "search" as const,
      value: "asha",
      contactId: "contact-2",
      segmentId: null,
      manualTagId: null,
    },
    {
      plan: "segment" as const,
      value: "contact-3",
      contactId: "contact-3",
      segmentId: "repeat_attendee",
      manualTagId: null,
    },
    {
      plan: "manualTag" as const,
      value: "contact-4",
      contactId: "contact-4",
      segmentId: null,
      manualTagId: "a".repeat(32),
    },
  ]) {
    assert.deepEqual(
      decodeContactCursor(encodeContactCursor(cursor)),
      cursor
    );
  }
});

test("manual tags reuse case-insensitive vocabulary entries", () => {
  const now = admin.firestore.Timestamp.fromMillis(1_000);
  const vocabulary: OrganizerContactTagVocabularyDocument = {
    organizerId: "organizer-1",
    tags: [{
      tagId: "a".repeat(32),
      label: "VIP",
      normalizedLabel: "vip",
      createdByUid: "manager-1",
      createdAt: now,
    }],
    updatedAt: now,
  };
  const resolved = resolveManualTags({
    organizerId: "organizer-1",
    labels: [" vip ", "Brings   friends"],
    vocabulary,
    actorUid: "manager-2",
    now,
  });

  assert.equal(resolved.vocabulary.tags.length, 2);
  assert.deepEqual(resolved.manualTags.map((tag) => tag.label), [
    "VIP",
    "Brings friends",
  ]);
  assert.equal(resolved.manualTags[0].tagId, "a".repeat(32));
});

test("manual tag caps fail with explicit organizer and contact errors", () => {
  const now = admin.firestore.Timestamp.fromMillis(1_000);
  assert.throws(
    () => resolveManualTags({
      organizerId: "organizer-1",
      labels: ["1", "2", "3", "4", "5", "6"],
      vocabulary: undefined,
      actorUid: "manager-1",
      now,
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument" &&
      error.message === "A contact can have at most 5 manual tags."
  );
  const vocabulary: OrganizerContactTagVocabularyDocument = {
    organizerId: "organizer-1",
    tags: Array.from({length: 20}, (_, index) => ({
      tagId: index.toString(16).padStart(32, "0"),
      label: `Tag ${index}`,
      normalizedLabel: `tag ${index}`,
      createdByUid: "manager-1",
      createdAt: now,
    })),
    updatedAt: now,
  };
  assert.throws(
    () => resolveManualTags({
      organizerId: "organizer-1",
      labels: ["New tag"],
      vocabulary,
      actorUid: "manager-1",
      now,
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition" &&
      error.message === "An organizer can have at most 20 manual tags."
  );
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

test("contact match counts never present a lower bound as exact", () => {
  assert.deepEqual(listContactsMatchCountResult(37, 8), {
    matchCount: 37,
    matchCountCoverage: "exact",
  });
  assert.deepEqual(listContactsMatchCountResult(null, 8), {
    matchCount: 8,
    matchCountCoverage: "atLeast",
  });
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
