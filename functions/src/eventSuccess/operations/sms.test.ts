import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore} from "firebase-admin/firestore";
import type {EventAssistanceMessageIntent as Intent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import {FakeFirestore} from "../../operations/testFirestore";
import {GuestAssistanceStore} from "./guestAssistanceStore";
import {guestCollections, parseGrant} from "./guestRecords";
import {GuestLinkSigningKeys} from "./guestLinkTokens";
import {assistanceMessageId} from "./messageOutbox";
import {
  SmsDispatchStore, smsCollections, smsBudgetScopes, smsBudgetId,
  smsPermissionId, Budget, parseSmsBudget, parseSmsPermission,
} from "./smsDispatchStore";
import {parseSmsConfig, renderEventSms, smsSegments, SmsConfig} from
  "./smsProtocol";
import {
  GupshupSmsProvider, parseGupshupSubmission, parseSmsCredentials,
  SmsCredentials,
} from "./gupshupSmsProvider";
import {EventSmsWorker} from "./smsWorker";
import {SmsPreferenceStore} from "./smsPreferenceStore";

const keys: GuestLinkSigningKeys = {currentKeyId: "sms-key-1",
  keyFor: () => Buffer.alloc(32, 7)};
const start = Date.parse("2026-09-06T14:30:00Z");

function config(senderId = "sms-sender-1"): SmsConfig {
  return {schemaVersion: 1, senderId, revision: 1, provider: "gupshup",
    senderIdentity: "catchPlatform", country: "IN", status: "ready",
    mask: "CATCHS", principalEntityId: "100100100100",
    credentialVersion: "projects/catchdates-dev/secrets/EVENT_SMS/versions/1",
    activation: {useCaseApprovalId: "fixture-use-case",
      senderApprovalId:
      "fixture-sender", approvedAt: start - 1000,
      validUntil: start + 3_600_000},
    maxSegments: 3, quote: {revision: 1, currency: "INR",
      maxMicrosPerSegment: 500_000, validUntil: start + 3_600_000},
    templates: [{templateId: "fixture-joining", revision: 1,
      purpose: "joiningUpdate", dltTemplateId: "100200200200",
      status: "approved",
      parts: [{kind: "literal", text: "Catch: "},
        {kind: "variable", name: "instruction", maxCharacters: 180},
        {kind: "literal", text: " Reply: "},
        {kind: "variable", name: "responseUrl", maxCharacters: 160}]}]};
}

async function harness(realDb?: Firestore, id = "test") {
  const fake = new FakeFirestore();
  const db = realDb ?? fake as unknown as Firestore;
  const clock = {now: start};
  const paths = new Set<string>();
  const write = async (path: string, value: object) => {
    paths.add(path);
    if (realDb) await realDb.doc(path).set(value);
    else fake.write(path, value as Record<string, unknown>);
  };
  const read = async (path: string) => realDb ?
    (await realDb.doc(path).get()).data() : fake.read(path);
  const context = {mode: "live" as const, eventId: "event-" + id,
    organizerId: "organizer-" + id};
  const attendeeId = "attendee-" + id;
  const sender = config("sender-" + id);
  await write("events/" + context.eventId, {organizerId: context.organizerId,
    name: "Friday social", status: "active", endTime: {
      seconds: (start + 3_600_000) / 1000, nanoseconds: 0,
    }});
  const attendeePath = "eventAttendees/" + attendeeId;
  await write(attendeePath, {organizerId: context.organizerId,
    eventId: context.eventId, status: "registered", linkedUid: "guest-uid",
    phoneE164: "+919999999999", createdAt: {
      seconds: (start - 1000) / 1000, nanoseconds: 4,
    }});
  const guests = new GuestAssistanceStore(db, () => clock.now);
  const guest = await guests.startEpisode(context, attendeeId, "start-1", null);
  const intent: Intent = {schemaVersion: 1, intentId: "message-" + id,
    revision: 1, context, eventId: context.eventId, attendeeId,
    episodeId: guest.episodeId,
    workflow: {kind: "lateJoin", occurrenceId: "departure-1"},
    createdAt: start, expiresAt: start + 1_800_000,
    permittedRoutes: ["catchEventSms"], deliveryPolicy: {maxAttempts: 2,
      maxAttemptsPerRoute: 1, minimumRetrySeconds: 1}, kind: "joiningUpdate",
    guidance: {revision: 1, materialKey: "stop-1", text: "Meet at stop one.",
      validUntil: start + 1_800_000, destination: {kind: "itineraryStop",
        itineraryId: "itinerary-1", stopId: "stop-1"}},
    choices: [{choiceId: "on-my-way", label: "I'm on my way", value: {
      kind: "joinIntent", intention: {kind: "onMyWay", claimedEta: null},
    }}]};
  const thread = await guests.publishMessage(intent, null);
  const link = await guests.issueLink(thread.threadId, "send-1", keys);
  const permissionPath = smsCollections.permissions + "/" +
    smsPermissionId(context, attendeeId, sender.senderId);
  const senderPath = smsCollections.senders + "/" + sender.senderId;
  await write(senderPath, sender);
  const preferences = new SmsPreferenceStore(db, () => clock.now,
    sender.senderId);
  await preferences.set({uid: "guest-uid", phone: "+919999999999"}, {
    eventId: context.eventId, attendeeId, requestId: "fixture-opt-in",
    expectedRevision: null, decision: {kind: "grant",
      copyVersion: "catch-event-service-sms-v1"},
  });
  const permission = parseSmsPermission(await read(permissionPath));
  const budgetPaths: string[] = [];
  for (const scope of smsBudgetScopes(context, start)) {
    const begins = scope.kind === "senderDay" ?
      Date.parse(scope.day + "T00:00:00+05:30") : start - 1000;
    const budget: Budget = {schemaVersion: 1,
      budgetId: smsBudgetId(sender.senderId, scope), revision: 1,
      senderId: sender.senderId, scope, status: "active",
      approvalId: "fixture-spending", currency: "INR",
      limitMicros: 10_000_000, chargedMicros: 0,
      startsAt: begins, endsAt: scope.kind === "senderDay" ?
        begins + 86_400_000 : start + 3_600_000, updatedAt: start};
    const path = smsCollections.budgets + "/" + budget.budgetId;
    budgetPaths.push(path);
    await write(path, budget);
  }
  const store = new SmsDispatchStore(db, sender.senderId, keys,
    () => clock.now);
  const credentials: SmsCredentials = {schema: "catch.event-sms-credential/v1",
    senderId: sender.senderId, userid: "1234", password: "private &=+password"};
  const requests: Array<{url: string; init?: RequestInit}> = [];
  const transport = {
    reply: "success|919999999999|660362025761505631-520576818555598760",
    status: 200, error: false, delay: 0};
  const fetchImpl: typeof fetch = async (url, init) => {
    requests.push({url: String(url), init});
    clock.now += transport.delay;
    if (transport.error) throw new Error(credentials.password);
    return new Response(transport.reply, {status: transport.status});
  };
  const provider = new GupshupSmsProvider(fetchImpl, () => clock.now);
  const credentialStore = {access: async () => credentials};
  const worker = new EventSmsWorker(store, credentialStore, provider,
    () => clock.now);
  const messageId = assistanceMessageId(intent);
  return {db, fake, clock, context, attendeeId, attendeePath,
    sender, senderPath, guest, guests, thread, link,
    permission, permissionPath, budgetPaths, store, credentials, requests,
    transport, provider, worker, write, read, intent, messageId, paths};
}

test("SMS segmentation counts GSM extensions and Unicode pairs at boundaries",
  () => {
    assert.deepEqual(smsSegments("a".repeat(160)), {
      encoding: "gsm7", units: 160, segments: 1,
    });
    assert.equal(smsSegments("a".repeat(161)).segments, 2);
    assert.equal(smsSegments("^".repeat(80)).segments, 1);
    assert.equal(smsSegments("^".repeat(81)).segments, 2);
    assert.equal(smsSegments("^".repeat(153)).segments, 3);
    assert.deepEqual(smsSegments("न".repeat(71)), {
      encoding: "unicode", units: 71, segments: 2,
    });
    assert.equal(smsSegments("🙂".repeat(35)).segments, 1);
    assert.equal(smsSegments("🙂".repeat(67)).segments, 3);
    assert.throws(() => smsSegments("\ud800"), /Invalid SMS/);
    assert.throws(() => smsSegments(""), /Invalid SMS/);
  });

test("SMS renders exact approved parts with a scoped response link",
  async () => {
    const h = await harness();
    const grant = parseGrant(await h.read(guestCollections.grants + "/" +
    h.link.linkId));
    const input = {config: h.sender, intent: h.intent, grant, keys,
      eventTitle: "Friday social", now: h.clock.now};
    const rendered = renderEventSms(input);
    assert.equal(rendered.text, "Catch: Meet at stop one. Reply: " +
    "https://catchdates.com/event-update/" + h.link.linkId + "#" + h.link.secret);
    assert.equal(rendered.maxCostMicros, rendered.segments * 500_000);
    assert.throws(() => renderEventSms({...input,
      grant: {...grant, episodeId: "wrong-episode"}}), /unavailable/);
    assert.throws(() => renderEventSms({...input,
      keys: {...keys, keyFor: () => Buffer.alloc(32, 1)}}), /key mismatch/);
    for (const change of ["slot", "length", "approval", "purpose", "quote"]) {
      const cfg = structuredClone(h.sender);
      if (change === "slot") cfg.templates[0].parts.pop();
      if (change === "length") cfg.maxSegments = 1;
      if (change === "approval") cfg.templates[0].status = "pending";
      if (change === "purpose") cfg.templates[0].purpose = "followUp";
      if (change === "quote") cfg.quote.validUntil = h.clock.now;
      // The default fixture happens to fit one segment. Force two for the cap.
      const intent = change === "length" ? {...h.intent,
        guidance: {...h.intent.guidance, text: "a".repeat(180)}} : h.intent;
      assert.throws(() => renderEventSms({...input, config: cfg, intent}),
        Error, change);
    }
    assert.throws(() => parseSmsConfig({...h.sender,
      templates: [...h.sender.templates, {...h.sender.templates[0],
        templateId: "duplicate-purpose"}]}), /Ambiguous/);
  });

test("provider uncertainty never becomes technical failure or retry permission",
  () => {
    for (const code of ["100", "117", "125", "190", "999"]) {
      assert.deepEqual(parseGupshupSubmission("error | " + code + " | omitted",
        "+919999999999"), {kind: "uncertain", reason: "providerPending", code});
    }
    assert.equal(parseGupshupSubmission("error|102|private provider body",
      "+919999999999").kind, "rejected");
    assert.deepEqual(parseGupshupSubmission("error|105|bad phone",
      "+919999999999"), {kind: "rejected", code: "105",
      classification: "invalidRecipient"});
    for (const body of ["<html>Error</html>",
      "success|918888888888|123-456", "success|919999999999|", "success|" +
    "919999999999|123-456\nsuccess|919999999999|789-012"]) {
      assert.equal(parseGupshupSubmission(body, "+919999999999").kind,
        "uncertain");
    }
  });

test("SMS worker contends once, debits atomically and posts correctly",
  async () => {
    const h = await harness();
    const results = await Promise.all(Array.from({length: 8}, () =>
      h.worker.dispatch(h.messageId, h.link.linkId)));
    assert.equal(results.filter((r) => r.kind === "submitted").length, 1);
    assert.equal(h.requests.length, 1);
    const request = h.requests[0];
    assert.equal(request.url, "https://enterprise.smsgupshup.com/GatewayAPI/rest");
    assert.equal(request.init?.method, "POST");
    assert.equal(request.init?.redirect, "error");
    const form = new URLSearchParams(String(request.init?.body));
    assert.equal(form.get("password"), h.credentials.password);
    assert.equal(form.get("send_to"), "919999999999");
    assert.equal(form.get("mask"), "CATCHS");
    assert.equal(form.get("dltTemplateId"), "100200200200");
    assert.equal(form.get("principalEntityId"), "100100100100");
    assert.match(form.get("msg_id")!, /^[a-f0-9]{64}$/);
    assert.ok(form.get("msg")!.includes(h.link.secret));
    const record = await h.store.outbox(h.link.linkId).get(h.messageId);
    assert.equal(record?.attempts[0].state.kind, "accepted");
    const debit = await h.read(smsCollections.dispatches + "/" +
    record!.attempts[0].attemptId);
    assert.ok(debit);
    for (const path of h.budgetPaths) {
      const budget = parseSmsBudget(await h.read(path));
      assert.equal(budget.chargedMicros, debit.maxCostMicros);
      assert.equal(budget.revision, 2);
    }
    const persisted = JSON.stringify(h.fake.entries());
    for (const secret of [h.link.secret, h.credentials.password]) {
      assert.equal(persisted.includes(secret), false);
      assert.equal(JSON.stringify(results).includes(secret), false);
    }
  });

test("failed claim commit rolls back both spending and dispatch evidence",
  async () => {
    const h = await harness();
    const outbox = h.store.outbox(h.link.linkId);
    const {record} = await outbox.reserve(h.messageId);
    h.fake.failNextCommit = true;
    await assert.rejects(outbox.claimLiveDispatch(h.messageId,
      record.attempts[0].attemptId, h.store.prepare(h.link.linkId, h.sender)),
    /interruption/);
    assert.equal((await outbox.get(h.messageId))?.attempts[0].state.kind,
      "reserved");
    assert.equal(await h.read(smsCollections.dispatches + "/" +
    record.attempts[0].attemptId), undefined);
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))?.chargedMicros, 0);
    }
    assert.equal((await h.worker.dispatch(h.messageId, h.link.linkId)).kind,
      "submitted");
    assert.equal(h.requests.length, 1);
  });

test("fresh source changes withhold a previously reserved send", async () => {
  for (const change of ["checkIn", "phone", "uid", "generation", "permission",
    "expiredPermission", "grant", "sender", "configSameRevision", "budget",
    "expiredPermit"]) {
    const h = await harness();
    const outbox = h.store.outbox(h.link.linkId);
    const {record} = await outbox.reserve(h.messageId);
    assert.equal(record.attempts.length, 1);
    const attendee = (await h.read(h.attendeePath))!;
    if (change === "checkIn") {
      await h.write(h.attendeePath,
        {...attendee, status: "checkedIn"});
    }
    if (change === "phone") {
      await h.write(h.attendeePath,
        {...attendee, phoneE164: "+918888888888"});
    }
    if (change === "uid") {
      await h.write(h.attendeePath,
        {...attendee, linkedUid: "different-person"});
    }
    if (change === "generation") {
      await h.write(h.attendeePath,
        {...attendee, createdAt: {seconds: start / 1000, nanoseconds: 0}});
    }
    if (change === "permission") {
      await h.write(h.permissionPath,
        {...h.permission, status: "revoked"});
    }
    if (change === "expiredPermission") {
      h.clock.now++;
      await h.write(h.permissionPath,
        {...h.permission, expiresAt: h.clock.now});
    }
    if (change === "grant") await h.guests.revokeLink(h.link.linkId);
    if (change === "sender") {
      await h.write(h.senderPath,
        {...h.sender, status: "paused"});
    }
    if (change === "configSameRevision") {
      await h.write(h.senderPath,
        {...h.sender, mask: "CHANGD"});
    }
    if (change === "budget") {
      await h.write(h.budgetPaths[0],
        {...(await h.read(h.budgetPaths[0])), limitMicros: 0});
    }
    if (change === "expiredPermit") h.clock.now += 30_001;
    const claim = await outbox.claimLiveDispatch(h.messageId,
      record.attempts[0].attemptId, h.store.prepare(h.link.linkId, h.sender));
    assert.equal(claim.kind, "withheld", change);
    assert.equal(h.requests.length, 0);
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))?.chargedMicros, 0, change);
    }
  }
});

test("uncertain submissions retain the debit and cannot send again",
  async () => {
    for (const problem of ["timeout", "maintenance", "wrongRecipient", "http",
      "oversize"]) {
      const h = await harness();
      if (problem === "timeout") h.transport.error = true;
      if (problem === "maintenance") {
        h.transport.reply = "error|125|Maintenance";
      }
      if (problem === "wrongRecipient") {
        h.transport.reply = "success|918888888888|123-456";
      }
      if (problem === "http") h.transport.status = 503;
      if (problem === "oversize") h.transport.reply = "x".repeat(9000);
      const result = await h.worker.dispatch(h.messageId, h.link.linkId);
      assert.ok(result.kind === "submitted");
      assert.equal(result.outcome.kind, "uncertain", problem);
      h.clock.now += 121_000;
      await h.worker.dispatch(h.messageId, h.link.linkId);
      assert.equal(h.requests.length, 1, problem);
      assert.ok(Number((await h.read(h.budgetPaths[0]))?.chargedMicros) > 0);
      assert.equal(JSON.stringify(result).includes(h.credentials.password),
        false);
    }
  });

test("credential I/O precedes short reservation; changed config cannot claim",
  async () => {
    const h = await harness();
    const slow = new EventSmsWorker(h.store, {access: async () => {
      h.clock.now += 35_000;
      return h.credentials;
    }}, h.provider, () => h.clock.now);
    assert.equal((await slow.dispatch(h.messageId, h.link.linkId)).kind,
      "submitted");
    assert.equal(h.requests.length, 1);
    const other = await harness();
    const changed = new EventSmsWorker(other.store, {access: async () => {
      await other.write(other.senderPath, {...other.sender,
        credentialVersion: other.sender.credentialVersion.replace("/1", "/2")});
      return other.credentials;
    }}, other.provider, () => other.clock.now);
    assert.equal((await changed.dispatch(other.messageId,
      other.link.linkId)).kind, "withheld");
    assert.equal(other.requests.length, 0);
    assert.throws(() => parseSmsCredentials({
      ...h.credentials, senderId: "other"},
    h.sender.senderId), /another sender/);
  });

async function contestedBudget(h: Awaited<ReturnType<typeof harness>>) {
  // Two distinct messages can both reserve before either spends the last unit.
  const secondIntent: Intent = {...h.intent, intentId: h.intent.intentId + "-2",
    workflow: {kind: "lateJoin", occurrenceId: "departure-2"}};
  const secondThread = await h.guests.publishMessage(secondIntent, null);
  const secondLink = await h.guests.issueLink(secondThread.threadId,
    "send-2", keys);
  const firstOutbox = h.store.outbox(h.link.linkId);
  const secondOutbox = h.store.outbox(secondLink.linkId);
  const secondMessageId = assistanceMessageId(secondIntent);
  for (const path of h.budgetPaths) {
    await h.write(path, {...(await h.read(path)), limitMicros: 500_000});
  }
  const first = await firstOutbox.reserve(h.messageId);
  const second = await secondOutbox.reserve(secondMessageId);
  assert.equal(first.record.attempts.length, 1);
  assert.equal(second.record.attempts.length, 1);
  const results = await Promise.all([
    h.worker.dispatch(h.messageId, h.link.linkId),
    h.worker.dispatch(secondMessageId, secondLink.linkId),
  ]);
  assert.equal(results.filter((r) => r.kind === "submitted").length, 1);
  assert.equal(h.requests.length, 1);
  for (const path of h.budgetPaths) {
    assert.equal((await h.read(path))?.chargedMicros, 500_000);
  }
}

test("different messages cannot overspend a shared event/day budget",
  async () => {
    await contestedBudget(await harness());
  });

test("Firestore atomically arbitrates different SMS budget claims", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const id = randomUUID();
  const app = initializeApp({projectId: "demo-catch-rules"}, "sms-" + id);
  const db = getFirestore(app);
  try {
    await contestedBudget(await harness(db, id));
  } finally {
    // This isolated demo project is erased by the owning emulator test suite.
    await deleteApp(app);
  }
});

test("a scoped webpage reply prevents later SMS dispatch", async () => {
  const h = await harness();
  const outbox = h.store.outbox(h.link.linkId);
  await outbox.reserve(h.messageId);
  const view = await h.guests.getView(h.link.linkId, h.link.secret);
  assert.ok(view.status === "ready");
  await h.guests.submit({linkId: h.link.linkId, secret: h.link.secret,
    intentId: view.intentId, intentRevision: view.intentRevision,
    expectedGuestRevision: view.guestRevision, choiceId: "on-my-way",
    requestId: "reply-1"});
  await h.worker.dispatch(h.messageId, h.link.linkId);
  assert.equal(h.requests.length, 0);
  assert.equal((await h.read(h.attendeePath))?.status, "registered");
});

test("missing event-service permission cannot inherit organizer marketing",
  async () => {
    const h = await harness();
    await h.write(h.permissionPath, {...h.permission, purpose: "marketing"});
    await assert.rejects(h.worker.dispatch(h.messageId, h.link.linkId),
      /event-service SMS permission/);
    assert.equal(h.requests.length, 0);
  });

test("slow resource preparation cannot commit an expired claim or debit",
  async () => {
    const h = await harness();
    const outbox = h.store.outbox(h.link.linkId);
    const reservation = await outbox.reserve(h.messageId);
    const prepare = h.store.prepare(h.link.linkId, h.sender);
    const result = await outbox.claimLiveDispatch(h.messageId,
      reservation.record.attempts[0].attemptId,
      async (...args) => {
        const resource = await prepare(...args);
        h.clock.now += 30_001;
        return resource;
      });
    assert.ok(result.kind === "withheld");
    assert.equal(result.reason, "authorizationExpired");
    for (const path of h.budgetPaths) {
      assert.equal((await h.read(path))?.chargedMicros, 0);
    }
  });

test("transport refuses an expired permit, changed phone or changed body",
  async () => {
    for (const change of ["phone", "body", "expiry"]) {
      const h = await harness();
      const outbox = h.store.outbox(h.link.linkId);
      const reservation = await outbox.reserve(h.messageId);
      const claimed = await outbox.claimLiveDispatch(h.messageId,
        reservation.record.attempts[0].attemptId,
        h.store.prepare(h.link.linkId, h.sender));
      assert.ok(claimed.kind === "claimed");
      const input = {permit: claimed.permit, config: claimed.resource.config,
        credentials: h.credentials, phoneE164: h.permission.phoneE164,
        rendered: claimed.resource.rendered};
      if (change === "phone") input.phoneE164 = "+918888888888";
      if (change === "body") input.rendered.text = "Changed after budget claim";
      if (change === "expiry") {
        h.clock.now = claimed.permit.validUntil;
        assert.deepEqual(await h.provider.send(input), {
          kind: "withheld", reason: "permitExpired",
        });
        await outbox.recordExpiredBeforeSend(claimed.permit);
        assert.equal((await outbox.get(h.messageId))?.attempts[0].state.kind,
          "notDispatched");
      } else {
        await assert.rejects(h.provider.send(input), /permit|material changed/);
      }
      assert.equal(h.requests.length, 0);
    }
  });

test("SMS cannot silently bypass WhatsApp or RCS selection", async () => {
  const h = await harness();
  const intent: Intent = {...h.intent, intentId: "multi-route",
    workflow: {kind: "lateJoin", occurrenceId: "multi-channel"},
    permittedRoutes: ["organizerEventWhatsapp", "catchEventRcs",
      "catchEventSms"]};
  const thread = await h.guests.publishMessage(intent, null);
  const link = await h.guests.issueLink(thread.threadId, "send-1", keys);
  const result = await h.worker.dispatch(assistanceMessageId(intent),
    link.linkId);
  assert.deepEqual(result, {kind: "withheld",
    reason: "routeCompositionUnavailable"});
  assert.equal(h.requests.length, 0);
});
