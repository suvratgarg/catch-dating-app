import assert from "node:assert/strict";
import test from "node:test";
import {createHmac, randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore, Timestamp} from "firebase-admin/firestore";
import {FakeFirestore} from "../../operations/testFirestore";
import {operationContentHash} from "../../operations/durableActions";
import {ingestMetaWhatsappWebhook} from
  "../../organizers/organizerWhatsappWebhook";
import {WHATSAPP_ENDPOINT_STOPS, parseWhatsappStop, whatsappStopId} from
  "../../shared/organizerWhatsappStops";
import type {SetEventWhatsappPreferenceCallablePayload as PreferenceInput} from
  "../../shared/generated/setEventWhatsappPreferenceCallablePayload";
import {GuestAssistanceStore} from "./guestAssistanceStore";
import {readEventAssistanceMessageGate} from "./guestMessageGate";
import {parseMessageIntent} from "./messageProtocol";
import {assistanceMessageId} from "./messageOutbox";
import type {MessageRecord} from "./messageOutbox";
import {WhatsappPreferenceStore} from "./whatsappPreferenceStore";
import {WHATSAPP_CONSENT_VERSION} from "./whatsappConsent";
import {WhatsappDispatchStore} from "./whatsappDispatchStore";
import {whatsappEndpointHash, WHATSAPP_REPLY_BINDINGS} from
  "./whatsappReplyProtocol";
import {whatsappBudgetScopes, whatsappBudgetId, WHATSAPP_BUDGETS,
  WHATSAPP_DISPATCHES} from "./whatsappSpend";
import {WHATSAPP_POLICIES, whatsappTemplateSnapshot, WhatsappPolicy} from
  "./whatsappTemplate";

const start = Date.parse("2026-09-07T12:00:00Z");
const keys = {currentKeyId: "fixture-key", keyFor: () => Buffer.alloc(32, 6)};
const appSecret = "fixture-stop-secret";
async function harness(realDb?: Firestore, id = "test") {
  const fake = new FakeFirestore();
  const db = realDb ?? fake as unknown as Firestore;
  const clock = {now: start};
  const write = async (path: string, value: object) => {
    if (realDb) await realDb.doc(path).set(value);
    else fake.write(path, value as Record<string, unknown>);
  };
  const read = async (path: string) => realDb ?
    (await realDb.doc(path).get()).data() : fake.read(path);
  const context = {mode: "live" as const, organizerId: "o-" + id,
    eventId: "e-" + id};
  const scope = {eventId: context.eventId, attendeeId: "a-" + id,
    senderId: "sender-" + id};
  const actor = {uid: "u-" + id, phone: "+919999999999"};
  const phoneNumberId = "800" + BigInt("0x" +
    operationContentHash(id).slice(0, 16)).toString();
  const senderPath = "organizerSenderConnections/" + scope.senderId;
  const policyPath = WHATSAPP_POLICIES + "/" + scope.senderId;
  const attendeePath = "eventAttendees/" + scope.attendeeId;
  const stamp = {_seconds: start / 1000, _nanoseconds: 0};
  await write("events/" + context.eventId, {organizerId: context.organizerId,
    status: "active", name: "Fixture event",
    endTime: {_seconds: start / 1000 + 3600, _nanoseconds: 0}});
  await write(attendeePath, {organizerId: context.organizerId,
    eventId: context.eventId, status: "registered", linkedUid: actor.uid,
    phoneE164: actor.phone, createdAt: stamp});
  await write(senderPath, {organizerId: context.organizerId,
    channel: "whatsapp", provider: "metaCloudApi", status: "active",
    wabaId: "700123", phoneNumberId, businessId: "900123",
    displayPhoneNumber: "+918888888888", verifiedName: "Fixture organizer",
    secretVersionResource: "projects/demo/secrets/WA_FIXTURE/versions/1",
    qualityRating: "GREEN", messagingLimitTier: null,
    templateSyncStatus: "current", webhookStatus: "subscribed",
    testStatus: "delivered", testProviderMessageId: "wamid.fixture",
    testRecipientHash: null, connectedByUid: "manager", revision: 1,
    createdAt: stamp, updatedAt: stamp, disconnectedAt: null});
  const templateId = "template-" + id;
  const templatePath = "organizerMessageTemplates/" + templateId;
  const template = {organizerId: context.organizerId,
    connectionId: scope.senderId, providerTemplateId: "600123", name: "update",
    language: "en", category: "UTILITY", status: "APPROVED",
    variableNames: ["instruction", "response_url"], parameterBindings: [
      {variableName: "instruction", component: "body", position: 0,
        buttonIndex: null},
      {variableName: "response_url", component: "body", position: 1,
        buttonIndex: null},
    ], hasMediaHeader: false, buttonKinds: ["QUICK_REPLY"],
    buttonLabels: ["On my way"], buttonUrls: [null], parameterFormat: "NAMED",
    contentHash: "f".repeat(64), providerUpdatedAt: null, syncedAt: stamp};
  await write(templatePath, template);
  const policy: WhatsappPolicy = {schemaVersion: 1, senderId: scope.senderId,
    organizerId: context.organizerId, revision: 1, status: "ready",
    providerAccountId: "700123", providerPhoneNumberId: phoneNumberId,
    maxTemplateAgeSeconds: 900, activation: {approvalId: "fixture-review",
      approvedAt: start - 1000, validUntil: start + 3_600_000},
    quote: {revision: 1, currency: "INR", recipientPrefixes: ["+91"],
      maxMicrosPerMessage: 500_000, validUntil: start + 3_600_000},
    templates: [{templateDocumentId: templateId, purpose: "joiningUpdate",
      templateHash: operationContentHash(whatsappTemplateSnapshot(template)),
      variables: [
        {providerName: "instruction", source: "instruction",
          maxCharacters: 500},
        {providerName: "response_url", source: "responseUrl",
          maxCharacters: 160},
      ], quickReplies: [{buttonIndex: 0, choiceId: "on-way", label: "On my way",
        action: "onMyWay"}]}]};
  await write(policyPath, policy);
  const guests = new GuestAssistanceStore(db, () => clock.now);
  const guest = await guests.startEpisode(context, scope.attendeeId,
    "start", null);
  const intent: MessageRecord["intent"] = {schemaVersion: 1,
    intentId: "m-" + id,
    revision: 1, context, eventId: context.eventId,
    attendeeId: scope.attendeeId,
    episodeId: guest.episodeId,
    workflow: {kind: "lateJoin", occurrenceId: "s1"},
    createdAt: start, expiresAt: start + 1_800_000,
    permittedRoutes: ["organizerEventWhatsapp"],
    deliveryPolicy: {maxAttempts: 2,
      maxAttemptsPerRoute: 1, minimumRetrySeconds: 1}, kind: "joiningUpdate",
    guidance: {revision: 1, materialKey: "s1", text: "Join us at stop one.",
      validUntil: start + 1_800_000, destination: {kind: "itineraryStop",
        itineraryId: "route", stopId: "s1"}}, choices: [{choiceId: "on-way",
      label: "On my way", value: {kind: "joinIntent",
        intention: {kind: "onMyWay", claimedEta: null}}}]};
  const thread = await guests.publishMessage(intent, null);
  const link = await guests.issueLink(thread.threadId, "send", keys);
  const preferences = new WhatsappPreferenceStore(db, () => clock.now);
  const initial = (await preferences.get(actor, scope)).view;
  const grant = {...scope, requestId: "grant", expectedRevision: null,
    decision: {kind: "grant" as const, copyVersion: WHATSAPP_CONSENT_VERSION,
      senderHash: initial.sender!.bindingHash,
      stopRecordHash: null}} satisfies PreferenceInput;
  await preferences.set(actor, grant);
  const budgetPaths: string[] = [];
  for (const budgetScope of whatsappBudgetScopes(context, start)) {
    const begins = budgetScope.kind === "senderDay" ?
      Date.parse(budgetScope.day + "T00:00:00Z") : start - 1000;
    const budgetId = whatsappBudgetId(scope.senderId, "INR", budgetScope);
    const path = WHATSAPP_BUDGETS + "/" + budgetId;
    budgetPaths.push(path);
    await write(path, {schemaVersion: 1, budgetId, senderId: scope.senderId,
      revision: 1, scope: budgetScope, status: "active", approvalId: "fixture",
      currency: "INR", limitMicros: 2_000_000, chargedMicros: 0,
      startsAt: begins, endsAt: budgetScope.kind === "senderDay" ?
        begins + 86_400_000 : start + 3_600_000, updatedAt: start});
  }
  const store = new WhatsappDispatchStore(db, scope.senderId, keys,
    () => clock.now);
  const expected = (await store.sender())!;
  const outbox = store.outbox(link.linkId);
  const messageId = assistanceMessageId(intent);
  const reserve = () => outbox.reserve(messageId);
  const claim = async () => {
    const reservation = await reserve();
    const attempt = reservation.record.attempts.at(-1)!;
    return outbox.claimLiveDispatch(messageId, attempt.attemptId,
      store.prepare(link.linkId, expected));
  };
  const stop = async (at: number, key = "stop") => {
    const rawBody = Buffer.from(JSON.stringify({entry: [{id: "700123",
      changes: [{value: {metadata: {phone_number_id: phoneNumberId},
        messages: [{id: "wamid." + id + key, from: actor.phone.slice(1),
          timestamp: String(at / 1000), type: "text", text: {body: "STOP"}}],
      }}]}]}));
    return ingestMetaWhatsappWebhook({db, rawBody, appSecret,
      now: Timestamp.fromMillis(clock.now), signatureHeader: "sha256=" +
        createHmac("sha256", appSecret).update(rawBody).digest("hex")});
  };
  return {fake, db, clock, context, scope, actor, expected, outbox, messageId,
    intent, guests,
    link, store, claim, reserve, stop, preferences, grant, budgetPaths,
    senderPath, policyPath, attendeePath, templatePath, read, write};
}

test("one claim atomically debits two ceilings and freezes native choices",
  async () => {
    const h = await harness();
    const result = await h.claim();
    assert.equal(result.kind, "claimed");
    if (result.kind !== "claimed") return;
    const attemptId = result.permit.attempt.attemptId;
    const dispatch = await h.read(WHATSAPP_DISPATCHES + "/" + attemptId);
    const native = await h.read(WHATSAPP_REPLY_BINDINGS + "/" + attemptId);
    assert.equal(dispatch!.maxCostMicros, 500_000);
    assert.equal(dispatch!.replyBindingId, attemptId);
    assert.equal(native!.attemptId, attemptId);
    assert.equal(result.resource.replies[0].payload,
      (native!.choices as Array<{nativeId: string}>)[0].nativeId);
    assert.equal(result.permit.attempt.state.kind, "unknown");
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))!.chargedMicros, 500_000);
    }
    assert.equal((await h.claim()).kind, "withheld");
    assert.equal(JSON.stringify([dispatch, native])
      .includes(h.actor.phone), false);
    assert.equal(JSON.stringify([dispatch, native])
      .includes(h.link.secret), false);
  });

test("failed commits leave no debit or reply binding and can safely retry",
  async () => {
    const h = await harness();
    await h.reserve();
    h.fake.failNextCommit = true;
    await assert.rejects(h.outbox.claimLiveDispatch(h.messageId,
      (await h.outbox.get(h.messageId))!.attempts[0].attemptId,
      h.store.prepare(h.link.linkId, h.expected)), /interruption/);
    assert.equal(h.fake.entries().some(([p]) =>
      p.startsWith(WHATSAPP_DISPATCHES + "/")), false);
    assert.equal(h.fake.entries().some(([p]) =>
      p.startsWith(WHATSAPP_REPLY_BINDINGS + "/")), false);
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))!.chargedMicros, 0);
    }
    assert.equal((await h.claim()).kind, "claimed");
  });

test("fresh consent, sender, template, roster and spending gate each claim",
  async () => {
    for (const change of ["consent", "sender", "template",
      "roster", "budget"]) {
      const h = await harness();
      await h.reserve();
      if (change === "consent") {
        await h.preferences.set(h.actor, {...h.scope,
          requestId: "withdraw", expectedRevision: 1,
          decision: {kind: "revoke"}});
      }
      const path = change === "sender" ? h.senderPath :
        change === "template" ? h.templatePath : change === "roster" ?
          h.attendeePath : h.budgetPaths[1];
      const patch = change === "sender" ? {revision: 2} :
        change === "template" ? {contentHash: "e".repeat(64)} :
          change === "roster" ? {status: "checkedIn"} : {limitMicros: 1};
      if (change !== "consent") {
        await h.write(path,
          {...(await h.read(path)), ...patch});
      }
      assert.equal((await h.claim()).kind, "withheld", change);
      for (const budget of h.budgetPaths) {
        assert.equal((await h.read(budget))!.chargedMicros, 0, change);
      }
    }
  });

test("STOP needs no CRM contact and fences unseen re-enablement",
  async () => {
    const h = await harness();
    await h.reserve();
    h.clock.now += 1000;
    await h.stop(h.clock.now);
    assert.equal((await h.claim()).kind, "withheld");
    const stopped = (await h.preferences.get(h.actor, h.scope)).view;
    assert.equal(stopped.preference, "disabled");
    h.clock.now += 1000;
    await assert.rejects(h.preferences.set(h.actor, {...h.grant,
      requestId: "stale-enable", expectedRevision: 1}), /cannot be enabled/);
    const renewed = await h.preferences.set(h.actor, {...h.grant,
      requestId: "fresh-enable", expectedRevision: 1,
      decision: {...h.grant.decision, stopRecordHash: stopped.stopRecordHash}});
    assert.equal(renewed.view.preference, "enabled");
    // A pre-STOP reservation cannot inherit the renewed permission.
    assert.equal((await h.claim()).kind, "withheld");
    const id = whatsappStopId(h.context.organizerId,
      whatsappEndpointHash(h.actor.phone)!);
    const record = parseWhatsappStop(await h.read(WHATSAPP_ENDPOINT_STOPS +
      "/" + id));
    assert.equal(record.revision, 1);
  });

test("older STOP deliveries cannot reverse a later explicit event opt-in",
  async () => {
    const h = await harness();
    h.clock.now += 1000;
    await h.stop(h.clock.now, "new-stop");
    const stopped = (await h.preferences.get(h.actor, h.scope)).view;
    h.clock.now += 1000;
    await h.preferences.set(h.actor, {...h.grant, requestId: "fresh",
      expectedRevision: 1, decision: {...h.grant.decision,
        stopRecordHash: stopped.stopRecordHash}});
    await h.stop(start, "old-stop");
    assert.equal((await h.preferences.get(h.actor, h.scope)).view.preference,
      "enabled");
    assert.equal((await h.claim()).kind, "claimed");
  });

test("unknown delivery retains its debit and cannot obtain another claim",
  async () => {
    const h = await harness();
    await h.claim();
    h.clock.now += 200_000;
    assert.equal((await h.reserve()).decision.kind, "reconcile");
    assert.equal((await h.claim()).kind, "withheld");
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))!.chargedMicros, 500_000);
    }
  });

test("event consent stays separate from announcement opt-out and CRM pauses",
  async () => {
    for (const kind of ["marketing", "admin", "provider", "legacyStop"]) {
      const h = await harness();
      await h.reserve();
      const stamp = {_seconds: start / 1000, _nanoseconds: 0};
      await h.write("organizerContactChannelStates/contact-state", {
        organizerId: h.context.organizerId, contactId: "contact",
        channel: "whatsapp", endpointHash: whatsappEndpointHash(h.actor.phone),
        suppressionStatus: kind === "provider" ? "providerBlocked" : "optedOut",
        suppressionSource: kind === "legacyStop" ? "inboundStop" : "preference",
        adminSuppressed: kind === "admin", campaignAcceptedCount: 0,
        lastCampaignAcceptedAt: null, lastInboundAt: stamp, lastReplyAt: null,
        createdAt: stamp, updatedAt: stamp,
      });
      assert.equal((await h.claim()).kind,
        kind === "marketing" ? "claimed" : "withheld", kind);
    }
  });

test("templates with webpage choices need no empty native binding",
  async () => {
    const h = await harness();
    const template = {...(await h.read(h.templatePath)),
      buttonKinds: [], buttonLabels: [], buttonUrls: []};
    await h.write(h.templatePath, template);
    const policy = structuredClone(h.expected.policy);
    policy.templates[0].quickReplies = [];
    policy.templates[0].templateHash = operationContentHash(
      whatsappTemplateSnapshot(template));
    await h.write(h.policyPath, policy);
    const expected = (await h.store.sender())!;
    const reserved = await h.reserve();
    const attempt = reserved.record.attempts[0];
    const result = await h.outbox.claimLiveDispatch(h.messageId,
      attempt.attemptId, h.store.prepare(h.link.linkId, expected));
    assert.equal(result.kind, "claimed");
    const dispatch = await h.read(WHATSAPP_DISPATCHES + "/" +
      attempt.attemptId);
    assert.equal(dispatch!.replyBindingId, null);
    assert.equal(await h.read(WHATSAPP_REPLY_BINDINGS + "/" +
      attempt.attemptId), undefined);
    if (result.kind === "claimed") {
      assert.ok(result.resource.rendered.variables.response_url
        .startsWith("https://catchdates.com/event-update/"));
    }
  });

test("shortened event windows cap existing post-event message authority",
  async () => {
    const h = await harness();
    const value: Record<string, unknown> = {...h.intent,
      kind: "operationalNotice", intentId: "follow-up", noticeKind: "followUp",
      instructionRevision: 1, title: "Thank you", body: "Thanks for joining.",
      workflow: {kind: "lateJoin", occurrenceId: "follow-up"},
      choices: [{choiceId: "ack", label: "Got it", value: {
        kind: "acknowledge", instructionRevision: 1}}]};
    delete value.guidance;
    const intent = parseMessageIntent(value);
    const path = "events/" + h.context.eventId;
    await h.write(path, {...(await h.read(path)),
      endTime: Timestamp.fromMillis(start - 86_400_000 + 1)});
    await h.guests.publishMessage(intent, null);
    const readGate = () => h.db.runTransaction((tx) =>
      readEventAssistanceMessageGate(h.db, tx, intent, h.clock.now));
    const before = await readGate();
    assert.equal(before.kind, "allow");
    if (before.kind === "allow") assert.equal(before.validUntil, start + 1);
    h.clock.now += 1;
    assert.deepEqual(await readGate(), {kind: "stop", reason: "eventClosed"});
  });

test("Firestore arbitrates one claim/debit under eight competing workers", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const id = randomUUID();
  const app = initializeApp({projectId: "demo-catch-rules"},
    "wa-dispatch-" + id);
  try {
    const h = await harness(getFirestore(app), id);
    const results = await Promise.all(Array.from({length: 8}, () => h.claim()));
    assert.equal(results.filter((r) => r.kind === "claimed").length, 1);
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))!.chargedMicros, 500_000);
      assert.equal((await h.read(path))!.revision, 2);
    }
    // Different outboxes must contend on spending, not just on message CAS.
    const shared = await harness(getFirestore(app), id + "-shared");
    for (const path of shared.budgetPaths) {
      await shared.write(path, {...(await shared.read(path)),
        limitMicros: 500_000});
    }
    const secondIntent = {...shared.intent, intentId: "second-" + id,
      workflow: {kind: "lateJoin" as const, occurrenceId: "s2"}};
    const thread = await shared.guests.publishMessage(secondIntent, null);
    const link = await shared.guests.issueLink(thread.threadId, "second", keys);
    const second = shared.store.outbox(link.linkId);
    const secondId = assistanceMessageId(secondIntent);
    const reservation = await second.reserve(secondId);
    await shared.reserve();
    const resultsAcrossMessages = await Promise.all([
      shared.claim(), second.claimLiveDispatch(secondId,
        reservation.record.attempts[0].attemptId,
        shared.store.prepare(link.linkId, shared.expected)),
    ]);
    assert.equal(resultsAcrossMessages.filter((r) => r.kind === "claimed")
      .length, 1);
    for (const path of shared.budgetPaths) {
      assert.equal((await shared.read(path))!.chargedMicros, 500_000);
    }
    shared.clock.now += 1000;
    const stops = await Promise.all(Array.from({length: 8}, () =>
      shared.stop(shared.clock.now)));
    assert.equal(stops.reduce((a, b) => a + b, 0), 1);
    const preference = await shared.preferences.get(shared.actor, shared.scope);
    assert.equal(preference.view.preference, "disabled");
  } finally {
    await deleteApp(app);
  }
});
