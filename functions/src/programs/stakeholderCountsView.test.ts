import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {getProgramStakeholderCountsHandler} from "./stakeholderCountsView";

const DAY = 86_400_000;

const grant = (uid: string, duty: string,
  extra: Record<string, unknown> = {}): FakeData => ({
  organizerId: "org-1",
  programId: "program-1",
  uid,
  displayName: "Viewer",
  phoneLastFour: "0099",
  duties: [{
    duty, expiresAtMillis: 1_800_000_000_000 + DAY,
    pickupPointIds: [], hotelIds: [], ...extra,
  }],
  status: "active",
  createdBy: "manager-1",
  createdAt: now,
  expiresAt: admin.firestore.Timestamp.fromMillis(1_800_000_000_000 + DAY),
  revokedBy: null,
  revokedAt: null,
  updatedAt: now,
  revision: 1,
});

const fn = (id: string, patch: Record<string, unknown> = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  name: `Function ${id}`,
  status: "scheduled",
  invitationMode: "allGuests",
  checkInEnabled: true,
  startsAt: admin.firestore.Timestamp.fromMillis(1_800_100_000_000),
  endsAt: admin.firestore.Timestamp.fromMillis(1_800_110_000_000),
  venueName: null,
  venueNotes: null,
  dressCode: null,
  instructions: null,
  expectedCount: 0,
  checkedInCount: 0,
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const joinRow = (functionId: string, guestId: string,
  patch: Record<string, unknown> = {}): FakeData => ({
  programId: "program-1",
  organizerId: "org-1",
  functionId,
  guestId,
  invited: true,
  rsvpStatus: "pending",
  attendanceStatus: "expected",
  partySize: null,
  respondedAt: null,
  responseNote: null,
  responseSource: null,
  recordedByUid: null,
  createdAt: now,
  updatedAt: now,
  revision: 1,
  ...patch,
});

const seed = () => ({
  ...baseSeed(),
  "programHouseholds/hh-1": {
    programId: "program-1", organizerId: "org-1", label: "Family",
    primaryContactName: "Contact", primaryPhoneE164: "+919900000000",
    primaryEmail: null, memberGuestIds: ["guest-1"],
    deliveryPreference: "none",
    createdAt: now, updatedAt: now, revision: 1,
  },
  "programFunctions/fn-1": fn("fn-1"),
  "programFunctions/fn-2": fn("fn-2",
    {invitationMode: "selectedGuests"}),
  "programFunctionGuests/fn-2_guest-1": joinRow("fn-2", "guest-1",
    {rsvpStatus: "attending", partySize: 2}),
  "programStaffGrants/program-1__viewer-1": grant(
    "viewer-1", "stakeholderViewer"),
  "programStaffGrants/program-1__viewer-hotel": grant(
    "viewer-hotel", "stakeholderViewer", {hotelIds: ["hotel-1"]}),
});

const view = (db: FakeFirestore, uid = "viewer-1") =>
  getProgramStakeholderCountsHandler(
    request({programId: "program-1"}, uid), deps(db));

test("stakeholderViewer gets headcounts, function histograms, and occupancy",
  async () => {
    const res = await view(new FakeFirestore(seed()));
    assert.equal(res.programId, "program-1");
    assert.equal(res.guestCount, 2);
    assert.equal(res.householdCount, 1);
    // No PII crosses: only ids and counts.
    assert.deepEqual(
      Object.keys(res.functions[0]).sort(),
      ["checkedInHeads", "expectedHeads", "functionId", "invitedCount",
        "noShowCount", "rsvpAttending", "rsvpDeclined", "rsvpMaybe",
        "rsvpPending", "status"].sort());

    const fn1 = res.functions.find((f) => f.functionId === "fn-1")!;
    assert.deepEqual(
      [fn1.invitedCount, fn1.rsvpPending, fn1.expectedHeads], [2, 2, 0]);
    const fn2 = res.functions.find((f) => f.functionId === "fn-2")!;
    // selectedGuests: only the invited row counts; partySize feeds heads.
    assert.equal(fn2.invitedCount, 1);
    assert.equal(fn2.rsvpAttending, 1);
    assert.equal(fn2.expectedHeads, 2);

    // Both baseSeed legs route to hotel-1 for distinct guests.
    const hotel1 = res.hotels.find((h) => h.hotelId === "hotel-1")!;
    assert.equal(hotel1.routedGuestCount, 2);
    assert.equal(hotel1.arrivedGuestCount, 0);
    assert.equal(hotel1.legCount, 2);

    // Staff expiry surfaces the earliest contributing duty deadline.
    assert.equal(res.accessExpiresAtMillis, 1_800_000_000_000 + DAY);
  });

test("hotel-scoped viewers only see occupancy for granted hotels", async () => {
  const db = new FakeFirestore({...seed(),
    "programTravelLegs/leg-hotel2": {
      ...baseSeed()["programTravelLegs/leg-1"],
      guestId: "guest-2", destinationHotelId: "hotel-2",
      readiness: "arrived",
    }});
  const res = await view(db, "viewer-hotel");
  assert.deepEqual(res.hotels.map((h) => h.hotelId), ["hotel-1"]);
  // Program-wide headcounts are still whole — the scope is occupancy-only.
  assert.equal(res.guestCount, 2);
});

test("managers bypass duties and get an unscoped view", async () => {
  const db = new FakeFirestore({...seed(),
    "programTravelLegs/leg-hotel2": {
      ...baseSeed()["programTravelLegs/leg-1"],
      guestId: "guest-2", destinationHotelId: "hotel-2",
    }});
  const res = await view(db, "manager-1");
  assert.equal(res.accessExpiresAtMillis, null);
  assert.deepEqual(res.hotels.map((h) => h.hotelId),
    ["hotel-1", "hotel-2"]);
});

test("staff without the stakeholderViewer duty are denied", async () => {
  await assert.rejects(view(new FakeFirestore(seed()), "greeter-1"),
    (error: unknown) => (error as {code?: string}).code ===
      "permission-denied");
  await assert.rejects(view(new FakeFirestore(seed()), "outsider-1"),
    (error: unknown) => (error as {code?: string}).code ===
      "permission-denied");
});

test("rows from other programs never leak into the counts", async () => {
  const db = new FakeFirestore({...seed(),
    "programGuests/foreign": {
      ...baseSeed()["programGuests/guest-1"], programId: "program-9",
    },
    "programTravelLegs/foreign": {
      ...baseSeed()["programTravelLegs/leg-1"],
      programId: "program-9", destinationHotelId: "hotel-1",
    }});
  const res = await view(db);
  assert.equal(res.guestCount, 2);
  assert.equal(res.hotels.find((h) => h.hotelId === "hotel-1")!.legCount, 2);
});
