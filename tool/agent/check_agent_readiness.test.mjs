import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  evaluateAgentReadiness,
  extractCommandPaths,
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

test("readiness rejects the retired --record-metric option", () => {
  const cliPath = fileURLToPath(new URL("./check_agent_readiness.mjs", import.meta.url));
  const result = spawnSync(process.execPath, [cliPath, "--record-metric"], {
    encoding: "utf8",
  });

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Unknown argument: --record-metric/u);
});

test("frozen governance evidence and the delegation recorder are unnecessary", () => {
  const source = createRepositorySnapshot();
  const baseline = evaluateAgentReadiness({snapshot: source});
  const retiredPaths = new Set([
    "docs/audit_registry/files.jsonl",
    "docs/audit_registry/passes.jsonl",
    "docs/audit_registry/agent_metrics.jsonl",
    "docs/audit_registry/doc_versions.json",
    "docs/agent_regression_ledger.json",
    "tool/agent/record_delegation_outcome.mjs",
  ]);
  const snapshot = {
    ...source,
    exists(relativePath) {
      return retiredPaths.has(relativePath) ? false : source.exists(relativePath);
    },
    listFiles(options) {
      return source.listFiles(options).filter((relativePath) =>
        !retiredPaths.has(relativePath));
    },
    listPaths(options) {
      return source.listPaths(options).filter((relativePath) =>
        !retiredPaths.has(relativePath));
    },
    readTexts(relativePaths, options) {
      assert.ok(
        relativePaths.every((relativePath) => !retiredPaths.has(relativePath)),
        "readiness must not load retired governance files",
      );
      const texts = source.readTexts(relativePaths, options);
      const manifestPath = "tool/tools_manifest.json";
      if (texts.has(manifestPath)) {
        const manifest = JSON.parse(texts.get(manifestPath));
        manifest.tools = manifest.tools.filter((tool) =>
          tool.id !== "agent:record-delegation");
        texts.set(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
      }
      return texts;
    },
  };

  const result = evaluateAgentReadiness({snapshot});

  assert.equal(baseline.failed, 0);
  assert.deepEqual(result, baseline);
});
