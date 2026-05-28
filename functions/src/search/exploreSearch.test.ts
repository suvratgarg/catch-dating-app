import assert from "node:assert/strict";
import test from "node:test";
import {buildAlgoliaExploreSearchBody} from "./exploreSearch.js";

test("buildAlgoliaExploreSearchBody targets club and event indices", () => {
  const body = buildAlgoliaExploreSearchBody(
    {query: "saket", cityName: "Indore", limit: 12},
    new Date("2026-05-28T10:30:00.000Z")
  );

  assert.equal(body.strategy, "none");
  assert.equal(body.requests.length, 2);
  assert.deepEqual(body.requests[0], {
    indexName: "clubs",
    query: "saket",
    hitsPerPage: 12,
    filters: "location:\"indore\"",
  });
  assert.deepEqual(body.requests[1], {
    indexName: "events",
    query: "saket",
    hitsPerPage: 12,
    filters: "discoveryCityName:\"indore\" AND startTimeEpoch >= 1779964200",
  });
});
