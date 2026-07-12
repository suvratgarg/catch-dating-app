import assert from "node:assert/strict";
import test from "node:test";
import {notificationCopy} from "./notificationCopy";

test("notificationCopy resolves named placeholders", () => {
  assert.deepEqual(
    notificationCopy("eventSignup", {
      eventLabel: "5 km event",
      locationName: "Cubbon Park",
    }),
    {
      title: "You're booked",
      body: "Your 5 km event from Cubbon Park is confirmed.",
    }
  );
});

test("notificationCopy fails closed for missing placeholders", () => {
  assert.throws(
    () => notificationCopy("eventSignup", {eventLabel: "5 km event"}),
    /locationName/
  );
});
