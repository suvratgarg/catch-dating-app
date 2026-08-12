import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {
  decodeContactCursor,
  encodeContactCursor,
} from "./organizerContacts";

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
