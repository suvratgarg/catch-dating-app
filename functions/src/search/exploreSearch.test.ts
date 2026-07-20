import assert from "node:assert/strict";
import test from "node:test";
import {buildAlgoliaExploreSearchBody} from "./exploreSearch.js";

test("Algolia Explore targets organizer and event indices", () => {
  const body = buildAlgoliaExploreSearchBody(
    {query: "saket", cityName: "in-mp-indore", limit: 12},
    new Date("2026-05-28T10:30:00.000Z")
  );

  assert.equal(body.strategy, "none");
  assert.equal(body.requests.length, 2);
  assert.deepEqual(body.requests[0], {
    indexName: "organizers",
    query: "saket",
    hitsPerPage: 12,
    filters: "locationMarketId:\"in-mp-indore\"",
  });
  assert.deepEqual(body.requests[1], {
    indexName: "events",
    query: "saket",
    hitsPerPage: 12,
    filters: "discoveryMarketId:\"in-mp-indore\"" +
      " AND startTimeEpoch >= 1779964200",
  });
});
