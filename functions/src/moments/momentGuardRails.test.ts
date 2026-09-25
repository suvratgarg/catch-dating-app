import assert from "node:assert/strict";
import test from "node:test";
import {
  checkHouseholdDailyBudget,
  checkMomentLimit,
} from "./momentGuardRails";

test("moment limit blocks only at the cap", () => {
  assert.deepEqual(checkMomentLimit({
    armedMomentsForFunction: 2, maxPerFunction: 3,
  }), {allowed: true});
  assert.deepEqual(checkMomentLimit({
    armedMomentsForFunction: 3, maxPerFunction: 3,
  }), {allowed: false, reason: "momentLimitReached"});
  assert.deepEqual(checkMomentLimit({
    armedMomentsForFunction: 99, maxPerFunction: null,
  }), {allowed: true});
});

test("household daily budget blocks only at the cap", () => {
  assert.deepEqual(checkHouseholdDailyBudget({
    sentTodayForHousehold: 2, capPerDay: 3,
  }), {allowed: true});
  assert.deepEqual(checkHouseholdDailyBudget({
    sentTodayForHousehold: 3, capPerDay: 3,
  }), {allowed: false, reason: "householdDailyCapReached"});
});

test("invalid counts fail fast", () => {
  for (const bad of [-1, 0.5, NaN, Infinity]) {
    assert.throws(() => checkMomentLimit({
      armedMomentsForFunction: bad, maxPerFunction: 3,
    }), RangeError);
    assert.throws(() => checkMomentLimit({
      armedMomentsForFunction: 0, maxPerFunction: bad,
    }), RangeError);
    assert.throws(() => checkHouseholdDailyBudget({
      sentTodayForHousehold: bad, capPerDay: 3,
    }), RangeError);
    assert.throws(() => checkHouseholdDailyBudget({
      sentTodayForHousehold: 0, capPerDay: bad,
    }), RangeError);
  }
});
