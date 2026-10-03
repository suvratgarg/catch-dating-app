import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {compareSelectors, requireComparedTargets} from "./compare_selectors.mjs";

function fixture(t) {
  const cwd = fs.mkdtempSync(path.join(os.tmpdir(), "catch-selector-compare-test-"));
  t.after(() => fs.rmSync(cwd, {recursive: true, force: true}));
  const git = (...args) => {
    const result = spawnSync("git", args, {cwd, encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  const write = (name, bytes) => {
    const file = path.join(cwd, name); fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, bytes);
  };
  for (const file of ["tool/harness/component_graph.json", "tool/harness/lib/component_graph.mjs", "tool/lib/path_glob.mjs"]) {
    write(file, fs.readFileSync(new URL(`../../${file}`, import.meta.url)));
  }
  git("init", "--quiet", "-b", "main"); git("config", "user.name", "Selector fixture");
  git("config", "user.email", "fixture@example.invalid");
  const commit = () => { git("add", "."); git("commit", "--quiet", "-m", "fixture"); return git("rev-parse", "HEAD"); };
  const base = commit();
  return {cwd, git, write, commit, base};
}

test("selector edits execute actual base and head implementations and retain full coverage", t => {
  const f = fixture(t);
  f.write("tool/harness/control-test.mjs", "// new controlled selector source\n");
  const head = f.commit();
  const result = compareSelectors({...f, head});
  assert.equal(result.status, "full-validation-required");
  assert.deepEqual(result.after.plan.operations.ciTargets, result.requiredTargets);
  assert.equal(result.before.sourceSha, f.base); assert.equal(result.after.sourceSha, head);
  assert.ok(result.before.inputHashes["tool/harness/lib/component_graph.mjs"]);
});

test("a head engine that falsely claims complete narrow coverage cannot suppress trusted-base obligations", t => {
  const f = fixture(t);
  f.write("tool/harness/lib/component_graph.mjs", `export function planAffected() {
    return {complete: true, operations: {ciTargets: ['docs']}};
  }`);
  f.commit();
  assert.throws(() => compareSelectors(f), /Selector-control edits require full validation; missing/);
});

test("unknown source plus selector edits fails closed", t => {
  const f = fixture(t);
  f.write("tool/harness/control-test.mjs", "// source\n");
  f.write("unowned/new.bin", "unknown"); f.commit();
  assert.throws(() => compareSelectors(f), /complete, unambiguous path coverage/);
});

test("snapshot runtime and missing dependency failures cannot be reported as success", t => {
  const f = fixture(t);
  f.write("tool/harness/lib/component_graph.mjs", "import './missing.mjs';\n"); f.commit();
  assert.throws(() => compareSelectors(f), /snapshot .* failed; retain full validation/);
});

test("ordinary changes do not require selector snapshot execution", t => {
  const f = fixture(t);
  f.write("docs/example.md", "authored decision"); f.commit();
  assert.equal(compareSelectors(f).status, "no-selector-control-change");
});

test("deletion and rename of selector source are both retained in the comparison", t => {
  const f = fixture(t);
  f.write("tool/harness/old.mjs", "export const example = true;\n"); const base = f.commit();
  f.git("mv", "tool/harness/old.mjs", "tool/harness/new.mjs"); f.commit();
  const result = compareSelectors({...f, base});
  assert.deepEqual(result.controls, ["tool/harness/new.mjs", "tool/harness/old.mjs"]);
});

test("main comparison retains reverted selector edits from the committed window", t => {
  const f = fixture(t);
  f.write("tool/harness/transient.mjs", "// temporary controlled input\n"); f.commit();
  f.git("rm", "tool/harness/transient.mjs"); f.commit();
  assert.equal(compareSelectors(f).status, "no-selector-control-change");
  const main = compareSelectors({...f, mode: "main"});
  assert.equal(main.status, "full-validation-required");
  assert.deepEqual(main.controls, ["tool/harness/transient.mjs"]);
});

test("actual fanout cannot suppress obligations found by independent comparison", () => {
  const comparison = {baseSha: "a".repeat(40), headSha: "b".repeat(40),
    status: "full-validation-required", requiredTargets: ["flutter", "firestore_rules"]};
  const plan = {baseSha: comparison.baseSha, sourceSha: comparison.headSha,
    operations: {ciTargets: ["flutter", "firestore_rules"]}};
  const githubOutput = "flutter=true\nfirestore_rules=true\n";
  requireComparedTargets(comparison, plan, githubOutput);
  for (const broken of ["flutter=false\nfirestore_rules=true\n", "firestore_rules=true\n", githubOutput + "flutter=true\n"]) {
    assert.throws(() => requireComparedTargets(comparison, plan, broken), /GitHub fanout suppressed or duplicated/);
  }
  assert.throws(() => requireComparedTargets(comparison, {...plan,
    operations: {ciTargets: ["flutter"]}}), /Actual CI plan suppressed compared obligations/);
  assert.throws(() => requireComparedTargets(comparison, {...plan, sourceSha: "c".repeat(40)}), /Planned source differs/);
  assert.throws(() => requireComparedTargets(comparison, {...plan, baseSha: "c".repeat(40)}), /Planned base differs/);
});

for (const file of ["tool/lib/path_glob.mjs", "tool/lib/tool_impact.mjs",
  "tool/lib/repository_snapshot.mjs", "tool/run.mjs", "tool/tools_manifest.json"]) {
  test(`selector comparison and graph agree for ${file}`, t => {
    const f = fixture(t);
    const existing = fs.existsSync(path.join(f.cwd, file)) ? fs.readFileSync(path.join(f.cwd, file), "utf8") : "";
    f.write(file, existing + "\n// isolated selector edit\n"); f.commit();
    assert.equal(compareSelectors(f).status, "full-validation-required");
  });
}
