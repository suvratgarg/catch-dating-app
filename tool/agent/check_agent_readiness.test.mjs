import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  appendReadinessMetric,
  dependencyBaselineGrowthWarnings,
  evaluateAgentReadiness,
  extractCommandPaths,
  extractDependencyBaselineSnapshot,
  testInventoryMatches,
} from "./check_agent_readiness.mjs";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";

test("extractCommandPaths validates Functions build outputs through tracked sources", () => {
  assert.deepEqual(
    extractCommandPaths(
      "npm --prefix functions run build && node --test functions/lib/operations/projectionImporter.test.js functions/test/operations-import-shadow-projection.test.cjs",
    ),
    [
      "functions/src/operations/projectionImporter.test.ts",
      "functions/test/operations-import-shadow-projection.test.cjs",
    ],
  );
});

test("extractCommandPaths keeps Functions lib paths without a declared build", () => {
  assert.deepEqual(
    extractCommandPaths("node --test functions/lib/operations/projectionImporter.test.js"),
    ["functions/lib/operations/projectionImporter.test.js"],
  );
});

test("extractDependencyBaselineSnapshot reads readiness baseline metrics", () => {
  const snapshot = extractDependencyBaselineSnapshot({
    event: "agent_readiness_check",
    architecture_baselines: {
      dependency_direction: {
        baseline_total: 79,
        baseline_by_rule: {
          crossFeaturePresentationImport: 69,
          domainFrameworkImport: 10,
        },
        new_findings_total: 0,
        checked_files: 672,
      },
    },
  });

  assert.deepEqual(snapshot, {
    baseline_total: 79,
    baseline_by_rule: {
      crossFeaturePresentationImport: 69,
      domainFrameworkImport: 10,
    },
    new_findings_total: 0,
    checked_files: 672,
  });
});

test("extractDependencyBaselineSnapshot reads dependency enforcement receipts", () => {
  const snapshot = extractDependencyBaselineSnapshot({
    event: "enforcement_baseline",
    baseline: "tool/architecture/dependency_direction_baseline.json",
    counts: {allowedFindings: 104},
    ruleCounts: {
      undocumentedKeepAlive: 37,
      widgetRefParameter: 21,
    },
  });

  assert.deepEqual(snapshot, {
    baseline_total: 104,
    baseline_by_rule: {
      undocumentedKeepAlive: 37,
      widgetRefParameter: 21,
    },
    new_findings_total: 0,
    checked_files: 0,
  });
});

test("extractDependencyBaselineSnapshot reads legacy dependency receipt counts", () => {
  const snapshot = extractDependencyBaselineSnapshot({
    event: "enforcement_baseline",
    baseline: "tool/architecture/dependency_direction_baseline.json",
    allowedFindingsCount: 27,
  });

  assert.deepEqual(snapshot, {
    baseline_total: 27,
    baseline_by_rule: {},
    new_findings_total: 0,
    checked_files: 0,
  });
});

test("dependencyBaselineGrowthWarnings warns when baseline total grows", () => {
  const warnings = dependencyBaselineGrowthWarnings(
    [
      {
        event: "agent_readiness_check",
        architecture_baselines: {
          dependency_direction: {
            baseline_total: 79,
            baseline_by_rule: {
              crossFeaturePresentationImport: 69,
              domainFrameworkImport: 10,
            },
            new_findings_total: 0,
            checked_files: 672,
          },
        },
      },
    ],
    {
      baseline_total: 81,
      baseline_by_rule: {
        crossFeaturePresentationImport: 70,
        domainFrameworkImport: 11,
      },
      new_findings_total: 0,
      checked_files: 672,
    },
  );

  assert.equal(warnings.length, 1);
  assert.match(warnings[0], /Dependency direction baseline grew 79->81/u);
  assert.match(warnings[0], /crossFeaturePresentationImport 69->70/u);
  assert.match(warnings[0], /domainFrameworkImport 10->11/u);
});

test("dependencyBaselineGrowthWarnings warns from enforcement receipts", () => {
  const warnings = dependencyBaselineGrowthWarnings(
    [
      {
        event: "enforcement_baseline",
        baseline: "tool/architecture/dependency_direction_baseline.json",
        counts: {allowedFindings: 0},
        ruleCounts: {},
      },
    ],
    {
      baseline_total: 2,
      baseline_by_rule: {
        multiRouteScreenFile: 2,
      },
      new_findings_total: 0,
      checked_files: 725,
    },
  );

  assert.equal(warnings.length, 1);
  assert.match(warnings[0], /Dependency direction baseline grew 0->2/u);
  assert.match(warnings[0], /multiRouteScreenFile 0->2/u);
});

test("dependencyBaselineGrowthWarnings is silent when baseline is stable", () => {
  const warnings = dependencyBaselineGrowthWarnings(
    [
      {
        event: "agent_readiness_check",
        architecture_baselines: {
          dependency_direction: {
            baseline_total: 81,
            baseline_by_rule: {
              crossFeaturePresentationImport: 70,
              domainFrameworkImport: 11,
            },
            new_findings_total: 0,
            checked_files: 672,
          },
        },
      },
    ],
    {
      baseline_total: 79,
      baseline_by_rule: {
        crossFeaturePresentationImport: 69,
        domainFrameworkImport: 10,
      },
      new_findings_total: 0,
      checked_files: 672,
    },
  );

  assert.deepEqual(warnings, []);
});

test("test inventory readiness proof rejects stale generated content", () => {
  const inventory = {
    schemaVersion: 1,
    generatedFrom: "fixture",
    generatedBy: "fixture",
    total: 1,
    categories: {
      flutter_unit_widget: {
        count: 1,
        files: ["test/current_test.dart"],
      },
    },
  };
  const current = `${JSON.stringify(inventory, null, 2)}\n`;

  assert.equal(testInventoryMatches(current, inventory), true);
  assert.equal(testInventoryMatches('{"total":0}\n', inventory), false);
});

test("agent readiness keeps check collection invocation-local", () => {
  const snapshot = createRepositorySnapshot();

  const first = evaluateAgentReadiness({snapshot});
  const second = evaluateAgentReadiness({snapshot});

  assert.ok(first.total > 100);
  assert.equal(first.total, second.total);
  assert.equal(first.passed, second.passed);
  assert.equal(first.failed, second.failed);
  assert.ok(first.architecture_baselines.dependency_direction.checked_files > 0);
  if (first.failed === 0) {
    assert.equal(first.score, 100);
  } else {
    assert.ok(first.score <= 99);
  }
});

test("malformed regression check_ids report readiness failures instead of throwing", () => {
  const source = createRepositorySnapshot();
  const snapshot = {
    ...source,
    readTexts(relativePaths, options) {
      const texts = source.readTexts(relativePaths, options);
      const relativePath = "docs/agent_regression_ledger.json";
      if (!texts.has(relativePath)) return texts;
      const ledger = JSON.parse(texts.get(relativePath));
      ledger.entries[0].guard.check_ids = {};
      texts.set(relativePath, `${JSON.stringify(ledger, null, 2)}\n`);
      return texts;
    },
  };

  const result = evaluateAgentReadiness({snapshot});
  assert.ok(result.failures.some((failure) => failure.includes("check_ids is non-empty")));
  assert.ok(result.failures.some((failure) => failure.includes("check_ids is unique")));
});

test("readiness metric write refuses a sparse-omitted target", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-readiness-metric-"));
  const snapshot = {
    root,
    exists(relativePath) {
      return relativePath === "docs/audit_registry/agent_metrics.jsonl";
    },
  };

  assert.throws(
    () => appendReadinessMetric(readinessResultFixture(), snapshot),
    /Refusing to write sparse-omitted repository path/u,
  );
});

test("readiness metric write appends to a materialized regular file", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-readiness-metric-"));
  const metricsPath = path.join(
    root,
    "docs/audit_registry/agent_metrics.jsonl",
  );
  fs.mkdirSync(path.dirname(metricsPath), {recursive: true});
  fs.writeFileSync(metricsPath, "");
  const snapshot = {
    root,
    exists(relativePath) {
      return relativePath === "docs/audit_registry/agent_metrics.jsonl";
    },
  };

  appendReadinessMetric(readinessResultFixture(), snapshot);

  const entry = JSON.parse(fs.readFileSync(metricsPath, "utf8"));
  assert.equal(entry.event, "agent_readiness_check");
  assert.equal(entry.readiness_score, 100);
});

function readinessResultFixture() {
  return {
    score: 100,
    passed: 1,
    failed: 0,
    total: 1,
    architecture_baselines: {
      dependency_direction: {
        baseline_total: 0,
        baseline_by_rule: {},
        new_findings_total: 0,
        checked_files: 1,
      },
    },
  };
}
