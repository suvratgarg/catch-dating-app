import assert from "node:assert/strict";
import test from "node:test";
import {
  applyEventMeetingLocationBackfillPlan,
  buildEventMeetingLocationBackfillPlan,
  canonicalEventMeetingLocation,
} from "./backfill_event_meeting_locations.mjs";

test("legacy-only event gains only the missing structured object", async () => {
  const firestore = fakeFirestore({
    events: {
      "event-1": {
        meetingPoint: "Carter Road",
        startingPointLat: 19.0608,
        startingPointLng: 72.8365,
        locationDetails: "Meet by the gate.",
      },
    },
  });
  const plan = await buildEventMeetingLocationBackfillPlan(firestore);

  assert.equal(plan.blockers.length, 0);
  assert.deepEqual(plan.repairs[0].patch, {
    meetingLocation: {
      name: "Carter Road",
      address: null,
      placeId: null,
      latitude: 19.0608,
      longitude: 72.8365,
      notes: "Meet by the gate.",
    },
  });
  assert.equal(plan.repairs[0].source, "legacy");
});

test("structured location wins and repairs every drifted mirror", async () => {
  const firestore = fakeFirestore({
    events: {
      "event-2": {
        meetingPoint: "Old venue",
        meetingLocation: location({
          name: " New Venue ",
          latitude: 19.1,
          longitude: 72.9,
          notes: " North gate ",
        }),
        startingPointLat: 1,
        startingPointLng: 2,
        locationDetails: "Old note",
      },
    },
  });
  const plan = await buildEventMeetingLocationBackfillPlan(firestore);

  assert.deepEqual(plan.repairs[0].patch, {
    meetingPoint: "New Venue",
    meetingLocation: location({
      name: "New Venue",
      latitude: 19.1,
      longitude: 72.9,
      notes: "North gate",
    }),
    startingPointLat: 19.1,
    startingPointLng: 72.9,
    locationDetails: "North gate",
  });
  assert.equal(plan.summary.warningCount, 1);
});

test("invalid structured pair falls back to the complete legacy pair", () => {
  const result = canonicalEventMeetingLocation({
    meetingPoint: "Legacy Venue",
    meetingLocation: location({latitude: 999, longitude: 72.9}),
    startingPointLat: 19.1,
    startingPointLng: 72.9,
    locationDetails: null,
  }, {path: "events/event-3", eventId: "event-3"});

  assert.equal(result.blocker, null);
  assert.equal(result.expected.meetingLocation.latitude, 19.1);
  assert.equal(result.expected.meetingLocation.longitude, 72.9);
  assert.equal(result.source, "mixed");
  assert.equal(result.warnings.length, 1);
});

test("missing name and invalid coordinate pairs remain blockers", () => {
  const blankName = canonicalEventMeetingLocation({
    meetingPoint: " ",
    startingPointLat: 19.1,
    startingPointLng: 72.9,
  });
  assert(blankName.blocker.reasons.some((reason) => reason.includes("name")));

  const missingPair = canonicalEventMeetingLocation({meetingPoint: "Venue"});
  assert(missingPair.blocker.reasons.some((reason) =>
    reason.includes("coordinate pair")
  ));

  const outOfRange = canonicalEventMeetingLocation({
    meetingPoint: "Venue",
    startingPointLat: -91,
    startingPointLng: 72.9,
  });
  assert(outOfRange.blocker.reasons.some((reason) =>
    reason.includes("coordinate pair")
  ));
});

test("optional strings normalize safely and invalid values block", () => {
  const normalized = canonicalEventMeetingLocation({
    meetingPoint: "Venue",
    meetingLocation: location({
      address: "  1 Main Road ",
      placeId: " ",
      notes: " Gate A ",
    }),
    startingPointLat: 19.1,
    startingPointLng: 72.9,
  });
  assert.equal(normalized.expected.meetingLocation.address, "1 Main Road");
  assert.equal(normalized.expected.meetingLocation.placeId, null);
  assert.equal(normalized.expected.meetingLocation.notes, "Gate A");

  const invalid = canonicalEventMeetingLocation({
    meetingPoint: "Venue",
    meetingLocation: location({address: 42}),
    startingPointLat: 19.1,
    startingPointLng: 72.9,
  });
  assert(invalid.blocker.reasons.includes(
    "meetingLocation.address must be a string or null"
  ));
});

test("apply is idempotent after writing a reviewed plan", async () => {
  const firestore = fakeFirestore({
    events: {
      "event-1": {
        meetingPoint: "Carter Road",
        startingPointLat: 19.0608,
        startingPointLng: 72.8365,
        locationDetails: null,
      },
    },
  });
  const plan = await buildEventMeetingLocationBackfillPlan(firestore);
  await applyEventMeetingLocationBackfillPlan(firestore, plan);
  const secondPlan = await buildEventMeetingLocationBackfillPlan(firestore);
  assert.equal(secondPlan.summary.repairsNeeded, 0);
  assert.equal(firestore.commitCount, 1);
});

test("apply refuses blockers before committing any batch", async () => {
  const firestore = fakeFirestore({
    events: {blocked: {meetingPoint: "Unknown venue"}},
  });
  const plan = await buildEventMeetingLocationBackfillPlan(firestore);
  await assert.rejects(
    applyEventMeetingLocationBackfillPlan(firestore, plan),
    /Refusing to apply with 1 unresolved blocker/
  );
  assert.equal(firestore.commitCount, 0);
});

function location(overrides = {}) {
  return {
    name: "Venue",
    address: null,
    placeId: null,
    latitude: 19.1,
    longitude: 72.9,
    notes: null,
    ...overrides,
  };
}

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  const versions = new Map(Object.entries(data).flatMap(([collection, rows]) =>
    Object.keys(rows).map((id) => [`${collection}/${id}`,
      {seconds: 1800000000, nanoseconds: 123456789}])));
  const firestore = {
    data,
    versions,
    commitCount: 0,
    collection: (collectionName) => ({
      get: async () => ({
        size: Object.keys(data[collectionName] ?? {}).length,
        docs: Object.entries(data[collectionName] ?? {}).map(([id, value]) => ({
          id,
          ref: {path: `${collectionName}/${id}`},
          updateTime: versions.get(`${collectionName}/${id}`),
          data: () => structuredClone(value),
        })),
      }),
    }),
    doc: (documentPath) => ({path: documentPath}),
    batch: () => {
      const writes = [];
      return {
        update: (ref, patch, precondition) =>
          writes.push({path: ref.path, patch, precondition}),
        commit: async () => {
          for (const write of writes) {
            const current = versions.get(write.path);
            const expected = write.precondition?.lastUpdateTime;
            if (!current || !expected || current.seconds !== expected.seconds ||
                current.nanoseconds !== expected.nanoseconds) {
              throw new Error("Source version changed");
            }
          }
          firestore.commitCount += 1;
          for (const write of writes) {
            const [collectionName, documentId] = write.path.split("/");
            versions.set(write.path, {seconds: 1800000001, nanoseconds: 0});
            data[collectionName][documentId] = {
              ...data[collectionName][documentId],
              ...structuredClone(write.patch),
            };
          }
        },
      };
    },
  };
  return firestore;
}


test("reviewed repair rejects a source edit within the same millisecond", async () => {
  const firestore = repairable();
  const plan = await buildEventMeetingLocationBackfillPlan(firestore);
  assert.equal(plan.repairs[0].sourceVersion.nanoseconds, 123456789);
  firestore.versions.set("events/event-1",
    {seconds: 1800000000, nanoseconds: 123456790});
  firestore.data.events["event-1"].meetingPoint = "Organizer changed venue";
  await assert.rejects(applyEventMeetingLocationBackfillPlan(firestore, plan),
    /Source version changed/);
  assert.equal(firestore.commitCount, 0);
  assert.equal(firestore.data.events["event-1"].meetingPoint,
    "Organizer changed venue");
  assert.equal(firestore.data.events["event-1"].meetingLocation, undefined);
});

test("a deleted source cannot be recreated by a reviewed repair", async () => {
  const firestore = repairable();
  const plan = await buildEventMeetingLocationBackfillPlan(firestore);
  firestore.versions.delete("events/event-1");
  delete firestore.data.events["event-1"];
  await assert.rejects(applyEventMeetingLocationBackfillPlan(firestore, plan),
    /Source version changed/);
  assert.equal(firestore.commitCount, 0);
  assert.equal(firestore.data.events["event-1"], undefined);
});

test("all missing or malformed plan versions fail before any batch", async () => {
  for (const sourceVersion of [null, {seconds: 1, nanoseconds: -1},
    {seconds: 1, nanoseconds: 1.5}, {seconds: Infinity, nanoseconds: 0}]) {
    const firestore = repairable();
    const plan = await buildEventMeetingLocationBackfillPlan(firestore);
    // Even a malformed entry beyond the first batch must prevent all writes.
    plan.repairs = [...Array(450).fill(plan.repairs[0]),
      {...plan.repairs[0], sourceVersion}];
    await assert.rejects(applyEventMeetingLocationBackfillPlan(firestore, plan),
      /Missing or invalid source version/);
    assert.equal(firestore.commitCount, 0);
  }
});

function repairable() {
  return fakeFirestore({events: {"event-1": {meetingPoint: "Venue",
    startingPointLat: 19.1, startingPointLng: 72.9, locationDetails: null}}});
}
