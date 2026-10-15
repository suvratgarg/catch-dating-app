import {backfillContactSummaries, activateContactSummaries} from
  "./contactBackfill";
import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {AudienceTestStore} from "../organizers/organizerAudienceTestStore";
import {reconcileContactSummary} from "./contactStore";

function store() {
  return new AudienceTestStore({
    "organizers/org": {hostUserId: "host"},
    "organizerContacts/person": {organizerId: "org", displayName: "Asha",
      phoneE164: null, email: null, displayNameOverride: null,
      searchName: "asha", identityState: "unlinked",
      identityConfidence: "eventOnly", ambiguousCandidateContactIds: [],
      lastSeenAt: Timestamp.fromMillis(123), deletedAt: null,
      hiddenAt: null, revision: 1},
    "organizerContactTraits/person": {organizerId: "org", contactId: "person",
      expectedEventCount: 0, attendedEventCount: 0,
      segmentIds: ["new_to_organizer"], linkedAccount: false,
      importedEventCount: 0, whatsappStatus: "unknown", smsStatus: "unknown",
      lastAttendedAt: null, sourceCoverage: "exact"},
  });
}

test("replays count once; deletion removes view and count", async () => {
  const db = store();
  await reconcileContactSummary(db.asFirestore(), "person");
  await reconcileContactSummary(db.asFirestore(), "person");
  const directory = db.docs["hostDirectorySummaries/org"] as unknown as import(
    "../shared/generated/firestoreAdminTypes"
  ).HostDirectorySummaryDocument;
  assert.equal(directory.summary.contactCount, 1);
  assert.equal(directory.segmentCounts.new_to_organizer, 1);
  assert.equal(directory.contactSummaryVersion, 0);
  delete db.docs["organizerContacts/person"];
  await reconcileContactSummary(db.asFirestore(), "person");
  await reconcileContactSummary(db.asFirestore(), "person");
  assert.equal(db.docs["hostContactSummaries/person"], undefined);
  assert.equal((db.docs["hostDirectorySummaries/org"] as unknown as import(
    "../shared/generated/firestoreAdminTypes"
  ).HostDirectorySummaryDocument)
    .summary.contactCount, 0);
});

test("trait changes move segments without inflating the total", async () => {
  const db = store();
  await reconcileContactSummary(db.asFirestore(), "person");
  Object.assign(db.docs["organizerContactTraits/person"], {
    attendedEventCount: 2, segmentIds: ["past_attendee", "repeat_attendee"]});
  await reconcileContactSummary(db.asFirestore(), "person");
  const directory = db.docs["hostDirectorySummaries/org"] as unknown as import(
    "../shared/generated/firestoreAdminTypes"
  ).HostDirectorySummaryDocument;
  assert.equal(directory.summary.contactCount, 1);
  assert.equal(directory.segmentCounts.new_to_organizer, 0);
  assert.equal(directory.summary.repeatAttendeeCount, 1);
});

test("foreign traits remove stale PII", async () => {
  const db = store();
  await reconcileContactSummary(db.asFirestore(), "person");
  db.docs["organizerContactTraits/person"].organizerId = "foreign";
  await reconcileContactSummary(db.asFirestore(), "person");
  assert.equal(db.docs["hostContactSummaries/person"], undefined);
  assert.equal((db.docs["hostDirectorySummaries/org"] as unknown as import(
    "../shared/generated/firestoreAdminTypes"
  ).HostDirectorySummaryDocument)
    .summary.contactCount, 0);
});

test("late events use current hidden state", async () => {
  const db = store();
  await reconcileContactSummary(db.asFirestore(), "person");
  db.docs["organizerContacts/person"].hiddenAt = Timestamp.fromMillis(456);
  await reconcileContactSummary(db.asFirestore(), "person");
  assert.equal(db.docs["hostContactSummaries/person"], undefined);
});

test("cutover requires parity and rejects missing traits", async () => {
  const db = store();
  await assert.rejects(activateContactSummaries(db.asFirestore(), "org"),
    /parity failed/);
  assert.equal(await backfillContactSummaries(db.asFirestore(), "org", false),
    1);
  assert.equal(db.docs["hostContactSummaries/person"], undefined);
  await backfillContactSummaries(db.asFirestore(), "org", true);
  assert.equal(await activateContactSummaries(db.asFirestore(), "org"), 1);
  assert.equal(db.docs["hostDirectorySummaries/org"].contactSummaryVersion, 1);
  delete db.docs["organizerContactTraits/person"];
  await assert.rejects(activateContactSummaries(db.asFirestore(), "org"),
    /Missing traits/);
});

test("an empty organizer has an explicitly verified zero count", async () => {
  const db = new AudienceTestStore({"organizers/empty": {hostUserId: "host"}});
  assert.equal(await activateContactSummaries(db.asFirestore(), "empty"), 0);
  assert.equal(db.docs["hostDirectorySummaries/empty"]
    .contactSummaryVersion, 1);
});
