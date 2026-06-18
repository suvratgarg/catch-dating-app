import assert from "node:assert/strict";
import test from "node:test";
import {buildSearchResultCandidateQueue} from "./lib/search_result_ingest_core.mjs";

test("builds normalized candidates and matches existing surface keys", () => {
  const queue = buildSearchResultCandidateQueue([sampleBatch()], {
    dedupeIndex: {
      generatedAt: null,
      dedupeKeys: [
        {
          entityId: "afterfly",
          reason: "luma eventListing surface.",
          strength: "strong",
          type: "surface",
          value: "luma:event:pxgmph3b",
        },
      ],
    },
  });

  assert.equal(queue.summary.batches, 1);
  assert.equal(queue.summary.results, 3);
  assert.equal(queue.summary.candidates, 3);
  assert.equal(queue.summary.matchedExistingEntities, 1);
  assert.deepEqual(queue.summary.platforms, {
    instagram: 1,
    luma: 1,
    news: 1,
  });

  const luma = queue.candidates.find((candidate) => candidate.resultId === "luma-event");
  assert.equal(luma.normalizedKey, "luma:event:pxgmph3b");
  assert.equal(luma.reviewAction, "attach_to_existing_or_curate");
  assert.deepEqual(luma.existingEntityMatches.map((match) => match.entityId), ["afterfly"]);

  const press = queue.candidates.find((candidate) => candidate.resultId === "press");
  assert.equal(press.normalizedKey, null);
  assert.equal(press.reviewAction, "supporting_evidence_only");
  assert.deepEqual(press.diagnostics, ["press_result_is_not_identity_key", "no_identity_dedupe_key"]);
});

test("reports duplicate normalized keys inside a search batch", () => {
  const batch = sampleBatch();
  batch.results.push({
    resultId: "luma-duplicate",
    rank: 4,
    title: "Duplicate Luma",
    url: "https://lu.ma/pxgmph3b",
    snippet: null,
    observedAt: "2026-06-17",
  });
  const queue = buildSearchResultCandidateQueue([batch], {});
  assert.deepEqual(queue.duplicateKeys, [
    {
      candidateIds: [
        "2026-06-17-afterfly-search-fixture:luma-duplicate",
        "2026-06-17-afterfly-search-fixture:luma-event",
      ],
      normalizedKey: "luma:event:pxgmph3b",
    },
  ]);
});

function sampleBatch() {
  return {
    schemaVersion: 1,
    batchId: "2026-06-17-afterfly-search-fixture",
    createdAt: "2026-06-17",
    source: "fixture",
    query: "Afterfly organizer",
    queryIntent: {
      activityKind: "socialRun",
      entityHint: "Afterfly",
      marketSlug: "indore",
    },
    results: [
      {
        resultId: "luma-event",
        rank: 1,
        title: "Afterfly Luma event",
        url: "https://luma.com/pxgmph3b?utm_source=google",
        snippet: "Luma event",
        observedAt: "2026-06-17",
      },
      {
        resultId: "instagram",
        rank: 2,
        title: "Afterfly Instagram",
        url: "https://instagram.com/afterfly.in/",
        snippet: "Instagram profile",
        observedAt: "2026-06-17",
      },
      {
        resultId: "press",
        rank: 3,
        title: "Afterfly press",
        url: "https://lbb.in/mumbai/afterfly-profile/",
        snippet: "Press coverage",
        observedAt: "2026-06-17",
      },
    ],
  };
}
