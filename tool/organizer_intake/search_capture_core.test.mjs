import assert from "node:assert/strict";
import test from "node:test";
import {
  buildSearchResultBatchFromCapture,
  defaultBatchId,
  findSearchPlanEntry,
} from "./lib/search_capture_core.mjs";

const planEntry = {
  candidateId: "afterfly-run-club-indore",
  candidateName: "AFTER FLY",
  categoryId: "social_run_club",
  city: "Indore",
  citySlug: "indore",
  planKind: "candidate_verification",
  renderedQuery: "\"AFTER FLY\" Luma",
  resultFingerprint: "c383931a89d36db6",
  runKey: "web_search|\"after fly\" luma|indore|social_run_club|afterfly-run-club-indore",
};

test("finds plan entries across planned and skipped-fresh buckets", () => {
  const searchPlan = {
    planned: [],
    skippedFresh: [planEntry],
  };
  assert.equal(findSearchPlanEntry(searchPlan, planEntry.runKey), planEntry);
  assert.equal(findSearchPlanEntry(searchPlan, "missing"), null);
});

test("normalizes SerpAPI organic results into a search result batch", () => {
  const batch = buildSearchResultBatchFromCapture({
    capture: {
      organic_results: [
        {
          position: 2,
          title: "AFTER FLY on Instagram",
          link: "https://www.instagram.com/afterfly.in/",
          snippet: "Primary Instagram profile.",
        },
      ],
    },
    capturedAt: "2026-06-17",
    planEntry,
    source: "serp_api",
  });

  assert.equal(batch.batchId, "2026-06-17-afterfly-run-club-indore-c383931a89d36db6");
  assert.equal(batch.source, "serp_api");
  assert.equal(batch.query, "\"AFTER FLY\" Luma");
  assert.deepEqual(batch.queryIntent, {
    activityKind: "socialRun",
    entityHint: "AFTER FLY",
    marketSlug: "indore",
  });
  assert.equal(batch.captureContext.runKey, planEntry.runKey);
  assert.deepEqual(batch.results, [
    {
      resultId: "result-2",
      rank: 2,
      title: "AFTER FLY on Instagram",
      url: "https://www.instagram.com/afterfly.in/",
      snippet: "Primary Instagram profile.",
      observedAt: "2026-06-17",
    },
  ]);
});

test("normalizes Google Custom Search items", () => {
  const batch = buildSearchResultBatchFromCapture({
    capture: {
      items: [
        {
          title: "Luma",
          link: "https://luma.com/pxgmph3b",
          snippet: "Event page.",
        },
      ],
    },
    capturedAt: "2026-06-17",
    planEntry,
    source: "custom_scraper",
  });
  assert.equal(batch.results[0].rank, 1);
  assert.equal(batch.results[0].resultId, "result-1");
});

test("uses deterministic fallback batch ids", () => {
  assert.equal(
    defaultBatchId({...planEntry, candidateId: null}, "2026-06-17"),
    "2026-06-17-social-run-club-indore-c383931a89d36db6"
  );
});

test("rejects empty or malformed captures", () => {
  assert.throws(
    () => buildSearchResultBatchFromCapture({
      capture: {},
      capturedAt: "2026-06-17",
      planEntry,
      source: "fixture",
    }),
    /must contain results/
  );
  assert.throws(
    () => buildSearchResultBatchFromCapture({
      capture: [{title: "Bad", link: "not a url"}],
      capturedAt: "2026-06-17",
      planEntry,
      source: "fixture",
    }),
    /invalid URL/
  );
});
