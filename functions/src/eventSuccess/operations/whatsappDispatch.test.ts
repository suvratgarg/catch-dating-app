import assert from "node:assert/strict";
import test from "node:test";
import {createHash, createHmac, randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore, Timestamp} from "firebase-admin/firestore";
import {FakeFirestore} from "../../operations/testFirestore";
import {operationContentHash} from "../../operations/durableActions";
import {ingestMetaWhatsappWebhook} from
  "../../organizers/organizerWhatsappWebhook";
import {MetaWhatsappProvider} from
  "../../organizers/organizerWhatsappProvider";
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
import {EventWhatsappWorker} from "./whatsappWorker";
import {WhatsappDeliveryStore} from "./whatsappDeliveryStore";
import {whatsappStatusCorrelation} from "./whatsappDeliveryProtocol";
import {WhatsappReplyStore} from "./whatsappReplyStore";
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

type Harness = Awaited<ReturnType<typeof harness>>;
function worker(h: Harness, fetchImpl: typeof fetch,
  credential = async () => "fixture-token") {
  const provider = new MetaWhatsappProvider({appId: "fixture",
    appSecret: "fixture", configId: "fixture", graphVersion: "v23.0"},
  fetchImpl, () => h.clock.now);
  return new EventWhatsappWorker(h.store, provider, {
    accessBound: async (scope) => {
      assert.deepEqual(scope, {
        versionResource: h.expected.connection.secretVersionResource,
        organizerId: h.context.organizerId, connectionId: h.scope.senderId,
      });
      return credential();
    },
  }, () => h.clock.now);
}

async function queuedStatus(h: Harness, correlation: string, status: string,
  overrides: Record<string, unknown> = {}) {
  const value = {id: "wamid.delivery", status,
    timestamp: String(h.clock.now / 1000),
    recipient_id: h.actor.phone.slice(1),
    biz_opaque_callback_data: correlation, ...overrides};
  const rawBody = Buffer.from(JSON.stringify({entry: [{
    id: h.expected.connection.wabaId, changes: [{value: {
      metadata: {phone_number_id: h.expected.connection.phoneNumberId},
      statuses: [value],
    }}],
  }]}));
  await ingestMetaWhatsappWebhook({db: h.db, rawBody, appSecret,
    now: Timestamp.fromMillis(h.clock.now), signatureHeader: "sha256=" +
      createHmac("sha256", appSecret).update(rawBody).digest("hex")});
  const identity = "status:" + value.id + ":" + value.status + ":" +
    Number(value.timestamp) * 1000;
  return "omwe_" + createHash("sha256").update(identity)
    .digest("hex").slice(0, 48);
}

test("WhatsApp worker claims once and sends the exact reviewed native payload",
  async () => {
    const h = await harness();
    let sends = 0;
    const service = worker(h, async (url, init) => {
      sends++;
      assert.ok(String(url).endsWith(
        "/" + h.expected.connection.phoneNumberId + "/messages"));
      const body = JSON.parse(init!.body as string);
      const attempt = (await h.outbox.get(h.messageId))!.attempts[0];
      assert.equal(attempt.state.kind, "unknown");
      const dispatch = await h.read(WHATSAPP_DISPATCHES + "/" +
        attempt.attemptId);
      assert.equal(body.biz_opaque_callback_data,
        whatsappStatusCorrelation(attempt.attemptId,
          dispatch!.payloadHash as string));
      assert.equal(body.to, h.actor.phone.slice(1));
      assert.equal(body.template.name, "update");
      assert.equal(body.template.components[0].parameters[0].text,
        "Join us at stop one.");
      const native = await h.read(WHATSAPP_REPLY_BINDINGS + "/" +
        attempt.attemptId);
      assert.equal(body.template.components[1].parameters[0].payload,
        (native!.choices as Array<{nativeId: string}>)[0].nativeId);
      return Response.json({messages: [{id: "wamid.delivery"}]});
    });
    const results = await Promise.all(Array.from({length: 8}, () =>
      service.dispatch(h.messageId, h.link.linkId)));
    assert.equal(sends, 1);
    assert.equal(results.filter((r) => r.kind === "submitted").length, 1);
    assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
      "accepted");
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))!.chargedMicros, 500_000);
    }
    const durable = JSON.stringify(h.fake.entries());
    assert.equal(durable.includes("fixture-token"), false);
  });

test("secret latency precedes reservation and sender rotation fences the claim",
  async () => {
    for (const mode of ["slow", "missing", "rotated"] as const) {
      const h = await harness();
      let sends = 0;
      const service = worker(h, async () => {
        sends++;
        return Response.json({messages: [{id: "wamid.delivery"}]});
      }, async () => {
        assert.equal((await h.outbox.get(h.messageId))!.attempts.length, 0);
        if (mode === "missing") throw new Error("private-vault-error");
        if (mode === "slow") h.clock.now += 60_000;
        if (mode === "rotated") {
          await h.write(h.senderPath,
            {...(await h.read(h.senderPath)), revision: 2,
              secretVersionResource:
              "projects/demo/secrets/WA_FIXTURE/versions/2"});
        }
        return "fixture-token";
      });
      const result = await service.dispatch(h.messageId, h.link.linkId);
      assert.equal(result.kind, mode === "slow" ? "submitted" : "withheld");
      assert.equal(sends, mode === "slow" ? 1 : 0);
      if (mode === "missing") {
        assert.deepEqual(result,
          {kind: "withheld", reason: "credentialUnavailable"});
      }
    }
  });

test("unknown submission and receipt commit failure never repeat provider I/O",
  async () => {
    const faults = ["connectionLost", "receiptLost", "httpError"] as const;
    for (const mode of faults) {
      const h = await harness();
      let sends = 0;
      let correlation = "";
      const service = worker(h, async (_, init) => {
        sends++;
        correlation = JSON.parse(init!.body as string).biz_opaque_callback_data;
        if (mode === "connectionLost") throw new Error("lost response");
        if (mode === "receiptLost") h.fake.failNextCommit = true;
        if (mode === "httpError") {
          return Response.json({error: {code: 190}},
            {status: 401});
        }
        return Response.json({messages: [{id: "wamid.delivery"}]});
      });
      const dispatch = () => service.dispatch(h.messageId, h.link.linkId);
      if (mode === "receiptLost") {
        await assert.rejects(dispatch,
          /injected transaction interruption/);
      } else {
        assert.deepEqual(await dispatch(),
          {kind: "submitted", outcome: {kind: "unknown"}});
      }
      assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
        "unknown");
      assert.equal((await dispatch()).kind, "waiting");
      assert.equal(sends, 1);
      h.clock.now += 1000;
      const queueId = await queuedStatus(h, correlation, "delivered");
      const reports = new WhatsappDeliveryStore(h.db, () => h.clock.now);
      assert.equal((await reports.consumeQueued(queueId)).kind, "recorded");
      assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
        "delivered");
    }
  });

test("expired dispatch and contradictory delivery remain distinguishable",
  async () => {
    const h = await harness();
    let sends = 0;
    let correlation = "";
    const actual = new MetaWhatsappProvider({appId: "f", appSecret: "f",
      configId: "f", graphVersion: "v23.0"}, async () => {
      sends++;
      throw new Error("must not send");
    }, () => h.clock.now);
    const service = new EventWhatsappWorker(h.store, {
      sendTemplate: async (input) => {
        correlation = input.callbackData!;
        h.clock.now = input.deadline!;
        return actual.sendTemplate(input);
      },
    }, {accessBound: async () => "fixture-token"}, () => h.clock.now);
    assert.deepEqual(await service.dispatch(h.messageId, h.link.linkId),
      {kind: "withheld", reason: "permitExpired"});
    assert.equal(sends, 0);
    assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
      "notDispatched");
    h.clock.now += 1000;
    const queueId = await queuedStatus(h, correlation, "delivered");
    const result = await new WhatsappDeliveryStore(h.db, () => h.clock.now)
      .consumeQueued(queueId);
    assert.equal(result.kind, "recorded");
    if (result.kind === "recorded") {
      assert.equal(result.disposition, "conflictingEvidence");
    }
    assert.equal((await h.outbox.get(h.messageId))!.deliveryConflict, true);
  });

test("signed receipt can precede submission response and survive event closure",
  async () => {
    const h = await harness();
    let correlation = "";
    const reports = new WhatsappDeliveryStore(h.db, () => h.clock.now);
    const service = worker(h, async (_, init) => {
      correlation = JSON.parse(init!.body as string).biz_opaque_callback_data;
      const id = await queuedStatus(h, correlation, "delivered");
      assert.equal((await reports.consumeQueued(id)).kind, "recorded");
      return Response.json({messages: [{id: "wamid.delivery"}]});
    });
    await service.dispatch(h.messageId, h.link.linkId);
    assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
      "delivered");
    h.clock.now += 1000;
    const readId = await queuedStatus(h, correlation, "read");
    h.fake.remove(h.senderPath);
    h.fake.remove("events/" + h.context.eventId);
    h.fake.remove(h.attendeePath);
    await h.outbox.close(h.messageId,
      (await h.outbox.get(h.messageId))!.revision, "cancelled");
    assert.equal((await reports.consumeQueued(readId)).kind, "recorded");
    const repeated = await reports.consumeQueued(readId);
    assert.equal(repeated.kind, "recorded");
    if (repeated.kind === "recorded") {
      assert.equal(repeated.disposition, "duplicateOrOlder");
    }
    assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
      "read");
  });

test("status correlation rejects wrong scope, recipient, time and receipt",
  async () => {
    for (const fault of ["endpoint", "payload", "account", "sender", "receipt",
      "time", "expired", "knownId", "notClaimed"] as const) {
      const h = await harness();
      const claim = await h.claim();
      assert.equal(claim.kind, "claimed");
      if (claim.kind !== "claimed") return;
      const attempt = claim.permit.attempt;
      const correlation = whatsappStatusCorrelation(attempt.attemptId,
        claim.resource.rendered.payloadHash);
      h.clock.now += 1000;
      const id = await queuedStatus(h,
        fault === "payload" ? correlation.slice(0, -1) +
          (correlation.endsWith("0") ? "1" : "0") : correlation,
        "delivered", fault === "endpoint" ?
          {recipient_id: "919999999998"} : fault === "time" ?
            {timestamp: String((start - 301_000) / 1000)} : {});
      const queuePath = "organizerMessagingWebhookEvents/" + id;
      if (fault === "account" || fault === "sender") {
        await h.write(queuePath, {...(await h.read(queuePath)),
          [fault === "account" ? "providerAccountId" : "connectionId"]:
            "wrong-scope"});
      }
      if (fault === "receipt") {
        h.fake.remove(
          "organizerCampaignWebhookReceipts/" + id);
      }
      if (fault === "expired") h.clock.now += 31 * 86_400_000;
      if (fault === "knownId") {
        await h.outbox.recordReceipt(h.messageId, {
          attemptId: attempt.attemptId, ...attempt.binding,
          providerEventId: "fixture-accepted", receivedAt: h.clock.now,
          state: {kind: "accepted", at: h.clock.now,
            providerMessageId: "wamid.other"},
        });
      }
      if (fault === "notClaimed") {
        const path = "eventAssistanceMessages/" + h.messageId;
        const record = (await h.outbox.get(h.messageId))!;
        await h.write(path, {...record, attempts: [{...attempt, state: {
          kind: "reserved", at: start, reconcileAfter: start + 120_000}}]});
      }
      const before = await h.outbox.get(h.messageId);
      assert.deepEqual(await new WhatsappDeliveryStore(h.db, () => h.clock.now)
        .consumeQueued(id), {kind: "rejected"}, fault);
      assert.deepEqual(await h.outbox.get(h.messageId), before, fault);
    }
  });

test("failed or inconsistent status evidence cannot unlock SMS fallback",
  async () => {
    for (const status of ["failed", "sent", "delivered"] as const) {
      const h = await harness();
      const claim = await h.claim();
      if (claim.kind !== "claimed") throw new Error("Expected claim");
      const correlation = whatsappStatusCorrelation(claim.permit.attempt
        .attemptId, claim.resource.rendered.payloadHash);
      const id = await queuedStatus(h, correlation, status,
        {errors: [{code: 131026}]});
      assert.deepEqual(await new WhatsappDeliveryStore(h.db, () => h.clock.now)
        .consumeQueued(id), {kind: "unconfirmed", messageId: h.messageId});
      assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
        "unknown");
    }
  });

test("a native reply resumes after signed status recovers a lost send response",
  async () => {
    const h = await harness();
    const claim = await h.claim();
    if (claim.kind !== "claimed") throw new Error("Expected claim");
    const attemptId = claim.permit.attempt.attemptId;
    const rawBody = Buffer.from(JSON.stringify({entry: [{
      id: h.expected.connection.wabaId, changes: [{value: {
        metadata: {phone_number_id: h.expected.connection.phoneNumberId},
        messages: [{id: "wamid.reply", from: h.actor.phone.slice(1),
          context: {id: "wamid.delivery"}, timestamp: String(start / 1000),
          type: "button", button: {text: "On my way",
            payload: claim.resource.replies[0].payload}}],
      }}],
    }]}));
    await ingestMetaWhatsappWebhook({db: h.db, rawBody, appSecret,
      now: Timestamp.fromMillis(h.clock.now), signatureHeader: "sha256=" +
        createHmac("sha256", appSecret).update(rawBody).digest("hex")});
    const replyId = "omwe_" + createHash("sha256").update("inbound:wamid.reply")
      .digest("hex").slice(0, 48);
    const replies = new WhatsappReplyStore(h.db, () => h.clock.now);
    assert.deepEqual(await replies.consumeQueued(replyId),
      {kind: "waiting", reason: "deliveryUnconfirmed"});
    const statusId = await queuedStatus(h,
      whatsappStatusCorrelation(attemptId, claim.resource.rendered.payloadHash),
      "sent");
    assert.equal((await new WhatsappDeliveryStore(h.db, () => h.clock.now)
      .consumeQueued(statusId)).kind, "recorded");
    assert.deepEqual(await replies.consumeQueued(replyId), {kind: "accepted"});
    assert.deepEqual(await replies.consumeQueued(replyId), {kind: "replayed"});
  });

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
    let sends = 0;
    let correlation = "";
    const service = worker(h, async (_, init) => {
      sends++;
      correlation = JSON.parse(init!.body as string).biz_opaque_callback_data;
      return Response.json({messages: [{id: "wamid.delivery"}]});
    });
    const results = await Promise.all(Array.from({length: 8}, () =>
      service.dispatch(h.messageId, h.link.linkId)));
    assert.equal(results.filter((r) => r.kind === "submitted").length, 1);
    assert.equal(sends, 1);
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))!.chargedMicros, 500_000);
      assert.equal((await h.read(path))!.revision, 2);
    }
    h.clock.now += 1000;
    const statusId = await queuedStatus(h, correlation, "delivered");
    const reports = new WhatsappDeliveryStore(h.db, () => h.clock.now);
    const reconciled = await Promise.all(Array.from({length: 8}, () =>
      reports.consumeQueued(statusId)));
    assert.equal(reconciled.filter((r) => r.kind === "recorded" &&
      r.disposition === "applied").length, 1);
    assert.equal((await h.outbox.get(h.messageId))!.attempts[0].state.kind,
      "delivered");
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
