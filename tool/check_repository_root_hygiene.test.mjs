import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {execFileSync} from "node:child_process";
import {
  checkRepository,
  classify,
  matchesImpactPath,
  matchesPattern,
  portableLinkViolations,
  relationshipViolations,
  retiredEvidenceViolations,
} from "./check_repository_root_hygiene.mjs";

test("glob matching covers dynamic root logs without widening paths", () => {
  assert.equal(matchesPattern("flutter_12.log", "flutter_*.log"), true);
  assert.equal(matchesPattern("nested/flutter_12.log", "flutter_*.log"), false);
  assert.equal(matchesPattern("firebase-debug.log", "firebase-debug.log"), true);
});

test("classification reports an unknown and an ambiguous entry", () => {
  const manifest = {entries: [{names: ["known"]}], patterns: [{pattern: "k*"}]};
  assert.equal(classify("unknown", manifest).length, 0);
  assert.equal(classify("known", manifest).length, 2);
});

test("portable links reject machine paths but accept repository links", () => {
  assert.deepEqual(portableLinkViolations("[bad](/Users/person/repo/a.md) [ok](docs/a.md)"), ["/Users/person/repo/a.md"]);
});

test("impact globs distinguish recursive paths from sibling roots", () => {
  assert.equal(matchesImpactPath("widgetbook/lib/main.dart", "widgetbook/**"), true);
  assert.equal(matchesImpactPath("website/src/main.tsx", "widgetbook/**"), false);
});

test("retired tracked governance evidence cannot return", () => {
  const present = new Set([
    "docs/agent_regression_ledger.json",
    "tool/policy/rules.json",
  ]);
  assert.deepEqual(retiredEvidenceViolations({
    exists: (value) => present.has(value),
    listPaths: ({prefix}) => prefix === "docs/audit_registry/"
      ? ["docs/audit_registry/arbitrary-new-receipt.json"]
      : [],
  }), [
    "docs/agent_regression_ledger.json: retired governance evidence must remain absent",
    "docs/audit_registry/arbitrary-new-receipt.json: retired governance evidence must remain absent",
  ]);
});

test("relationship validation rejects unknown tools and unmapped files", () => {
  const manifest = {
    ownerVocabulary: ["repository_tooling"],
    relationships: [{
      id: "control",
      owner: "repository_tooling",
      sources: ["tool/**"],
      checks: ["missing:tool"],
      ciWorkflows: [],
    }],
    auditPolicies: [],
  };
  assert.deepEqual(relationshipViolations({
    manifest,
    toolIds: new Set(),
    root: process.cwd(),
    trackedPaths: ["tool/run.mjs", "README.md"],
  }), [
    "control: unknown tool missing:tool",
    "README.md: no impact relationship",
  ]);
});

test("repository findings are identical when docs and workflows are sparse omitted", (context) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-root-hygiene-sparse-"));
  context.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const manifest = {
    ownerVocabulary: ["repository_tooling"],
    entries: [
      rootEntry(".git"),
      rootEntry(".github", {expectation: "tracked"}),
      rootEntry("docs", {
        expectation: "tracked",
        kind: "curated-artifact",
        consumer: "tool/tools_manifest.json",
      }),
      rootEntry("tool", {expectation: "tracked"}),
    ],
    patterns: [],
    prohibitedRootEntries: [],
    cleanupTargets: [],
    protectedPaths: [],
    relationships: [{
      id: "control-plane",
      owner: "repository_tooling",
      sources: [".github/**", "docs/**", "tool/**"],
      checks: [],
      ciWorkflows: [".github/workflows/ci.yml"],
    }],
    auditPolicies: [],
  };
  write(root, "tool/repository_root_manifest.json", `${JSON.stringify(manifest)}\n`);
  write(root, "tool/tools_manifest.json", '{"tools":[]}\n');
  write(root, ".github/workflows/ci.yml", "name: CI\n");
  write(root, "docs/readme.md", "[machine](/Users/example/private.md)\n");
  git(root, ["init", "-q"]);
  git(root, ["config", "user.email", "snapshot@example.com"]);
  git(root, ["config", "user.name", "Snapshot Test"]);
  git(root, ["add", "."]);
  git(root, ["commit", "-qm", "fixture"]);

  const full = checkRepository({root});
  git(root, ["sparse-checkout", "init", "--no-cone"]);
  git(root, ["sparse-checkout", "set", "--no-cone", "/tool/"]);
  const sparse = checkRepository({root});

  assert.deepEqual(sparse, full);
  assert.deepEqual(sparse, [
    "docs/readme.md: non-portable Markdown link /Users/example/private.md",
  ]);
  assert.equal(fs.existsSync(path.join(root, ".github/workflows/ci.yml")), false);
  assert.equal(fs.existsSync(path.join(root, "docs/readme.md")), false);
});

function rootEntry(name, overrides = {}) {
  return {
    names: [name],
    owner: "repository_tooling",
    recovery: "restore fixture",
    ...overrides,
  };
}

function write(root, relativePath, source) {
  const absolutePath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
  fs.writeFileSync(absolutePath, source);
}

function git(root, args) {
  execFileSync("git", args, {cwd: root, stdio: "pipe"});
}
