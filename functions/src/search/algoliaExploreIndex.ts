import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  ClubDocument,
  EventDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  algoliaAppId,
  clubsIndexName,
  eventsIndexName,
  normalizeSearchCityName,
} from "./exploreSearch";

export const algoliaWriteApiKey = defineSecret("ALGOLIA_WRITE_API_KEY");

type FetchImpl = typeof fetch;

interface AlgoliaExploreIndexDeps {
  firestore: () => FirebaseFirestore.Firestore;
  fetchImpl: FetchImpl;
  writeApiKey: () => string;
}

const defaultDeps: AlgoliaExploreIndexDeps = {
  firestore: () => admin.firestore(),
  fetchImpl: fetch,
  writeApiKey: () => algoliaWriteApiKey.value(),
};

export interface AlgoliaClubSearchRecord {
  objectID: string;
  type: "club";
  name: string;
  description: string;
  location: string;
  area: string;
  hostName: string;
  tags: string[];
  memberCount: number;
  rating: number;
  reviewCount: number;
  status: ClubDocument["status"];
  archived: boolean;
  nextEventAtEpoch: number | null;
  nextEventLabel: string | null;
}

export interface AlgoliaEventSearchRecord {
  objectID: string;
  type: "event";
  clubId: string;
  clubName: string;
  meetingPoint: string;
  locationDetails: string | null;
  description: string;
  discoveryCityName: string;
  discoveryActivityKind: string;
  discoveryAvailability: string | null;
  startTimeEpoch: number;
  endTimeEpoch: number | null;
  status: EventDocument["status"];
}

/**
 * Builds the settings needed by the club search index.
 * @return {Record<string, unknown>} Algolia settings payload.
 */
export function clubSearchIndexSettings(): Record<string, unknown> {
  return {
    searchableAttributes: [
      "name",
      "area",
      "hostName",
      "tags",
      "description",
    ],
    attributesForFaceting: [
      "filterOnly(location)",
      "filterOnly(status)",
      "filterOnly(archived)",
    ],
    customRanking: [
      "desc(memberCount)",
      "desc(rating)",
      "desc(reviewCount)",
    ],
  };
}

/**
 * Builds the settings needed by the event search index.
 * @return {Record<string, unknown>} Algolia settings payload.
 */
export function eventSearchIndexSettings(): Record<string, unknown> {
  return {
    searchableAttributes: [
      "clubName",
      "meetingPoint",
      "locationDetails",
      "description",
      "discoveryActivityKind",
    ],
    attributesForFaceting: [
      "filterOnly(discoveryCityName)",
      "filterOnly(status)",
      "filterOnly(clubId)",
    ],
    customRanking: [
      "asc(startTimeEpoch)",
    ],
  };
}

/**
 * Converts a Firestore club document into an Algolia club record.
 * @param {string} clubId Firestore club id.
 * @param {ClubDocument} club Club document data.
 * @return {AlgoliaClubSearchRecord | null} Algolia record, or null if hidden.
 */
export function buildClubSearchRecord(
  clubId: string,
  club: ClubDocument
): AlgoliaClubSearchRecord | null {
  const location = normalizeSearchCityName(club.location);
  if (
    club.status !== "active" ||
    club.archived ||
    club.appVisibility === "hidden" ||
    !location ||
    club.name.trim().length === 0
  ) {
    return null;
  }

  return {
    objectID: clubId,
    type: "club",
    name: club.name,
    description: club.description,
    location,
    area: club.area,
    hostName: club.hostName ?? club.name,
    tags: Array.isArray(club.tags) ? club.tags : [],
    memberCount: finiteNumberOrZero(club.memberCount),
    rating: finiteNumberOrZero(club.rating),
    reviewCount: finiteNumberOrZero(club.reviewCount),
    status: club.status,
    archived: club.archived,
    nextEventAtEpoch: timestampEpochSeconds(club.nextEventAt),
    nextEventLabel: club.nextEventLabel ?? null,
  };
}

/**
 * Converts a Firestore event document into an Algolia event record.
 * @param {string} eventId Firestore event id.
 * @param {EventDocument} event Event document data.
 * @param {ClubDocument} club Parent club document data.
 * @return {AlgoliaEventSearchRecord | null} Algolia record, or null if hidden.
 */
export function buildEventSearchRecord(
  eventId: string,
  event: EventDocument,
  club: ClubDocument
): AlgoliaEventSearchRecord | null {
  const startTimeEpoch = timestampEpochSeconds(event.startTime);
  const discoveryCityName =
    normalizeSearchCityName(club.location) ??
    normalizeSearchCityName(event.discoveryCityName);
  if (
    event.status !== "active" ||
    club.status !== "active" ||
    club.archived ||
    club.appVisibility === "hidden" ||
    !discoveryCityName ||
    startTimeEpoch == null
  ) {
    return null;
  }

  return {
    objectID: eventId,
    type: "event",
    clubId: event.clubId,
    clubName: club.name,
    meetingPoint: event.meetingPoint,
    locationDetails: event.locationDetails ?? null,
    description: event.description,
    discoveryCityName,
    discoveryActivityKind:
      event.discoveryActivityKind ??
      event.eventFormat?.activityKind ??
      "socialRun",
    discoveryAvailability: event.discoveryAvailability ?? null,
    startTimeEpoch,
    endTimeEpoch: timestampEpochSeconds(event.endTime),
    status: event.status,
  };
}

/**
 * Syncs one club and its events into Algolia after a club write.
 * @param {string} clubId Firestore club id.
 * @param {ClubDocument | undefined} club Current club data.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @return {Promise<void>}
 */
export async function syncAlgoliaClubIndexHandler(
  clubId: string,
  club: ClubDocument | undefined,
  deps: AlgoliaExploreIndexDeps = defaultDeps
): Promise<void> {
  const clubRecord = club ? buildClubSearchRecord(clubId, club) : null;
  if (clubRecord) {
    await upsertAlgoliaObject(clubsIndexName(), clubRecord, deps);
  } else {
    await deleteAlgoliaObject(clubsIndexName(), clubId, deps);
  }

  await syncEventsForClub(clubId, clubRecord ? club : undefined, deps);
}

/**
 * Syncs one event into Algolia after an event write.
 * @param {string} eventId Firestore event id.
 * @param {EventDocument | undefined} event Current event data.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @return {Promise<void>}
 */
export async function syncAlgoliaEventIndexHandler(
  eventId: string,
  event: EventDocument | undefined,
  deps: AlgoliaExploreIndexDeps = defaultDeps
): Promise<void> {
  if (!event) {
    await deleteAlgoliaObject(eventsIndexName(), eventId, deps);
    return;
  }

  const db = deps.firestore();
  const clubSnap = await db.collection("clubs").doc(event.clubId).get();
  const club = clubSnap.exists ?
    clubSnap.data() as ClubDocument :
    undefined;
  if (!club) {
    logger.warn("Deleting Algolia event record for missing club", {
      eventId,
      clubId: event.clubId,
    });
    await deleteAlgoliaObject(eventsIndexName(), eventId, deps);
    return;
  }

  await syncEventWithClub(eventId, event, club, deps);
}

/**
 * Reindexes all events that belong to a club after club visibility changes.
 * @param {string} clubId Club id.
 * @param {ClubDocument | undefined} club Current indexable club data.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @return {Promise<void>}
 */
async function syncEventsForClub(
  clubId: string,
  club: ClubDocument | undefined,
  deps: AlgoliaExploreIndexDeps
): Promise<void> {
  const eventsSnap = await deps.firestore()
    .collection("events")
    .where("clubId", "==", clubId)
    .get();
  await Promise.all(eventsSnap.docs.map((doc) => {
    if (!club) {
      return deleteAlgoliaObject(eventsIndexName(), doc.id, deps);
    }
    return syncEventWithClub(
      doc.id,
      doc.data() as EventDocument,
      club,
      deps
    );
  }));
}

/**
 * Upserts or deletes one event record using already-loaded club data.
 * @param {string} eventId Event id.
 * @param {EventDocument} event Event document data.
 * @param {ClubDocument} club Parent club document data.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @return {Promise<void>}
 */
async function syncEventWithClub(
  eventId: string,
  event: EventDocument,
  club: ClubDocument,
  deps: AlgoliaExploreIndexDeps
): Promise<void> {
  const record = buildEventSearchRecord(eventId, event, club);
  if (record) {
    await upsertAlgoliaObject(eventsIndexName(), record, deps);
  } else {
    await deleteAlgoliaObject(eventsIndexName(), eventId, deps);
  }
}

/**
 * Writes one Algolia object by object id.
 * @param {string} indexName Algolia index name.
 * @param {{objectID: string}} record Algolia record with object id.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @return {Promise<void>}
 */
async function upsertAlgoliaObject(
  indexName: string,
  record: {objectID: string},
  deps: AlgoliaExploreIndexDeps
): Promise<void> {
  await algoliaFetch(
    `/1/indexes/${encodeURIComponent(indexName)}/` +
      encodeURIComponent(String(record.objectID)),
    {
      method: "PUT",
      body: JSON.stringify(record),
    },
    deps
  );
}

/**
 * Deletes one Algolia object and ignores absent objects.
 * @param {string} indexName Algolia index name.
 * @param {string} objectId Algolia object id.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @return {Promise<void>}
 */
async function deleteAlgoliaObject(
  indexName: string,
  objectId: string,
  deps: AlgoliaExploreIndexDeps
): Promise<void> {
  await algoliaFetch(
    `/1/indexes/${encodeURIComponent(indexName)}/` +
      encodeURIComponent(objectId),
    {method: "DELETE"},
    deps,
    {ignoreNotFound: true}
  );
}

/**
 * Sends a write request to Algolia with backend-only credentials.
 * @param {string} path Algolia REST path.
 * @param {RequestInit} init Fetch init.
 * @param {AlgoliaExploreIndexDeps} deps Injectable dependencies.
 * @param {object} options Error handling options.
 * @return {Promise<void>}
 */
async function algoliaFetch(
  path: string,
  init: RequestInit,
  deps: AlgoliaExploreIndexDeps,
  options: {ignoreNotFound?: boolean} = {}
): Promise<void> {
  const response = await deps.fetchImpl(algoliaEndpoint(path), {
    ...init,
    headers: {
      "accept": "application/json",
      "content-type": "application/json",
      "x-algolia-application-id": algoliaAppId.value(),
      "x-algolia-api-key": deps.writeApiKey(),
      ...init.headers,
    },
  });
  if (response.ok || (options.ignoreNotFound && response.status === 404)) {
    return;
  }

  const body = await response.text().catch(() => "");
  throw new Error(
    `Algolia request failed with ${response.status}: ${body.slice(0, 500)}`
  );
}

/**
 * Builds an Algolia app endpoint for a REST path.
 * @param {string} path Algolia REST path.
 * @return {string} Absolute endpoint URL.
 */
function algoliaEndpoint(path: string): string {
  return `https://${algoliaAppId.value()}.algolia.net${path}`;
}

/**
 * Converts a Firestore timestamp to epoch seconds.
 * @param {FirebaseFirestore.Timestamp | null | undefined} value Timestamp.
 * @return {number | null} Epoch seconds, or null.
 */
function timestampEpochSeconds(
  value: FirebaseFirestore.Timestamp | null | undefined
): number | null {
  if (!value) return null;
  return Math.floor(value.toMillis() / 1000);
}

/**
 * Normalizes optional numeric ranking fields.
 * @param {number} value Candidate number.
 * @return {number} Finite number, or zero.
 */
function finiteNumberOrZero(value: number): number {
  return Number.isFinite(value) ? value : 0;
}

export const syncAlgoliaClubIndex = onDocumentWritten(
  {
    document: "clubs/{clubId}",
    secrets: [algoliaAppId, algoliaWriteApiKey],
  },
  async (event) => {
    const club = event.data?.after.data() as ClubDocument | undefined;
    await syncAlgoliaClubIndexHandler(event.params.clubId, club);
  }
);

export const syncAlgoliaEventIndex = onDocumentWritten(
  {
    document: "events/{eventId}",
    secrets: [algoliaAppId, algoliaWriteApiKey],
  },
  async (event) => {
    const eventDoc = event.data?.after.data() as EventDocument | undefined;
    await syncAlgoliaEventIndexHandler(event.params.eventId, eventDoc);
  }
);
