import assert from "node:assert/strict";
import test from "node:test";
import {
  participationStatus,
  projectedParticipationStatus,
} from "./eventAttendeeProjection";

test("participationStatus preserves the operational roster lifecycle", () => {
  assert.equal(participationStatus("signedUp"), "registered");
  assert.equal(participationStatus("waitlisted"), "waitlisted");
  assert.equal(participationStatus("attended"), "checkedIn");
  assert.equal(participationStatus("cancelled"), "cancelled");
  assert.equal(participationStatus("deleted"), "cancelled");
  assert.equal(participationStatus(undefined), "cancelled");
});

test("Consumer projection does not undo a Host check-in", () => {
  assert.equal(
    projectedParticipationStatus("registered", "checkedIn"),
    "checkedIn"
  );
  assert.equal(
    projectedParticipationStatus("cancelled", "checkedIn"),
    "cancelled"
  );
});
