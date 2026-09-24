import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {deps as baseDeps, request, now} from
  "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {
  getProgramHouseholdRsvpViewHandler,
  issueProgramHouseholdRsvpLinkHandler,
  submitProgramHouseholdRsvpHandler,
} from "./householdRsvp";
import {mintHouseholdToken} from "./rsvpLinkTokens";

const SECRET = "test-household-secret";
const FUTURE = now.toMillis() + 86_400_000;

const deps = (db: FakeFirestore) => baseDeps(db,
  {householdTokenSecret: () => SECRET});

const fn = (id: string, patch: FakeData = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  name: id,
  startsAt: admin.firestore.Timestamp.fromMillis(1_800_600_000_000),
  endsAt: admin.firestore.Timestamp.fromMillis(1_800_603_000_000),
  venueName: "Venue",
  venueNotes: null,
  venueLocation: null,
  dressCode: null,
  instructions: null,
  invitationMode: "allGuests",
  checkInEnabled: true,
  expectedCount: 0,
  checkedInCount: 0,
  status: "scheduled",
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const guest = (id: string, householdId: string | null,
  patch: FakeData = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  displayName: id,
  householdId,
  contactId: null,
  phoneE164: null,
  email: null,
  externalReference: null,
  invitationStatus: "invited",
  rsvpStatus: "pending",
  source: "manual",
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const seed = (): Record<string, FakeData> => ({
  "organizers/org-1": {
    hostUserId: "manager-1", ownerUserId: "manager-1",
    hostUserIds: ["manager-1"], hostProfiles: [],
  },
  "organizerPrograms/program-1": {
    organizerId: "org-1", kind: "wedding", title: "Wedding",
    timezone: "Asia/Kolkata", status: "active", capabilities: [],
    transportSettings: {vehicleClasses: []},
    startsAt: admin.firestore.Timestamp.fromMillis(1_800_600_000_000),
    endsAt: admin.firestore.Timestamp.fromMillis(1_800_900_000_000),
    createdBy: "manager-1", createdAt: now, updatedAt: now, revision: 1,
  },
  "programFunctions/fn-sangeet": fn("fn-sangeet"),
  "programFunctions/fn-mehndi": fn("fn-mehndi",
    {invitationMode: "selectedGuests",
      startsAt: admin.firestore.Timestamp.fromMillis(
        1_800_700_000_000),
      endsAt: admin.firestore.Timestamp.fromMillis(
        1_800_703_000_000)}),
  "programFunctions/fn-cancelled": fn("fn-cancelled",
    {status: "cancelled"}),
  "programGuests/g-1": guest("g-1", "hh-1"),
  "programGuests/g-2": guest("g-2", "hh-1"),
  "programGuests/g-3": guest("g-3", "hh-2"),
  "programHouseholds/hh-1": {
    programId: "program-1", organizerId: "org-1", label: "Sharma family",
    primaryContactName: "Ashok", primaryPhoneE164: "+919900000001",
    primaryEmail: null, memberGuestIds: ["g-1", "g-2"],
    deliveryPreference: "none", messagingConsent: null,
    createdAt: now, updatedAt: now, revision: 1,
  },
  "programHouseholds/hh-2": {
    programId: "program-1", organizerId: "org-1", label: "Rao family",
    primaryContactName: "Meena", primaryPhoneE164: "+919900000002",
    primaryEmail: null, memberGuestIds: ["g-3"],
    deliveryPreference: "none", messagingConsent: null,
    createdAt: now, updatedAt: now, revision: 1,
  },
  "programFunctionGuests/fn-mehndi_g-2": {
    programId: "program-1", organizerId: "org-1",
    functionId: "fn-mehndi", guestId: "g-2",
    invited: true, rsvpStatus: "pending", attendanceStatus: "expected",
    partySize: null, responseNote: null, respondedAt: null,
    responseSource: null, recordedByUid: null,
    createdAt: now, updatedAt: now, revision: 1,
  },
  "programStaffGrants/program-1__staff-1": {
    organizerId: "org-1", programId: "program-1", uid: "staff-1",
    displayName: "Staff", phoneLastFour: "0000",
    duties: [{duty: "guestRelations", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: FUTURE}],
    status: "active", createdBy: "manager-1", createdAt: now,
    expiresAt: admin.firestore.Timestamp.fromMillis(FUTURE),
    revokedBy: null, revokedAt: null, updatedAt: now, revision: 1,
  },
});

const token = (householdId = "hh-1") => mintHouseholdToken({
  programId: "program-1", householdId, expiresAtMillis: FUTURE,
}, SECRET);

test("issue link returns a token scoped to the household", async () => {
  const db = new FakeFirestore(seed());
  const out = await issueProgramHouseholdRsvpLinkHandler(request({
    programId: "program-1", householdId: "hh-1",
  }, "staff-1"), deps(db));
  assert.equal(out.entityId, "hh-1");
  // Program end is the default expiry.
  assert.equal(out.expiresAtMillis, 1_800_900_000_000);
  // The minted token opens the view.
  const view = await getProgramHouseholdRsvpViewHandler(
    request({token: out.token}, "anonymous"), deps(db));
  assert.equal(view.householdId, "hh-1");
});

test("view exposes only the household members and invited functions",
  async () => {
    const db = new FakeFirestore(seed());
    const view = await getProgramHouseholdRsvpViewHandler(
      request({token: token()}, "anonymous"), deps(db));
    assert.equal(view.programTitle, "Wedding");
    assert.equal(view.householdLabel, "Sharma family");
    assert.equal(view.messagingConsentGranted, false);
    assert.equal(view.members.length, 2);
    const [g1, g2] = view.members;
    // g-1: allGuests function only — fn-mehndi is selectedGuests and
    // g-1 has no invited row; cancelled never appears.
    assert.deepEqual(g1.functions.map((f) => f.functionId),
      ["fn-sangeet"]);
    assert.equal(g1.functions[0].rsvpStatus, "pending");
    // g-2 has an invited row on the selectedGuests function.
    assert.deepEqual(g2.functions.map((f) => f.functionId),
      ["fn-sangeet", "fn-mehndi"]);
  });

test("submit lands member responses, rollups and explicit consent",
  async () => {
    const db = new FakeFirestore(seed());
    const out = await submitProgramHouseholdRsvpHandler(request({
      token: token(),
      responses: [
        {guestId: "g-1", functionId: "fn-sangeet",
          rsvpStatus: "attending", partySize: 2},
        {guestId: "g-2", functionId: "fn-mehndi",
          rsvpStatus: "declined"},
      ],
      messagingConsent: true,
    }, "anonymous"), deps(db));
    assert.equal(out.appliedCount, 2);
    assert.equal(out.messagingConsentGranted, true);
    const sangeet = db.getDoc("programFunctionGuests/fn-sangeet_g-1")!;
    assert.equal(sangeet.rsvpStatus, "attending");
    assert.equal(sangeet.responseSource, "householdLink");
    assert.equal(sangeet.recordedByUid, null);
    assert.equal(
      db.getDoc("programFunctionGuests/fn-mehndi_g-2")!.rsvpStatus,
      "declined");
    // Function counters and guest rollups derived.
    assert.equal(db.getDoc("programFunctions/fn-sangeet")!.expectedCount,
      2);
    assert.equal(db.getDoc("programGuests/g-1")!.rsvpStatus, "attending");
    assert.equal(db.getDoc("programGuests/g-2")!.rsvpStatus, "declined");
    const hh = db.getDoc("programHouseholds/hh-1")!;
    const consent = hh.messagingConsent as
      {granted: boolean; source: string};
    assert.equal(consent.granted, true);
    assert.equal(consent.source, "householdRsvpLink");
  });

test("submit rejects cross-household and uninvited responses",
  async () => {
    const db = new FakeFirestore(seed());
    const foreign = submitProgramHouseholdRsvpHandler(request({
      token: token(),
      responses: [{guestId: "g-3", functionId: "fn-sangeet",
        rsvpStatus: "attending"}],
      messagingConsent: false,
    }, "anonymous"), deps(db));
    await assert.rejects(foreign, (err) =>
      (err as {code?: string}).code === "permission-denied");
    // g-1 is not invited to the selectedGuests function.
    const uninvited = submitProgramHouseholdRsvpHandler(request({
      token: token(),
      responses: [{guestId: "g-1", functionId: "fn-mehndi",
        rsvpStatus: "attending"}],
      messagingConsent: false,
    }, "anonymous"), deps(db));
    await assert.rejects(uninvited, (err) =>
      (err as {code?: string}).code === "permission-denied");
    // Nothing landed.
    assert.equal(db.getDoc("programFunctionGuests/fn-mehndi_g-1"),
      undefined);
    assert.equal(
      db.getDoc("programHouseholds/hh-1")!.messagingConsent, null);
  });

test("bad, expired and foreign tokens never open a view", async () => {
  const db = new FakeFirestore(seed());
  const bad = getProgramHouseholdRsvpViewHandler(
    request({token: `${token()}x`}, "anonymous"), deps(db));
  await assert.rejects(bad, (err) =>
    (err as {code?: string}).code === "unauthenticated");
  const expired = mintHouseholdToken({
    programId: "program-1", householdId: "hh-1",
    expiresAtMillis: now.toMillis() - 1,
  }, SECRET);
  await assert.rejects(
    getProgramHouseholdRsvpViewHandler(
      request({token: expired}, "anonymous"), deps(db)),
    (err) => (err as {code?: string}).code === "unauthenticated");
  // hh-2's token must not reach hh-1's members.
  const view = await getProgramHouseholdRsvpViewHandler(
    request({token: token("hh-2")}, "anonymous"), deps(db));
  assert.equal(view.members.length, 1);
  assert.equal(view.members[0].guestId, "g-3");
});
