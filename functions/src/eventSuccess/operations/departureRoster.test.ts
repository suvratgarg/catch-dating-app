import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync} from "node:fs";
import {randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore, Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import type {EventAssistanceDepartureRosterCallableResponse as Response} from
  "../../shared/generated/eventAssistanceDepartureRosterCallableResponse";
import {validateEventAssistanceCommand} from
  "../../shared/generated/validators/eventAssistanceCommand";
import {validateEventAssistanceDepartureRosterDocument} from
  "../../shared/generated/validators/eventAssistanceDepartureRosterDocument";
import {EventDepartureRosterStore} from "./departureRosterStore";
import {getEventAssistanceDepartureRosterHandler} from
  "./departureRosterHandlers";
import {DEPARTURE_ROSTERS} from "./departureRosterSource";
import {EventGroupProgressStore} from "./groupProgressStore";
import {ProgressFirestore, seedJoiningProgress, progressFixtureManager} from
  "./groupProgressTestFixtures";
import {GuestAssistanceStore} from "./guestAssistanceStore";
import {EventMembershipStore} from "./membershipStore";
import {EventGroupStaffStore} from "./groupStaffStore";
import {guestCollections, guestIdentity} from "./guestRecords";

const manager = progressFixtureManager;
const start = 1_000_000;
async function harness(real?: Firestore) {
  const fake = new ProgressFirestore();
  const db = real ?? fake as unknown as Firestore;
  const id = randomUUID();
  const context = {mode: "live" as const, eventId: "e-" + id,
    organizerId: "o-" + id};
  const scope = {context, groupId: "event:whole"};
  const seed = await seedJoiningProgress(db, context, start, 3_000_000);
  const attendeeId = "a-" + id;
  const attendee = {...JSON.parse(readFileSync(
    "../contracts/fixtures/valid/event_attendee_doc.json", "utf8")),
  eventId: context.eventId, organizerId: context.organizerId,
  clubId: context.organizerId, status: "checkedIn", linkedUid: null,
  checkedInAt: Timestamp.fromMillis(start - 100), checkedInBy: manager,
  attendanceRevision: 7, createdAt: Timestamp.fromMillis(start - 1000),
  updatedAt: Timestamp.fromMillis(start - 100)};
  const put = async (path: string, value: object) => {
    if (real) await db.doc(path).set(value);
    else fake.write(path, value as Record<string, unknown>);
  };
  const read = async (path: string) => real ?
    (await db.doc(path).get()).data() : fake.read(path);
  const attendeePath = "eventAttendees/" + attendeeId;
  await put(attendeePath, attendee);
  const clock = {now: start};
  const store = new EventDepartureRosterStore(db, () => clock.now);
  const progress = new EventGroupProgressStore(db, () => clock.now);
  const guests = new GuestAssistanceStore(db, () => clock.now);
  const membership = new EventMembershipStore(db, () => clock.now);
  const staff = new EventGroupStaffStore(db, () => clock.now);
  const review = (ids = [attendeeId], actor = manager,
    groupId = scope.groupId) => store.get(actor, {...scope, groupId,
    attendeeIds: ids});
  async function command(ids = [attendeeId], actor = manager,
    groupId = scope.groupId) {
    const view = (await progress.get(actor, {...scope, groupId})).view;
    const roster = await review(ids, actor, groupId);
    return {expectedSourceHash: view.sourceHash, command: {
      kind: "confirmDeparture" as const, context, eventId: context.eventId,
      operationId: randomUUID(), payload: {groupId,
        destination: view.destinations.find((d) =>
          d.target.kind !== "fixedPlace")!.target,
        expectedProgressRevision: view.revision,
        departureRoster: roster.selection}}};
  }
  async function groups() {
    await put("events/" + context.eventId, {...seed.event, eventFormat: {
      version: 1, activityKind: "socialRun", interactionModel: "pacePods",
      activityDetails: {routePlan: {version: 2, movementMode: "run",
        routeShape: "loop", groupStrategy: "paceGroups",
        stopCadence: "hostedStops", stopKinds: ["regroup"],
        roleKinds: ["pacer", "sweep"], path: [
          {latitude: 22.7, longitude: 75.8},
          {latitude: 22.8, longitude: 75.8}],
        paceGroups: ["easy", "fast"].map((id, sortOrder) =>
          ({id, label: id, sortOrder}))}}}});
    await guests.startEpisode(context, attendeeId, "begin", null);
  }
  async function place(groupId: string) {
    const view = (await membership.get(manager, {context, attendeeId})).view;
    await membership.transfer(manager, {expectedSourceHash: view.sourceHash,
      command: {kind: "transferGroup", context, eventId: context.eventId,
        operationId: randomUUID(), payload: {attendeeId,
          episodeId: view.episodeId, expectedMembershipRevision: view.revision,
          expectedParticipationRevision: view.participationRevision,
          decision: {kind: "place", groupId}}}});
  }
  async function grant(uid: string, groupId: string,
    duty: "lead" | "pacer" | "sweep", until = start + 100_000) {
    const target = {uid, displayName: "Crew", phoneLastFour: "1234"};
    const view = (await staff.get(manager, target, {context, groupId})).view;
    await staff.set(manager, target, {context, groupId,
      phoneNumber: "+919999991234", expectedUid: uid,
      expectedRevision: view.revision, expectedSourceHash: view.sourceHash,
      requestId: randomUUID(), decision: {kind: "assign", duty,
        expiresAtMillis: until}});
  }
  return {fake, db, scope, seed, attendeeId, attendee, attendeePath,
    clock, store, progress, guests, membership, put, read, review, command,
    groups, place, grant};
}

test("explicit departure selection and immutable roster commit together once",
  async () => {
    const h = await harness();
    // A checked-in person omitted from the explicit selection is not inferred.
    await h.put("eventAttendees/omitted", h.attendee);
    const before = h.fake.entries();
    const input = await h.command();
    assert.deepEqual(h.fake.entries(), before);
    assert.ok(validateEventAssistanceCommand(input.command));
    h.fake.failNextCommit = true;
    await assert.rejects(h.progress.confirmDeparture(manager, input),
      /interruption/);
    assert.deepEqual(h.fake.entries(), before);
    const result = await h.progress.confirmDeparture(manager, input);
    const id = result.view.progress!.departureRosterId!;
    const manifest = await h.read(DEPARTURE_ROSTERS + "/" + id);
    assert.ok(validateEventAssistanceDepartureRosterDocument(manifest));
    assert.equal(manifest.progressRevision, result.operationRevision);
    assert.deepEqual(manifest.members.map((m) => m.attendeeId), [h.attendeeId]);
    assert.equal(manifest.members[0].episodeId, null);
    assert.equal(manifest.members[0].membershipHash, null);
    assert.deepEqual(await h.read(h.attendeePath),
      before.find(([path]) => path === h.attendeePath)![1]);
    assert.equal(h.fake.entries().filter(([p]) =>
      p.startsWith(guestCollections.guests + "/")).length, 0);
    const saved = h.fake.entries();
    assert.equal((await h.progress.confirmDeparture(manager, input)).outcome,
      "replayed");
    assert.deepEqual(h.fake.entries(), saved);
    const next = await h.progress.confirmDeparture(manager,
      await h.command([]));
    assert.notEqual(next.view.progress!.departureRosterId, id);
    assert.deepEqual(await h.read(DEPARTURE_ROSTERS + "/" + id), manifest);
    const replay = await h.progress.confirmDeparture(manager, input);
    assert.equal(replay.operationRevision, result.operationRevision);
    assert.equal(replay.view.revision, next.view.revision);
    await assert.rejects(h.progress.confirmDeparture(manager, {...input,
      command: {...input.command, payload: {...input.command.payload,
        departureRoster: {...input.command.payload.departureRoster,
          attendeeIds: []}}}}), {code: "aborted"});
  });

test("unrecorded departures and confirmed empty rosters stay distinct",
  async () => {
    const h = await harness();
    assert.equal(h.seed.view.progress!.departureRosterId, undefined);
    const first = await h.progress.confirmDeparture(manager,
      await h.command([]));
    const roster = await h.read(DEPARTURE_ROSTERS + "/" +
      first.view.progress!.departureRosterId);
    assert.deepEqual(roster!.members, []);
    const input = await h.command();
    const {departureRoster, ...payload} = input.command.payload;
    void departureRoster;
    const latest = await h.progress.confirmDeparture(manager, {...input,
      command: {...input.command, payload}});
    assert.equal(latest.view.progress!.departureRosterId, undefined);
    assert.deepEqual((await h.read(DEPARTURE_ROSTERS + "/" +
      first.view.progress!.departureRosterId))!.members, []);
  });

test("changed check-in, roster generation or progress invalidates selection",
  async () => {
    for (const change of ["visit", "revision", "generation", "progress",
      "episode"] as const) {
      const h = await harness();
      const input = await h.command();
      if (change === "visit") {
        await h.put(h.attendeePath, {...h.attendee,
          checkedInAt: new Timestamp(999, 900_000_001)});
      } else if (change === "revision") {
        await h.put(h.attendeePath, {...h.attendee, attendanceRevision: 9});
      } else if (change === "generation") {
        h.fake.generation = Timestamp.fromMillis(2);
      } else if (change === "episode") {
        await h.guests.startEpisode(h.scope.context, h.attendeeId,
          "new-episode", null);
      } else {
        await h.progress.confirmDeparture(manager, await h.command([]));
      }
      await assert.rejects(h.progress.confirmDeparture(manager, input),
        {code: "aborted"});
    }
  });

test("selection rejects unadmitted, cancelled, absent or foreign roster rows",
  async () => {
    const h = await harness();
    for (const status of ["registered", "invited", "waitlisted", "cancelled"]) {
      await h.put(h.attendeePath, {...h.attendee, status});
      await assert.rejects(h.review(), {code: "failed-precondition"});
    }
    for (const row of [
      {...h.attendee, checkedInAt: null},
      {...h.attendee, checkedInAt: Timestamp.fromMillis(start + 1)},
      {...h.attendee, eventId: "other"},
      {...h.attendee, organizerId: "other"},
    ]) {
      await h.put(h.attendeePath, row);
      await assert.rejects(h.review(), {code: "failed-precondition"});
    }
    await assert.rejects(h.review(["missing"]), {code: "failed-precondition"});
  });

test("reported intentions and contact updates are not physical roster facts",
  async () => {
    const h = await harness();
    await h.guests.startEpisode(h.scope.context, h.attendeeId, "begin", null);
    const input = await h.command();
    const path = guestCollections.guests + "/" +
      guestIdentity(h.scope.context, h.attendeeId);
    const guest = (await h.read(path))!;
    await h.put(path, {...guest, intention: {kind: "notComing"},
      revision: Number(guest.revision) + 1});
    await h.put(h.attendeePath, {...h.attendee,
      updatedAt: Timestamp.fromMillis(start)});
    const result = await h.progress.confirmDeparture(manager, input);
    const manifest = (await h.read(DEPARTURE_ROSTERS + "/" +
      result.view.progress!.departureRosterId))!;
    const text = JSON.stringify(manifest);
    assert.doesNotMatch(text, /phone|email|displayName|notComing|linkedUid/);
    assert.deepEqual((await h.read(path))!.intention, {kind: "notComing"});
  });

test("pace departure requires accepted membership and current group duty",
  async () => {
    const h = await harness();
    await h.groups();
    await h.grant("pacer", "easy", "pacer");
    await h.grant("sweep", "easy", "sweep");
    await assert.rejects(h.review([h.attendeeId], "pacer", "easy"),
      {code: "failed-precondition"});
    await h.place("fast");
    await assert.rejects(h.review([h.attendeeId], "pacer", "easy"),
      {code: "failed-precondition"});
    // Place cannot overwrite an accepted membership; leave before re-placement.
    const view = (await h.membership.get(manager, {context: h.scope.context,
      attendeeId: h.attendeeId})).view;
    await h.membership.transfer(manager, {expectedSourceHash: view.sourceHash,
      command: {kind: "transferGroup", context: h.scope.context,
        eventId: h.scope.context.eventId, operationId: randomUUID(), payload: {
          attendeeId: h.attendeeId, episodeId: view.episodeId,
          expectedMembershipRevision: view.revision,
          expectedParticipationRevision: view.participationRevision,
          decision: {kind: "leave"}}}});
    await h.place("easy");
    const input = await h.command([h.attendeeId], "pacer", "easy");
    await assert.rejects(h.progress.confirmDeparture("sweep", input),
      {code: "permission-denied"});
    const result = await h.progress.confirmDeparture("pacer", input);
    const manifest = await h.read(DEPARTURE_ROSTERS + "/" +
      result.view.progress!.departureRosterId);
    assert.ok(validateEventAssistanceDepartureRosterDocument(manifest));
    assert.ok(manifest.members[0].episodeId);
    assert.match(manifest.members[0].membershipHash!, /^[a-f0-9]{64}$/);
    h.clock.now = start + 100_000;
    await assert.rejects(h.progress.confirmDeparture("pacer", input),
      {code: "permission-denied"});
  });

test("participation breaks and revoked membership withhold a reviewed roster",
  async () => {
    for (const state of ["temporaryBreak", "departed"] as const) {
      const h = await harness();
      await h.guests.startEpisode(h.scope.context, h.attendeeId, "begin", null);
      const input = await h.command();
      const path = guestCollections.guests + "/" +
        guestIdentity(h.scope.context, h.attendeeId);
      const guest = (await h.read(path))!;
      await h.put(path, {...guest, participation: {state, resumeAtUnit: null},
        revision: Number(guest.revision) + 1});
      await assert.rejects(h.progress.confirmDeparture(manager, input),
        {code: "failed-precondition"});
    }
    const h = await harness();
    await h.groups();
    await h.place("easy");
    const input = await h.command([h.attendeeId], manager, "easy");
    const view = (await h.membership.get(manager, {context: h.scope.context,
      attendeeId: h.attendeeId})).view;
    await h.membership.transfer(manager, {expectedSourceHash: view.sourceHash,
      command: {kind: "transferGroup", context: h.scope.context,
        eventId: h.scope.context.eventId, operationId: randomUUID(), payload: {
          attendeeId: h.attendeeId, episodeId: view.episodeId,
          expectedMembershipRevision: view.revision,
          expectedParticipationRevision: view.participationRevision,
          decision: {kind: "leave"}}}});
    await assert.rejects(h.progress.confirmDeparture(manager, input),
      {code: "failed-precondition"});
    assert.equal(h.fake.entries().filter(([path]) =>
      path.startsWith(DEPARTURE_ROSTERS + "/")).length, 0);
  });

test("authority and event time are checked after reading the departure roster",
  async () => {
    for (const phase of ["read", "write"] as const) {
      const h = await harness();
      await h.grant("lead", "event:whole", "lead", start + 100);
      const input = await h.command();
      h.fake.beforeRead = (path) => {
        if (path === h.attendeePath) h.clock.now = start + 100;
      };
      await assert.rejects(phase === "read" ?
        h.review([h.attendeeId], "lead") :
        h.progress.confirmDeparture("lead", input),
      {code: "permission-denied"});
    }
    const h = await harness();
    const input = await h.command();
    h.fake.beforeRead = (path) => {
      if (path === h.attendeePath) h.clock.now = 3_000_000;
    };
    await assert.rejects(h.progress.confirmDeparture(manager, input),
      {code: "failed-precondition"});
  });

test("bounded selection supports all 1,000 guests and rejects larger requests",
  async () => {
    const h = await harness();
    const ids = Array.from({length: 1000}, (_, i) => "guest-" + i);
    for (const id of ids) await h.put("eventAttendees/" + id, h.attendee);
    const input = await h.command(ids);
    assert.equal(input.command.payload.departureRoster.attendeeIds.length,
      1000);
    const result = await h.progress.confirmDeparture(manager, input);
    const saved = await h.read(DEPARTURE_ROSTERS + "/" +
      result.view.progress!.departureRosterId);
    assert.ok(validateEventAssistanceDepartureRosterDocument(saved));
    assert.equal(saved.members.length, 1000);
    await assert.rejects(h.review([...ids, h.attendeeId]),
      {code: "invalid-argument"});
    await assert.rejects(h.review([h.attendeeId, h.attendeeId]),
      {code: "invalid-argument"});
  });

test("roster review authenticates, limits and rejects rehearsal before reads",
  async () => {
    const calls: string[] = [];
    const deps = {db: () => ({}) as Firestore, rateLimit: async () => {
      calls.push("limit");
    }, store: () => ({get: async () => {
      calls.push("get"); return {} as Response;
    }})};
    await assert.rejects(getEventAssistanceDepartureRosterHandler(
      {data: {}} as CallableRequest, deps), {code: "unauthenticated"});
    assert.deepEqual(calls, []);
    await getEventAssistanceDepartureRosterHandler(
      {data: {}, auth: {uid: "actor"}} as CallableRequest, deps);
    assert.deepEqual(calls, ["limit", "get"]);
    const h = await harness();
    const before: string[] = [];
    h.fake.beforeRead = (path) => before.push(path);
    await assert.rejects(h.review([h.attendeeId], "stranger"),
      {code: "permission-denied"});
    assert.ok(before.every((p) => !p.startsWith("eventAttendees/")));
    await assert.rejects(h.store.get(manager, {...h.scope,
      context: {mode: "rehearsal", rehearsalId: "r", virtualEventId: "v",
        clockId: "clock"}, attendeeIds: [h.attendeeId]}),
    {code: "invalid-argument"});
  });

test("Firestore competing departures publish one immutable roster", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const app = initializeApp({projectId: "demo-catch-rules"}, randomUUID());
  try {
    const h = await harness(getFirestore(app));
    const input = await h.command();
    const results = await Promise.all(Array.from({length: 8}, () =>
      h.progress.confirmDeparture(manager, input)));
    assert.equal(results.filter((r) => r.outcome === "applied").length, 1);
    assert.equal(results.filter((r) => r.outcome === "replayed").length, 7);
    const id = results[0].view.progress!.departureRosterId!;
    const manifest = await h.read(DEPARTURE_ROSTERS + "/" + id);
    assert.ok(validateEventAssistanceDepartureRosterDocument(manifest));
    assert.equal(manifest.members.length, 1);
    assert.equal((await h.read(h.attendeePath))!.attendanceRevision, 7);
    const stale = await h.command();
    await h.put(h.attendeePath, {...h.attendee,
      checkedInAt: Timestamp.fromMillis(start - 1), attendanceRevision: 8});
    await assert.rejects(h.progress.confirmDeparture(manager, stale),
      {code: "aborted"});
    assert.deepEqual(await h.read(DEPARTURE_ROSTERS + "/" + id), manifest);
  } finally {
    await deleteApp(app);
  }
});
