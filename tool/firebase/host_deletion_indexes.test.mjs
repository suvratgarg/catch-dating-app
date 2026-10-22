import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import {assertSource, inspectField, patchBody, assertPreserved, assertDevReceipt, fields, indexes} from "./host_deletion_indexes.mjs";

const field = (fieldPath = "swiperId", complete = false) => ({
  name: `projects/catchdates-dev/databases/(default)/collectionGroups/outgoing/fields/${fieldPath}`,
  indexConfig: {usesAncestorConfig: !complete, indexes: indexes.slice(0, complete ? 4 : 3)
    .map(({queryScope, ...mode}) => ({queryScope, state: "READY", fields: [{fieldPath, ...mode}]}))},
});
test("deletion source owns both collection-group indexes and retains collection indexing", () => {
  const source = JSON.parse(fs.readFileSync("firestore.indexes.json", "utf8"));
  assertSource(source);
  for (const path of fields) {
    const changed = structuredClone(source);
    changed.fieldOverrides.find(row => row.collectionGroup === "outgoing" && row.fieldPath === path).indexes.pop();
    assert.throws(() => assertSource(changed));
  }
  const handler = fs.readFileSync("functions/src/safety/accountDeletion.ts", "utf8");
  for (const path of fields) assert.ok(handler.includes(`collectionGroup("outgoing").where("${path}", "==", uid)`));
});
test("field patch adds one query scope without dropping inherited indexes or changing TTL", () => {
  for (const path of fields) {
    assert.equal(inspectField(field(path), "dev", path), false);
    assert.equal(inspectField(field(path, true), "dev", path), true);
    const body = patchBody(field(path), "dev", path);
    assert.equal(body.indexConfig.indexes.length, 4);
    assert.deepEqual(Object.keys(body).sort(), ["indexConfig", "name"]);
    assert.throws(() => patchBody(field(path, true), "dev", path));
  }
  for (const mutate of [
    f => f.indexConfig.indexes.pop(),
    f => f.indexConfig.indexes[0].state = "CREATING",
    f => f.indexConfig.indexes[0].fields[0].fieldPath = "someoneElse",
    f => f.ttlConfig = {state: "ACTIVE"},
    f => f.indexConfig.reverting = true,
    f => f.name = f.name.replace("catchdates-dev", "catch-dating-app-64e51"),
    f => f.indexConfig.indexes.push(structuredClone(f.indexConfig.indexes[0])),
  ]) {
    const changed = field(); mutate(changed);
    assert.throws(() => patchBody(changed, "dev", "swiperId"));
  }
});
test("index repair rejects unrelated runtime and field configuration drift", () => {
  const before = {functions: [{name: "requestAccountDeletion", sha256: "same"}], protectedResources: {fields: "old", indexes: "same", rules: "same"}};
  const after = structuredClone(before); after.protectedResources.fields = "new";
  const unrelated = {name: "other-field", ttlConfig: {state: "ACTIVE"}};
  assertPreserved(before, after, [unrelated], [unrelated, field("swiperId", true), field("targetId", true)], "dev");
  assert.throws(() => assertPreserved(before, after, [unrelated], [], "dev"));
  assert.throws(() => assertPreserved(before, after, [unrelated], [{...unrelated, ttlConfig: {state: "DISABLED"}}], "dev"));
  after.functions[0].sha256 = "changed";
  assert.throws(() => assertPreserved(before, after, [unrelated], [unrelated], "dev"));
});
test("production evidence must be successful DEV from the same source run and attempt", () => {
  const env = {GITHUB_SHA: "a".repeat(40), GITHUB_RUN_ID: "123", GITHUB_RUN_ATTEMPT: "1"};
  const receipt = {environment: "dev", sourceSha: env.GITHUB_SHA, runId: "123", runAttempt: "1", fields, ready: true, preserved: true};
  assertDevReceipt(receipt, env);
  for (const [key, value] of Object.entries({environment: "prod", sourceSha: "b".repeat(40), runId: "124", runAttempt: "2", fields: ["swiperId"], ready: false, preserved: false})) {
    assert.throws(() => assertDevReceipt({...receipt, [key]: value}, env));
  }
});
test("workflow orders DEV before protected human PROD and never invokes broad deployment", () => {
  const workflow = fs.readFileSync(".github/workflows/host-deletion-indexes.yml", "utf8");
  assert.match(workflow, /needs: dev/u);
  assert.match(workflow, /environment: prod/u);
  assert.match(workflow, /required_reviewers/u);
  assert.match(workflow, /actions\/runs\/\$GITHUB_RUN_ID\/approvals/u);
  assert.match(workflow, /host-deletion-indexes-dev-\$\{\{ github.run_id \}\}-\$\{\{ github.run_attempt \}\}/u);
  assert.doesNotMatch(workflow, /firebase deploy|--force|continue-on-error|secrets: inherit/u);
});
