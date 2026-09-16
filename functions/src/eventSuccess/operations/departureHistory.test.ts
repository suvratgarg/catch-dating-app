import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {readFileSync, writeFileSync} from "node:fs";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {EventDepartureHistoryStore} from "./departureHistoryStore";
import {listEventAssistanceDepartureRostersHandler} from
  "./departureHistoryHandlers";
import {departureRosterHarness} from "./departureRosterTestFixtures";
import {progressFixtureManager as manager} from "./groupProgressTestFixtures";
import {EventCheckpointStore} from "./checkpointStore";
import {CHECKPOINTS, checkpointIdentity} from "./checkpointRecords";
import {DEPARTURE_ROSTERS} from "./departureRosterSource";
import {GROUP_PROGRESS} from "./groupProgressReader";
import {progressIdentity} from "./groupProgressSource";

async function harness(real?: Firestore, id?: string) {
  const h = await departureRosterHarness(real, id);
  const history = new EventDepartureHistoryStore(h.db, () => h.clock.now);
  const checkpoints = new EventCheckpointStore(h.db, () => h.clock.now);
  return {...h, history, checkpoints};
}

async function depart(h: Awaited<ReturnType<typeof harness>>, ids: string[],
  groupId = "event:whole", request = false) {
  const input = await h.command(ids, manager, groupId);
  await h.progress.confirmDeparture(manager, {...input, command: {
    ...input.command, payload: {...input.command.payload,
      ...(request ? {checkpointRequest: {responsibleOperatorId: manager,
        dueAt: h.clock.now + 30_000}} : {})}}});
}

test("bounded history preserves original checkpoint scope across later moves",
  async () => {
    const h = await harness();
    await depart(h, [h.attendeeId], "event:whole", true);
    const first = await h.history.list(manager, h.scope);
    const row = first.rosters[0];
    assert.equal(row.progressRevision, 2);
    assert.equal(row.rosterSize, 1);
    assert.equal(row.label, "Stop one");
    assert.deepEqual(row.checkpoint, {checkpointId: "one",
      reportStatus: "unreported", reportRevision: 0, accountedForCount: 0,
      originalRequestedDueAt: h.clock.now + 30_000});
    const scope = {...h.scope, checkpointId: "one", progressRevision: 2};
    const view = (await h.checkpoints.get(manager, scope)).view;
    await h.checkpoints.record(manager, {expectedSourceHash: view.sourceHash,
      command: {kind: "recordCheckpoint", context: h.scope.context,
        eventId: h.scope.context.eventId, operationId: randomUUID(), payload: {
          groupId: scope.groupId, checkpointId: scope.checkpointId,
          expectedProgressRevision: 2, expectedCheckpointRevision: 0,
          accountedFor: [h.attendeeId], correctionReason: null}}});
    for (let i = 0; i < 11; i++) {
      h.clock.now++;
      await depart(h, []);
    }
    // A newer unrecorded departure must not hide previous recorded rosters.
    h.clock.now++;
    const unrecorded = await h.command([]);
    const {departureRoster, ...payload} = unrecorded.command.payload;
    void departureRoster;
    await h.progress.confirmDeparture(manager, {...unrecorded, command: {
      ...unrecorded.command, payload}});
    const before = h.fake.entries();
    const page = await h.history.list(manager, h.scope);
    assert.equal(page.progressRevision, 14);
    assert.deepEqual(page.rosters.map((r) => r.progressRevision),
      [13, 12, 11, 10, 9, 8, 7, 6, 5, 4]);
    assert.equal(page.nextBeforeRevision, 4);
    const next = await h.history.list(manager, {...h.scope, beforeRevision: 4});
    assert.deepEqual(next.rosters.map((r) => r.progressRevision), [3, 2]);
    assert.equal(next.nextBeforeRevision, null);
    assert.equal(next.rosters[1].checkpoint!.reportStatus, "complete");
    assert.equal(next.rosters[1].checkpoint!.accountedForCount, 1);
    assert.equal(next.rosters[1].checkpoint!.reportRevision, 1);
    assert.equal(page.rosters[0].checkpoint!.reportStatus, "unreported");
    assert.deepEqual(h.fake.entries(), before, "history is read only");
    assert.ok(!JSON.stringify(page).includes(h.attendeeId));
    assert.ok(!JSON.stringify(next).includes(h.attendeeId));
  });

test("history distinguishes omitted, empty, fixed and legacy", async () => {
  const h = await harness();
  assert.deepEqual((await h.history.list(manager, h.scope)).rosters, []);
  await depart(h, []);
  const input = await h.command([]);
  const view = (await h.progress.get(manager, h.scope)).view;
  input.command.payload.destination = view.destinations.find((d) =>
    d.target.kind === "fixedPlace")!.target;
  await h.progress.confirmDeparture(manager, input);
  const page = await h.history.list(manager, h.scope);
  assert.equal(page.rosters[0].checkpoint, null);
  assert.equal(page.rosters[1].checkpoint!.reportStatus, "unreported");
  const [path, roster] = h.fake.entries().find(([p, r]) =>
    p.startsWith(DEPARTURE_ROSTERS + "/") && r.progressRevision === 2)!;
  const {destination, ...legacy} = roster;
  void destination;
  await h.put(path, legacy);
  const old = (await h.history.list(manager, h.scope)).rosters[1];
  assert.equal(old.destination, null);
  assert.equal(old.label, null);
  assert.equal(old.checkpoint, null);
  assert.equal(old.sourceState, "destinationNotRecorded");
});

test("changed setup retains counts without claiming current obligations",
  async () => {
    const h = await harness();
    await depart(h, [h.attendeeId], "event:whole", true);
    h.clock.now += 40_000;
    await h.put("events/" + h.scope.context.eventId, {...h.seed.event,
      itinerary: h.seed.event.itinerary.map((stop: object) =>
        ({...stop, title: "Replacement stop"}))});
    const row = (await h.history.list(manager, h.scope)).rosters[0];
    assert.equal(row.sourceState, "setupChanged");
    assert.equal(row.label, null);
    assert.equal(row.rosterSize, 1);
    assert.equal(row.checkpoint!.reportStatus, "unreported");
    assert.ok(!("state" in row.checkpoint!));
    assert.ok(!("responsibleOperatorId" in row.checkpoint!));
    assert.ok(row.checkpoint!.originalRequestedDueAt! < h.clock.now);
  });

test("scope access precedes history and expires again after report reads",
  async () => {
    const h = await harness();
    await h.groups();
    await h.place("easy");
    await h.grant("sweep", "easy", "sweep");
    await h.grant("wrong-group", "fast", "sweep");
    await depart(h, [h.attendeeId], "easy");
    let queries = 0;
    const entries = h.fake.entries.bind(h.fake);
    h.fake.entries = () => {
      queries++; return entries();
    };
    const scope = {...h.scope, groupId: "easy"};
    for (const uid of ["stranger", "wrong-group"]) {
      await assert.rejects(h.history.list(uid, scope),
        {code: "permission-denied"});
    }
    assert.equal(queries, 0);
    const allowed = await h.history.list("sweep", scope);
    assert.equal(allowed.rosters.length, 1);
    h.fake.beforeRead = (path) => {
      if (path.startsWith(CHECKPOINTS + "/")) h.clock.now += 100_000;
      if (path.startsWith("eventAttendees/")) {
        throw new Error("History must not read current guest records.");
      }
    };
    await assert.rejects(h.history.list("sweep", scope),
      {code: "permission-denied"});
    h.fake.beforeRead = undefined;
    assert.equal((await h.history.list(manager, scope)).rosters.length, 1);
  });

test("malformed rows, overflow witnesses and reports fail closed",
  async () => {
    const h = await harness();
    for (let i = 0; i < 11; i++) await depart(h, []);
    const rosters = h.fake.entries().filter(([p]) =>
      p.startsWith(DEPARTURE_ROSTERS + "/"));
    const [path, original] = rosters[0];
    for (const patch of [{groupId: "foreign"},
      {confirmedAt: h.clock.now + 1}, {members: [{attendeeId: "invented"}]}]) {
      await h.put(path, {...original, ...patch});
      await assert.rejects(h.history.list(manager, h.scope),
        {code: "failed-precondition"});
    }
    await h.put(path, original);
    const [latestPath, latest] = rosters.at(-1)!;
    await h.put(latestPath, {...latest, confirmedBy: "other"});
    await assert.rejects(h.history.list(manager, h.scope),
      {code: "failed-precondition"});
    await h.put(latestPath, latest);
    const reportPath = CHECKPOINTS + "/" + checkpointIdentity({...h.scope,
      progressRevision: Number(latest.progressRevision), checkpointId: "one"});
    await h.put(reportPath, {invalid: true});
    await assert.rejects(h.history.list(manager, h.scope),
      {code: "failed-precondition"});
    h.fake.remove(reportPath);
    const progressPath = GROUP_PROGRESS + "/" +
      progressIdentity(h.scope.context, h.scope.groupId);
    h.fake.remove(progressPath);
    await assert.rejects(h.history.list(manager, h.scope),
      {code: "failed-precondition"});
  });

test("history rejects invalid cursors, foreign modes and clock reversal",
  async () => {
    const h = await harness();
    for (const input of [{...h.scope, beforeRevision: 0},
      {...h.scope, beforeRevision: 1.5}, {...h.scope, limit: 100},
      {...h.scope, context: {...h.scope.context, mode: "rehearsal"}}]) {
      await assert.rejects(h.history.list(manager, input),
        {code: "invalid-argument"});
    }
    let calls = 0;
    const store = new EventDepartureHistoryStore(h.db,
      () => ++calls > 3 ? h.clock.now - 1 : h.clock.now);
    await assert.rejects(store.list(manager, h.scope),
      {code: "failed-precondition"});
  });

test("callable authenticates and limits before reading", async () => {
  const calls: string[] = [];
  const deps = {db: () => ({}) as Firestore, rateLimit: async () => {
    calls.push("limit");
  }, store: () => ({list: async (uid: string, input: unknown) => {
    calls.push("list:" + uid); return input as never;
  }})};
  await assert.rejects(listEventAssistanceDepartureRostersHandler(
    {data: {}} as CallableRequest, deps), {code: "unauthenticated"});
  assert.deepEqual(calls, []);
  await listEventAssistanceDepartureRostersHandler(
    {auth: {uid: manager}, data: {}} as CallableRequest, deps);
  assert.deepEqual(calls, ["limit", "list:" + manager]);
});

test("native fixture comes from the live scoped projection", async () => {
  const h = await harness(undefined, "departure-history-native");
  await depart(h, [h.attendeeId], "event:whole", true);
  h.clock.now += 1;
  await depart(h, []);
  const response = await h.history.list(manager, h.scope);
  const path = "../test/event_success/fixtures/departure_history.json";
  if (process.env.UPDATE_DEPARTURE_HISTORY_FIXTURE === "1") {
    writeFileSync(path, JSON.stringify(response, null, 2) + "\n");
  }
  assert.deepEqual(response, JSON.parse(readFileSync(path, "utf8")));
});

test("Firestore history query paginates older roster scopes", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const app = initializeApp({projectId: "demo-catch-rules"}, randomUUID());
  try {
    const h = await harness(getFirestore(app));
    for (let i = 0; i < 12; i++) await depart(h, []);
    const first = await h.history.list(manager, h.scope);
    const second = await h.history.list(manager, {...h.scope,
      beforeRevision: first.nextBeforeRevision!});
    assert.equal(first.rosters.length, 10);
    assert.equal(second.rosters.length, 2);
    assert.equal(second.nextBeforeRevision, null);
    assert.equal(new Set([...first.rosters, ...second.rosters].map((r) =>
      r.progressRevision)).size, 12);
  } finally {
    await deleteApp(app);
  }
});
