import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import {OPERATOR_SOURCE_SHA, COMPATIBILITY_CHECKPOINT, REVIEWED_DELTA,
  verifySourceCompatibility} from "./operator_source_compatibility.mjs";

function evidence() {
  return {sourceSha: OPERATOR_SOURCE_SHA, currentSha: COMPATIBILITY_CHECKPOINT,
    sourceAncestor: true, checkpointAncestor: true,
    changedPaths: REVIEWED_DELTA.map((row) => row.path), currentDifference: [],
    rows: REVIEWED_DELTA.map((row) => ({...row, candidateMode: "100644", checkpointMode: "100644"}))};
}
test("accepts only the exact reviewed seven-file compatibility delta", () => {
  assert.equal(verifySourceCompatibility(evidence()).sourceSha, OPERATOR_SOURCE_SHA);
});
for (const [name, change] of [
  ["different immutable source", (e) => {e.sourceSha = "0".repeat(40);} ],
  ["nonancestor source", (e) => {e.sourceAncestor = false;} ],
  ["missing reviewed checkpoint ancestry", (e) => {e.checkpointAncestor = false;} ],
  ["additional backend change", (e) => {e.currentDifference.push("functions/src/new.ts");} ],
  ["modified reviewed backend body", (e) => {e.rows[0].mergedGitBlob = "0".repeat(40);} ],
  ["modified candidate body", (e) => {e.rows[0].candidateGitBlob = "0".repeat(40);} ],
  ["symlink replacement", (e) => {e.rows[0].checkpointMode = "120000";} ],
  ["omitted reviewed difference", (e) => {e.changedPaths.pop();} ],
  ["duplicate evidence row", (e) => {e.rows[1] = e.rows[0];} ],
  ["index scope change", (e) => {e.currentDifference.push("firestore.indexes.json");} ],
  ["package dependency change", (e) => {e.currentDifference.push("functions/package-lock.json");} ],
]) {
  test(`rejects ${name}`, () => {const e = evidence(); change(e); assert.throws(() => verifySourceCompatibility(e));});
}
test("operator workflow retains immutable artifact and exact selector authority", () => {
  const workflow = fs.readFileSync(new URL("../../.github/workflows/selective-backend-release.yml", import.meta.url), "utf8");
  assert.match(workflow, /11319623826/);
  assert.match(workflow, /sha256:a3f0636ba0ba631f66990b2a41ac25dd486ed9650eb6060a0a9a0a1caebc9029/);
  assert.match(workflow, /confirm_four_functions_five_indexes/);
  assert.match(workflow, /source_sha: 656f093d1910afdbe4d93d31565d1782c39aab63/);
});

test("workflow checks use trusted helper and the freshly fetched proof checkout", () => {
  const caller = fs.readFileSync(new URL("../../.github/workflows/selective-backend-release.yml", import.meta.url), "utf8");
  assert.ok(caller.includes('node tool/ci/operator_source_compatibility.mjs "$REQUESTED_SHA" "$GITHUB_SHA"'));
  const workflow = fs.readFileSync(new URL("../../.github/workflows/_firebase-promote.yml", import.meta.url), "utf8");
  const calls = workflow.match(/node tool\/ci\/operator_source_compatibility\.mjs[^\n]*\n[^\n]*/g);
  assert.equal(calls.length, 2);
  for (const call of calls) assert.ok(call.endsWith('"$SOURCE_CHECKOUT"'));
});
