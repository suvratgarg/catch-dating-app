import crypto from "node:crypto";

const allowedSources = new Set([
  "custom_scraper",
  "fixture",
  "manual_google_search",
  "manual_web_search",
  "serp_api",
]);

export function buildSearchResultBatchFromCapture({
  capture,
  capturedAt,
  planEntry,
  source,
}) {
  if (!allowedSources.has(source)) {
    throw new Error(`Unsupported search-result source: ${source}`);
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(capturedAt ?? "")) {
    throw new Error("--date must be YYYY-MM-DD.");
  }
  if (!planEntry) {
    throw new Error("A search plan entry is required.");
  }

  const rawResults = extractRawResults(capture);
  const results = rawResults.map((result, index) =>
    capturedResultFor(result, index, capturedAt)
  );
  if (results.length === 0) {
    throw new Error("Captured search result payload has no usable results.");
  }

  return {
    schemaVersion: 1,
    batchId: defaultBatchId(planEntry, capturedAt),
    createdAt: capturedAt,
    source,
    query: planEntry.renderedQuery,
    queryIntent: {
      activityKind: activityKindFromCategory(planEntry.categoryId),
      entityHint: planEntry.candidateName ?? null,
      marketSlug: planEntry.citySlug ?? null,
    },
    captureContext: {
      candidateId: planEntry.candidateId ?? null,
      categoryId: planEntry.categoryId ?? null,
      city: planEntry.city ?? null,
      citySlug: planEntry.citySlug ?? null,
      planKind: planEntry.planKind ?? null,
      providerResultCount: rawResults.length,
      resultFingerprint: planEntry.resultFingerprint ?? null,
      runKey: planEntry.runKey,
      sourcePlanFile: "tool/host_discovery/generated/search_plan.json",
    },
    results,
    notes:
      `Captured from host-discovery search plan run key ${planEntry.runKey}. ` +
      "Raw provider payload is intentionally not persisted in the batch.",
  };
}

export function findSearchPlanEntry(searchPlan, runKey) {
  const entries = [
    ...(searchPlan.planned ?? []),
    ...(searchPlan.skippedFresh ?? []),
  ];
  return entries.find((entry) => entry.runKey === runKey) ?? null;
}

export function defaultBatchId(planEntry, capturedAt) {
  const target = planEntry.candidateId ?? `${planEntry.categoryId}-${planEntry.citySlug}`;
  const suffix = planEntry.resultFingerprint ?? hashString(planEntry.runKey).slice(0, 16);
  return slugify(`${capturedAt}-${target}-${suffix}`);
}

function extractRawResults(capture) {
  if (Array.isArray(capture)) return capture;
  if (Array.isArray(capture.results)) return capture.results;
  if (Array.isArray(capture.organic_results)) return capture.organic_results;
  if (Array.isArray(capture.items)) return capture.items;
  throw new Error("Raw search payload must contain results, organic_results, items, or be an array.");
}

function capturedResultFor(result, index, observedAt) {
  const rank = numberFrom(result.rank ?? result.position ?? result.index) ?? index + 1;
  const title = stringFrom(result.title ?? result.name);
  const url = stringFrom(result.url ?? result.link ?? result.href);
  const snippet = nullableStringFrom(
    result.snippet ?? result.description ?? result.summary ?? result.body
  );
  if (!title) throw new Error(`Result ${rank} is missing title.`);
  if (!url) throw new Error(`Result ${rank} is missing url/link.`);
  assertUrl(url, rank);
  return {
    resultId: slugify(`result-${rank}`),
    rank,
    title,
    url,
    snippet,
    observedAt,
  };
}

function activityKindFromCategory(categoryId) {
  return {
    board_game_social: "boardGameSocial",
    creator_community_host: "creatorCommunity",
    racket_sport_social: "racketSportSocial",
    singles_event_operator: "singlesEvent",
    social_run_club: "socialRun",
    supper_club: "supperClub",
    venue_led_social: "venueLedSocial",
    walks_experiences: "walksExperiences",
  }[categoryId] ?? null;
}

function assertUrl(value, rank) {
  try {
    new URL(value);
  } catch {
    throw new Error(`Result ${rank} has invalid URL: ${value}`);
  }
}

function numberFrom(value) {
  const number = Number(value);
  return Number.isInteger(number) && number > 0 ? number : null;
}

function stringFrom(value) {
  const string = String(value ?? "").trim();
  return string.length > 0 ? string : null;
}

function nullableStringFrom(value) {
  const string = stringFrom(value);
  return string ?? null;
}

function slugify(value) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function hashString(value) {
  return crypto.createHash("sha256").update(String(value)).digest("hex");
}
