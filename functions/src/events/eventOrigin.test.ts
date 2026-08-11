import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {EventDocument} from "../shared/generated/firestoreAdminTypes";
import {requireCatchBookingAuthority} from "./eventOrigin";

test("Catch booking fails closed for external companion events", () => {
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
  assert.doesNotThrow(() => requireCatchBookingAuthority({} as EventDocument));
});
