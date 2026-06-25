import assert from "node:assert/strict";
import test from "node:test";
import {buildSourceMentionResolution} from "./lib/source_mention_resolution_core.mjs";

test("source mention resolver auto-attaches hard event URL duplicates", () => {
  const resolution = buildSourceMentionResolution({
    externalEventCandidateQueue: eventQueue([
      eventCandidate({
        candidateId: "cntraveler:result-1",
        eventUrl: "https://events.example.com/rooftop-mixer?utm_source=cntraveler",
        sourceUrl: "https://cntraveler.example/mumbai-events",
        title: "Rooftop Singles Mixer",
      }),
      eventCandidate({
        candidateId: "vogue:result-2",
        eventUrl: "https://events.example.com/rooftop-mixer?utm_source=vogue",
        sourceUrl: "https://vogue.example/weekend-guide",
        title: "Singles Mixer at Four Seasons",
      }),
    ]),
  });

  assert.equal(resolution.extractedMentions.summary.eventMentions, 2);
  assert.equal(resolution.resolutionClusters.summary.clusters, 1);
  assert.equal(resolution.resolutionClusters.clusters[0].resolutionState, "auto_attach");
  assert.match(
    resolution.resolutionClusters.clusters[0].hardSignals.join(" "),
    /hard:eventUrl/
  );
});

test("source mention resolver preserves oversized hard-key duplicate blocks", () => {
  const resolution = buildSourceMentionResolution({
    externalEventCandidateQueue: eventQueue(
      Array.from({length: 31}, (_, index) =>
        eventCandidate({
          candidateId: `source-${index}:result-1`,
          eventUrl: `https://events.example.com/rooftop-mixer?utm_source=${index}`,
          sourceUrl: `https://publisher-${index}.example/mumbai-weekend`,
          title: `Rooftop Singles Mixer ${index}`,
        })
      )
    ),
    policy: {
      ...defaultPolicy(),
      thresholds: {
        ...defaultPolicy().thresholds,
        maxPairsPerBlockingKey: 10,
      },
    },
  });

  assert.equal(resolution.resolutionClusters.summary.clusters, 1);
  assert.equal(resolution.resolutionClusters.clusters[0].resolutionState, "auto_attach");
  assert.equal(resolution.resolutionClusters.summary.candidatePairs, 30);
  assert.match(resolution.resolutionClusters.warnings.join("\n"), /oversized hard block/);
});

test("source mention resolver queues editorial-style fuzzy duplicates for review", () => {
  const resolution = buildSourceMentionResolution({
    externalEventCandidateQueue: eventQueue([
      eventCandidate({
        candidateId: "cntraveler:result-4",
        eventUrl: null,
        sourceUrl: "https://cntraveler.example/mumbai-weekend",
        title: "Rooftop Singles Mixer",
        venueName: "AER",
      }),
      eventCandidate({
        candidateId: "vogue:result-2",
        eventUrl: null,
        sourceUrl: "https://vogue.example/mumbai-weekend",
        title: "Singles Mixer at Four Seasons",
        venueName: "Four Seasons Mumbai",
      }),
    ]),
  });

  assert.equal(resolution.resolutionClusters.summary.clusters, 1);
  const cluster = resolution.resolutionClusters.clusters[0];
  assert.equal(cluster.resolutionState, "needs_human_review");
  assert.equal(cluster.llmReview.status, "eligible");
  assert.deepEqual(cluster.conflictingSignals, ["different_venue"]);
  assert.equal(resolution.reviewPackets.summary.humanReviewRequired, 1);
});

test("source mention resolver keeps unrelated blocked mentions as singletons", () => {
  const resolution = buildSourceMentionResolution({
    externalEventCandidateQueue: eventQueue([
      eventCandidate({
        candidateId: "one:result-1",
        citySlug: "mumbai",
        eventUrl: "https://events.example.com/board-games-social",
        startAt: "2026-07-04T14:00:00+05:30",
        title: "Board Games Social",
      }),
      eventCandidate({
        candidateId: "two:result-1",
        citySlug: "indore",
        eventUrl: "https://events.example.com/supper-club-dinner",
        startAt: "2026-07-11T14:00:00+05:30",
        title: "Supper Club Dinner",
      }),
    ]),
  });

  assert.equal(resolution.resolutionClusters.summary.clusters, 2);
  assert.equal(resolution.resolutionClusters.summary.candidatePairs, 0);
  assert.equal(resolution.resolutionClusters.summary.singletonClusters, 2);
});

test("source mention resolver creates organizer candidates from search surfaces", () => {
  const resolution = buildSourceMentionResolution({
    searchResultCandidateQueue: searchQueue([
      {
        batchId: "2026-06-24-run-club-mumbai",
        candidateId: "2026-06-24-run-club-mumbai:result-1",
        canonicalUrl: "https://instagram.com/mumbairunclub",
        diagnostics: [],
        existingEntityMatches: [],
        normalizedKey: "instagram:mumbairunclub",
        observedAt: "2026-06-24",
        platform: "instagram",
        query: "run club Mumbai",
        queryIntent: {activityKind: "socialRun", marketSlug: "mumbai"},
        resultId: "result-1",
        snippet: "Mumbai social runs.",
        surfaceKind: "socialProfile",
        suggestedSurface: {normalizedKey: "instagram:mumbairunclub"},
        title: "Mumbai Run Club",
        url: "https://instagram.com/mumbairunclub?igshid=abc",
      },
    ]),
  });

  assert.equal(resolution.sourceArtifacts.summary.searchResultBatches, 1);
  assert.equal(resolution.extractedMentions.summary.organizerMentions, 1);
  assert.equal(resolution.resolutionCandidates.summary.hardKeyedCandidates, 1);
});

function eventQueue(candidates) {
  return {
    candidates,
    generatedFrom: {batches: ["editorial-fixture"]},
    summary: {candidates: candidates.length},
  };
}

function searchQueue(candidates) {
  return {
    candidates,
    generatedFrom: {batches: ["search-fixture"]},
    summary: {candidates: candidates.length},
  };
}

function defaultPolicy() {
  return {
    schemaVersion: 1,
    policyId: "test-source-mention-resolution-v1",
    status: "draft",
    summary: "test policy",
    canonicalBoundary: {
      generatedCandidates: "private",
      organizerCanonicalTarget: "clubs",
      eventCanonicalTarget: "external events",
      platformVerifiedMeaning: "claimed only",
    },
    hardKeyPolicy: {
      stableProviderEventPlatforms: ["luma"],
      note: "test",
    },
    blockingKeys: [],
    signalWeights: {
      hardKeyMatch: 1,
      sameCanonicalUrl: 0.95,
      sameProviderEvent: 0.95,
      sameSurfaceKey: 0.95,
      sameDate: 0.24,
      sameCity: 0.12,
      sameVenue: 0.18,
      sameOrganizer: 0.18,
      titleSimilarity: 0.22,
      sameCategory: 0.06,
      conflictingDate: -0.45,
      conflictingCity: -0.3,
      conflictingVenue: -0.12,
    },
    thresholds: {
      autoAttach: 0.9,
      probableDuplicate: 0.72,
      needsHumanReview: 0.45,
      llmAdjudicationMinScore: 0.45,
      maxClusterSizeForLlm: 8,
      maxPairsPerBlockingKey: 400,
    },
    llm: {
      status: "disabled",
      extractionModelEnv: "LLM_EXTRACTION_MODEL",
      adjudicationModelEnv: "LLM_DEDUPE_MODEL",
      apiKeyEnv: "OPENAI_API_KEY",
      cacheRoot: "tool/organizer_intake/llm_cache",
      promptVersions: {
        extraction: "event-mention-extract-v1",
        adjudication: "event-cluster-adjudicate-v1",
      },
      costControls: [],
    },
  };
}

function eventCandidate(overrides) {
  return {
    batchId: "editorial-fixture",
    blockers: [],
    candidateId: "source:result-1",
    description: "Editorial mention.",
    endAt: "2026-07-04T17:00:00+05:30",
    entityId: "mumbai-social-host",
    eventUrl: "https://events.example.com/one",
    imageUrl: null,
    importReadiness: "blocked",
    importState: "blocked_by_policy",
    location: {
      address: "Four Seasons Mumbai",
      citySlug: "mumbai",
      countryCode: "IN",
      latitude: null,
      longitude: null,
      name: "Four Seasons Mumbai",
      placeId: null,
    },
    normalizedEventKey: "mumbai-social-host:2026-07-04T14:00:00+05:30:rooftop-singles-mixer",
    platform: "editorial",
    priceText: null,
    reviewStatus: "needs_admin_review",
    sourceEventId: "result-1",
    sourceEventKey: "editorial:event:result-1",
    sourceStatus: "scheduled",
    sourceUrl: "https://example.com/list",
    startAt: "2026-07-04T14:00:00+05:30",
    surfaceId: "editorial-surface",
    timezone: "Asia/Kolkata",
    title: "Rooftop Singles Mixer",
    ...overrides,
    location: {
      address: overrides.venueName ?? "Four Seasons Mumbai",
      citySlug: overrides.citySlug ?? "mumbai",
      countryCode: "IN",
      latitude: null,
      longitude: null,
      name: overrides.venueName ?? "Four Seasons Mumbai",
      placeId: overrides.placeId ?? null,
    },
  };
}
