import test from "node:test";
import assert from "node:assert/strict";
import {
  classify,
  matchesImpactPath,
  matchesPattern,
  portableLinkViolations,
  relationshipViolations,
} from "./check_repository_root_hygiene.mjs";

test("glob matching covers dynamic root logs without widening paths", () => {
  assert.equal(matchesPattern("flutter_12.log", "flutter_*.log"), true);
  assert.equal(matchesPattern("nested/flutter_12.log", "flutter_*.log"), false);
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
