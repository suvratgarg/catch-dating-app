import assert from "node:assert/strict";
import test from "node:test";
import {
  buildCoverageReport,
  parseLcov,
  renderCoverageMarkdown,
} from "./flutter_coverage_report.mjs";

const fixture = `TN:
SF:/repo/lib/core/clock.dart
DA:1,1
DA:2,0
end_of_record
SF:/repo/lib/explore/feed.dart
DA:10,3
DA:11,1
DA:12,0
end_of_record
SF:/repo/lib/explore/feed.g.dart
DA:1,1
DA:2,1
end_of_record
SF:/repo/test/not_product.dart
DA:1,1
end_of_record
`;

test("parseLcov keeps product Dart line observations and normalizes paths", () => {
  assert.deepEqual(parseLcov(fixture), [
    {path: "lib/core/clock.dart", linesFound: 2, linesHit: 1},
    {path: "lib/explore/feed.dart", linesFound: 3, linesHit: 2},
    {path: "lib/explore/feed.g.dart", linesFound: 2, linesHit: 2},
  ]);
});

test("coverage report separates generated code and groups handwritten features", () => {
  const report = buildCoverageReport(fixture);

  assert.equal(report.policy, "visibility_only_no_global_threshold");
  assert.deepEqual(report.summary, {
    files: 2,
    linesFound: 5,
    linesHit: 3,
    percent: 60,
  });
  assert.deepEqual(report.excludedGeneratedOrConfig, {
    files: 1,
    linesFound: 2,
    linesHit: 2,
    percent: 100,
  });
  assert.deepEqual(
    report.features.map(({feature, linesFound, linesHit}) => ({
      feature,
      linesFound,
      linesHit,
    })),
    [
      {feature: "explore", linesFound: 3, linesHit: 2},
      {feature: "core", linesFound: 2, linesHit: 1},
    ],
  );
});

test("markdown makes the no-threshold and unobserved-file caveats explicit", () => {
  const markdown = renderCoverageMarkdown(buildCoverageReport(fixture));

  assert.match(markdown, /visibility-only/u);
  assert.match(markdown, /does not impose an aggregate/u);
  assert.match(markdown, /never loads are not represented/u);
  assert.match(markdown, /\| explore \| 2 \/ 3 \| 66\.7% \| 1 \|/u);
});

test("known-bad LCOV records fail closed", () => {
  assert.throws(
    () => parseLcov("SF:/repo/lib/core/bad.dart\nDA:not-a-line,1\n"),
    /Invalid LCOV line record/u,
  );
});
