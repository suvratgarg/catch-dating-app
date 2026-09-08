import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync} from "node:fs";
import {randomUUID, createHash} from "node:crypto";
import * as admin from "firebase-admin";
import {Firestore, Timestamp} from "firebase-admin/firestore";
import type {OrganizerDocument} from
  "../shared/generated/firestoreAdminTypes";
import {validateEventRehearsalCaseDocument} from
  "../shared/generated/validators/eventRehearsalCaseDocument";
import {validateEventRehearsalBootstrapCallableResponse} from
  "../shared/generated/validators/eventRehearsalBootstrapOutput";
import {FakeFirestore} from "../operations/testFirestore";
import {buildRehearsalActors} from "./engine";
import {practiceSession, practicePlan} from "./assistanceTestFixtures";
import {preparePracticeHelp, rehearsalCases, practiceHelpProjection} from
  "./assistanceCases";
import {applyPracticeHostCommand, applyPracticeGuestReply} from
  "./assistanceTransactions";
import {rehearsalMessages, PracticeMessage, practiceContext} from
  "./assistanceRuntime";

function organizer(): OrganizerDocument {
  const fixture = JSON.parse(readFileSync(
    "../contracts/fixtures/valid/club_doc.json", "utf8"));
  const schema = JSON.parse(readFileSync(
    "../contracts/firestore/organizers.schema.json", "utf8"));
  return {...Object.fromEntries(Object.entries(fixture).filter(([k]) =>
    k in schema.properties)), followerCount: 0, organizerPhotos: [],
  organizerType: "community", hostUserIds: ["host-1", "host-2"]} as
    unknown as OrganizerDocument;
}
async function harness() {
  const fake = new FakeFirestore();
  const db = fake as unknown as Firestore;
  const session = practiceSession();
  let actor = buildRehearsalActors("practice-help", 2, 1,
    session.virtualNow)[0];
  const org = organizer();
  fake.write("organizers/" + session.organizerId,
    org as unknown as Record<string, unknown>);
  const actorRef = db.collection("eventRehearsalActors")
    .doc(actor.sessionId + "_" + actor.actorId);
  const open = async (actionId = "request-one") => {
    actor = await db.runTransaction(async (tx) => {
      const change = await preparePracticeHelp(db, tx, session, actor,
        {kind: "guestAction", actionId}, "other");
      change.commit(); tx.set(actorRef, change.actor);
      return change.actor;
    });
  };
  const view = () => practiceHelpProjection(db, actor.sessionId,
    session, [actor], "host-1");
  const resolve = async (row: Awaited<ReturnType<typeof view>>["cases"][number],
    outcome: "resolved" | "declined" | "transferred", owner = "host-1") => {
    actor = await db.runTransaction(async (tx) => {
      const next = await applyPracticeHostCommand(db, tx, session, actor,
        {kind: "resolveAssistance", actorId: actor.actorId,
          expectedSourceHash: row.sourceHash,
          payload: {caseId: row.caseId, expectedRevision: row.revision!,
            outcome, owner}}, {actorUid: "host-1", organizer: org});
      tx.set(actorRef, next); return next;
    });
  };
  return {fake, db, session, org, open, view, resolve,
    actor: () => actor, setActor: (next: typeof actor) => {
      actor = next;
    }};
}

test("practice help transfers and settles independently", async () => {
  const h = await harness();
  await h.open(); await h.open();
  assert.equal((await h.view()).cases.length, 1);
  let row = (await h.view()).cases[0];
  await h.resolve(row, "transferred", "host-2");
  assert.equal(h.actor().helpRequested, true);
  await assert.rejects(h.resolve(row, "resolved"), {code: "aborted"});
  row = (await h.view()).cases[0];
  assert.deepEqual(row.assignment,
    {kind: "assigned", uid: "host-2", authority: "current"});
  await h.open("request-two");
  await h.resolve(row, "resolved");
  assert.equal(h.actor().helpRequested, true);
  row = (await h.view()).cases.find((c) => c.status === "open")!;
  await h.resolve(row, "declined");
  assert.equal(h.actor().helpRequested, false);
  assert.equal(h.actor().status, "expected");
  await h.open();
  assert.equal(h.actor().helpRequested, false);
  assert.equal((await h.view()).cases.length, 2);
  assert.deepEqual((await h.view()).untrackedActorIds, []);
  assert.equal(h.fake.entries().some(([p]) =>
    p.startsWith("eventAssistance")), false);
});

test("legacy flags and interrupted resolutions survive closure", async () => {
  const h = await harness();
  const {untrackedHelpRequested: omitted, ...old} = h.actor();
  assert.equal(omitted, false);
  h.setActor({...old, helpRequested: true});
  await h.open();
  const row = (await h.view()).cases[0];
  const before = h.fake.entries();
  h.fake.failNextCommit = true;
  await assert.rejects(h.resolve(row, "resolved"), /interruption/u);
  assert.deepEqual(h.fake.entries(), before);
  h.session.status = "complete";
  await h.resolve(row, "resolved");
  assert.equal(h.actor().helpRequested, true);
  assert.deepEqual((await h.view()).untrackedActorIds, [h.actor().actorId]);
});

test("help handling binds authority, source and clock", async () => {
  const h = await harness();
  await h.open();
  const row = (await h.view()).cases[0];
  await assert.rejects(h.resolve(row, "transferred", "outsider"),
    {code: "failed-precondition"});
  await assert.rejects(h.resolve(row, "resolved", "host-2"),
    {code: "permission-denied"});
  await h.resolve(row, "transferred", "host-2");
  h.org.hostUserIds = ["host-1"];
  h.fake.write("organizers/" + h.session.organizerId,
    h.org as unknown as Record<string, unknown>);
  assert.deepEqual((await h.view()).cases[0].assignment,
    {kind: "assigned", uid: "host-2", authority: "revoked"});
  const saved = h.fake.entries()
    .find(([p]) => p.startsWith(rehearsalCases))![1];
  assert.equal(validateEventRehearsalCaseDocument(saved), true);
  for (const changed of [{...saved, category: "comfortSafety"},
    {...saved, status: "resolved"}, {...saved, senderId: "live"}]) {
    assert.equal(validateEventRehearsalCaseDocument(changed), false);
  }
  h.session.setupRevision++;
  assert.deepEqual((await h.view()).cases, []);
  await assert.rejects(h.resolve(row, "resolved"),
    {code: "failed-precondition"});
});

test("message help and settlement preserve attendance", async () => {
  const h = await harness();
  h.setActor(await h.db.runTransaction((tx) => applyPracticeHostCommand(
    h.db, tx, h.session, h.actor(), {kind: "publish",
      actorId: h.actor().actorId,
      plan: practicePlan(h.session.virtualNow.toMillis())})));
  const message = h.fake.entries().find(([p]) =>
    p.startsWith(rehearsalMessages))![1] as unknown as PracticeMessage;
  const reply = () => h.db.runTransaction((tx) => applyPracticeGuestReply(
    h.db, tx, h.session, h.actor(), {messageId: message.record.messageId,
      intentRevision: 1, choiceId: "need-help", requestId: "reply-one",
      actionId: "practice-one"}));
  const before = h.fake.entries();
  h.fake.failNextCommit = true;
  await assert.rejects(reply(), /interruption/u);
  assert.deepEqual(h.fake.entries(), before);
  h.setActor(await reply());
  const row = (await h.view()).cases[0];
  await h.resolve(row, "resolved");
  h.setActor(await reply());
  assert.equal(h.actor().helpRequested, false);
  assert.equal(h.actor().status, "expected");
  assert.equal((await h.view()).cases.length, 1);
});

test("Firestore help uses exact Host receipts and reset cleanup", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const {getEventRehearsalGuestBootstrapHandler: guestBootstrap,
    submitEventRehearsalGuestActionHandler: guestAction,
    getEventRehearsalBootstrapHandler: bootstrap,
    controlEventRehearsalHandler: control, resetEventRehearsalHandler: reset} =
      await import("./handlers.js");
  if (!admin.apps.length) admin.initializeApp({projectId: "demo-catch-rules"});
  const db = admin.firestore();
  const id = randomUUID();
  const session = practiceSession();
  session.organizerId = "practice-help-" + id;
  session.clubId = session.organizerId;
  session.publicRehearsalId = "public-" + id;
  session.viewerTokenHash = createHash("sha256")
    .update(session.publicRehearsalId).digest("hex");
  const sessionRef = db.collection("eventRehearsals").doc(id);
  const actors = buildRehearsalActors(id, 2, 1, session.virtualNow);
  const batch = db.batch();
  batch.set(db.collection("organizers").doc(session.organizerId), organizer());
  batch.set(sessionRef, session);
  for (const actor of actors) {
    batch.set(db.collection("eventRehearsalActors")
      .doc(id + "_" + actor.actorId), {...actor, assistanceAutomation: {
      clockId: practiceContext(session, actor).clockId, status: "enabled",
      plan: {...practicePlan(session.virtualNow.toMillis()),
        departureConfirmed: false}, outcomes: [{kind: "delivered"}],
      nextOutcomeIndex: 0, evaluation: null}});
  }
  await batch.commit();
  const request = (data: unknown) => ({data,
    auth: {uid: "host-1", token: {}}}) as Parameters<typeof control>[0];
  const guest = await guestBootstrap(request({
    publicRehearsalId: session.publicRehearsalId,
    clientInstanceId: randomUUID(), viewerToken: session.publicRehearsalId,
    slotToken: null}));
  const ask = {publicRehearsalId: session.publicRehearsalId,
    slotToken: guest.slotToken, clientActionId: randomUUID(),
    action: "askForHelp"};
  await guestAction(request(ask));
  await guestAction(request(ask));
  const first = await bootstrap(request({sessionId: id}));
  assert.equal(validateEventRehearsalBootstrapCallableResponse(first), true);
  assert.equal(first.helpRequests!.cases.length, 1);
  const row = first.helpRequests!.cases[0];
  const command = {sessionId: id,
    expectedRevision: first.session.runtimeRevision,
    expectedSetupRevision: first.session.setupRevision,
    clientActionId: randomUUID(), action: "assistance",
    assistance: {kind: "resolveAssistance", actorId: row.attendeeId,
      expectedSourceHash: row.sourceHash, payload: {caseId: row.caseId,
        expectedRevision: row.revision, outcome: "resolved", owner: "host-1"}}};
  const settled = await control(request(command));
  assert.equal(settled.helpRequests!.cases[0].status, "resolved");
  assert.equal(settled.actors.find((a) => a.actorId === row.attendeeId)!
    .helpRequested, false);
  const replay = await control(request(command));
  assert.equal(replay.session.runtimeRevision, settled.session.runtimeRevision);
  await assert.rejects(control(request({...command, assistance: {
    ...command.assistance, payload: {...command.assistance.payload,
      outcome: "declined"}}})), {code: "aborted"});
  const laterGuest = await guestAction(request(ask));
  assert.equal(laterGuest.actor.helpRequested, false);
  assert.equal("helpRequests" in laterGuest, false);
  await reset(request({sessionId: id, fork: false, seed: null}));
  assert.equal((await db.collection(rehearsalCases)
    .where("sessionId", "==", id).get()).size, 0);
  await assert.rejects(control(request(command)), {code: "aborted"});
  const {expireEventRehearsalsHandler} = await import("./handlers.js");
  await sessionRef.update({expiresAt: Timestamp.fromMillis(0)});
  await expireEventRehearsalsHandler(db, Timestamp.fromMillis(0));
  await db.collection("organizers").doc(session.organizerId).delete();
});
