import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {
  csvCell,
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
