import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {contactFilterKey, contactFilterSelection, contactMatchesFilters} from
  "./organizerContactFilters";
import {listOrganizerContactsHandler, exportOrganizerContactsHandler} from
  "./organizerContacts";
import {AudienceTestStore} from "./organizerAudienceTestStore";
import type {OrganizerContactTraitDocument} from
  "../shared/generated/firestoreAdminTypes";

const tagA = "a".repeat(32);
const tagB = "b".repeat(32);
const selection = contactFilterSelection({
  segmentIds: ["repeat_attendee", "first_time_attendee", "reliable_attendee"],
  manualTagIds: [tagA, tagB],
});
function harness() {
  const store = new AudienceTestStore({
    "organizers/org-1": {ownerUserId: "host-1", hostUserIds: ["host-1"],
      hostProfiles: []},
    "organizerAudienceSummaries/org-1": {organizerId: "org-1",
      contactCount: 9, sourceCoverage: "exact", projectionVersion: 1},
  });
  function person(id: string, segments: string[], tags = [tagA],
    overrides: Record<string, unknown> = {}) {
    store.docs[`organizerContacts/${id}`] = {organizerId: "org-1",
      contactId: id, searchName: id, displayName: id, displayNameOverride: null,
      phoneE164: null, email: null, identityState: "unlinked",
      identityConfidence: "eventOnly", ambiguousCandidateContactIds: [],
      manualTagIds: tags, deletedAt: null, hiddenAt: null, revision: 1,
      lastSeenAt: admin.firestore.Timestamp.fromMillis(1000), ...overrides};
    store.docs[`organizerContactTraits/${id}`] = {organizerId: "org-1",
      segmentIds: segments, attendedEventCount: 2, expectedEventCount: 2,
      noShowCount: 0, attendanceRate: 1, lastAttendedAt: null,
      whatsappStatus: "unknown", smsStatus: "unknown", sourceCoverage: "exact"};
  }
  person("asha", ["repeat_attendee", "reliable_attendee"]);
  person("arya", ["first_time_attendee", "reliable_attendee"], [tagB]);
  person("reliability-only", ["reliable_attendee"]);
  person("attendance-only", ["repeat_attendee"]);
  person("wrong-tag", ["repeat_attendee", "reliable_attendee"], []);
  person("hidden", ["repeat_attendee", "reliable_attendee"], [tagA],
    {hiddenAt: admin.firestore.Timestamp.now()});
  person("merged", ["repeat_attendee", "reliable_attendee"], [tagA],
    {identityState: "merged"});
  person("foreign", ["repeat_attendee", "reliable_attendee"], [tagA],
    {organizerId: "other"});
  person("foreign-trait", ["repeat_attendee", "reliable_attendee"]);
  store.docs["organizerContactTraits/foreign-trait"].organizerId = "other";
  const deps = {firestore: () => store.asFirestore(),
    checkRateLimit: async () => undefined, identitySecret: () => "unused"};
  const request = (data: Record<string, unknown>) => ({
    auth: {uid: "host-1"}, data: {organizerId: "org-1", ...data},
  } as CallableRequest<unknown>);
  return {store, deps, request};
}

test("list combines categories before counting, sorting and pagination",
  async () => {
    const h = harness();
    const data = {...selection, limit: 1, sort: "name", query: "ar"};
    const searched = await listOrganizerContactsHandler(
      h.request(data), h.deps);
    assert.deepEqual(searched.contacts.map((c) => c.contactId), ["arya"]);
    assert.equal(searched.matchCount, 1);
    const first = await listOrganizerContactsHandler(h.request({...data,
      query: null}), h.deps);
    assert.deepEqual(first.contacts.map((c) => c.contactId), ["arya"]);
    assert.equal(first.matchCount, 2);
    assert.equal(first.matchCountCoverage, "exact");
    assert.ok(first.nextCursor);
    const second = await listOrganizerContactsHandler(h.request({...data,
      query: null,
      segmentIds: [...selection.segmentIds].reverse(),
      cursor: first.nextCursor}), h.deps);
    assert.deepEqual(second.contacts.map((c) => c.contactId), ["asha"]);
    assert.equal(second.matchCount, 2);
    assert.equal(second.nextCursor, null);
    await assert.rejects(listOrganizerContactsHandler(h.request({...data,
      query: null,
      segmentIds: ["repeat_attendee"], cursor: first.nextCursor}), h.deps),
    (error: unknown) => error instanceof HttpsError &&
        error.code === "invalid-argument");
  });

test("export respects the same combined selections and search", async () => {
  const h = harness();
  const result = await exportOrganizerContactsHandler(h.request({...selection,
    query: "ar"}), h.deps);
  assert.equal(result.rowCount, 1);
  assert.equal(result.truncated, false);
  assert.match(result.csv, /arya/);
  assert.doesNotMatch(result.csv, /asha|hidden|foreign|wrong-tag/);
});

test("empty facets do not restrict and past attendance works inside OR", () => {
  const trait = {attendedEventCount: 1,
    segmentIds: ["reliable_attendee"]} as OrganizerContactTraitDocument;
  assert.equal(contactMatchesFilters(contactFilterSelection({}), [],
    undefined), true);
  assert.equal(contactMatchesFilters(contactFilterSelection({segmentIds: [
    "new_to_organizer", "past_attendee", "reliable_attendee",
  ]}), [], trait), true);
  assert.equal(contactMatchesFilters(contactFilterSelection({segmentIds: [
    "new_to_organizer", "past_attendee", "needs_confirmation",
  ]}), [], trait), false);
  assert.equal(contactFilterKey(selection), contactFilterKey({
    segmentIds: [...selection.segmentIds].reverse(), manualTagIds: [tagB, tagA],
  }));
});

test("bounded queries fail instead of returning incomplete counts",
  async () => {
    const h = harness();
    for (let i = 0; i < 2501; i++) {
      h.store.docs[`organizerContactTraits/large-${i}`] = {
        organizerId: "org-1", segmentIds: ["repeat_attendee"],
      };
    }
    await assert.rejects(listOrganizerContactsHandler(h.request({...selection}),
      h.deps),
    (error: unknown) => error instanceof HttpsError &&
        error.code === "resource-exhausted");
  });
