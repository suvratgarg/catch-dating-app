import assert from "node:assert/strict";
import test from "node:test";
import {eventStaffDisplayName} from "./eventStaff";

test("uses the Auth display name without a Consumer profile", () => {
  assert.equal(eventStaffDisplayName({displayName: "  Casey  "}), "Casey");
});

test("has a safe label when the Auth account has no display name", () => {
  assert.equal(eventStaffDisplayName({displayName: undefined}), "Event staff");
});
