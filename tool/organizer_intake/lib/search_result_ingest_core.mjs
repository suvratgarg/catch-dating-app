import {surfaceFromUrl} from "./platform_adapters.mjs";

export function buildSearchResultCandidateQueue(batches, options = {}) {
  const dedupeMatchesByKey = buildDedupeMatchesByKey(options.dedupeIndex);
  const candidates = [];
  const errors = [];
  const warnings = [];

  for (const batch of [...batches].sort((a, b) => a.batchId.localeCompare(b.batchId))) {
    validateBatch(batch, errors);
    for (const result of [...(batch.results ?? [])].sort((a, b) => a.rank - b.rank)) {
      const candidate = candidateForResult(batch, result, dedupeMatchesByKey, warnings);
      if (candidate) candidates.push(candidate);
    }
  }

  const duplicateKeys = duplicateNormalizedKeys(candidates);
  return {
    schemaVersion: 1,
    generatedFrom: {
      batches: batches.map((batch) => batch.batchId).sort(),
      dedupeIndexGeneratedAt: options.dedupeIndex?.generatedAt ?? null,
    },
    summary: {
      batches: batches.length,
      results: batches.reduce((sum, batch) => sum + (batch.results?.length ?? 0), 0),
      candidates: candidates.length,
      matchedExistingEntities: countCandidatesWithMatches(candidates),
      duplicateNormalizedKeys: duplicateKeys.length,
      platforms: countBy(candidates, "platform"),
    },
    candidates,
    duplicateKeys,
    warnings: warnings.sort(),
    errors: errors.sort(),
  };
}

function candidateForResult(batch, result, dedupeMatchesByKey, warnings) {
  let surface;
  try {
    surface = surfaceFromUrl(result.url, {
      surfaceId: `${batch.batchId}-${result.resultId}`,
    });
  } catch (error) {
    warnings.push(`${batch.batchId}/${result.resultId}: ${error.message}`);
    return null;
  }
  const matches = surface.normalizedKey ? (dedupeMatchesByKey.get(surface.normalizedKey) ?? []) : [];
  const reviewAction = reviewActionFor(surface, matches);
  return {
    candidateId: `${batch.batchId}:${result.resultId}`,
    batchId: batch.batchId,
    resultId: result.resultId,
    rank: result.rank,
    query: batch.query,
    queryIntent: batch.queryIntent,
    observedAt: result.observedAt,
    title: result.title,
    snippet: result.snippet,
    url: result.url,
    canonicalUrl: surface.url,
    platform: surface.platform,
    surfaceKind: surface.surfaceKind,
    normalizedKey: surface.normalizedKey,
    suggestedSurface: surface,
    existingEntityMatches: matches,
    reviewAction,
    diagnostics: diagnosticsFor(surface, matches),
  };
}

function reviewActionFor(surface, matches) {
  if (surface.platform === "news") return "supporting_evidence_only";
  if (!surface.normalizedKey) return "needs_manual_url_resolution";
  if (matches.length > 0) return "attach_to_existing_or_curate";
  if (surface.platform === "officialWebsite") return "verify_ownership_before_attach";
  return "create_or_merge_candidate";
}

function diagnosticsFor(surface, matches) {
  const diagnostics = [];
  if (surface.platform === "officialWebsite") diagnostics.push("first_party_claim_requires_manual_confirmation");
  if (surface.platform === "news") diagnostics.push("press_result_is_not_identity_key");
  if (!surface.normalizedKey) diagnostics.push("no_identity_dedupe_key");
  if (matches.length > 1) diagnostics.push("normalized_key_matches_multiple_entities");
  return diagnostics;
}

function buildDedupeMatchesByKey(dedupeIndex) {
  const matches = new Map();
  for (const key of dedupeIndex?.dedupeKeys ?? []) {
    if (key.type !== "surface" || typeof key.value !== "string") continue;
    if (!matches.has(key.value)) matches.set(key.value, []);
    matches.get(key.value).push({
      entityId: key.entityId,
      strength: key.strength,
      reason: key.reason,
    });
  }
  for (const [key, values] of matches.entries()) {
    matches.set(key, values.sort((a, b) => a.entityId.localeCompare(b.entityId)));
  }
  return matches;
}

function duplicateNormalizedKeys(candidates) {
  const groups = new Map();
  for (const candidate of candidates) {
    if (!candidate.normalizedKey) continue;
    if (!groups.has(candidate.normalizedKey)) groups.set(candidate.normalizedKey, []);
    groups.get(candidate.normalizedKey).push(candidate.candidateId);
  }
  return [...groups.entries()]
    .filter(([, ids]) => ids.length > 1)
    .map(([normalizedKey, candidateIds]) => ({normalizedKey, candidateIds: candidateIds.sort()}))
    .sort((a, b) => a.normalizedKey.localeCompare(b.normalizedKey));
}

function countCandidatesWithMatches(candidates) {
  return candidates.filter((candidate) => candidate.existingEntityMatches.length > 0).length;
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function validateBatch(batch, errors) {
  if (batch.schemaVersion !== 1) errors.push(`${batch.batchId ?? "<unknown>"}: schemaVersion must be 1.`);
  if (!isSlug(batch.batchId)) errors.push(`${batch.batchId ?? "<unknown>"}: invalid batchId.`);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(batch.createdAt ?? "")) {
    errors.push(`${batch.batchId ?? "<unknown>"}: createdAt must be YYYY-MM-DD.`);
  }
  if (!batch.queryIntent || typeof batch.queryIntent !== "object") {
    errors.push(`${batch.batchId ?? "<unknown>"}: queryIntent is required.`);
  }
  const resultIds = new Set();
  for (const result of batch.results ?? []) {
    if (!isSlug(result.resultId)) errors.push(`${batch.batchId}: invalid resultId ${result.resultId}.`);
    if (resultIds.has(result.resultId)) errors.push(`${batch.batchId}: duplicate resultId ${result.resultId}.`);
    resultIds.add(result.resultId);
    if (!Number.isInteger(result.rank) || result.rank < 1) {
      errors.push(`${batch.batchId}/${result.resultId}: rank must be a positive integer.`);
    }
  }
}

function isSlug(value) {
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(String(value ?? ""));
}
