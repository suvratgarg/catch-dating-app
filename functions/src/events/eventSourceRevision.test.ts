import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {eventSourceRevision} from "./eventSourceRevision";

const snapshot = (updateTime?: Timestamp) => ({updateTime}) as
  Pick<FirebaseFirestore.DocumentSnapshot, "updateTime">;

test("legacy event uses lossless Firestore update microseconds", () => {
  assert.equal(eventSourceRevision({}, snapshot(new Timestamp(
    1_800_000_000, 123_456_000))), 1_800_000_000_123_456);
  assert.equal(eventSourceRevision({setupRevision: 7}, snapshot()), 7);
});

test("missing, malformed and unsafe metadata fail closed", () => {
  assert.equal(eventSourceRevision({}, snapshot()), null);
  assert.equal(eventSourceRevision({setupRevision: 0}, snapshot(
    new Timestamp(1_800_000_000, 0))), null);
  assert.equal(eventSourceRevision({setupRevision: "7"}, snapshot(
    new Timestamp(1_800_000_000, 0))), null);
  assert.equal(eventSourceRevision({}, snapshot(new Timestamp(
    1_800_000_000, 123_456_789))), null);
  assert.equal(eventSourceRevision({}, snapshot(new Timestamp(
    9_007_199_255, 0))), null);
});
