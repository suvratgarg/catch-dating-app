import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import {appCheckCallableOptionsWithSecrets} from
  "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {ExploreSearchCallablePayload} from
  "../shared/generated/exploreSearchCallablePayload";
import {ExploreSearchCallableResponse} from
  "../shared/generated/exploreSearchCallableResponse";
import {validateExploreSearchCallablePayload} from
  "../shared/generated/schemaValidators";

export const algoliaAppId = defineSecret("ALGOLIA_APP_ID");
export const algoliaSearchApiKey = defineSecret("ALGOLIA_SEARCH_API_KEY");

const defaultLimit = 20;

type FetchImpl = typeof fetch;

interface ExploreSearchDeps {
  firestore: () => FirebaseFirestore.Firestore;
  fetchImpl: FetchImpl;
  now: () => Date;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ExploreSearchDeps = {
  firestore: () => admin.firestore(),
  fetchImpl: fetch,
  now: () => new Date(),
  checkRateLimit: defaultCheckRateLimit,
};

interface AlgoliaMultiSearchResponse {
  results?: AlgoliaSearchResult[];
}

interface AlgoliaSearchResult {
  hits?: AlgoliaHit[];
}

interface AlgoliaHit {
  objectID?: string;
}

/**
 * Searches the Explore club and event indices through Algolia.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ExploreSearchDeps} deps Injectable dependencies for tests.
 * @return {Promise<ExploreSearchCallableResponse>} Search hit ids.
 */
export async function exploreSearchHandler(
  request: CallableRequest<unknown>,
  deps: ExploreSearchDeps = defaultDeps
): Promise<ExploreSearchCallableResponse> {
  const uid = requireAuth(request);
  const payload = validateCallableWithAjv<ExploreSearchCallablePayload>(
    request,
    validateExploreSearchCallablePayload,
    normalizeExploreSearchPayload
  );
  await deps.checkRateLimit?.(deps.firestore(), uid, "exploreSearch");

  return searchExploreWithAlgolia(payload, deps);
}

/**
 * Calls Algolia's multi-query endpoint for club and event matches.
 * @param {ExploreSearchCallablePayload} payload Normalized search payload.
 * @param {ExploreSearchDeps} deps Injectable dependencies.
 * @return {Promise<ExploreSearchCallableResponse>} Search hit ids.
 */
export async function searchExploreWithAlgolia(
  payload: ExploreSearchCallablePayload,
  deps: Pick<ExploreSearchDeps, "fetchImpl" | "now">
): Promise<ExploreSearchCallableResponse> {
  const body = buildAlgoliaExploreSearchBody(payload, deps.now());
  const response = await deps.fetchImpl(algoliaEndpoint(), {
    method: "POST",
    headers: {
      "accept": "application/json",
      "content-type": "application/json",
      "x-algolia-application-id": algoliaAppId.value(),
      "x-algolia-api-key": algoliaSearchApiKey.value(),
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    throw new HttpsError(
      "unavailable",
      "Explore search is unavailable."
    );
  }

  const data = await response.json() as AlgoliaMultiSearchResponse;
  const [clubsResult, eventsResult] = data.results ?? [];
  return {
    clubIds: uniqueHitIds(clubsResult),
    eventIds: uniqueHitIds(eventsResult),
  };
}

/**
 * Builds the Algolia multi-search request for Explore search.
 * @param {ExploreSearchCallablePayload} payload Search payload.
 * @param {Date} now Current server time for event freshness.
 * @return {object} Algolia multi-search request.
 */
export function buildAlgoliaExploreSearchBody(
  payload: ExploreSearchCallablePayload,
  now: Date
) {
  const limit = payload.limit ?? defaultLimit;
  const cityName = normalizeSearchCityName(payload.cityName);
  return {
    requests: [
      {
        indexName: clubsIndexName(),
        query: payload.query,
        hitsPerPage: limit,
        filters: cityName ? `location:${quoteFilterValue(cityName)}` : "",
      },
      {
        indexName: eventsIndexName(),
        query: payload.query,
        hitsPerPage: limit,
        filters: eventFilters(cityName, now),
      },
    ],
    strategy: "none",
  };
}

/**
 * Trims Explore search payload strings before schema validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
function normalizeExploreSearchPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["query", "cityName"],
  });
}

/**
 * Returns the Algolia REST endpoint for the configured app.
 * @return {string} Algolia multi-query endpoint.
 */
function algoliaEndpoint(): string {
  return `https://${algoliaAppId.value()}.algolia.net/1/indexes/*/queries`;
}

/**
 * Reads the club index name with a local-test fallback.
 * @return {string} Algolia clubs index name.
 */
export function clubsIndexName(): string {
  return process.env.ALGOLIA_CLUBS_INDEX || "clubs";
}

/**
 * Reads the event index name with a local-test fallback.
 * @return {string} Algolia events index name.
 */
export function eventsIndexName(): string {
  return process.env.ALGOLIA_EVENTS_INDEX || "events";
}

/**
 * Builds Algolia filters for upcoming event search.
 * @param {string | undefined} cityName Optional city filter.
 * @param {Date} now Current server time.
 * @return {string} Algolia filter expression.
 */
function eventFilters(cityName: string | undefined, now: Date): string {
  const filters = [`startTimeEpoch >= ${Math.floor(now.getTime() / 1000)}`];
  if (cityName) {
    filters.unshift(`discoveryCityName:${quoteFilterValue(cityName)}`);
  }
  return filters.join(" AND ");
}

/**
 * Normalizes city names used by Algolia Explore facet filters.
 * @param {string | null | undefined} value Raw city value.
 * @return {string | undefined} Lowercase city filter value.
 */
export function normalizeSearchCityName(
  value: string | null | undefined
): string | undefined {
  const normalized = (value ?? "").trim().toLowerCase();
  return normalized.length > 0 ? normalized : undefined;
}

/**
 * Escapes a string facet value for Algolia filter syntax.
 * @param {string} value Raw facet value.
 * @return {string} Quoted facet value.
 */
function quoteFilterValue(value: string): string {
  return `"${value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"")}"`;
}

/**
 * Extracts unique object ids from one Algolia result set.
 * @param {AlgoliaSearchResult | undefined} result Algolia result set.
 * @return {string[]} Unique hit ids.
 */
function uniqueHitIds(result: AlgoliaSearchResult | undefined): string[] {
  const ids = new Set<string>();
  for (const hit of result?.hits ?? []) {
    if (hit.objectID) ids.add(hit.objectID);
  }
  return Array.from(ids);
}

export const exploreSearch = onCall(
  appCheckCallableOptionsWithSecrets([algoliaAppId, algoliaSearchApiKey]),
  (request) => exploreSearchHandler(request)
);
