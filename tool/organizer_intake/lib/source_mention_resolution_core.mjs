import crypto from "node:crypto";

const stableProviderEventPlatforms = new Set(["eventbrite", "luma", "meetup"]);

export const defaultSourceMentionResolutionPolicy = {
  schemaVersion: 1,
  policyId: "source-mention-resolution-v1",
  status: "draft",
  summary:
    "Resolve crawler/editorial organizer and event mentions before canonical Firestore projection.",
  canonicalBoundary: {
    generatedCandidates:
      "Source artifacts, extracted mentions, resolution candidates, and clusters are private intake artifacts.",
    organizerCanonicalTarget:
      "Reviewed organizer clusters may project to clubs/{clubId} only through publication review and createClub-compatible contracts.",
    eventCanonicalTarget:
      "Reviewed event clusters may project to read-only external event preflight or events/{eventId} only after import policy approval.",
    platformVerifiedMeaning:
      "Platform verified means claimed/owner-controlled on Catch; human-reviewed accuracy is tracked separately as reviewVerified.",
  },
  hardKeyPolicy: {
    stableProviderEventPlatforms: [...stableProviderEventPlatforms].sort(),
    note:
      "Provider event IDs are hard keys only for platforms whose source event IDs are stable outside one crawl batch. Editorial/import batch row IDs are not hard provider keys.",
  },
  blockingKeys: [
    {id: "hard:eventUrl", entityType: "event", strength: "hard"},
    {id: "hard:providerEvent", entityType: "event", strength: "hard"},
    {id: "date-city", entityType: "event", strength: "blocking"},
    {id: "date-venue", entityType: "event", strength: "blocking"},
    {id: "date-organizer", entityType: "event", strength: "blocking"},
    {id: "title-city", entityType: "event", strength: "blocking"},
    {id: "week-category-city", entityType: "event", strength: "broad"},
    {id: "hard:surface", entityType: "organizer", strength: "hard"},
    {id: "organizer-name-city", entityType: "organizer", strength: "blocking"},
    {id: "organizer-domain", entityType: "organizer", strength: "blocking"},
  ],
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
    costControls: [
      "Never call from the React admin app.",
      "Hash normalized prompt inputs and reuse cached JSON outputs.",
      "Send short reviewed excerpts or compact cluster records, not whole pages.",
      "Only send ambiguous clusters under maxClusterSizeForLlm.",
      "Validate JSON output before it can enter generated intake artifacts.",
    ],
  },
};

export function buildSourceMentionResolution({
  externalEventCandidateQueue = emptyExternalEventCandidateQueue(),
  policy = defaultSourceMentionResolutionPolicy,
  searchResultCandidateQueue = emptySearchResultCandidateQueue(),
} = {}) {
  const sourceArtifacts = buildSourceArtifacts({
    externalEventCandidateQueue,
    searchResultCandidateQueue,
  });
  const extractedMentions = buildExtractedMentions({
    externalEventCandidateQueue,
    searchResultCandidateQueue,
  });
  const resolutionCandidates = buildResolutionCandidates({
    mentions: extractedMentions.mentions,
    policy,
  });
  const pairResult = buildCandidatePairs({
    candidates: resolutionCandidates.candidates,
    policy,
  });
  const clusterResult = buildResolutionClusters({
    candidates: resolutionCandidates.candidates,
    candidatePairs: pairResult.candidatePairs,
    pairWarnings: pairResult.warnings,
    policy,
  });
  const reviewPackets = buildReviewPackets({
    clusters: clusterResult.clusters,
    policy,
  });
  return {
    sourceArtifacts,
    extractedMentions,
    resolutionCandidates: {
      ...resolutionCandidates,
      blockingKeyStats: pairResult.blockingKeyStats,
    },
    resolutionClusters: clusterResult,
    reviewPackets,
    resolutionPolicy: policy,
  };
}

function buildSourceArtifacts({
  externalEventCandidateQueue,
  searchResultCandidateQueue,
}) {
  const artifacts = new Map();
  for (const candidate of searchResultCandidateQueue.candidates ?? []) {
    const artifactId = `search-batch:${candidate.batchId}`;
    ensureArtifact(artifacts, artifactId, {
      artifactId,
      artifactKind: "search_result_batch",
      sourceType: "search_result",
      batchId: candidate.batchId,
      sourceUrl: null,
      publisher: candidate.platform,
      query: candidate.query,
      citySlug: candidate.queryIntent?.marketSlug ?? null,
      categoryId: candidate.queryIntent?.activityKind ?? null,
      candidateIds: [],
      mentionIds: [],
      attributionUrls: [],
    });
    addArtifactReference(artifacts.get(artifactId), {
      attributionUrl: candidate.url,
      candidateId: candidate.candidateId,
      mentionId: mentionIdFor("organizer", candidate.candidateId),
    });
  }
  for (const candidate of externalEventCandidateQueue.candidates ?? []) {
    const artifactId = `event-batch:${candidate.batchId}`;
    ensureArtifact(artifacts, artifactId, {
      artifactId,
      artifactKind: "event_source_batch",
      sourceType: candidate.platform,
      batchId: candidate.batchId,
      sourceUrl: candidate.sourceUrl ?? null,
      publisher: candidate.platform,
      query: null,
      citySlug: candidate.location?.citySlug ?? null,
      categoryId: activityKindForEventCandidate(candidate),
      candidateIds: [],
      mentionIds: [],
      attributionUrls: [],
    });
    addArtifactReference(artifacts.get(artifactId), {
      attributionUrl: candidate.eventUrl ?? candidate.sourceUrl,
      candidateId: candidate.candidateId,
      mentionId: mentionIdFor("event", candidate.candidateId),
    });
  }
  const list = [...artifacts.values()].sort((a, b) =>
    a.artifactId.localeCompare(b.artifactId)
  );
  return {
    schemaVersion: 1,
    generatedFrom: {
      searchResultCandidateQueue:
        "tool/organizer_intake/generated/search_result_candidate_queue.json",
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
    },
    summary: {
      artifacts: list.length,
      searchResultBatches:
        list.filter((artifact) => artifact.artifactKind === "search_result_batch").length,
      eventSourceBatches:
        list.filter((artifact) => artifact.artifactKind === "event_source_batch").length,
      attributionUrls: new Set(list.flatMap((artifact) => artifact.attributionUrls)).size,
    },
    artifacts: list,
  };
}

function buildExtractedMentions({
  externalEventCandidateQueue,
  searchResultCandidateQueue,
}) {
  const mentions = [
    ...(searchResultCandidateQueue.candidates ?? []).map(organizerMentionForSearchCandidate),
    ...(externalEventCandidateQueue.candidates ?? []).map(eventMentionForEventCandidate),
  ].sort(compareMentions);
  return {
    schemaVersion: 1,
    generatedFrom: {
      searchResultCandidateQueue:
        "tool/organizer_intake/generated/search_result_candidate_queue.json",
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
    },
    extractionPolicy: {
      llmExtractionEnabled: false,
      deterministicExtractors: [
        "search_result_url_surface",
        "reviewed_event_source_batch",
      ],
      note:
        "LLM extraction can create mentions in this same schema after prompt/cache validation, but is disabled by default.",
    },
    summary: {
      mentions: mentions.length,
      eventMentions: mentions.filter((mention) => mention.entityType === "event").length,
      organizerMentions:
        mentions.filter((mention) => mention.entityType === "organizer").length,
      editorialMentions:
        mentions.filter((mention) => mention.source.sourceType === "news").length,
      llmExtractedMentions:
        mentions.filter((mention) => mention.extraction.method === "llm").length,
    },
    mentions,
  };
}

function buildResolutionCandidates({mentions, policy}) {
  const candidates = mentions.map((mention) => {
    const blockingKeys = blockingKeysForMention(mention);
    return {
      candidateId: `resolution:${mention.mentionId}`,
      mentionId: mention.mentionId,
      entityType: mention.entityType,
      extractionMethod: mention.extraction.method,
      displayName: mention.fields.title ?? mention.fields.organizerName ?? mention.source.title,
      citySlug: mention.fields.citySlug,
      date: datePart(mention.fields.startAt),
      categoryId: mention.fields.categoryId,
      normalized: normalizedFactsForMention(mention),
      hardKeys: blockingKeys.filter((key) => key.strength === "hard"),
      blockingKeys,
      source: mention.source,
      citations: mention.citations,
      publishBoundary: publishBoundaryForMention(mention, policy),
    };
  }).sort(compareResolutionCandidates);
  return {
    schemaVersion: 1,
    generatedFrom: {
      extractedMentions:
        "tool/organizer_intake/generated/source_mention_extracted_mentions.json",
      resolutionPolicy:
        "tool/organizer_intake/generated/source_mention_resolution_policy.json",
    },
    summary: {
      candidates: candidates.length,
      eventCandidates:
        candidates.filter((candidate) => candidate.entityType === "event").length,
      organizerCandidates:
        candidates.filter((candidate) => candidate.entityType === "organizer").length,
      hardKeyedCandidates:
        candidates.filter((candidate) => candidate.hardKeys.length > 0).length,
      blockingKeys:
        candidates.reduce((sum, candidate) => sum + candidate.blockingKeys.length, 0),
    },
    candidates,
  };
}

function buildCandidatePairs({candidates, policy}) {
  const warnings = [];
  const byBlockingKey = new Map();
  for (const candidate of candidates) {
    for (const key of candidate.blockingKeys) {
      const mapKey = `${candidate.entityType}:${key.key}`;
      if (!byBlockingKey.has(mapKey)) byBlockingKey.set(mapKey, []);
      byBlockingKey.get(mapKey).push(candidate);
    }
  }
  const pairIds = new Set();
  const candidatePairs = [];
  const maxPairs = policy.thresholds.maxPairsPerBlockingKey;
  for (const [blockingKey, blockCandidates] of [...byBlockingKey.entries()]
    .sort(([left], [right]) => left.localeCompare(right))) {
    const possiblePairs = (blockCandidates.length * (blockCandidates.length - 1)) / 2;
    if (possiblePairs > maxPairs) {
      if (isHardBlockingKey(blockingKey)) {
        warnings.push(
          `${blockingKey}: reduced oversized hard block with ${blockCandidates.length} candidates and ${possiblePairs} possible pairs to ${blockCandidates.length - 1} star pairs.`
        );
        for (let rightIndex = 1; rightIndex < blockCandidates.length; rightIndex += 1) {
          addCandidatePair({
            candidatePairs,
            left: blockCandidates[0],
            pairIds,
            policy,
            right: blockCandidates[rightIndex],
          });
        }
        continue;
      }
      warnings.push(
        `${blockingKey}: skipped oversized soft block with ${blockCandidates.length} candidates and ${possiblePairs} possible pairs.`
      );
      continue;
    }
    for (let leftIndex = 0; leftIndex < blockCandidates.length; leftIndex += 1) {
      for (let rightIndex = leftIndex + 1; rightIndex < blockCandidates.length; rightIndex += 1) {
        addCandidatePair({
          candidatePairs,
          left: blockCandidates[leftIndex],
          pairIds,
          policy,
          right: blockCandidates[rightIndex],
        });
      }
    }
  }
  candidatePairs.sort((a, b) =>
    b.score - a.score || a.pairId.localeCompare(b.pairId)
  );
  return {
    blockingKeyStats: [...byBlockingKey.entries()]
      .map(([key, values]) => ({
        key,
        candidates: values.length,
        possiblePairs: (values.length * (values.length - 1)) / 2,
      }))
      .sort((a, b) => b.candidates - a.candidates || a.key.localeCompare(b.key)),
    candidatePairs,
    warnings,
  };
}

function addCandidatePair({
  candidatePairs,
  left,
  pairIds,
  policy,
  right,
}) {
  const pairId = pairIdFor(left.candidateId, right.candidateId);
  if (pairIds.has(pairId)) return;
  pairIds.add(pairId);
  const scorecard = scorePair(left, right, policy);
  if (scorecard.score >= policy.thresholds.needsHumanReview ||
    scorecard.hardSignals.length > 0 ||
    scorecard.conflictingSignals.length > 0) {
    candidatePairs.push({
      pairId,
      leftCandidateId: left.candidateId,
      rightCandidateId: right.candidateId,
      entityType: left.entityType,
      score: scorecard.score,
      scoreBand: scoreBand(scorecard.score, policy),
      blockingKeys: sharedBlockingKeys(left, right),
      hardSignals: scorecard.hardSignals,
      matchingSignals: scorecard.matchingSignals,
      conflictingSignals: scorecard.conflictingSignals,
      reason: scorecard.reason,
    });
  }
}

function isHardBlockingKey(blockingKey) {
  return blockingKey.includes(":hard:");
}

function buildResolutionClusters({
  candidates,
  candidatePairs,
  pairWarnings,
  policy,
}) {
  const candidateById = new Map(candidates.map((candidate) => [candidate.candidateId, candidate]));
  const union = new UnionFind(candidates.map((candidate) => candidate.candidateId));
  for (const pair of candidatePairs) {
    if (pair.score >= policy.thresholds.needsHumanReview || pair.hardSignals.length > 0) {
      union.union(pair.leftCandidateId, pair.rightCandidateId);
    }
  }
  const grouped = new Map();
  for (const candidate of candidates) {
    const root = union.find(candidate.candidateId);
    if (!grouped.has(root)) grouped.set(root, []);
    grouped.get(root).push(candidate);
  }
  const pairsByCluster = new Map();
  for (const pair of candidatePairs) {
    const root = union.find(pair.leftCandidateId);
    if (!pairsByCluster.has(root)) pairsByCluster.set(root, []);
    pairsByCluster.get(root).push(pair);
  }
  const clusters = [...grouped.entries()].map(([root, clusterCandidates]) =>
    clusterFor({
      clusterCandidates: clusterCandidates.sort(compareResolutionCandidates),
      pairs: (pairsByCluster.get(root) ?? []).sort((a, b) =>
        b.score - a.score || a.pairId.localeCompare(b.pairId)
      ),
      policy,
      root,
    })
  ).sort(compareClusters);
  const llmReviewQueue = clusters
    .filter((cluster) =>
      cluster.llmReview.status === "eligible" ||
        cluster.llmReview.status === "recommended"
    )
    .map((cluster) => ({
      clusterId: cluster.clusterId,
      entityType: cluster.entityType,
      mentions: cluster.candidateIds.length,
      deterministicScore: cluster.score,
      status: cluster.llmReview.status,
      promptVersion: policy.llm.promptVersions.adjudication,
      inputHash: hashJson({
        clusterId: cluster.clusterId,
        candidateIds: cluster.candidateIds,
        score: cluster.score,
        conflicts: cluster.conflictingSignals,
      }),
      reason: cluster.llmReview.reason,
    }));
  return {
    schemaVersion: 1,
    generatedFrom: {
      resolutionCandidates:
        "tool/organizer_intake/generated/source_mention_resolution_candidates.json",
      resolutionPolicy:
        "tool/organizer_intake/generated/source_mention_resolution_policy.json",
    },
    summary: {
      clusters: clusters.length,
      singletonClusters:
        clusters.filter((cluster) => cluster.resolutionState === "singleton").length,
      autoAttachClusters:
        clusters.filter((cluster) => cluster.resolutionState === "auto_attach").length,
      probableDuplicateClusters:
        clusters.filter((cluster) => cluster.resolutionState === "probable_duplicate").length,
      needsHumanReviewClusters:
        clusters.filter((cluster) => cluster.resolutionState === "needs_human_review").length,
      llmReviewQueued: llmReviewQueue.length,
      candidatePairs: candidatePairs.length,
      warnings: pairWarnings.length,
    },
    candidatePairs,
    clusters,
    llmReviewQueue,
    warnings: pairWarnings,
    commands: {
      regenerate:
        "node tool/organizer_intake/organizer_intake.mjs",
      llmPromptDryRun:
        "node tool/organizer_intake/llm_source_resolution.mjs --dry-run",
      review:
        "Use admin source-mention resolution panels to confirm same/separate/split/suppress before projection.",
    },
  };
}

function buildReviewPackets({clusters, policy}) {
  const packets = clusters
    .filter((cluster) => cluster.resolutionState !== "singleton" ||
      cluster.candidateIds.length > 0)
    .map((cluster) => ({
      packetId: `source-resolution:${cluster.clusterId}`,
      clusterId: cluster.clusterId,
      entityType: cluster.entityType,
      resolutionState: cluster.resolutionState,
      score: cluster.score,
      recommendedAction: recommendedActionForCluster(cluster),
      humanReviewRequired:
        ["needs_human_review", "probable_duplicate"].includes(cluster.resolutionState),
      llmReview: cluster.llmReview,
      checklist: {
        attributionReviewed: false,
        deterministicSignalsReviewed: false,
        conflictsReviewed: cluster.conflictingSignals.length === 0,
        canonicalProjectionReviewed: false,
        ownerSafeCopyReviewed: false,
      },
      candidateIds: cluster.candidateIds,
      mentionIds: cluster.mentionIds,
      topSignals: cluster.matchingSignals.slice(0, 6),
      conflicts: cluster.conflictingSignals,
      publishBoundary: cluster.publishBoundary,
    }));
  return {
    schemaVersion: 1,
    generatedFrom: {
      resolutionClusters:
        "tool/organizer_intake/generated/source_mention_resolution_clusters.json",
      resolutionPolicy:
        "tool/organizer_intake/generated/source_mention_resolution_policy.json",
    },
    policy: {
      autoAttachThreshold: policy.thresholds.autoAttach,
      humanReviewThreshold: policy.thresholds.needsHumanReview,
      llmStatus: policy.llm.status,
    },
    summary: {
      packets: packets.length,
      humanReviewRequired:
        packets.filter((packet) => packet.humanReviewRequired).length,
      llmReviewRecommended:
        packets.filter((packet) => packet.llmReview.status === "recommended").length,
      autoAttach:
        packets.filter((packet) => packet.resolutionState === "auto_attach").length,
      singleton:
        packets.filter((packet) => packet.resolutionState === "singleton").length,
    },
    packets,
  };
}

function organizerMentionForSearchCandidate(candidate) {
  return {
    mentionId: mentionIdFor("organizer", candidate.candidateId),
    entityType: "organizer",
    source: {
      sourceArtifactId: `search-batch:${candidate.batchId}`,
      sourceCandidateId: candidate.candidateId,
      sourceType: candidate.platform,
      title: candidate.title,
      sourceUrl: candidate.url,
      canonicalUrl: candidate.canonicalUrl,
      observedAt: candidate.observedAt,
      query: candidate.query,
    },
    extraction: {
      method: "deterministic_url_surface",
      extractorVersion: "search-result-surface-v1",
      promptVersion: null,
      model: null,
      inputHash: hashJson({
        candidateId: candidate.candidateId,
        canonicalUrl: candidate.canonicalUrl,
        title: candidate.title,
      }),
    },
    fields: {
      title: candidate.title,
      organizerName: candidate.suggestedSurface?.normalizedKey ?
        organizerNameFromSurface(candidate) :
        candidate.title,
      citySlug: candidate.queryIntent?.marketSlug ?? null,
      categoryId: candidate.queryIntent?.activityKind ?? null,
      officialUrl: candidate.canonicalUrl,
      platform: candidate.platform,
      surfaceKind: candidate.surfaceKind,
      normalizedKey: candidate.normalizedKey,
      description: candidate.snippet ?? null,
      startAt: null,
      venueName: null,
    },
    citations: [
      citation("title", candidate.url, candidate.resultId),
      citation("officialUrl", candidate.url, candidate.resultId),
    ],
    diagnostics: candidate.diagnostics ?? [],
  };
}

function eventMentionForEventCandidate(candidate) {
  return {
    mentionId: mentionIdFor("event", candidate.candidateId),
    entityType: "event",
    source: {
      sourceArtifactId: `event-batch:${candidate.batchId}`,
      sourceCandidateId: candidate.candidateId,
      sourceType: candidate.platform,
      title: candidate.title,
      sourceUrl: candidate.sourceUrl,
      canonicalUrl: candidate.eventUrl,
      observedAt: candidate.startAt,
      query: null,
    },
    extraction: {
      method: "deterministic_event_source",
      extractorVersion: "event-source-batch-v1",
      promptVersion: null,
      model: null,
      inputHash: hashJson({
        candidateId: candidate.candidateId,
        eventUrl: candidate.eventUrl,
        startAt: candidate.startAt,
        title: candidate.title,
      }),
    },
    fields: {
      title: candidate.title,
      organizerName: candidate.entityId,
      citySlug: candidate.location?.citySlug ?? null,
      categoryId: activityKindForEventCandidate(candidate),
      officialUrl: candidate.eventUrl,
      platform: candidate.platform,
      surfaceKind: "eventListing",
      normalizedKey: candidate.sourceEventKey,
      description: candidate.description ?? null,
      startAt: candidate.startAt,
      endAt: candidate.endAt ?? null,
      venueName: candidate.location?.name ?? candidate.location?.address ?? null,
      venueAddress: candidate.location?.address ?? null,
      placeId: candidate.location?.placeId ?? null,
      priceText: candidate.priceText ?? null,
      imageUrl: candidate.imageUrl ?? null,
    },
    citations: [
      citation("title", candidate.eventUrl ?? candidate.sourceUrl, candidate.sourceEventId),
      citation("startAt", candidate.eventUrl ?? candidate.sourceUrl, candidate.sourceEventId),
      citation("venueName", candidate.eventUrl ?? candidate.sourceUrl, candidate.sourceEventId),
    ],
    diagnostics: candidate.diagnostics ?? [],
  };
}

function blockingKeysForMention(mention) {
  if (mention.entityType === "event") return eventBlockingKeys(mention);
  return organizerBlockingKeys(mention);
}

function eventBlockingKeys(mention) {
  const keys = [];
  const date = datePart(mention.fields.startAt);
  const city = slugOrNull(mention.fields.citySlug);
  const venue = normalizeText(mention.fields.placeId ?? mention.fields.venueName);
  const organizer = normalizeText(mention.fields.organizerName);
  const titlePrefix = titleTokenPrefix(mention.fields.title);
  const category = slugOrNull(mention.fields.categoryId);
  const canonicalUrl = canonicalUrlKey(mention.fields.officialUrl);
  const providerId = providerEventKey(mention);
  if (canonicalUrl) keys.push(blockingKey("hard:eventUrl", canonicalUrl, "hard"));
  if (providerId) keys.push(blockingKey("hard:providerEvent", providerId, "hard"));
  if (date && city) keys.push(blockingKey("date-city", `${date}:${city}`, "blocking"));
  if (date && venue) keys.push(blockingKey("date-venue", `${date}:${venue}`, "blocking"));
  if (date && organizer) keys.push(blockingKey("date-organizer", `${date}:${organizer}`, "blocking"));
  if (titlePrefix && city) keys.push(blockingKey("title-city", `${titlePrefix}:${city}`, "blocking"));
  const week = isoWeekKey(date);
  if (week && category && city) keys.push(blockingKey("week-category-city", `${week}:${category}:${city}`, "broad"));
  return uniqueKeys(keys);
}

function organizerBlockingKeys(mention) {
  const keys = [];
  const city = slugOrNull(mention.fields.citySlug);
  const name = normalizeText(mention.fields.organizerName ?? mention.fields.title);
  const surface = mention.fields.normalizedKey;
  const domain = domainKey(mention.fields.officialUrl);
  if (surface) keys.push(blockingKey("hard:surface", surface, "hard"));
  if (name && city) keys.push(blockingKey("organizer-name-city", `${name}:${city}`, "blocking"));
  if (domain) keys.push(blockingKey("organizer-domain", domain, "blocking"));
  return uniqueKeys(keys);
}

function scorePair(left, right, policy) {
  const weights = policy.signalWeights;
  const matchingSignals = [];
  const conflictingSignals = [];
  const hardSignals = [];
  let score = 0;
  const sharedHard = sharedBlockingKeys(left, right)
    .filter((key) => key.startsWith("hard:"));
  if (sharedHard.length > 0) {
    score += weights.hardKeyMatch;
    hardSignals.push(...sharedHard);
  }
  if (left.entityType === "event") {
    score += eventPairScore(left, right, weights, matchingSignals, conflictingSignals);
  } else {
    score += organizerPairScore(left, right, weights, matchingSignals, conflictingSignals);
  }
  const bounded = Math.max(0, Math.min(1, round(score)));
  return {
    score: bounded,
    hardSignals,
    matchingSignals: [...new Set(matchingSignals)].sort(),
    conflictingSignals: [...new Set(conflictingSignals)].sort(),
    reason: reasonForScore(bounded, matchingSignals, conflictingSignals, hardSignals),
  };
}

function eventPairScore(left, right, weights, matchingSignals, conflictingSignals) {
  let score = 0;
  score += exactOrConflict({
    field: "date",
    left: left.normalized.date,
    right: right.normalized.date,
    matchWeight: weights.sameDate,
    conflictWeight: weights.conflictingDate,
    matchingSignals,
    conflictingSignals,
  });
  score += exactOrConflict({
    field: "city",
    left: left.normalized.citySlug,
    right: right.normalized.citySlug,
    matchWeight: weights.sameCity,
    conflictWeight: weights.conflictingCity,
    matchingSignals,
    conflictingSignals,
  });
  score += exactOrConflict({
    field: "venue",
    left: left.normalized.venueName,
    right: right.normalized.venueName,
    matchWeight: weights.sameVenue,
    conflictWeight: weights.conflictingVenue,
    matchingSignals,
    conflictingSignals,
  });
  score += exactSignal({
    field: "organizer",
    left: left.normalized.organizerName,
    right: right.normalized.organizerName,
    weight: weights.sameOrganizer,
    matchingSignals,
  });
  score += exactSignal({
    field: "category",
    left: left.normalized.categoryId,
    right: right.normalized.categoryId,
    weight: weights.sameCategory,
    matchingSignals,
  });
  const similarity = tokenSimilarity(left.normalized.title, right.normalized.title);
  if (similarity > 0) {
    score += weights.titleSimilarity * similarity;
    if (similarity >= 0.66) matchingSignals.push("similar_title");
  }
  return score;
}

function organizerPairScore(left, right, weights, matchingSignals, conflictingSignals) {
  let score = 0;
  score += exactOrConflict({
    field: "city",
    left: left.normalized.citySlug,
    right: right.normalized.citySlug,
    matchWeight: weights.sameCity,
    conflictWeight: weights.conflictingCity,
    matchingSignals,
    conflictingSignals,
  });
  score += exactSignal({
    field: "domain",
    left: left.normalized.domain,
    right: right.normalized.domain,
    weight: weights.sameCanonicalUrl,
    matchingSignals,
  });
  const similarity = tokenSimilarity(left.normalized.organizerName, right.normalized.organizerName);
  if (similarity > 0) {
    score += weights.titleSimilarity * similarity;
    if (similarity >= 0.66) matchingSignals.push("similar_organizer_name");
  }
  return score;
}

function clusterFor({clusterCandidates, pairs, policy, root}) {
  const score = pairs.length > 0 ?
    Math.max(...pairs.map((pair) => pair.score)) :
    0;
  const matchingSignals = uniqueSorted(pairs.flatMap((pair) => pair.matchingSignals));
  const conflictingSignals = uniqueSorted(pairs.flatMap((pair) => pair.conflictingSignals));
  const hardSignals = uniqueSorted(pairs.flatMap((pair) => pair.hardSignals));
  const entityType = clusterCandidates[0]?.entityType ?? "unknown";
  const resolutionState = resolutionStateFor({
    candidateCount: clusterCandidates.length,
    conflictingSignals,
    hardSignals,
    policy,
    score,
  });
  const clusterId = clusterIdFor({
    entityType,
    root,
    candidates: clusterCandidates,
  });
  const llmReview = llmReviewForCluster({
    clusterSize: clusterCandidates.length,
    conflictingSignals,
    policy,
    resolutionState,
    score,
  });
  return {
    clusterId,
    entityType,
    resolutionState,
    score,
    scoreBand: scoreBand(score, policy),
    candidateIds: clusterCandidates.map((candidate) => candidate.candidateId),
    mentionIds: clusterCandidates.map((candidate) => candidate.mentionId),
    displayNames: uniqueSorted(clusterCandidates.map((candidate) => candidate.displayName)),
    cities: uniqueSorted(clusterCandidates.map((candidate) => candidate.citySlug).filter(Boolean)),
    dates: uniqueSorted(clusterCandidates.map((candidate) => candidate.date).filter(Boolean)),
    blockingKeys: uniqueSorted(clusterCandidates.flatMap((candidate) =>
      candidate.blockingKeys.map((key) => key.key)
    )),
    hardSignals,
    matchingSignals,
    conflictingSignals,
    pairIds: pairs.map((pair) => pair.pairId),
    llmReview,
    publishBoundary: publishBoundaryForCluster(clusterCandidates),
  };
}

function resolutionStateFor({
  candidateCount,
  conflictingSignals,
  hardSignals,
  policy,
  score,
}) {
  if (candidateCount <= 1) return "singleton";
  if (hardSignals.length > 0 && conflictingSignals.length === 0) return "auto_attach";
  if (score >= policy.thresholds.autoAttach && conflictingSignals.length === 0) {
    return "auto_attach";
  }
  if (score >= policy.thresholds.probableDuplicate) return "probable_duplicate";
  return "needs_human_review";
}

function llmReviewForCluster({
  clusterSize,
  conflictingSignals,
  policy,
  resolutionState,
  score,
}) {
  if (policy.llm.status !== "enabled") {
    return {
      status: resolutionState === "needs_human_review" || conflictingSignals.length > 0 ?
        "eligible" :
        "not_needed",
      reason: "LLM adjudication is disabled by policy.",
    };
  }
  if (clusterSize > policy.thresholds.maxClusterSizeForLlm) {
    return {status: "blocked_oversized_cluster", reason: "Cluster exceeds LLM size cap."};
  }
  if (score < policy.thresholds.llmAdjudicationMinScore) {
    return {status: "not_needed", reason: "Deterministic score is below LLM threshold."};
  }
  if (resolutionState === "auto_attach" && conflictingSignals.length === 0) {
    return {status: "not_needed", reason: "Hard deterministic match does not need LLM."};
  }
  return {status: "recommended", reason: "Ambiguous cluster is within LLM policy bounds."};
}

class UnionFind {
  constructor(ids) {
    this.parent = new Map(ids.map((id) => [id, id]));
  }

  find(id) {
    const parent = this.parent.get(id) ?? id;
    if (parent === id) return id;
    const root = this.find(parent);
    this.parent.set(id, root);
    return root;
  }

  union(left, right) {
    const leftRoot = this.find(left);
    const rightRoot = this.find(right);
    if (leftRoot !== rightRoot) {
      this.parent.set(rightRoot, leftRoot < rightRoot ? leftRoot : rightRoot);
      this.parent.set(leftRoot, leftRoot < rightRoot ? leftRoot : rightRoot);
    }
  }
}

function emptySearchResultCandidateQueue() {
  return {candidates: [], generatedFrom: {}, summary: {}};
}

function emptyExternalEventCandidateQueue() {
  return {candidates: [], generatedFrom: {}, summary: {}};
}

function ensureArtifact(map, key, artifact) {
  if (!map.has(key)) map.set(key, artifact);
}

function addArtifactReference(artifact, {attributionUrl, candidateId, mentionId}) {
  artifact.candidateIds.push(candidateId);
  artifact.mentionIds.push(mentionId);
  if (attributionUrl) artifact.attributionUrls.push(attributionUrl);
  artifact.candidateIds = uniqueSorted(artifact.candidateIds);
  artifact.mentionIds = uniqueSorted(artifact.mentionIds);
  artifact.attributionUrls = uniqueSorted(artifact.attributionUrls);
}

function normalizedFactsForMention(mention) {
  return {
    title: normalizeText(mention.fields.title),
    organizerName: normalizeText(mention.fields.organizerName),
    citySlug: slugOrNull(mention.fields.citySlug),
    categoryId: slugOrNull(mention.fields.categoryId),
    date: datePart(mention.fields.startAt),
    venueName: normalizeText(mention.fields.placeId ?? mention.fields.venueName),
    domain: domainKey(mention.fields.officialUrl),
    canonicalUrl: canonicalUrlKey(mention.fields.officialUrl),
    providerEvent: providerEventKey(mention),
    surfaceKey: mention.fields.normalizedKey ?? null,
  };
}

function publishBoundaryForMention(mention, policy) {
  return mention.entityType === "event" ?
    policy.canonicalBoundary.eventCanonicalTarget :
    policy.canonicalBoundary.organizerCanonicalTarget;
}

function publishBoundaryForCluster(candidates) {
  const entityTypes = new Set(candidates.map((candidate) => candidate.entityType));
  if (entityTypes.has("event") && entityTypes.has("organizer")) {
    return "Mixed entity clusters are invalid and require manual split before projection.";
  }
  return candidates[0]?.publishBoundary ?? null;
}

function recommendedActionForCluster(cluster) {
  if (cluster.resolutionState === "auto_attach") return "attach_sources_to_cluster";
  if (cluster.resolutionState === "probable_duplicate") return "confirm_same_or_split";
  if (cluster.resolutionState === "needs_human_review") return "review_conflicts_before_projection";
  return "keep_as_single_source_candidate";
}

function blockingKey(type, value, strength) {
  return {type, value, key: `${type}:${value}`, strength};
}

function uniqueKeys(keys) {
  const seen = new Set();
  const result = [];
  for (const key of keys) {
    if (!key.value || seen.has(key.key)) continue;
    seen.add(key.key);
    result.push(key);
  }
  return result.sort((a, b) => a.key.localeCompare(b.key));
}

function sharedBlockingKeys(left, right) {
  const rightKeys = new Set(right.blockingKeys.map((key) => key.key));
  return left.blockingKeys
    .map((key) => key.key)
    .filter((key) => rightKeys.has(key))
    .sort();
}

function exactOrConflict({
  conflictingSignals,
  conflictWeight,
  field,
  left,
  matchingSignals,
  matchWeight,
  right,
}) {
  if (!left || !right) return 0;
  if (left === right) {
    matchingSignals.push(`same_${field}`);
    return matchWeight;
  }
  conflictingSignals.push(`different_${field}`);
  return conflictWeight;
}

function exactSignal({field, left, matchingSignals, right, weight}) {
  if (!left || !right || left !== right) return 0;
  matchingSignals.push(`same_${field}`);
  return weight;
}

function scoreBand(score, policy) {
  if (score >= policy.thresholds.autoAttach) return "auto_attach";
  if (score >= policy.thresholds.probableDuplicate) return "probable_duplicate";
  if (score >= policy.thresholds.needsHumanReview) return "needs_human_review";
  return "low_signal";
}

function reasonForScore(score, matchingSignals, conflictingSignals, hardSignals) {
  if (hardSignals.length > 0) return `Hard key match: ${hardSignals.join(", ")}`;
  const parts = [];
  if (matchingSignals.length > 0) parts.push(`matches ${matchingSignals.join(", ")}`);
  if (conflictingSignals.length > 0) parts.push(`conflicts ${conflictingSignals.join(", ")}`);
  return parts.length > 0 ? `${round(score)} from ${parts.join("; ")}` : "no material overlap";
}

function clusterIdFor({candidates, entityType, root}) {
  const primary = candidates[0];
  const basis = [
    entityType,
    primary?.date,
    primary?.citySlug,
    primary?.displayName,
    root,
  ].filter(Boolean).join(":");
  return `cluster:${slugify(basis).slice(0, 80)}:${hashString(basis).slice(0, 8)}`;
}

function pairIdFor(left, right) {
  return [left, right].sort().join("::");
}

function mentionIdFor(type, candidateId) {
  return `${type}:${candidateId}`;
}

function citation(field, sourceUrl, spanId) {
  return {
    field,
    sourceUrl: sourceUrl ?? null,
    spanId: spanId ?? null,
  };
}

function organizerNameFromSurface(candidate) {
  const key = candidate.suggestedSurface?.normalizedKey ?? "";
  const parts = key.split(":");
  return parts[parts.length - 1]?.replaceAll("-", " ") || candidate.title;
}

function activityKindForEventCandidate(candidate) {
  if (candidate.platform === "luma") return "event_platform";
  return candidate.platform ?? "external_event";
}

function providerEventKey(mention) {
  if (mention.entityType !== "event") return null;
  const platform = slugOrNull(mention.fields.platform);
  if (!stableProviderEventPlatforms.has(platform)) return null;
  const key = String(mention.fields.normalizedKey ?? "").trim();
  if (!key) return null;
  if (key.startsWith(`${platform}:event:`)) return key;
  return `${platform}:event:${slugify(key)}`;
}

function canonicalUrlKey(value) {
  try {
    const url = new URL(String(value ?? ""));
    for (const param of [...url.searchParams.keys()]) {
      if (["fbclid", "gclid", "igshid", "mc_cid", "mc_eid", "ref", "source", "utm_campaign", "utm_content", "utm_medium", "utm_source", "utm_term"].includes(param)) {
        url.searchParams.delete(param);
      }
    }
    url.hash = "";
    url.hostname = url.hostname.toLowerCase().replace(/^www\./, "");
    return url.toString().replace(/\/$/, "");
  } catch {
    return null;
  }
}

function domainKey(value) {
  try {
    return new URL(String(value ?? "")).hostname.toLowerCase().replace(/^www\./, "");
  } catch {
    return null;
  }
}

function datePart(value) {
  return typeof value === "string" && /^\d{4}-\d{2}-\d{2}/.test(value) ?
    value.slice(0, 10) :
    null;
}

function isoWeekKey(date) {
  if (!date) return null;
  const value = new Date(`${date}T00:00:00.000Z`);
  if (Number.isNaN(value.getTime())) return null;
  const day = value.getUTCDay() || 7;
  value.setUTCDate(value.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(value.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((value - yearStart) / 86400000) + 1) / 7);
  return `${value.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

function titleTokenPrefix(value) {
  const tokens = tokenSet(value);
  return tokens.slice(0, 4).join("-");
}

function tokenSimilarity(left, right) {
  const leftTokens = new Set(tokenSet(left));
  const rightTokens = new Set(tokenSet(right));
  if (leftTokens.size === 0 || rightTokens.size === 0) return 0;
  const intersection = [...leftTokens].filter((token) => rightTokens.has(token)).length;
  const union = new Set([...leftTokens, ...rightTokens]).size;
  return intersection / union;
}

function tokenSet(value) {
  const stop = new Set(["a", "an", "and", "at", "by", "for", "in", "of", "on", "the", "to", "with"]);
  return normalizeText(value)
    .split(" ")
    .filter((token) => token.length > 1 && !stop.has(token))
    .sort();
}

function normalizeText(value) {
  return String(value ?? "")
    .normalize("NFKD")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}

function slugOrNull(value) {
  const text = String(value ?? "").trim();
  return text ? slugify(text) : null;
}

function slugify(value) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function compareMentions(left, right) {
  return left.entityType.localeCompare(right.entityType) ||
    left.mentionId.localeCompare(right.mentionId);
}

function compareResolutionCandidates(left, right) {
  return left.entityType.localeCompare(right.entityType) ||
    String(left.date ?? "").localeCompare(String(right.date ?? "")) ||
    String(left.citySlug ?? "").localeCompare(String(right.citySlug ?? "")) ||
    left.candidateId.localeCompare(right.candidateId);
}

function compareClusters(left, right) {
  return left.entityType.localeCompare(right.entityType) ||
    bScore(left, right) ||
    left.clusterId.localeCompare(right.clusterId);
}

function bScore(left, right) {
  return right.score - left.score;
}

function uniqueSorted(values) {
  return [...new Set(values.filter((value) => value !== null && value !== undefined && value !== ""))]
    .sort((a, b) => String(a).localeCompare(String(b)));
}

function round(value) {
  return Math.round(value * 1000) / 1000;
}

function hashJson(value) {
  return hashString(JSON.stringify(sortValue(value)));
}

function hashString(value) {
  return crypto.createHash("sha256").update(String(value)).digest("hex");
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortValue(nested)])
    );
  }
  return value;
}
