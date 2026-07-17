import assert from "node:assert/strict";
import test from "node:test";
import {
  buildClubSearchRecord,
  buildEventSearchRecord,
  clubSearchIndexSettings,
  eventSearchIndexSettings,
} from "./algoliaExploreIndex.js";
import {
  ClubDocument,
  EventDocument,
} from "../shared/generated/firestoreAdminTypes.js";

/**
 * Builds a minimal Firestore timestamp double for pure record tests.
 * @param {string} iso ISO-8601 timestamp.
 * @return {FirebaseFirestore.Timestamp} Timestamp-like test value.
 */
function timestamp(iso: string) {
  const millis = Date.parse(iso);
  return {
    toMillis: () => millis,
  } as FirebaseFirestore.Timestamp;
}

/**
 * Builds a complete club document for search indexing tests.
 * @param {Partial<ClubDocument>} overrides Field overrides.
 * @return {ClubDocument} Club document.
 */
function club(overrides: Partial<ClubDocument> = {}): ClubDocument {
  return {
    name: "Saket Social Runners",
    description: "Run and coffee",
    location: "in-mp-indore",
    locationCityId: "in-mp-indore",
    locationMarketId: "in-mp-indore",
    cityName: "Indore",
    regionName: "Madhya Pradesh",
    countryCode: "IN",
    countryName: "India",
    area: "Saket",
    hostUserId: "host-1",
    hostName: "Suvrat",
    hostAvatarUrl: null,
    ownerUserId: "host-1",
    hostUserIds: ["host-1"],
    hostProfiles: [],
    createdAt: timestamp("2026-05-01T00:00:00.000Z"),
    imageUrl: null,
    profileImageUrl: null,
    tags: ["running"],
    memberCount: 12,
    rating: 4.8,
    reviewCount: 5,
    nextEventAt: timestamp("2026-05-30T01:30:00.000Z"),
    nextEventLabel: "Saket Square",
    instagramHandle: null,
    phoneNumber: null,
    email: null,
    status: "active" as const,
    archived: false,
    archivedAt: null,
    archiveReason: null,
    ...overrides,
  };
}

/**
 * Builds a complete event document for search indexing tests.
 * @param {Partial<EventDocument>} overrides Field overrides.
 * @return {EventDocument} Event document.
 */
function event(overrides: Partial<EventDocument> = {}): EventDocument {
  return {
    clubId: "club-1",
    startTime: timestamp("2026-05-30T01:30:00.000Z"),
    endTime: timestamp("2026-05-30T02:30:00.000Z"),
    meetingPoint: "Saket Square",
    meetingLocation: {
      name: "Saket Square",
      address: null,
      placeId: null,
      latitude: 22.7196,
      longitude: 75.8577,
      notes: null,
    },
    startingPointLat: 22.7196,
    startingPointLng: 75.8577,
    locationDetails: null,
    distanceKm: 5,
    eventFormat: {
      version: 1,
      activityKind: "running" as const,
      interactionModel: "pacePods" as const,
    },
    pace: "easy" as const,
    capacityLimit: 20,
    description: "Easy community run",
    priceInPaise: 0,
    currency: "INR",
    bookedCount: 0,
    checkedInCount: 0,
    waitlistedCount: 0,
    genderCounts: {},
    cohortCounts: {},
    waitlistedCohortCounts: {},
    constraints: {minAge: 18, maxAge: 99},
    status: "active" as const,
    discoveryCityName: "indore",
    discoveryMarketId: "in-mp-indore",
    discoveryActivityKind: "running" as const,
    discoveryGeoCell: "283:948",
    discoveryHasOpenSpots: true,
    discoveryAvailability: "open" as const,
    discoveryOpenCohorts: [],
    discoveryWaitlistCohorts: [],
    discoveryInviteRequired: false,
    discoveryMembershipRequired: false,
    discoveryManualApprovalRequired: false,
    discoveryMinAge: 18,
    discoveryMaxAge: 99,
    ...overrides,
  };
}

test("buildClubSearchRecord normalizes city facets", () => {
  const record = buildClubSearchRecord("club-1", club());

  assert.equal(record?.objectID, "club-1");
  assert.equal(record?.location, "Indore");
  assert.equal(record?.locationMarketId, "in-mp-indore");
  assert.equal(record?.nextEventAtEpoch, 1780104600);
  assert.equal(record?.memberCount, 12);
});

test("buildClubSearchRecord omits archived clubs", () => {
  assert.equal(
    buildClubSearchRecord("club-1", club({archived: true})),
    null
  );
});

test("buildEventSearchRecord uses the club city and event time", () => {
  const record = buildEventSearchRecord("event-1", event(), club());

  assert.equal(record?.objectID, "event-1");
  assert.equal(record?.clubName, "Saket Social Runners");
  assert.equal(record?.discoveryCityName, "indore");
  assert.equal(record?.discoveryMarketId, "in-mp-indore");
  assert.equal(record?.startTimeEpoch, 1780104600);
});

test("buildEventSearchRecord omits cancelled events", () => {
  assert.equal(
    buildEventSearchRecord("event-1", event({status: "cancelled"}), club()),
    null
  );
});

test("index settings expose required filters", () => {
  assert.deepEqual(clubSearchIndexSettings().attributesForFaceting, [
    "filterOnly(locationMarketId)",
    "filterOnly(status)",
    "filterOnly(archived)",
  ]);
  assert.deepEqual(eventSearchIndexSettings().attributesForFaceting, [
    "filterOnly(discoveryMarketId)",
    "filterOnly(status)",
    "filterOnly(clubId)",
  ]);
});
