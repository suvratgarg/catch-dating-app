import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore, type FakeData} from
  "../shared/testing/programFirestore";
import {listProgramStaffAttentionHandler} from "./programStaffAttention";

const FUTURE = now.toMillis() + 86_400_000;

const grant = (uid: string, duties: FakeData[],
  displayName = "Staff"): FakeData => ({
  organizerId: "org-1",
  programId: "program-1",
  uid,
  displayName,
  phoneLastFour: "0000",
  duties,
  status: "active",
  createdBy: "manager-1",
  createdAt: now,
  expiresAt: admin.firestore.Timestamp.fromMillis(FUTURE),
  revokedBy: null,
  revokedAt: null,
  updatedAt: now,
  revision: 1,
});

const duty = (name: string): FakeData => ({
  duty: name,
  pickupPointIds: [],
  hotelIds: [],
  expiresAtMillis: FUTURE,
});

const send = (id: string, patch: FakeData = {}): FakeData => ({
  momentId: "m-late",
  recipientKey: `k-${id}`,
  decision: "sent",
  dayKey: "2027-02-20",
  createdAtMillis: now.toMillis() - 60_000,
  runId: `run-${id}`,
  actionKind: "staffAttention",
  organizerId: "org-1",
  scopeKind: "program",
  scopeId: "program-1",
  duty: "functionLead",
  severity: "warning",
  title: `Late arrival — escort to Sangeet (${id})`,
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
  "programStaffGrants/program-1__lead-1":
    grant("lead-1", [duty("functionLead")], "Lead One"),
  "programStaffGrants/program-1__coord-1":
    grant("coord-1", [duty("programCoordinator")], "Coord"),
  "programStaffGrants/program-1__greeter-1":
    grant("greeter-1", [duty("airportGreeter")], "Greeter"),
  // Fanout: the same run addressed two function leads.
  "organizerMomentSends/run-a_lead-a": send("a",
    {runId: "run-a", title: "Late arrival at hotel — escort to Sangeet"}),
  "organizerMomentSends/run-a_lead-b": send("b",
    {runId: "run-a", title: "Late arrival at hotel — escort to Sangeet"}),
  // A different duty's alert the function lead must not see.
  "organizerMomentSends/run-c_disp": send("c",
    {runId: "run-c", duty: "transportDispatcher", severity: "urgent",
      title: "Flight disruption — rework transport"}),
  // A second function-lead alert from a different run.
  "organizerMomentSends/run-d_lead-a": send("d",
    {runId: "run-d", duty: "functionLead",
      createdAtMillis: now.toMillis() - 30_000,
      title: "Late arrival at hotel — escort to Mehndi"}),
  // Scoped to a different program — invisible here.
  "organizerMomentSends/run-e_lead-a": send("e",
    {runId: "run-e", scopeId: "program-9", title: "Other program alert"}),
  // Event-scoped send — invisible here.
  "organizerMomentSends/run-f_lead-a": send("f",
    {runId: "run-f", scopeKind: "event", scopeId: "event-1"}),
  // Outside the 24h attention window — invisible here.
  "organizerMomentSends/run-g_lead-a": send("g",
    {runId: "run-g", duty: "functionLead",
      createdAtMillis: now.toMillis() - 26 * 60 * 60 * 1000}),
  // A non-attention send sharing the organizer — invisible here.
  "organizerMomentSends/run-h_guest": {
    momentId: "m-rsvp", recipientKey: "k-guest", decision: "sent",
    dayKey: "2027-02-20", createdAtMillis: now.toMillis() - 10_000,
  },
});

const list = (db: FakeFirestore, uid: string) =>
  listProgramStaffAttentionHandler(
    request({programId: "program-1"}, uid), deps(db));

const denied = (err: unknown) =>
  (err as {code?: string}).code === "permission-denied";

test("function leads read program attention deduplicated per run", async () => {
  const result = await list(new FakeFirestore(seed()), "lead-1");
  assert.equal(result.programId, "program-1");
  assert.equal(result.truncated, false);
  // run-a fanout collapses; transport/other-program/event/expired rows drop.
  const runIds = result.items.map((i) => i.runId).sort();
  assert.deepEqual(runIds, ["run-a", "run-d"]);
  const runA = result.items.find((i) => i.runId === "run-a")!;
  assert.equal(runA.itemId, "run-a_functionLead");
  assert.equal(runA.severity, "warning");
  // Newest first.
  assert.equal(result.items[0].runId, "run-d");
});

test("coordinators see every duty's program alerts", async () => {
  const result = await list(new FakeFirestore(seed()), "coord-1");
  const runIds = result.items.map((i) => i.runId).sort();
  assert.deepEqual(runIds, ["run-a", "run-c", "run-d"]);
  const dispatch = result.items.find((i) => i.runId === "run-c")!;
  assert.equal(dispatch.duty, "transportDispatcher");
  assert.equal(dispatch.severity, "urgent");
});

test("managers read the program's full alert stream", async () => {
  const result = await list(new FakeFirestore(seed()), "manager-1");
  assert.equal(result.items.length, 3);
});

test("staff without the functionLead duty are denied", async () => {
  await assert.rejects(
    list(new FakeFirestore(seed()), "greeter-1"), denied);
});

test("accounts with no program access are denied", async () => {
  await assert.rejects(
    list(new FakeFirestore(seed()), "stranger-1"), denied);
});
