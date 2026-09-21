import assert from "node:assert/strict";
import test from "node:test";

import {
  canonicalIndex,
  parseIndexContracts,
  requiresCompositeIndexContract,
  validateConfiguredIndexes,
  validateContracts,
} from "./check_firestore_query_indexes.mjs";

const indexConfig = {
  indexes: [
    {
      collectionGroup: "events",
      fields: [
        {fieldPath: "marketId", mode: "ASCENDING"},
        {fieldPath: "startTime", mode: "ASCENDING"},
      ],
    },
  ],
};

test("known-good repository contract resolves to a configured index", () => {
  const source = `
Future<void> load() async {
  // firestore-index: events (marketId:ASCENDING,startTime:ASCENDING)
  await events.where('marketId', isEqualTo: 'mumbai').orderBy('startTime').get();
}
`;
  const result = validateContracts({
    sources: [{path: "lib/events/data/repository.dart", contents: source}],
    indexConfig,
  });
  assert.deepEqual(result.errors, []);
  assert.equal(result.contractCount, 1);
});

test("known-bad missing composite index is detected", () => {
  const source = `
Future<void> load() async {
  // firestore-index: events (status:ASCENDING,startTime:ASCENDING)
  await events.where('status', isEqualTo: 'active').orderBy('startTime').get();
}
`;
  const result = validateContracts({
    sources: [{path: "lib/events/data/repository.dart", contents: source}],
    indexConfig,
  });
  assert.match(result.errors.join("\n"), /missing firestore\.indexes\.json entry/u);
});

test("known-bad uncontracted composite query builder is detected", () => {
  const source = `
Future<void> load() async {
  await events.where('status', isEqualTo: 'active').orderBy('startTime').get();
}
`;
  assert.equal(requiresCompositeIndexContract(source), true);
  const result = validateContracts({
    sources: [{path: "lib/events/data/repository.dart", contents: source}],
    indexConfig,
  });
  assert.match(result.errors.join("\n"), /has no firestore-index contract/u);
});

test("known-bad unnecessary single-field composite index is detected", () => {
  const errors = validateConfiguredIndexes({
    indexes: [
      {
        collectionGroup: "organizerCampaignRecipients",
        fields: [
          {fieldPath: "providerMessageId", mode: "ASCENDING"},
        ],
      },
      {
        collectionGroup: "adminActionExecutions",
        fields: [
          {fieldPath: "startedAt", mode: "DESCENDING"},
          {fieldPath: "__name__", mode: "DESCENDING"},
        ],
      },
    ],
  });
  assert.match(
    errors.join("\n"),
    /unnecessary composite index organizerCampaignRecipients\|providerMessageId:ASCENDING/u
  );
  assert.match(
    errors.join("\n"),
    /unnecessary composite index adminActionExecutions\|startedAt:DESCENDING,__name__:DESCENDING/u
  );
});

test("single-field vector indexes are not classified as built-in indexes", () => {
  const errors = validateConfiguredIndexes({
    indexes: [{
      collectionGroup: "profiles",
      fields: [{fieldPath: "embedding", vectorConfig: {dimension: 128}}],
    }],
  });
  assert.deepEqual(errors, []);
});

test("known-bad duplicate composite index is detected", () => {
  const duplicate = {
    collectionGroup: "organizerFormResponses",
    queryScope: "COLLECTION",
    fields: [
      {fieldPath: "organizerId", mode: "ASCENDING"},
      {fieldPath: "submittedAt", mode: "ASCENDING"},
      {fieldPath: "__name__", mode: "ASCENDING"},
    ],
  };
  const result = validateContracts({
    sources: [],
    indexConfig: {indexes: [duplicate, structuredClone(duplicate)]},
  });
  assert.deepEqual(result.errors, [
    "firestore.indexes.json: duplicate composite index " +
      "organizerFormResponses at entries 1 and 2; " +
      "declare each deployable index only once",
  ]);
});

test("duplicate detection shares deployment normalization for aliases and implicit name", () => {
  const original = indexConfig.indexes[0];
  const equivalent = {
    ...original,
    queryScope: "COLLECTION",
    apiScope: "ANY_API",
    fields: [
      ...original.fields.map(({fieldPath, mode}) => ({fieldPath, order: mode})),
      {fieldPath: "__name__", order: "ASCENDING"},
    ],
  };
  assert.match(
    validateConfiguredIndexes({indexes: [original, equivalent]}).join("\n"),
    /duplicate composite index events at entries 1 and 2/u
  );
});

test("distinct index scopes, field order, direction and vector dimensions remain valid", () => {
  const original = indexConfig.indexes[0];
  const indexes = [
    original,
    {...original, queryScope: "COLLECTION_GROUP"},
    {...original, apiScope: "DATASTORE_MODE_API"},
    {...original, fields: [...original.fields].reverse()},
    {...original, fields: [
      original.fields[0], {fieldPath: "startTime", order: "DESCENDING"},
    ]},
    ...[128, 256].map((dimension) => ({
      collectionGroup: "profiles",
      fields: [{fieldPath: "embedding", vectorConfig: {dimension}}],
    })),
  ];
  assert.deepEqual(validateConfiguredIndexes({indexes}), []);
});

test("contract parser preserves ordered and array index modes", () => {
  const source =
    "// firestore-index: events " +
    "(marketId:ASCENDING,cohorts:CONTAINS,startTime:DESCENDING)";
  const [contract] = parseIndexContracts(source);
  assert.equal(
    canonicalIndex(contract.collectionGroup, contract.fields),
    "events|marketId:ASCENDING,cohorts:CONTAINS,startTime:DESCENDING"
  );
});
