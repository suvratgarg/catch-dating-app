import assert from "node:assert/strict";
import test from "node:test";
import {
  activityAttributesForProfile,
  assignmentConstraintsForStructureConfig,
  paceBandForRange,
  rotationPolicyForStructureConfig,
} from "./assignmentPrimitiveControls";

test("sanitizes saved rotation repeat policy controls", () => {
  assert.deepEqual(
    rotationPolicyForStructureConfig({
      rotationRepeatStrategy: "allowWhenExhausted",
      maxPairMeetings: 4.8,
    }),
    {
      repeatStrategy: "allowWhenExhausted",
      maxPairMeetings: 4,
    }
  );
  assert.deepEqual(
    rotationPolicyForStructureConfig({
      rotationRepeatStrategy: "unknown",
      maxPairMeetings: 0,
    }),
    {
      repeatStrategy: "avoid",
      maxPairMeetings: 1,
    }
  );
});

test("sanitizes saved activity assignment controls", () => {
  assert.deepEqual(
    assignmentConstraintsForStructureConfig({
      balanceActivityAttributes: [
        "skillBand",
        "bad",
        "paceBand",
        "skillBand",
      ],
      clusterActivityAttributes: ["paceBand", "roleBand", "roleBand"],
    }),
    {
      activity: {
        balanceAttributes: ["skillBand", "paceBand"],
        clusterAttributes: ["roleBand"],
      },
    }
  );
});

test("extracts pace bands only from real run preference signal", () => {
  assert.deepEqual(
    activityAttributesForProfile({
      activityPreferences: {
        running: {
          paceMinSecsPerKm: 300,
          paceMaxSecsPerKm: 420,
          preferredDistances: [],
          runningReasons: [],
          preferredRunTimes: [],
          version: 0,
        },
      },
    }),
    {}
  );
  assert.deepEqual(
    activityAttributesForProfile({
      activityPreferences: {
        running: {
          paceMinSecsPerKm: 420,
          paceMaxSecsPerKm: 480,
          preferredDistances: [],
          runningReasons: [],
          preferredRunTimes: [],
          version: 0,
        },
      },
    }),
    {paceBand: "easy"}
  );
});

test("buckets pace ranges for assignment clustering", () => {
  assert.equal(paceBandForRange(280, 300), "competitive");
  assert.equal(paceBandForRange(320, 360), "fast");
  assert.equal(paceBandForRange(390, 420), "moderate");
  assert.equal(paceBandForRange(450, 510), "easy");
  assert.equal(paceBandForRange(0, 420), undefined);
});
