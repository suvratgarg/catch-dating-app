import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import type {EventDocument} from
  "../shared/generated/firestoreAdminTypes";
import {eventPlanChangeFields} from "./planChangeRecords";

const startTime = admin.firestore.Timestamp.fromMillis(1000);
const endTime = admin.firestore.Timestamp.fromMillis(2000);

function event(end?: FirebaseFirestore.Timestamp): EventDocument {
  return {
    name: "Club walk",
    startTime,
    ...(end ? {endTime: end} : {}),
  } as EventDocument;
}

test("adding or clearing an optional end time is a schedule change", () => {
  assert.deepEqual(eventPlanChangeFields(event(), event(endTime)),
    ["schedule"]);
  assert.deepEqual(eventPlanChangeFields(event(endTime), event()),
    ["schedule"]);
  assert.deepEqual(eventPlanChangeFields(event(), event()), []);
});
