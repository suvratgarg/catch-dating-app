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
    /unnecessary composite index adminActionExecutions\|startedAt:DESCENDING,__name__:DESCENDING/u
  );
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
