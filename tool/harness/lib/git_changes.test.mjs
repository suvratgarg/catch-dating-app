import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {changedPathsSince} from "./git_changes.mjs";

function fixture(context) {
  const cwd = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ci-window-"));
  context.after(() => fs.rmSync(cwd, {recursive: true, force: true}));
  const git = (...args) => {
    const result = spawnSync("git", args, {cwd, encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr || `git ${args.join(" ")} failed`);
    return result.stdout.trim();
  };
  const write = (name, text) => {
    fs.mkdirSync(path.dirname(path.join(cwd, name)), {recursive: true});
    fs.writeFileSync(path.join(cwd, name), text);
  };
  const commit = () => {
    git("add", "."); git("commit", "--quiet", "-m", "fixture");
    return git("rev-parse", "HEAD");
  };
  git("init", "--quiet", "-b", "main");
  git("config", "user.name", "CI Window Test");
  git("config", "user.email", "ci-window@example.invalid");
  return {cwd, git, write, commit,
    changes: (base, options = {}) => changedPathsSince({cwd, base, ...options})};
}

test("a commit window retains an update and reversion hidden by endpoint diff", (context) => {
  const f = fixture(context);
  f.write("functions/src/a.ts", "export const a = 1;\n");
  const base = f.commit();
  f.write("functions/src/a.ts", "export const a = 2;\n");
  const intermediate = f.commit();
  f.write("functions/src/a.ts", "export const a = 1;\n");
  const head = f.commit();
  assert.deepEqual(f.changes(base), []);
  assert.deepEqual(f.changes(base, {commitWindow: true}), ["functions/src/a.ts"]);
  assert.deepEqual(f.changes(intermediate, {head, commitWindow: true}), ["functions/src/a.ts"]);
  assert.deepEqual(f.changes(head, {commitWindow: true}), []);
});

test("a failed predecessor window keeps its changes alongside the newer change", (context) => {
  const f = fixture(context);
  f.write("lib/a.dart", "const a = 1;\n"); f.write("lib/b.dart", "const b = 1;\n");
  const base = f.commit();
  f.write("lib/a.dart", "const a = 2;\n"); f.commit();
  f.write("lib/b.dart", "const b = 2;\n"); f.commit();
  assert.deepEqual(f.changes(base, {commitWindow: true}), ["lib/a.dart", "lib/b.dart"]);
});

test("merged transient files survive window selection when the branch predates the baseline", (context) => {
  const f = fixture(context);
  f.write("base.md", "base\n"); f.commit();
  f.git("checkout", "--quiet", "-b", "feature");
  f.write("transient.md", "temporary\n"); f.commit();
  f.git("checkout", "--quiet", "main");
  f.write("main-only.md", "main\n"); const base = f.commit();
  f.git("merge", "--quiet", "--no-ff", "feature", "-m", "merge fixture");
  f.git("rm", "transient.md"); f.commit();
  assert.deepEqual(f.changes(base), []);
  assert.ok(f.changes(base, {commitWindow: true}).includes("transient.md"));
});

test("renames retain both dependency paths and null-delimited names", (context) => {
  const f = fixture(context);
  f.write("lib/old name.dart", "const a = 1;\n"); const base = f.commit();
  f.git("mv", "lib/old name.dart", "lib/new name.dart"); f.commit();
  const expected = ["lib/new name.dart", "lib/old name.dart"];
  assert.deepEqual(f.changes(base, {commitWindow: true}), expected);
  assert.deepEqual(f.changes(base), expected);
});

test("committed CI windows exclude local staged and untracked work", (context) => {
  const f = fixture(context);
  f.write("a.md", "before\n"); const base = f.commit();
  f.write("a.md", "after\n"); f.commit();
  f.write("staged.md", "staged\n"); f.git("add", "staged.md");
  f.write("untracked.md", "untracked\n"); f.write("a.md", "dirty\n");
  assert.deepEqual(f.changes(base, {commitWindow: true}), ["a.md"]);
  assert.deepEqual(f.changes(base), ["a.md", "staged.md", "untracked.md"]);
});

test("invalid and non-ancestor windows fail instead of omitting changes", (context) => {
  const f = fixture(context);
  f.write("a.md", "base\n"); f.commit();
  f.git("branch", "other");
  f.write("a.md", "main\n"); const base = f.commit();
  f.git("checkout", "--quiet", "other");
  f.write("b.md", "other\n"); f.commit();
  assert.throws(() => f.changes(base, {commitWindow: true}));
  assert.throws(() => f.changes("missing-ref", {commitWindow: true}));
});
