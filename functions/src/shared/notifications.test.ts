import assert from "node:assert/strict";
import test from "node:test";
import {
  activityNotificationId,
  allowsPushPreference,
} from "./notifications";

test("Cross Paths invitation push is explicit opt-in", () => {
  assert.equal(allowsPushPreference({}, "crossPathsInvitations"), false);
  assert.equal(allowsPushPreference({
    prefsCrossPathsInvitations: false,
  }, "crossPathsInvitations"), false);
  assert.equal(allowsPushPreference({
    prefsCrossPathsInvitations: true,
  }, "crossPathsInvitations"), true);
});

test("Cross Paths activity notification ids are deterministic", () => {
  assert.equal(
    activityNotificationId("crossPathsInvitation", "invitation-1"),
    "crossPathsInvitation_invitation-1"
  );
});
