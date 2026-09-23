import assert from "node:assert/strict";
import test from "node:test";
import {resolveArrivalTiming, type ArrivalTimingInput} from "./arrivalTiming";

const input: ArrivalTimingInput = {
  flight: {
    status: "landed",
    scheduledLandingAtMillis: 10_000,
    estimatedLandingAtMillis: 12_000,
    actualLandingAtMillis: 9_000,
  },
  exitLagMillis: 1_000,
  manualCurbAtMillis: null,
  readyAtMillis: null,
};

test("early actual landing supersedes schedule and obsolete delay", () => {
  assert.deepEqual(resolveArrivalTiming(input), {
    kind: "available", curbAtMillis: 10_000, source: "actualLanding",
  });
});

test("estimated then scheduled landing are explicit fallbacks", () => {
  assert.deepEqual(resolveArrivalTiming({...input, flight: {
    ...input.flight!, actualLandingAtMillis: null,
    estimatedLandingAtMillis: 8_000,
  }}), {kind: "available", curbAtMillis: 9_000, source: "estimatedLanding"});
  assert.deepEqual(resolveArrivalTiming({...input, flight: {
    ...input.flight!, actualLandingAtMillis: null,
    estimatedLandingAtMillis: null,
  }}), {kind: "available", curbAtMillis: 11_000, source: "scheduledLanding"});
});

test("cancelled and diverted observations do not imply a usable pickup", () => {
  for (const status of ["cancelled", "diverted"] as const) {
    assert.deepEqual(resolveArrivalTiming({...input, flight: {
      ...input.flight!, status,
    }}), {kind: "unavailable", reason: status});
  }
});

test("manual curb time takes priority without adding exit lag", () => {
  assert.deepEqual(resolveArrivalTiming({...input, manualCurbAtMillis: 15_000,
    flight: {...input.flight!, status: "cancelled"}}), {
    kind: "available", curbAtMillis: 15_000, source: "manual",
  });
});

test("observed ready time wins over both manual and flight estimates", () => {
  assert.deepEqual(resolveArrivalTiming({...input, readyAtMillis: 7_000,
    manualCurbAtMillis: 15_000}), {
    kind: "available", curbAtMillis: 7_000, source: "ready",
  });
});

test("ground arrivals work with manual timing and no flight", () => {
  assert.deepEqual(resolveArrivalTiming({...input, flight: null,
    manualCurbAtMillis: 12_000}), {
    kind: "available", curbAtMillis: 12_000, source: "manual",
  });
  assert.deepEqual(resolveArrivalTiming({...input, flight: null}), {
    kind: "unavailable", reason: "missingTiming",
  });
});

test("a flight with no times is explicitly unresolved", () => {
  assert.deepEqual(resolveArrivalTiming({...input, flight: {
    status: "scheduled", scheduledLandingAtMillis: null,
    estimatedLandingAtMillis: null, actualLandingAtMillis: null,
  }}), {kind: "unavailable", reason: "missingTiming"});
});

test("zero timestamps are not mistaken for missing values", () => {
  assert.deepEqual(resolveArrivalTiming({...input, readyAtMillis: 0}), {
    kind: "available", curbAtMillis: 0, source: "ready",
  });
});

test("invalid times, negative lag and overflowing derived times fail", () => {
  for (const invalid of [-1, NaN, Infinity, 0.5, Number.MAX_SAFE_INTEGER + 1]) {
    assert.throws(() => resolveArrivalTiming({...input,
      exitLagMillis: invalid}), RangeError);
    assert.throws(() => resolveArrivalTiming({...input,
      readyAtMillis: invalid}), RangeError);
    assert.throws(() => resolveArrivalTiming({...input,
      manualCurbAtMillis: invalid}), RangeError);
    assert.throws(() => resolveArrivalTiming({...input, flight: {
      ...input.flight!, estimatedLandingAtMillis: invalid,
    }}), RangeError);
  }
  assert.throws(() => resolveArrivalTiming({...input, flight: {
    ...input.flight!, actualLandingAtMillis: Number.MAX_SAFE_INTEGER,
  }}), RangeError);
});
