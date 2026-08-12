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
