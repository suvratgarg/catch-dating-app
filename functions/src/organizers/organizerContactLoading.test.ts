import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getOrganizerContactDetailHandler} from "./organizerContacts";
import {AudienceTestStore} from "./organizerAudienceTestStore";

const operationalCollections = [
  "organizerCampaignRecipients", "organizerBroadcastSummaries",
  "organizerManualSendTasks", "organizerWhatsappMessages",
  "organizerContactMergeReceipts",
];

function harness(includeHistory?: boolean) {
  const collections: string[] = [];
  const store = new AudienceTestStore({
    "organizers/org-1": {ownerUserId: "host-1", hostUserIds: ["host-1"],
      hostProfiles: []},
    "organizerContacts/person": {organizerId: "org-1", contactId: "person",
      displayName: "Ananya", displayNameOverride: null, linkedUid: null,
      phoneE164: null, email: null, identityState: "unlinked",
      identityConfidence: "eventOnly", ambiguousCandidateContactIds: [],
      manualTagIds: [], deletedAt: null, hiddenAt: null, revision: 1},
    "organizerContactTraits/person": {organizerId: "org-1",
      expectedEventCount: 0, attendedEventCount: 0, cancelledEventCount: 0,
      noShowCount: 0, importedEventCount: 0, attendanceRate: null,
      segmentIds: [], whatsappStatus: "unknown", smsStatus: "unknown",
      sourceCoverage: "exact"},
  });
  const collection = store.collection.bind(store);
  store.collection = (name) => {
    collections.push(name);
    return collection(name);
  };
  const request = {auth: {uid: "host-1"}, data: {organizerId: "org-1",
    contactId: "person", ...(includeHistory === undefined ? {} :
      {includeHistory})}} as CallableRequest<unknown>;
  const deps = {firestore: () => store.asFirestore(),
    checkRateLimit: async () => undefined, identitySecret: () => "unused"};
  return {store, collections, request, deps};
}

test("overview skips history reads and retains customer facts", async () => {
  const h = harness(false);
  const result = await getOrganizerContactDetailHandler(h.request, h.deps);
  assert.equal(result.displayName, "Ananya");
  assert.equal(result.historyLoaded, false);
  assert.deepEqual(result.timeline, []);
  assert.equal(result.timelineCoverage.events, "unavailable");
  for (const name of operationalCollections) {
    assert.equal(h.collections.includes(name), false, `${name} was read`);
  }
  assert.ok(h.collections.includes("organizerContactEventEdges"));
  assert.ok(h.collections.includes("organizerContactNotes"));
});

test("legacy and explicit history requests read operations", async () => {
  for (const includeHistory of [undefined, true]) {
    const h = harness(includeHistory);
    const result = await getOrganizerContactDetailHandler(h.request, h.deps);
    assert.equal(result.historyLoaded, true);
    for (const name of operationalCollections) {
      assert.ok(h.collections.includes(name), `${name} was omitted`);
    }
  }
});

test("deferred overview keeps cross-organizer access closed", async () => {
  const h = harness(false);
  h.store.docs["organizerContacts/person"].organizerId = "other";
  await assert.rejects(getOrganizerContactDetailHandler(h.request, h.deps),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "not-found");
});
