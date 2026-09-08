import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {Firestore, Timestamp} from "firebase-admin/firestore";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import {FakeFirestore} from "../operations/testFirestore";
import {buildRehearsalActors, applyRehearsalBehavior} from "./engine";
import {applyPracticeHostCommand, applyPracticeGuestReply,
  PracticeCommand} from "./assistanceTransactions";
import {PracticePlan, PracticeMessage, practiceMessageView,
  readPracticeMessage, rehearsalMessages} from "./assistanceRuntime";

export function practiceSession(now = Date.now()): Session {
  const time = Timestamp.fromMillis(now);
  return {organizerId: "organizer-1", clubId: "organizer-1", ownerUid: "host-1",
    sourceEventId: null, sourceEventRevision: null,
    publicRehearsalId: "practicepublic1234567890",
    viewerTokenHash: "a".repeat(64),
    scenarioId: "lateAndNoShow", seed: 1, actorCount: 2, actionCount: 0,
    status: "running", setup: {title: "Practice",
      locationName: "Practice venue",
      durationMinutes: 120, hostGoal: "Learn", attendeePrompt: "Say hello",
      moduleIds: ["arrival"]}, setupRevision: 0, runtimeRevision: 1,
    activeStepIndex: 1, virtualStartedAt: time, virtualNow: time,
    faultId: "none", faultConsumed: false, createdAt: time, updatedAt: time,
    expiresAt: Timestamp.fromMillis(now + 86400000), completedAt: null};
}
export function practicePlan(now: number): PracticePlan {
  return {policy: {destination: {kind: "fixedPlace", placeId: "venue",
    lateEntry: "allowed"}, cutoff: {kind: "eventEnd"}, maxMessagesPerEpisode: 4,
  minimumMinutesBetweenMessages: 5, updateOn: "materialGuidanceChange",
  unanswered: "keepUnknownUntilCutoff"}, guidance: {revision: 1,
    destination: {kind: "fixedPlace", placeId: "venue", lateEntry: "allowed"},
    materialKey: "venue-1", text: "Meet us at the practice venue.",
    validUntil: now + 7200000}, departureConfirmed: true,
  responseDeadline: null, routes: ["organizerEventWhatsapp", "catchEventSms"],
  deliveryPolicy: {maxAttempts: 3, maxAttemptsPerRoute: 2,
    minimumRetrySeconds: 1}};
}
type WithoutActor<T> = T extends {actorId: string} ? Omit<T, "actorId"> : never;
function setup() {
  const fake = new FakeFirestore();
  const db = fake as unknown as Firestore;
  const session = practiceSession();
  let actor = buildRehearsalActors("practice-1", 2, 1,
    session.virtualNow)[0];
  const actorRef = db.collection("eventRehearsalActors").doc(
    "practice-1_actor-1");
  const host = async (command: WithoutActor<PracticeCommand>) => {
    actor = await db.runTransaction(async (tx) => {
      const next = await applyPracticeHostCommand(db, tx, session, actor,
        {...command, actorId: actor.actorId});
      tx.set(actorRef, next);
      return next;
    });
    return actor;
  };
  const message = () => fake.entries().filter(([path]) =>
    path.startsWith(rehearsalMessages + "/")).map(([, value]) =>
    value as unknown as PracticeMessage).find((m) =>
    m.record.messageId === actor.assistance?.latestMessageId)!;
  const reply = async (choiceId: string, requestId = "reply-once") => {
    const current = message();
    actor = await db.runTransaction(async (tx) => {
      const next = await applyPracticeGuestReply(db, tx, session, actor, {
        messageId: current.record.messageId, intentRevision: 1, choiceId,
        requestId, actionId: requestId});
      tx.set(actorRef, next);
      return next;
    });
    return actor;
  };
  const advance = (minutes: number) => {
    session.virtualNow = Timestamp.fromMillis(
      session.virtualNow.toMillis() + minutes * 60000);
  };
  return {fake, session, host, message, reply, advance,
    actor: () => actor, behavior: (behavior: "arrive" | "leaveEarly") => {
      actor = applyRehearsalBehavior(actor, behavior, [], session.virtualNow);
    }};
}

test(
  "practice outreach supports venues, stops and pace groups", async () => {
    for (const kind of ["fixedPlace", "itineraryStop",
      "groupCheckpoint"] as const) {
      const h = setup();
      const plan = practicePlan(h.session.virtualNow.toMillis());
      if (kind === "itineraryStop") {
        plan.policy.destination = {kind, itineraryId: "crawl",
          permittedStopIds: ["bar"]};
        plan.guidance.destination = {kind, itineraryId: "crawl", stopId: "bar"};
      } else if (kind === "groupCheckpoint") {
        plan.policy.destination = {kind, routeId: "run", groupId: "slow",
          permittedCheckpointIds: ["water"]};
        plan.guidance.destination = {kind, routeId: "run", groupId: "slow",
          checkpointId: "water"};
      }
      await h.host({kind: "publish", plan});
      const message = h.message();
      assert.equal(message.record.intent.context.mode, "rehearsal");
      assert.equal(message.plan.guidance.destination.kind, kind);
      assert.equal(h.actor().status, "expected");
      const view = practiceMessageView(h.session, h.actor(), message)!;
      assert.equal(view.canRespond, true);
      assert.equal("plan" in view, false);
      assert.equal("attempts" in view, false);
      assert.deepEqual(h.fake.entries().map(([p]) => p.split("/")[0]).sort(),
        ["eventRehearsalActors", "eventRehearsalMessages"]);
    }
  });

test(
  "uncertainty holds fallback until confirmed non-delivery", async () => {
    const h = setup();
    await h.host({kind: "publish",
      plan: practicePlan(h.session.virtualNow.toMillis())});
    const messageId = h.message().record.messageId;
    await h.host({kind: "dispatch", messageId,
      outcome: {kind: "unknown", reason: "timeout"}});
    const attemptId = h.message().record.attempts[0].attemptId;
    h.advance(3);
    await h.host({kind: "dispatch", messageId,
      outcome: {kind: "delivered"}});
    assert.equal(h.message().record.attempts.length, 1);
    await h.host({kind: "receipt", messageId, attemptId,
      outcome: {kind: "failed", classification: "technical"}});
    h.advance(1);
    await h.host({kind: "dispatch", messageId,
      outcome: {kind: "delivered"}});
    const attempts = h.message().record.attempts;
    assert.equal(attempts.length, 2);
    assert.ok(attempts[1].mode === "rehearsal");
    assert.equal(attempts[1].routeId, "catchEventSms");
    assert.equal(attempts.every((a) => a.mode === "rehearsal" &&
    !("binding" in a)), true);
  });

test("instruction refresh survives an outreach cap without sending again",
  async () => {
    const h = setup();
    const plan = practicePlan(h.session.virtualNow.toMillis());
    plan.policy.maxMessagesPerEpisode = 1;
    await h.host({kind: "publish", plan});
    await h.host({kind: "dispatch", messageId: h.message().record.messageId,
      outcome: {kind: "delivered"}});
    h.advance(10);
    const changed = {...plan, guidance: {...plan.guidance, revision: 2,
      materialKey: "venue-2", text: "Meet at the updated entrance."}};
    await h.host({kind: "publish", plan: changed});
    await h.host({kind: "dispatch", messageId: h.message().record.messageId,
      outcome: {kind: "delivered"}});
    assert.equal(h.message().record.attempts.length, 0);
    assert.equal(practiceMessageView(h.session, h.actor(), h.message())?.text,
      changed.guidance.text);
    await h.reply("on-my-way");
    assert.equal(h.actor().assistance?.intention.kind, "onMyWay");
  });

test(
  "arrival and deadlines close current reply controls", async () => {
    for (const change of ["arrive", "deadline"] as const) {
      const h = setup();
      const plan = practicePlan(h.session.virtualNow.toMillis());
      plan.policy.unanswered = "hostReviewAtDeadline";
      plan.responseDeadline = h.session.virtualNow.toMillis() + 60000;
      await h.host({kind: "publish", plan});
      if (change === "arrive") h.behavior("arrive");
      else h.advance(2);
      assert.equal(practiceMessageView(h.session, h.actor(),
        h.message())?.canRespond, false);
      await assert.rejects(h.reply("on-my-way"), {code: "failed-precondition"});
      assert.equal(h.message().record.response, null);
    }
  });

test(
  "guest intentions and help commit with the response without attendance",
  async () => {
    for (const choice of ["on-my-way", "not-coming", "need-help"]) {
      const h = setup();
      await h.host({kind: "publish",
        plan: practicePlan(h.session.virtualNow.toMillis())});
      await h.reply(choice);
      assert.equal(h.actor().status, "expected");
      assert.equal(h.actor().assistance?.intention.kind,
        choice === "on-my-way" ? "onMyWay" : choice === "not-coming" ?
          "notComing" : "unknown");
      assert.equal(h.actor().helpRequested, choice === "need-help");
      assert.equal(h.message().record.response?.choiceId, choice);
      assert.equal(practiceMessageView(h.session, h.actor(),
        h.message())?.canRespond, false);
      const before = h.fake.entries();
      await h.reply(choice);
      assert.deepEqual(h.fake.entries(), before);
      await assert.rejects(h.reply(choice, "different-request"),
        {code: "failed-precondition"});
    }
  });

test("join-later keeps the chosen stop", async () => {
  const h = setup();
  const plan = practicePlan(h.session.virtualNow.toMillis());
  plan.policy.destination = {kind: "itineraryStop", itineraryId: "crawl",
    permittedStopIds: ["first", "second"]};
  plan.guidance.destination = {kind: "itineraryStop", itineraryId: "crawl",
    stopId: "first"};
  const target = {kind: "itineraryStop" as const, itineraryId: "crawl",
    stopId: "second"};
  plan.laterChoices = [{label: "Join at the second stop", target}];
  await h.host({kind: "publish", plan});
  const choice = h.message().record.intent.choices.find((c) =>
    c.label === "Join at the second stop")!;
  await h.reply(choice.choiceId);
  assert.deepEqual(h.actor().assistance?.intention,
    {kind: "joinLater", target});
  assert.equal(h.actor().status, "expected");
  await assert.rejects(h.host({kind: "publish", plan}),
    {code: "failed-precondition"});
  h.advance(30);
  await h.host({kind: "publish", plan: {...plan, guidance: {...plan.guidance,
    revision: 2, materialKey: "second-stop", destination: target,
    text: "We have reached the second stop."}}});
  assert.equal(h.message().record.lifecycle, "active");
  assert.deepEqual(h.message().plan.guidance.destination, target);
});

test("an interrupted reply leaves both the actor and message unchanged",
  async () => {
    const h = setup();
    await h.host({kind: "publish",
      plan: practicePlan(h.session.virtualNow.toMillis())});
    const before = h.fake.entries();
    h.fake.failNextCommit = true;
    await assert.rejects(h.reply("not-coming"), /interruption/u);
    assert.deepEqual(h.fake.entries(), before);
    await h.reply("not-coming");
    assert.equal(h.message().record.lifecycle, "responded");
  });

test("a reset epoch ignores messages left by an older run", async () => {
  const h = setup();
  const plan = practicePlan(h.session.virtualNow.toMillis());
  await h.host({kind: "publish", plan});
  const old = h.message().record.messageId;
  h.session.setupRevision += 1;
  await h.host({kind: "publish", plan});
  assert.notEqual(h.message().record.messageId, old);
  await h.reply("on-my-way");
  assert.equal(h.actor().assistance?.intention.kind, "onMyWay");
});

test(
  "attendance and confirmed departure govern practice outreach", async () => {
    for (const mode of ["arrive", "leaveEarly", "unconfirmed"] as const) {
      const h = setup();
      const plan = practicePlan(h.session.virtualNow.toMillis());
      if (mode === "unconfirmed") plan.departureConfirmed = false;
      else h.behavior(mode);
      await assert.rejects(h.host({kind: "publish", plan}),
        {code: "failed-precondition"});
      assert.equal(h.fake.entries().length, 0);
    }
  });

test(
  "reset, foreign scope and forged plans fail closed", async () => {
    const h = setup();
    await h.host({kind: "publish",
      plan: practicePlan(h.session.virtualNow.toMillis())});
    const message = h.message();
    for (const other of [{...h.session, setupRevision: 1},
      {...h.session, virtualStartedAt: Timestamp.fromMillis(0)}]) {
      assert.throws(() => readPracticeMessage(message, other, h.actor()));
    }
    for (const patch of [{actorId: "other"}, {sessionId: "other"},
      {record: {...message.record, intent: {...message.record.intent,
        context: {mode: "live", organizerId: "real", eventId: "real"}}}}]) {
      assert.throws(() => readPracticeMessage({...message, ...patch},
        h.session, h.actor()));
    }
    const invalid = {...message.plan, routes: ["catchEventSms"]};
    assert.throws(() => readPracticeMessage({...message, plan: invalid},
      h.session, h.actor()));
  });

test("Firestore serializes Host rehearsal commands, guest replies and reset", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const {readFileSync} = await import("node:fs");
  const {createHash, randomUUID} = await import("node:crypto");
  const {controlEventRehearsalHandler, submitEventRehearsalGuestActionHandler,
    resetEventRehearsalHandler} = await import("./handlers.js");
  if (!admin.apps.length) admin.initializeApp({projectId: "demo-catch-rules"});
  const db = admin.firestore();
  const id = randomUUID();
  const session = practiceSession();
  session.organizerId = "practice-owner-" + id;
  session.clubId = session.organizerId;
  session.publicRehearsalId = "public-" + id;
  const fixture = JSON.parse(readFileSync(
    "../contracts/fixtures/valid/club_doc.json", "utf8"));
  const organizerSchema = JSON.parse(readFileSync(
    "../contracts/firestore/organizers.schema.json", "utf8"));
  const organizer = {...Object.fromEntries(Object.entries(fixture).filter((
    [key]) =>
    key in organizerSchema.properties)), followerCount: 0,
  organizerPhotos: [], organizerType: "community"};
  const sessionRef = db.collection("eventRehearsals").doc(id);
  const actors = buildRehearsalActors(id, 2, 1, session.virtualNow);
  await db.collection("organizers").doc(session.organizerId).set(organizer);
  await sessionRef.set(session);
  for (const actor of actors) {
    await db.collection("eventRehearsalActors")
      .doc(id + "_" + actor.actorId).set(actor);
  }
  const request = (data: unknown, uid = "host-1") => ({data,
    auth: {uid,
      token: {}}}) as Parameters<typeof controlEventRehearsalHandler>[0];
  const publish = {sessionId: id, expectedRevision: 1,
    clientActionId: randomUUID(),
    action: "assistance", assistance: {kind: "publish",
      actorId: actors[0].actorId,
      plan: practicePlan(session.virtualNow.toMillis())}};
  await assert.rejects(controlEventRehearsalHandler(request(publish,
    "stranger")),
  {code: "permission-denied"});
  const first = await controlEventRehearsalHandler(request(publish));
  const message = first.actors.find((a) =>
    a.actorId === actors[0].actorId)?.assistanceMessage;
  assert.ok(message);
  const replay = await controlEventRehearsalHandler(request(publish));
  assert.equal(replay.session.runtimeRevision, first.session.runtimeRevision);
  assert.equal(replay.session.actionCount, 1);
  await assert.rejects(controlEventRehearsalHandler(request({...publish,
    assistance: {...publish.assistance, plan: {...publish.assistance.plan,
      departureConfirmed: false}}})), {code: "aborted"});
  const slotId = "a".repeat(24);
  const slotToken = slotId + "_" + "b".repeat(40);
  await db.collection("eventRehearsalGuestViews").doc(id + "_" + slotId).set({
    sessionId: id, slotId, actorId: actors[0].actorId,
    tokenHash: createHash("sha256").update(slotToken).digest("hex"),
    createdAt: session.createdAt, lastSeenAt: session.createdAt,
    expiresAt: session.expiresAt});
  const replies = ["on-my-way", "not-coming"].map((choiceId) => ({
    publicRehearsalId: session.publicRehearsalId, slotToken,
    clientActionId: (choiceId === "on-my-way" ? "a" : "b").repeat(120),
    action: "respondToAssistance",
    messageId: message.messageId, intentRevision: message.intentRevision,
    choiceId}));
  const results = await Promise.allSettled(replies.map((data) =>
    submitEventRehearsalGuestActionHandler(request(data))));
  assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
  const winner = results.findIndex((r) => r.status === "fulfilled");
  const response = await submitEventRehearsalGuestActionHandler(request(
    replies[winner]));
  assert.equal(response.actor.status, "expected");
  assert.equal(response.actor.assistanceMessage?.responseChoiceId,
    replies[winner].choiceId);
  assert.equal(response.session.runtimeRevision,
    first.session.runtimeRevision + 1);
  await assert.rejects(submitEventRehearsalGuestActionHandler(request({
    ...replies[winner], slotToken: slotId + "_" + "c".repeat(40)})),
  {code: "permission-denied"});
  assert.equal((await db.collection("eventAssistanceMessages")
    .where("intent.context.rehearsalId", "==", id).get()).empty, true);
  // Old-generation remnants must not survive a cleanup batch boundary.
  const remnants = db.batch();
  for (let index = 0; index < 500; index += 1) {
    remnants.set(db.collection(rehearsalMessages).doc(id + "_old_" + index),
      {sessionId: id});
  }
  await remnants.commit();
  await resetEventRehearsalHandler(request({sessionId: id, fork: false,
    seed: null}));
  assert.equal((await db.collection(rehearsalMessages)
    .where("sessionId", "==", id).get()).empty, true);
  await assert.rejects(submitEventRehearsalGuestActionHandler(request(
    replies[winner])));
});
