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
  usesRetiredTaskScopeFlag,
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

test("task-scope guidance rejects retired or ambiguous task command scope", () => {
  for (const source of [
    "node tool/agent/context_pack.mjs --task docs --path docs",
    "node tool/agent/context_pack.mjs --task docs --paths docs",
    "node ./tool/agent/context_pack.mjs --task docs --paths docs",
    "node  tool/agent/context_pack.mjs --task docs --paths docs",
    "node tool/agent/context_pack.mjs --task docs --owned-paths docs --impact-paths docs/README.md",
    "node tool/agent/context_pack.mjs --task docs docs/README.md",
    "node tool/agent/context_pack.mjs --task docs --owned-paths docs docs/README.md",
    "node tool/harness.mjs task start --task-id docs --paths docs",
    "node ./tool/harness.mjs task start --task-id docs --owned-paths docs stray",
    "node tool/agent/context_pack.mjs --paths docs --help",
    "node tool/harness.mjs task start --help",
    "node tool/harness.mjs task start --paths docs --help",
    "node tool/agent/context_pack.mjs \\\n  --task docs \\\n  --paths docs",
  ]) {
    assert.equal(usesRetiredTaskScopeFlag(source), true);
  }
  for (const source of [
    "node tool/agent/context_pack.mjs --task docs --owned-paths docs",
    "node tool/agent/context_pack.mjs --task docs --owned-paths docs --planned-impact-paths docs/README.md",
    "node ./tool/agent/context_pack.mjs --help",
    "node tool/agent/context_pack.mjs --task <task-name> --owned-paths <path[,path...]>",
    "Generate `node tool/agent/context_pack.mjs --mode parallel-delegation --owned-paths <write-ceiling> --planned-impact-paths <expected-diff>` before editing.",
    "node tool/harness.mjs task start --task-id docs --owned-paths docs",
    "node tool/harness.mjs task start --task-id <id> --base-sha <40-character-sha> --owned-paths <path[,path...]> --context-pack build/agent-context/<id>.json",
    "Use tool/agent/context_pack.mjs to generate context.",
    "node tool/agent/context_pack.mjs \\\n  --task docs \\\n  --owned-paths docs",
    "node tool/run.mjs impact --paths docs",
  ]) {
    assert.equal(usesRetiredTaskScopeFlag(source), false);
  }

  for (const source of [
    "Use `node tool/agent/context_pack.mjs` to assemble this packet.",
    "Run node tool/agent/context_pack.mjs --task docs --owned-paths docs before editing.",
    "The command node tool/harness.mjs task start --owned-paths docs is canonical.",
    "Use `node tool/agent/context_pack.mjs` with `--owned-paths docs stray`.",
    "Use `node tool/harness.mjs task start` with `--bogus docs`.",
    "See `foo`, then run node tool/agent/context_pack.mjs --task docs --owned-paths docs before `bar`.",
    "Run node tool/run.mjs impact --paths docs, then node tool/agent/context_pack.mjs --task docs --owned-paths docs.",
    "Run node tool/run.mjs impact --paths docs before node tool/agent/context_pack.mjs --task docs --owned-paths docs.",
    "Run node tool/agent/context_pack.mjs --task docs --owned-paths docs and then node tool/run.mjs impact --paths docs.",
    "Use --paths docs with node tool/agent/context_pack.mjs.",
    "Pass --paths docs to node tool/harness.mjs task start.",
    "Use `--paths docs` with `node tool/agent/context_pack.mjs`.",
    "After node tool/run.mjs impact, use --paths docs with node tool/agent/context_pack.mjs.",
  ]) {
    assert.equal(usesRetiredTaskScopeFlag(source, {prose: true}), false);
  }
  for (const source of [
    "Use `node tool/agent/context_pack.mjs --task docs --paths docs` before editing.",
    "Use `node tool/harness.mjs task start --task-id docs --paths docs` before editing.",
  ]) {
    assert.equal(usesRetiredTaskScopeFlag(source, {prose: true}), true);
  }
});

test("agent readiness rejects retired task-scope flags in skills and guidance", () => {
  const source = createRepositorySnapshot();
  const snapshot = {
    ...source,
    readTexts(relativePaths, options) {
      const texts = source.readTexts(relativePaths, options);
      const manifestPath = "docs/agent_skills/skills_manifest.json";
      if (texts.has(manifestPath)) {
        const manifest = JSON.parse(texts.get(manifestPath));
        manifest.skills[0].required_commands[0] =
          "node tool/agent/context_pack.mjs --task stale lib";
        texts.set(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
      }
      const skillPath = "docs/agent_skills/catch-react-surface-refactor.md";
      if (texts.has(skillPath)) {
        texts.set(
          skillPath,
          `${texts.get(skillPath)}\nnode tool/agent/context_pack.mjs --task stale --path website\n`,
        );
      }
      return texts;
    },
  };

  const result = evaluateAgentReadiness({snapshot});
  assert.ok(result.failures.some((failure) =>
    failure.includes("required commands use canonical task-scope flags")));
  assert.ok(result.failures.some((failure) =>
    failure.includes("catch-react-surface-refactor.md uses canonical task-scope flags")));
});

test("malformed skill commands report readiness failures instead of throwing", () => {
  const source = createRepositorySnapshot();
  const snapshot = {
    ...source,
    readTexts(relativePaths, options) {
      const texts = source.readTexts(relativePaths, options);
      const manifestPath = "docs/agent_skills/skills_manifest.json";
      if (!texts.has(manifestPath)) return texts;
      const manifest = JSON.parse(texts.get(manifestPath));
      manifest.skills[0].required_commands = {};
      texts.set(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
      return texts;
    },
  };

  const result = evaluateAgentReadiness({snapshot});
  assert.ok(result.failures.some((failure) =>
    failure.includes("declares required commands")));
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
