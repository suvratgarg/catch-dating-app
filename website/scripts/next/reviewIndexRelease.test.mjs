import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {assertIndexSource, indexNeedsCreation, assertReviewIndexReady, assertUnselectedIndexesPreserved, reviewIndex} from "./reviewIndexRelease.mjs";
const live = (state = "READY") => ({name: "projects/catch-dating-app-64e51/databases/(default)/collectionGroups/reviews/indexes/expected", queryScope: "COLLECTION", state,
  fields: [...reviewIndex.fields.map(({fieldPath, mode}) => ({fieldPath, order: mode})), {fieldPath: "__name__", order: "DESCENDING"}]});
test("index release permits exactly the checked-in organiser-review definition", () => {
  const document = JSON.parse(fs.readFileSync(new URL("../../../firestore.indexes.json", import.meta.url)));
  assertIndexSource(document);
  assert.throws(() => assertIndexSource({indexes: []}));
  assert.throws(() => assertIndexSource({indexes: [reviewIndex, reviewIndex]}));
  assert.throws(() => assertIndexSource({indexes: [{...reviewIndex, queryScope: "COLLECTION_GROUP"}]}));
});
test("existing, building and failed indexes cannot cause duplicate creation or early promotion", () => {
  assert.equal(indexNeedsCreation([]), true);
  assert.equal(indexNeedsCreation([live()]), false); assertReviewIndexReady([live()]);
  assert.equal(indexNeedsCreation([live("CREATING")]), false);
  assert.throws(() => assertReviewIndexReady([live("CREATING")]));
  assert.throws(() => assertReviewIndexReady([]));
  assert.throws(() => indexNeedsCreation([live("NEEDS_REPAIR")]));
  assert.throws(() => indexNeedsCreation([live(), live()]));
});
test("postconditions preserve unselected index identities and fields", () => {
  const other = {...live(), name: live().name.replace("expected", "other"), fields: [{fieldPath: "eventId", order: "ASCENDING"}, {fieldPath: "createdAt", order: "DESCENDING"}, {fieldPath: "__name__", order: "DESCENDING"}]};
  assertUnselectedIndexesPreserved([other], [other, live()]);
  assert.throws(() => assertUnselectedIndexesPreserved([other], [live()]));
  assert.throws(() => assertUnselectedIndexesPreserved([other], [{...other, fields: live().fields}]));
});
test("the only index mutation retains protected production review and both backend locks", () => {
  const workflow = fs.readFileSync(new URL("../../../.github/workflows/website-review-index.yml", import.meta.url), "utf8");
  assert.match(workflow, /environment: prod\n/u);
  assert.match(workflow, /group: backend-delivery/u); assert.match(workflow, /group: firebase-prod/u);
  assert.ok(workflow.indexOf("reviewIndexRelease.mjs authorize") < workflow.indexOf("google-github-actions/auth"));
  assert.doesNotMatch(workflow, /prod-hosting|firebase deploy|--force|workflow_run|repository_dispatch/u);
  const source = fs.readFileSync(new URL("./reviewIndexRelease.mjs", import.meta.url), "utf8");
  assert.equal((source.match(/"composite", "create"/gu) ?? []).length, 1);
  assert.doesNotMatch(source, /"delete"|"update"|--force/u);
  assert.match(source, /--collection-group=reviews/u);
  const promotion = fs.readFileSync(new URL("../../../.github/workflows/website-next-promote.yml", import.meta.url), "utf8");
  assert.ok(promotion.indexOf("assertReviewIndexReady(gcloudIndexList") < promotion.indexOf("gcloud run deploy"));
});
