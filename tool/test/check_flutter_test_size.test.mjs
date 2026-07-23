import assert from "node:assert/strict";
import test from "node:test";
import {
  buildFlutterTestSizeBaseline,
  checkFlutterTestSizes,
  lineCount,
} from "./check_flutter_test_size.mjs";

test("known-bad new oversized Flutter test spec fails closed", () => {
  const findings = checkFlutterTestSizes(
    [{path: "test/new_feature_test.dart", lines: 1201}],
    {maxLines: 1200, allowedFindings: []},
  );

  assert.deepEqual(findings, [
    "test/new_feature_test.dart: 1201 lines exceeds 1200 without a baseline entry",
  ]);
});

test("ratchet rejects growth and asks reductions to refresh the baseline", () => {
  const baseline = {
    maxLines: 1200,
    allowedFindings: [
      {path: "test/growing_test.dart", maxLines: 1500},
      {path: "test/shrinking_test.dart", maxLines: 1500},
    ],
  };

  assert.deepEqual(
    checkFlutterTestSizes(
      [
        {path: "test/growing_test.dart", lines: 1501},
        {path: "test/shrinking_test.dart", lines: 1400},
      ],
      baseline,
    ),
    [
      "test/growing_test.dart: grew from 1500 to 1501 lines",
      "test/shrinking_test.dart: improved from 1500 to 1400; refresh the baseline to lock in the reduction",
    ],
  );
});

test("baseline generator records only current debt deterministically", () => {
  assert.deepEqual(
    buildFlutterTestSizeBaseline(
      [
        {path: "test/z_test.dart", lines: 1201},
        {path: "test/a_test.dart", lines: 1200},
        {path: "test/b_tests.dart", lines: 1300},
      ],
      {maxLines: 1200},
    ),
    {
      schemaVersion: 1,
      maxLines: 1200,
      policy:
        "new_or_split_flutter_test_specs_stay_bounded_existing_debt_cannot_grow",
      allowedFindings: [
        {path: "test/b_tests.dart", maxLines: 1300},
        {path: "test/z_test.dart", maxLines: 1201},
      ],
    },
  );
});

test("lineCount handles trailing newlines without an extra phantom line", () => {
  assert.equal(lineCount("one\ntwo\n"), 2);
  assert.equal(lineCount("one\ntwo"), 2);
  assert.equal(lineCount(""), 0);
});
