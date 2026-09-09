import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync} from "node:fs";
import {randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore, Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import type {EventAssistanceMessageIntent as Intent} from
  "../shared/generated/eventAssistanceMessageIntent";
import type {EventAttendanceDispositionCallableResponse as Response} from
  "../shared/generated/eventAttendanceDispositionCallableResponse";
import {validateEventDocument} from
  "../shared/generated/validators/eventDocument";
import {validateEventAttendeeDocument} from
  "../shared/generated/validators/eventAttendeeDocument";
import {validateEventAssistanceCommand} from
  "../shared/generated/validators/eventAssistanceCommand";
import {EventAttendanceDispositionStore, dispositionCollections as collections}
  from "./attendanceDispositionStore";
import {Decision, dispositionIdentity, dispositionReceiptIdentity, View} from
  "./attendanceDispositionPolicy";
import {getEventAttendanceDispositionHandler, recordEventNoShowHandler} from
  "./attendanceDispositionHandlers";
import {setEventAttendeeAttendanceHandler} from "./eventAttendees";
import {ProgressFirestore, seedJoiningProgress, progressFixtureManager} from
  "../eventSuccess/operations/groupProgressTestFixtures";
import {GuestAssistanceStore} from
  "../eventSuccess/operations/guestAssistanceStore";
import {guestCollections, guestIdentity} from
  "../eventSuccess/operations/guestRecords";

const manager = progressFixtureManager;
const start = 1_000_000;
const end = 3_000_000;
const hostDecision: Decision = {kind: "record",
  evidence: {kind: "hostConfirmed"}};
const fixture = (name: string) => JSON.parse(readFileSync(
  "../contracts/fixtures/valid/" + name + ".json", "utf8"));

async function harness(realDb?: Firestore) {
  const fake = new ProgressFirestore();
  const db = realDb ?? fake as unknown as Firestore;
  const id = randomUUID();
  const context = {mode: "live" as const, eventId: "e-" + id,
    organizerId: "o-" + id};
  const scope = {context, attendeeId: "a-" + id};
  const seeded = await seedJoiningProgress(db, context, start, end);
  const progress = {...seeded, plan: {...seeded.plan,
    createdAt: Timestamp.fromMillis(start - 1000),
    updatedAt: Timestamp.fromMillis(start)}};
  const attendee = {...fixture("event_attendee_doc"),
    eventId: context.eventId, organizerId: context.organizerId,
    clubId: context.organizerId, status: "registered", linkedUid: "guest-1",
    checkedInAt: null, checkedInBy: null, attendanceRevision: 7,
    createdAt: Timestamp.fromMillis(start - 1000),
    updatedAt: Timestamp.fromMillis(start - 1000)};
  const put = async (path: string, value: object) => {
    if (realDb) await db.doc(path).set(value);
    else fake.write(path, value as Record<string, unknown>);
  };
  const attendeePath = "eventAttendees/" + scope.attendeeId;
  const planPath = "eventSuccessPlans/" + context.eventId;
  const eventPath = "events/" + context.eventId;
  await put(attendeePath, attendee);
  await put(planPath, progress.plan);
  const clock = {now: start};
  const store = new EventAttendanceDispositionStore(db, () => clock.now);
  const finish = async () => {
    clock.now = end;
    await put(planPath, {...progress.plan, status: "complete",
      completedAt: Timestamp.fromMillis(end)});
  };
  const view = async () => (await store.get(manager, scope)).view;
  return {db, fake, scope, progress, attendee, attendeePath, eventPath,
    planPath, clock, store, put, finish, view};
}
type Harness = Awaited<ReturnType<typeof harness>>;
function command(view: View, decision: Decision = hostDecision,
  operationId = "decision") {
  return {expectedSourceHash: view.sourceHash, command: {
    kind: "recordNoShow", context: view.context, eventId: view.context.eventId,
    operationId, payload: {attendeeId: view.attendeeId,
      expectedAttendanceRevision: view.attendance.revision,
      expectedDispositionRevision: view.disposition.revision, decision}}};
}

async function decline(h: Harness) {
  const guests = new GuestAssistanceStore(h.db, () => h.clock.now);
  const guest = await guests.startEpisode(h.scope.context,
    h.scope.attendeeId, "begin", null);
  const intent: Intent = {schemaVersion: 1, kind: "joiningUpdate",
    intentId: "decline-" + randomUUID(), revision: 1, context: h.scope.context,
    eventId: h.scope.context.eventId, attendeeId: h.scope.attendeeId,
    episodeId: guest.episodeId,
    workflow: {kind: "lateJoin", occurrenceId: "departure"},
    createdAt: start, expiresAt: end - 1,
    permittedRoutes: ["catchEventSms"], deliveryPolicy: {maxAttempts: 1,
      maxAttemptsPerRoute: 1, minimumRetrySeconds: 1},
    guidance: h.progress.guidance, choices: [{choiceId: "decline",
      label: "Not coming", value: {kind: "joinIntent",
        intention: {kind: "notComing"}}}]};
  const thread = await guests.publishMessage(intent, null);
  const link = await guests.issueLink(thread.threadId, "attempt", {
    currentKeyId: "fixture-key", keyFor: () => Buffer.alloc(32, 9)});
  const view = await guests.getView(link.linkId, link.secret);
  assert.equal(view.status, "ready");
  if (view.status !== "ready") throw new Error("Missing guest reply view");
  await guests.submit({linkId: link.linkId, secret: link.secret,
    intentId: view.intentId, intentRevision: view.intentRevision,
    expectedGuestRevision: view.guestRevision, choiceId: "decline",
    requestId: "guest-declined"});
}

test("closeout is explicit and changes no attendance", async () => {
  const h = await harness();
  await h.finish();
  const before = h.fake.entries();
  const view = await h.view();
  assert.deepEqual(view.disposition, {kind: "unreviewed", revision: 0});
  assert.equal(view.declineEvidence, null);
  assert.deepEqual(h.fake.entries(), before);
  const input = command(view);
  assert.equal(validateEventAssistanceCommand(input.command), true);
  const saved = await h.store.recordNoShow(manager, input);
  assert.equal(saved.outcome, "applied");
  assert.equal(saved.view.disposition.kind, "recorded");
  assert.equal(saved.view.attendance.checkedIn, false);
  assert.equal(saved.view.attendance.revision, 7);
  assert.deepEqual((await h.store.recordNoShow(manager, input)),
    {...saved, outcome: "replayed"});
  const old = new Map(before);
  const changed = h.fake.entries().filter(([path, data]) =>
    JSON.stringify(old.get(path)) !== JSON.stringify(data));
  assert.equal(changed.length, 2);
  assert.ok(changed.every(([path]) => Object.values(collections)
    .some((collection) => path.startsWith(collection + "/"))));
});

test("overruns stay open; no-shows require admission", async () => {
  const h = await harness();
  h.clock.now = end + 1000;
  assert.deepEqual((await h.view()).closure, {kind: "open"});
  await assert.rejects(h.store.recordNoShow(manager, command(await h.view())),
    {code: "failed-precondition"});
  await h.finish();
  for (const status of ["invited", "waitlisted", "cancelled", "checkedIn"]) {
    await h.put(h.attendeePath, {...h.attendee, status});
    const view = await h.view();
    assert.equal(view.recordability.kind, "unavailable");
    await assert.rejects(h.store.recordNoShow(manager, command(view)),
      {code: "failed-precondition"});
  }
  await h.put(h.attendeePath, {...h.attendee,
    checkedInAt: Timestamp.fromMillis(start)});
  assert.deepEqual((await h.view()).recordability,
    {kind: "unavailable", reason: "alreadyAttended"});
  await h.put(h.eventPath, {...h.progress.event, status: "cancelled"});
  assert.deepEqual((await h.view()).recordability,
    {kind: "unavailable", reason: "eventCancelled"});
});

test("scheduled closeout preserves exact time and fresh review", async () => {
  const h = await harness();
  await h.put(h.planPath, {...h.progress.plan, status: "setup"});
  await h.put(h.eventPath, {...h.progress.event,
    endTime: new Timestamp(end / 1000, 1)});
  h.clock.now = end;
  const early = await h.view();
  assert.deepEqual(early.closure, {kind: "open"});
  h.clock.now++;
  await assert.rejects(h.store.recordNoShow(manager, command(early)),
    {code: "aborted"});
  const view = await h.view();
  assert.deepEqual(view.closure, {kind: "scheduledEnd", endedAt: end + 1});
  await h.store.recordNoShow(manager, command(view));
});

test("invalid completion evidence fails closed", async () => {
  const h = await harness();
  await h.finish();
  for (const completedAt of [null, Timestamp.fromMillis(end + 1),
    Timestamp.fromMillis(start - 1001)]) {
    await h.put(h.planPath,
      {...h.progress.plan, status: "complete", completedAt});
    await assert.rejects(h.view(), {code: "failed-precondition"});
  }
});

test("decline evidence requires the current guest response", async () => {
  const h = await harness();
  await decline(h);
  await h.finish();
  const view = await h.view();
  assert.ok(view.declineEvidence);
  await assert.rejects(h.store.recordNoShow(manager, command(view,
    {kind: "record", evidence: {...view.declineEvidence,
      guestRevision: view.declineEvidence.guestRevision + 1}})),
  {code: "aborted"});
  const saved = await h.store.recordNoShow(manager, command(view,
    {kind: "record", evidence: view.declineEvidence}));
  assert.equal(saved.view.disposition.kind, "recorded");
  const path = guestCollections.guests + "/" + guestIdentity(h.scope.context,
    h.scope.attendeeId);
  const guest = h.fake.read(path)!;
  await h.put(path, {...guest, revision: Number(guest.revision) + 1,
    intention: {kind: "unknown"}});
  assert.deepEqual((await h.view()).disposition,
    {kind: "superseded", revision: 1, reason: "guestIntentionChanged"});
});

test("silence and old episodes are not decline evidence", async () => {
  const h = await harness();
  await h.finish();
  await assert.rejects(h.store.recordNoShow(manager, command(await h.view(),
    {kind: "record", evidence: {kind: "guestDeclined", guestRevision: 0,
      episodeId: "invented"}})), {code: "aborted"});
  const replacement = await harness();
  await decline(replacement);
  await replacement.finish();
  replacement.fake.generation = Timestamp.fromMillis(2);
  assert.equal((await replacement.view()).declineEvidence, null);
});

test("attendance facts supersede unbumped decisions", async () => {
  const h = await harness();
  await h.finish();
  const input = command(await h.view());
  await h.store.recordNoShow(manager, input);
  await h.put(h.attendeePath, {...h.attendee, status: "checkedIn",
    checkedInAt: Timestamp.fromMillis(end)});
  const view = await h.view();
  assert.deepEqual(view.disposition,
    {kind: "superseded", revision: 1, reason: "attendanceChanged"});
  assert.equal(view.canClear, true);
  const cleared = await h.store.recordNoShow(manager, command(view,
    {kind: "clear", reason: "attendanceCorrected"}, "clear"));
  assert.equal(cleared.view.disposition.kind, "cleared");
  const replay = await h.store.recordNoShow(manager, input);
  assert.equal(replay.operationRevision, 1);
  assert.equal(replay.view.disposition.kind, "cleared");
  assert.equal(replay.view.disposition.revision, 2);
});

test("clearing requires a supported reason and never checks in", async () => {
  const h = await harness();
  await h.finish();
  await assert.rejects(h.store.recordNoShow(manager, command(await h.view(),
    {kind: "clear", reason: "recordingMistake"})),
  {code: "failed-precondition"});
  await h.store.recordNoShow(manager, command(await h.view()));
  for (const reason of ["attendanceCorrected", "noLongerApplicable"] as const) {
    await assert.rejects(h.store.recordNoShow(manager, command(await h.view(),
      {kind: "clear", reason}, "clear")), {code: "failed-precondition"});
  }
  const cleared = await h.store.recordNoShow(manager, command(await h.view(),
    {kind: "clear", reason: "recordingMistake"}, "clear"));
  assert.equal(cleared.view.attendance.checkedIn, false);
  assert.equal(cleared.view.disposition.kind, "cleared");
});

test("cancellation supersedes and permits clearing", async () => {
  const h = await harness();
  await h.finish();
  await h.store.recordNoShow(manager, command(await h.view()));
  await h.put(h.eventPath, {...h.progress.event, status: "cancelled"});
  const view = await h.view();
  assert.deepEqual(view.disposition,
    {kind: "superseded", revision: 1, reason: "eventChanged"});
  const saved = await h.store.recordNoShow(manager, command(view,
    {kind: "clear", reason: "noLongerApplicable"}, "cancelled"));
  assert.equal(saved.view.disposition.kind, "cleared");
});

test("replacement identity hides decisions and prevents replay", async () => {
  const h = await harness();
  await h.finish();
  const input = command(await h.view());
  await h.store.recordNoShow(manager, input);
  await h.put(h.attendeePath, {...h.attendee, linkedUid: "replacement"});
  const view = await h.view();
  assert.deepEqual(view.disposition, {kind: "sourceChanged", revision: 1});
  assert.equal(view.canClear, false);
  await assert.rejects(h.store.recordNoShow(manager, input), {code: "aborted"});
  const saved = await h.store.recordNoShow(manager, command(view,
    hostDecision, "reviewed-replacement"));
  assert.equal(saved.view.disposition.kind, "recorded");
  h.fake.generation = Timestamp.fromMillis(2);
  assert.equal((await h.view()).disposition.kind, "sourceChanged");
});

test("stale or interrupted writes cannot overwrite closeout", async () => {
  const h = await harness();
  await h.finish();
  const input = command(await h.view());
  const before = h.fake.entries();
  h.fake.failNextCommit = true;
  await assert.rejects(h.store.recordNoShow(manager, input), /interruption/);
  assert.deepEqual(h.fake.entries(), before);
  const saved = await h.store.recordNoShow(manager, input);
  await assert.rejects(h.store.recordNoShow(manager,
    {...input, command: {...input.command, operationId: "stale"}}),
  {code: "aborted"});
  await assert.rejects(h.store.recordNoShow(manager, command(saved.view,
    {kind: "clear", reason: "recordingMistake"})), {code: "aborted"});
});

test("manager authority gates reads, writes and replay", async () => {
  const h = await harness();
  await h.finish();
  const input = command(await h.view());
  await h.store.recordNoShow(manager, input);
  for (const actor of ["guest-1", "check-in-operator", "stranger"]) {
    await assert.rejects(h.store.get(actor, h.scope),
      {code: "permission-denied"});
    await assert.rejects(h.store.recordNoShow(actor, input),
      {code: "permission-denied"});
  }
  const path = "organizers/" + h.scope.context.organizerId;
  const organizer = h.fake.read(path)!;
  await h.put(path, {...organizer, hostUserIds: [], ownerUserId: "other",
    hostUserId: "other", hostProfiles: []});
  await assert.rejects(h.store.recordNoShow(manager, input),
    {code: "permission-denied"});
});

test("invalid contexts and placeholder payloads cannot execute", async () => {
  const h = await harness();
  await h.finish();
  const input = command(await h.view());
  for (const change of [
    {...input.command, eventId: "other-event"},
    {...input.command, context: {mode: "rehearsal", rehearsalId: "r",
      virtualEventId: "v", clockId: "c"}},
    {...input.command, payload: {attendeeId: h.scope.attendeeId,
      evidence: "guestDeclined", decisionId: "invented"}},
  ]) {
    await assert.rejects(h.store.recordNoShow(manager,
      {...input, command: change}), {code: "invalid-argument"});
  }
});

test("handlers authenticate and rate-limit before store access", async () => {
  for (const handler of [getEventAttendanceDispositionHandler,
    recordEventNoShowHandler]) {
    const calls: string[] = [];
    const deps = {db: () => ({}) as Firestore,
      rateLimit: async () => {
        calls.push("limit");
      },
      store: () => ({get: async () => {
        calls.push("get"); return {} as Response;
      }, recordNoShow: async () => {
        calls.push("record"); return {} as Response;
      }})};
    await assert.rejects(handler({data: {}} as CallableRequest, deps),
      {code: "unauthenticated"});
    assert.deepEqual(calls, []);
    await handler({data: {}, auth: {uid: manager}} as CallableRequest, deps);
    assert.equal(calls[0], "limit");
    assert.equal(calls.length, 2);
    calls.length = 0;
    await assert.rejects(handler({data: {}, auth: {uid: manager}} as
      CallableRequest, {...deps, rateLimit: async () => {
      throw new Error("rate limited");
    }}), /rate limited/);
    assert.deepEqual(calls, []);
  }
});

test("Firestore retries commit once; real check-in supersedes closeout", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const app = initializeApp({projectId: "demo-catch-rules"}, randomUUID());
  const db = getFirestore(app);
  try {
    const h = await harness(db);
    await h.finish();
    const input = command(await h.view());
    const saved = await Promise.all(Array.from({length: 8}, () =>
      h.store.recordNoShow(manager, input)));
    assert.equal(saved.filter((r) => r.outcome === "applied").length, 1);
    assert.equal(saved.filter((r) => r.outcome === "replayed").length, 7);
    const receiptId = dispositionReceiptIdentity(h.scope.context,
      h.scope.attendeeId, input.command.operationId);
    assert.ok((await db.collection(collections.receipts).doc(receiptId)
      .get()).exists);
    await setEventAttendeeAttendanceHandler({auth: {uid: manager}, data: {
      eventId: h.scope.context.eventId, attendeeId: h.scope.attendeeId,
      expectedRevision: 7, desiredCheckedIn: true,
      clientOperationId: randomUUID()}} as CallableRequest, {
      firestore: () => db, checkRateLimit: async () => undefined,
      timestamp: () => Timestamp.fromMillis(end)});
    assert.ok(validateEventDocument((await db.doc(h.eventPath).get()).data()),
      JSON.stringify(validateEventDocument.errors));
    assert.ok(validateEventAttendeeDocument(
      (await db.doc(h.attendeePath).get()).data()),
    JSON.stringify(validateEventAttendeeDocument.errors));
    const latest = await h.view();
    assert.equal(latest.attendance.checkedIn, true);
    assert.deepEqual(latest.disposition,
      {kind: "superseded", revision: 1, reason: "attendanceChanged"});
    const replay = await h.store.recordNoShow(manager, input);
    assert.equal(replay.operationRevision, 1);
    assert.equal(replay.view.disposition.kind, "superseded");
    await db.doc(h.attendeePath).delete();
    await h.put(h.attendeePath, h.attendee);
    assert.deepEqual((await h.view()).disposition,
      {kind: "sourceChanged", revision: 1});
    await assert.rejects(h.store.recordNoShow(manager, input),
      {code: "aborted"});
    const recordId = dispositionIdentity(h.scope.context, h.scope.attendeeId);
    const record = (await db.collection(collections.records)
      .doc(recordId).get()).data();
    assert.equal(record?.revision, 1);
  } finally {
    await deleteApp(app);
  }
});
