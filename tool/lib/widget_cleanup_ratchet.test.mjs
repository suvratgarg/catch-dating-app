import assert from "node:assert/strict";
import test from "node:test";
import {
  compareWidgetCleanupCounts,
  parseWidgetCleanupSummary,
  totalCounts,
} from "./widget_cleanup_ratchet.mjs";

test("parses live widget cleanup summary categories", () => {
  const counts = parseWidgetCleanupSummary(`
Widget cleanup candidate scan summary
  centralized_widget_timing: 10
  raw_text_style_candidates: 1
`);

  assert.deepEqual(counts, {
    centralized_widget_timing: 10,
    raw_text_style_candidates: 1,
  });
  assert.equal(totalCounts(counts), 11);
});

test("ratchet accepts reductions and unchanged counts", () => {
  assert.deepEqual(
    compareWidgetCleanupCounts({
      actual: {first: 2, second: 0},
      maxCounts: {first: 3, second: 0},
    }),
    [],
  );
});

test("ratchet flags increases, missing categories, and new categories", () => {
  const errors = compareWidgetCleanupCounts({
    actual: {first: 4, new_category: 1},
    maxCounts: {first: 3, missing_category: 0},
  });

  assert.deepEqual(errors, [
    "first: live 4 exceeds baseline maximum 3.",
    "Live widget cleanup summary is missing category missing_category.",
    "Live widget cleanup summary has unbaselined category new_category.",
  ]);
});
