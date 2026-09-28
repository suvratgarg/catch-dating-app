import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import {Timestamp} from "firebase-admin/firestore";
import type {EventDocument, OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {eventPublicationReadiness, preparePublishedEventPatch} from
  "./publicationReadiness";

function setup() {
  const raw = JSON.parse(readFileSync(resolve(__dirname,
    "../../../../contracts/fixtures/valid/event_doc.json"), "utf8"));
  const event = {...raw, publicationState: "private",
    eventMarketId: "in-mp-indore", startTime: Timestamp.fromMillis(500_000),
    endTime: Timestamp.fromMillis(600_000)} as EventDocument;
  return {event,
    organizer: {appVisibility: "discoverable"} as OrganizerDocument,
    nowMillis: 100_000, timestampFromMillis: Timestamp.fromMillis};
}

test("readiness and publication share the same complete contract check", () => {
  const params = setup();
  assert.deepEqual(eventPublicationReadiness(params), {canPublish: true,
    missing: []});
  assert.ok(preparePublishedEventPatch(params).discoveryMarketId);
  delete params.event.locationDetails;
  assert.deepEqual(eventPublicationReadiness(params), {canPublish: false,
    missing: ["contract"]});
  assert.throws(() => preparePublishedEventPatch(params));
});

test("readiness lists actionable missing fields without mutation", () => {
  const params = setup();
  for (const key of ["endTime", "meetingLocation", "eventFormat", "description",
    "priceInPaise", "distanceKm", "pace"] as const) delete params.event[key];
  params.organizer.appVisibility = "hidden";
  const before = JSON.stringify(params.event);
  const result = eventPublicationReadiness(params);
  assert.equal(result.canPublish, false);
  assert.deepEqual(result.missing, ["organizerVisibility", "duration", "venue",
    "format", "description", "admissionTerms", "distancePace"]);
  assert.equal(JSON.stringify(params.event), before);
});

test("past events cannot publish; published events cannot republish", () => {
  const params = setup();
  params.nowMillis = 700_000;
  assert.ok(eventPublicationReadiness(params).missing.includes("futureActive"));
  params.event.publicationState = "published";
  assert.deepEqual(eventPublicationReadiness(params), {canPublish: false,
    missing: []});
});


test("readiness rejects an invalid registration revision", () => {
  const params = setup();
  params.event.publicRegistrationRevision = -1;
  assert.deepEqual(eventPublicationReadiness(params), {canPublish: false,
    missing: ["contract"]});
  assert.throws(() => preparePublishedEventPatch(params));
});
