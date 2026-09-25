import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {listMyHostAssignmentsHandler} from "./listMyHostAssignments";

const FAR_FUTURE = now.toMillis() + 86_400_000;
const PAST = now.toMillis() - 1_000;

const programGrant = (
  uid: string,
  overrides: FakeData = {},
): FakeData => ({
  organizerId: "org-1",
  programId: "program-1",
  uid,
  displayName: "Staff",
  phoneLastFour: "0000",
  duties: [
    {
      duty: "airportGreeter",
      pickupPointIds: ["pp-t3"],
      hotelIds: [],
      expiresAtMillis: FAR_FUTURE,
    },
  ],
  status: "active",
  createdBy: "manager-1",
  createdAt: now,
  expiresAt: admin.firestore.Timestamp.fromMillis(FAR_FUTURE),
  revokedBy: null,
  revokedAt: null,
  updatedAt: now,
  revision: 1,
  ...overrides,
});

const eventGrant = (
  uid: string,
  role: string,
  overrides: FakeData = {},
): FakeData => ({
  organizerId: "org-2",
  eventId: "event-1",
  uid,
  displayName: "Staff",
  phoneLastFour: "0000",
  role,
  permissions: ["setAttendance"],
  status: "active",
  createdBy: "manager-1",
  createdAt: now,
  expiresAt: admin.firestore.Timestamp.fromMillis(FAR_FUTURE),
  revokedBy: null,
  revokedAt: null,
  updatedAt: now,
  revision: 1,
  ...overrides,
});

const seed = (): Record<string, FakeData> => ({
  "organizers/org-1": {name: "Sharma Weddings", hostUserIds: ["manager-1"]},
  "organizers/org-2": {name: "Catch Mixers", hostUserIds: ["manager-2"]},
  "organizerPrograms/program-1": {
    organizerId: "org-1", title: "Sharma–Rao Wedding", kind: "wedding",
    status: "active", timezone: "Asia/Kolkata", capabilities: [],
    transportSettings: {vehicleClasses: []},
    createdBy: "manager-1", createdAt: now, updatedAt: now, revision: 1,
  },
  "events/event-1": {
    organizerId: "org-2", name: "Winter Mixer",
    createdBy: "manager-2", createdAt: now, updatedAt: now, revision: 1,
  },
  "organizerTeamMemberships/mem-1": {
    organizerId: "org-1", uid: "manager-1", role: "owner",
    status: "active",
  },
  "programStaffGrants/prog_program-1_staff-1": programGrant("staff-1"),
  "eventStaffGrants/estaff_event-1_staff-1":
    eventGrant("staff-1", "checkInOperator"),
});

const list = (db: FakeFirestore, uid: string,
  data: Record<string, unknown> = {}) =>
  listMyHostAssignmentsHandler(request(data, uid), deps(db));

test("staff receive both scopes sorted event-first with resolved shells",
  async () => {
    const out = await list(new FakeFirestore(seed()), "staff-1");
    assert.equal(out.shellEntry, "workShell");
    assert.equal(out.assignments.length, 2);
    const [event, program] = out.assignments;
    // Events sort before programs by scope kind.
    assert.equal(event.kind, "event");
    assert.equal(event.scopeId, "event-1");
    assert.equal(event.title, "Winter Mixer");
    assert.equal(event.organizerName, "Catch Mixers");
    assert.deepEqual(event.duties, [{duty: "functionCheckIn"}]);
    assert.deepEqual(event.destinations, ["door", "walkIns"]);
    assert.equal(event.shellMode, "tabs");
    assert.equal(program.kind, "program");
    assert.equal(program.title, "Sharma–Rao Wedding");
    assert.deepEqual(program.destinations, ["arrivals"]);
    assert.equal(program.shellMode, "task");
    // Station scopes ride along for the client to label.
    assert.deepEqual(program.duties[0].pickupPointIds, ["pp-t3"]);
  });

test("greeter sees dispatch only when dispatcher is also granted", async () => {
  const data = seed();
  data["programStaffGrants/prog_program-1_staff-1"] =
      programGrant("staff-1", {
        duties: [
          {duty: "airportGreeter", pickupPointIds: [], hotelIds: [],
            expiresAtMillis: FAR_FUTURE},
          {duty: "transportDispatcher", pickupPointIds: [], hotelIds: [],
            expiresAtMillis: FAR_FUTURE},
        ],
      });
  const out = await list(new FakeFirestore(data), "staff-1");
  const program = out.assignments.find((a) => a.kind === "program")!;
  assert.deepEqual(program.destinations, ["arrivals", "dispatch"]);
});

test("revoked and expired grants never resolve", async () => {
  const data = seed();
  data["programStaffGrants/prog_program-1_staff-1"] =
      programGrant("staff-1", {status: "revoked"});
  data["eventStaffGrants/estaff_event-1_staff-1"] =
      eventGrant("staff-1", "checkInOperator", {
        expiresAt: admin.firestore.Timestamp.fromMillis(PAST),
      });
  const out = await list(new FakeFirestore(data), "staff-1");
  assert.equal(out.assignments.length, 0);
  assert.equal(out.shellEntry, "none");
});

test("includeExpired returns dead grants with an empty shell", async () => {
  const data = seed();
  data["eventStaffGrants/estaff_event-1_staff-1"] =
      eventGrant("staff-1", "checkInOperator", {
        expiresAt: admin.firestore.Timestamp.fromMillis(PAST),
      });
  const out = await list(
    new FakeFirestore(data), "staff-1", {includeExpired: true});
  const expired = out.assignments.find((a) => a.scopeId === "event-1")!;
  assert.equal(expired.shellMode, "none");
  assert.deepEqual(expired.destinations, []);
  // The live program assignment still resolves normally.
  assert.equal(
    out.assignments.find((a) => a.scopeId === "program-1")?.shellMode,
    "task");
});

test("per-duty expiry drops only the dead duty", async () => {
  const data = seed();
  data["programStaffGrants/prog_program-1_staff-1"] =
      programGrant("staff-1", {
        duties: [
          {duty: "airportGreeter", pickupPointIds: [], hotelIds: [],
            expiresAtMillis: PAST},
          {duty: "hotelDesk", pickupPointIds: [], hotelIds: ["hotel-1"],
            expiresAtMillis: FAR_FUTURE},
        ],
      });
  const out = await list(new FakeFirestore(data), "staff-1");
  const program = out.assignments.find((a) => a.kind === "program")!;
  assert.deepEqual(program.duties.map((d) => d.duty), ["hotelDesk"]);
  assert.deepEqual(program.destinations, ["inbound", "rooms"]);
});

test("archived programs and unknown event roles are skipped", async () => {
  const data = seed();
  data["organizerPrograms/program-1"] = {
    ...(data["organizerPrograms/program-1"] as FakeData),
    status: "archived",
  };
  data["eventStaffGrants/estaff_event-1_staff-1"] =
      eventGrant("staff-1", "unknownRole");
  const out = await list(new FakeFirestore(data), "staff-1");
  assert.equal(out.assignments.length, 0);
  assert.equal(out.shellEntry, "none");
});

test("managers land in the manager shell even with staff grants",
  async () => {
    const data = seed();
    data["programStaffGrants/prog_program-1_manager-1"] =
      programGrant("manager-1");
    const out = await list(new FakeFirestore(data), "manager-1");
    assert.equal(out.shellEntry, "managerShell");
    assert.equal(out.assignments.length, 1);
  });
