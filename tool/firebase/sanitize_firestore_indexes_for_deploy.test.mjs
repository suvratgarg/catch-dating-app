import assert from "node:assert/strict";
import test from "node:test";

import {
  isRedundantSingleFieldComposite,
  sanitizeFirestoreIndexesForDeploy,
} from "./sanitize_firestore_indexes_for_deploy.mjs";

const redundant = {
  collectionGroup: "organizerCampaignRecipients",
  queryScope: "COLLECTION",
  fields: [{fieldPath: "providerMessageId", mode: "ASCENDING"}],
};

const composite = {
  collectionGroup: "organizerCampaignRecipients",
  queryScope: "COLLECTION",
  fields: [
    {fieldPath: "campaignId", mode: "ASCENDING"},
    {fieldPath: "status", mode: "ASCENDING"},
  ],
};

test("single-field composite declarations are classified as redundant", () => {
  assert.equal(isRedundantSingleFieldComposite(redundant), true);
  assert.equal(isRedundantSingleFieldComposite(composite), false);
  assert.equal(isRedundantSingleFieldComposite({
    ...redundant,
    queryScope: "COLLECTION_GROUP",
  }), false);
  assert.equal(isRedundantSingleFieldComposite({
    ...redundant,
    fields: [{fieldPath: "embedding", vectorConfig: {dimension: 128}}],
  }), false);
});

test("an obsolete redundant declaration is removed from only the deploy copy", () => {
  const packaged = {indexes: [redundant, composite], fieldOverrides: []};
  const current = {indexes: [composite], fieldOverrides: []};
  const result = sanitizeFirestoreIndexesForDeploy({packaged, current});
  assert.deepEqual(result.document.indexes, [composite]);
  assert.equal(result.removed.length, 1);
  assert.deepEqual(packaged.indexes, [redundant, composite]);
});

test("a declaration still present in current source is never removed", () => {
  const result = sanitizeFirestoreIndexesForDeploy({
    packaged: {indexes: [redundant]},
    current: {indexes: [redundant]},
  });
  assert.deepEqual(result.document.indexes, [redundant]);
  assert.deepEqual(result.removed, []);
});

test("field overrides fail closed instead of assuming a built-in index", () => {
  const fieldOverride = {
    collectionGroup: "organizerCampaignRecipients",
    fieldPath: "providerMessageId",
    indexes: [],
  };
  const result = sanitizeFirestoreIndexesForDeploy({
    packaged: {indexes: [redundant], fieldOverrides: [fieldOverride]},
    current: {indexes: [], fieldOverrides: []},
  });
  assert.deepEqual(result.document.indexes, [redundant]);
  assert.deepEqual(result.removed, []);
});

test("identical historical composite duplicates are removed only from the deploy copy", () => {
  const fieldOverrides = [{collectionGroup: "events", fieldPath: "note", indexes: []}];
  const packaged = {
    indexes: [composite, structuredClone(composite), structuredClone(composite)],
    fieldOverrides,
  };
  const original = structuredClone(packaged);
  const result = sanitizeFirestoreIndexesForDeploy({packaged, current: packaged});
  assert.deepEqual(result.document.indexes, [composite]);
  assert.equal(result.document.indexes[0], packaged.indexes[0]);
  assert.deepEqual(result.document.fieldOverrides, fieldOverrides);
  assert.deepEqual(packaged, original);
  assert.equal(result.duplicates.length, 2);
  assert.deepEqual(result.removed, []);
  const repeated = sanitizeFirestoreIndexesForDeploy({
    packaged: result.document, current: packaged,
  });
  assert.deepEqual(repeated.document, result.document);
  assert.deepEqual(repeated.duplicates, []);
});

test("deduplication retains definitions that differ in any property or field order", () => {
  const indexes = [
    composite,
    {...composite, queryScope: "COLLECTION_GROUP"},
    {...composite, apiScope: "DATASTORE_MODE_API"},
    {...composite, density: "DENSE"},
    {...composite, multikey: true},
    {...composite, fields: [...composite.fields].reverse()},
    {...composite, futureOption: true},
    ...[128, 256].map((dimension) => ({
      ...composite,
      fields: [{fieldPath: "embedding", vectorConfig: {dimension}}],
    })),
  ];
  const result = sanitizeFirestoreIndexesForDeploy({
    packaged: {indexes}, current: {indexes},
  });
  assert.deepEqual(result.document.indexes, indexes);
  assert.deepEqual(result.duplicates, []);
  assert.deepEqual(result.removed, []);
});
