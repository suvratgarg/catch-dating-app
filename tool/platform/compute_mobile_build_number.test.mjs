import assert from "node:assert/strict";
import test from "node:test";
import {computeMobileBuildNumber} from "./compute_mobile_build_number.mjs";

test("iOS build numbers are 18-digit, monotonic, and above the legacy date namespace", () => {
  const first = computeMobileBuildNumber({platform: "ios", utcDate: "20260711", runNumber: 26, runAttempt: 1});
  const retry = computeMobileBuildNumber({platform: "ios", utcDate: "20260711", runNumber: 26, runAttempt: 2});
  const next = computeMobileBuildNumber({platform: "ios", utcDate: "20260711", runNumber: 27, runAttempt: 1});
  assert.equal(first, "202607110000002601");
  assert.equal(first.length, 18);
  assert.ok(BigInt(first) > 20_260_711_026n);
  assert.ok(BigInt(first) < BigInt(retry));
  assert.ok(BigInt(retry) < BigInt(next));
});

test("Android version codes reserve two retry digits without adjacent-run collisions", () => {
  const retry99 = computeMobileBuildNumber({platform: "android", utcDate: "20260711", runNumber: 26, runAttempt: 99});
  const next = computeMobileBuildNumber({platform: "android", utcDate: "20260711", runNumber: 27, runAttempt: 1});
  assert.equal(retry99, "102699");
  assert.equal(next, "102701");
  assert.ok(Number(retry99) < Number(next));
});

test("build numbers fail closed when the reserved retry width is exceeded", () => {
  assert.throws(
    () => computeMobileBuildNumber({platform: "ios", utcDate: "20260711", runNumber: 26, runAttempt: 100}),
    /reserved two digits/u,
  );
});
