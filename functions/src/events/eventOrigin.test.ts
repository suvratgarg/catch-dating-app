import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";
import {requireCatchBookingAuthority} from "./eventOrigin";

test("Catch booking requires explicit Catch authority", () => {
  assert.throws(
    () => requireCatchBookingAuthority({
      eventOrigin: {bookingAuthority: "external"},
    } as EventDocument),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition"
  );
  assert.doesNotThrow(() => requireCatchBookingAuthority({
    eventOrigin: {bookingAuthority: "catch"},
  } as EventDocument));
  assert.throws(
    () => requireCatchBookingAuthority({} as EventDocument),
    (error) => error instanceof HttpsError &&
      error.code === "failed-precondition"
  );
});
