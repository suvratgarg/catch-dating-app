import assert from "node:assert/strict";
import test from "node:test";

import {
  checkUiLintDriftRatchet,
  countDiagnostics,
} from "./check_ui_lint_drift_ratchet.mjs";

test("ratchet counts machine diagnostic code fields only", () => {
  const diagnostics = [
    "INFO|STATIC_WARNING|CATCH_ONE|/tmp/a.dart|1|1|1|message",
    "INFO|LINT|UNRELATED|/tmp/b.dart|1|1|1|mentions catch_one",
    "INFO|STATIC_WARNING|CATCH_ONE|/tmp/c.dart|1|1|1|message",
  ].join("\n");
  assert.deepEqual(countDiagnostics(diagnostics), {catch_one: 2});
});

test("ratchet fails increases, missing codes, and stale codes", () => {
  const result = checkUiLintDriftRatchet({
    diagnostics: [
      "INFO|STATIC_WARNING|CATCH_ONE|/tmp/a.dart|1|1|1|message",
      "INFO|STATIC_WARNING|CATCH_ONE|/tmp/b.dart|1|1|1|message",
    ].join("\n"),
    baseline: {maxCounts: {catch_one: 1, catch_stale: 0}},
    pluginSource: "LintCode('catch_one', 'x'); LintCode('catch_two', 'x');",
  });
  assert.deepEqual(result.failures, [
    "catch_two: missing from ratchet baseline",
    "catch_one: 2 exceeds ratchet maximum 1",
    "catch_stale: stale baseline code is not declared by the plugin",
  ]);
});

test("ratchet accepts reductions and checked zero codes", () => {
  const result = checkUiLintDriftRatchet({
    diagnostics: "INFO|STATIC_WARNING|CATCH_ONE|/tmp/a.dart|1|1|1|message\n",
    baseline: {maxCounts: {catch_one: 2, catch_two: 0}},
    pluginSource: "LintCode('catch_one', 'x'); LintCode('catch_two', 'x');",
  });
  assert.deepEqual(result.failures, []);
});
