import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {compare, findingKeys, main, shrinkBaseline, workspaceOf} from "./check_unused_code.mjs";

const report = {issues: [
  {file: "website/src/a.ts", files: [{name: "website/src/a.ts"}], exports: [{name: "A"}], types: [],
    unlisted: [{name: "vite"}], unresolved: [], dependencies: [], devDependencies: [], duplicates: []},
  {file: "functions/package.json", files: [], exports: [], dependencies: [], devDependencies: [{name: "x"}]},
  {file: "tool/x.mjs", files: [], exports: [], duplicates: [[{name: "b"}, {name: "a"}]]},
]};

function withBaseline(t, findings) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "unused-code-"));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const baselinePath = path.join(dir, "baseline.json");
  fs.writeFileSync(baselinePath, JSON.stringify({version: 1, findings}));
  return baselinePath;
}

function quietly(t) {
  for (const method of ["log", "error"]) t.mock.method(console, method, () => {});
}

test("Knip's JSON report becomes stable, sorted finding keys", () => {
  assert.deepEqual(findingKeys(report), ["devDependency functions/package.json x", "duplicate tool/x.mjs a|b",
    "export website/src/a.ts A", "file website/src/a.ts", "unlisted website/src/a.ts vite"]);
  assert.equal(workspaceOf("packages/web-ui/src/x.ts"), "packages/web-ui");
  assert.equal(workspaceOf("package.json"), ".");
  assert.equal(workspaceOf("tool/x.mjs"), ".");
});

test("a lane compares only the workspaces it checks", () => {
  const baseline = ["export website/src/a.ts A", "file website/src/old.ts", "file tool/y.mjs"];
  assert.deepEqual(compare({found: findingKeys(report), baseline, scope: ["website"]}), {
    added: ["file website/src/a.ts", "unlisted website/src/a.ts vite"],
    fixed: ["file website/src/old.ts"],
  });
  assert.deepEqual(compare({found: [], baseline, scope: ["."]}), {added: [], fixed: ["file tool/y.mjs"]});
});

test("known-bad new unused export fails the check", (t) => {
  quietly(t);
  const baselinePath = withBaseline(t, ["unlisted website/src/a.ts vite", "file website/src/a.ts"]);
  const code = main(["--check", "--workspace", "website"], {baselinePath, knip: () => report});
  assert.equal(code, 1);
});

test("a fixed finding still in the baseline fails until --update removes it", (t) => {
  quietly(t);
  const baselinePath = withBaseline(t, ["file website/src/old.ts", "file tool/y.mjs"]);
  const empty = () => ({issues: []});
  assert.equal(main(["--check", "--workspace", "website"], {baselinePath, knip: empty}), 1);
  assert.equal(main(["--update", "--workspace", "website"], {baselinePath, knip: empty}), 0);
  assert.deepEqual(JSON.parse(fs.readFileSync(baselinePath, "utf8")).findings, ["file tool/y.mjs"]);
  assert.equal(main(["--check", "--workspace", "website"], {baselinePath, knip: empty}), 0);
});

test("--update refuses to add findings to the baseline", () => {
  assert.throws(() => shrinkBaseline({baseline: [], added: ["file website/src/a.ts"], fixed: []}),
    /baseline only shrinks/);
});
