import assert from "node:assert/strict";
import test from "node:test";
import {
  dependencyBaselineGrowthWarnings,
  extractDependencyBaselineSnapshot,
} from "./check_agent_readiness.mjs";

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
