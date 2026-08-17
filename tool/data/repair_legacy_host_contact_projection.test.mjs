import assert from "node:assert/strict";
import {test} from "node:test";
import {assertExpectedPlan} from
  "./repair_legacy_host_contact_projection.mjs";

test("repair count gate accepts one exact organizer plan", () => {
  assert.doesNotThrow(() => assertExpectedPlan({
    highConfidenceCount: 3,
    humanReconciliationCount: 0,
    organizers: [{organizerId: "courtside"}],
    entries: Array.from({length: 3}, () => ({
      classification: "highConfidencePrivateProjection",
    })),
  }, {
    organizerId: "courtside",
    expectedHighConfidence: "3",
    expectedHumanReconciliation: "0",
  }));
});

test("repair count gate fails closed on drift or reconciliation rows", () => {
  assert.throws(() => assertExpectedPlan({
    highConfidenceCount: 2,
    humanReconciliationCount: 1,
    organizers: [{organizerId: "courtside"}],
    entries: [{classification: "humanReconciliationRequired"}],
  }, {
    organizerId: "courtside",
    expectedHighConfidence: "3",
    expectedHumanReconciliation: "0",
  }), /Repair plan changed/u);
});
