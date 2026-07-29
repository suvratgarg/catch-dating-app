import assert from "node:assert/strict";
import test from "node:test";
import {
  checkTestLifecycle,
  containsSkippedTest,
} from "./check_test_lifecycle.mjs";

const rules = {
  rules: {
    "TEST-LIFECYCLE-001": {},
    "FLUTTER-TEST-MAINTAINABILITY-001": {},
  },
};
const regressionLedger = {entries: []};
const today = new Date("2026-07-29T12:00:00.000Z");

function fixture({
  files = ["lib/example.dart", "test/example_test.dart"],
  exceptionalTests = [],
  criticalObligations = [],
  allowedFindings = [],
  sources = new Map(),
} = {}) {
  return checkTestLifecycle({
    files,
    sources,
    today,
    rules,
    regressionLedger,
    oversizedBaseline: {allowedFindings},
    config: {
      schemaVersion: 1,
      reviewCadenceDays: 90,
      policy: {
        allowedLifecycles: [
          "active",
          "compatibility",
          "platform_specific",
          "quarantined",
          "retire_candidate",
        ],
        exceptionReasons: [
          "compatibility",
          "oversized",
          "platform_specific",
          "quarantined",
          "non_colocated",
        ],
      },
      exceptionalTests,
      criticalObligations,
    },
  });
}

function exceptional(overrides = {}) {
  return {
    path: "test/example_test.dart",
    owner: "flutter/example",
    lifecycle: "active",
    reason: "oversized",
    contractIds: ["FLUTTER-TEST-MAINTAINABILITY-001"],
    ownerPaths: ["lib/example.dart"],
    sunsetWhen: "The spec is split below the maintained ceiling.",
    reviewBy: "2026-10-27",
    ...overrides,
  };
}

test("valid exceptional lifecycle and critical obligation pass", () => {
  const result = fixture({
    exceptionalTests: [exceptional()],
    allowedFindings: [{path: "test/example_test.dart", maxLines: 1300}],
    criticalObligations: [
      {
        id: "example",
        owner: "flutter/example",
        sourcePaths: ["lib/example.dart"],
        testPaths: ["test/example_test.dart"],
        rationale: "Example risk remains directly covered.",
      },
    ],
  });
  assert.deepEqual(result.findings, []);
  assert.equal(result.counts.retirementCandidates, 0);
});

test("known-bad missing owner anchor becomes a retirement candidate", () => {
  const result = fixture({
    files: ["test/example_test.dart"],
    exceptionalTests: [exceptional()],
    allowedFindings: [{path: "test/example_test.dart", maxLines: 1300}],
  });
  assert.match(result.findings.join("\n"), /review retirement/u);
  assert.equal(result.retirementCandidates.length, 1);
});

test("known-bad oversized test without lifecycle metadata fails closed", () => {
  const result = fixture({
    allowedFindings: [{path: "test/example_test.dart", maxLines: 1300}],
  });
  assert.match(
    result.findings.join("\n"),
    /oversized baseline requires lifecycle metadata/u,
  );
});

test("known-bad skipped test without lifecycle metadata fails closed", () => {
  const result = fixture({
    sources: new Map([
      ["test/example_test.dart", "test('temporary', () {}, " + "skip: true);"],
    ]),
  });
  assert.match(
    result.findings.join("\n"),
    /skipped test requires platform_specific or quarantined/u,
  );
});

test("known-bad executable test outside the inventory classifier fails closed", () => {
  const result = fixture({
    files: ["apps/new-role/test/example_test.dart"],
  });
  assert.match(
    result.findings.join("\n"),
    /executable test is not classified/u,
  );
});

test("skip detection ignores collection skip and ordinary prose", () => {
  assert.equal(
    containsSkippedTest("values.skip(1);", "test/example_test.dart"),
    false,
  );
  assert.equal(
    containsSkippedTest(
      "test('darwin', {" + "skip: process.platform !== 'darwin'}, () => {});",
      "tool/example.test.mjs",
    ),
    true,
  );
});
