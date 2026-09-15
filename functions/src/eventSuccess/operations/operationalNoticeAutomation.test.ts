import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import type {EventAssistanceMessageIntent as MessageIntent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import {operationCollections} from "../../operations/collections";
import {rcsHarness} from "./rcsDispatchTestHarness";
import {keys, start} from "./whatsappTestHarness";
import {EventAssistanceSettingsStore} from "./policySettingsStore";
import {ASSISTANCE_POLICY_VERSION} from "./policySettings";
import {deliveryWorkIds, hasAutomaticDelivery} from "./deliveryWorkRecords";
import {assistanceMessageId} from "./messageOutbox";
import {messageAllowsSender} from "./lateJoinDispatchPolicy";
import {LiveMessageDispatcher, createLiveMessageWorker} from
  "./liveMessageDispatcher";
import {operationalNoticeContentHash, parseMessageIntent} from
  "./messageProtocol";

type Notice = Extract<MessageIntent, {kind: "operationalNotice"}>;

async function setup() {
  const h = await rcsHarness(undefined, randomUUID(), ["catchEventRcs"]);
  const settings = new EventAssistanceSettingsStore(h.db, () => h.clock.now);
  const scope = {context: h.context, groupId: "event:whole",
    workflowKind: "planChangeCommunication" as const};
  const view = (await settings.get("host-1", scope)).view;
  const saved = await settings.set("host-1", {...scope,
    requestId: randomUUID(), expectedRevision: view.ownRevision,
    expectedSourceHash: view.sourceHash, preference: {kind: "configured",
      template: {kind: "planChangeCommunication", version: 1,
        setting: {kind: "enabled", authority: "executeWithinPolicy"},
        config: {templateIntent: "planChange", audience: "affectedGuests",
          maximumPerGuest: 2, expiryMinutes: 30}}}});
  assert.ok(saved.view.own);
  const sourceId = "plan-change-1";
  const sourceRevision = 2;
  const base: Notice = {schemaVersion: 1, intentId: "notice-1", revision: 1,
    context: h.context, eventId: h.context.eventId,
    attendeeId: h.scope.attendeeId, episodeId: h.intent.episodeId,
    workflow: {kind: "planChangeCommunication", occurrenceId: sourceId},
    createdAt: start, expiresAt: start + 15 * 60_000,
    permittedRoutes: ["catchEventRcs"], deliveryPolicy: {maxAttempts: 2,
      maxAttemptsPerRoute: 1, minimumRetrySeconds: 1},
    kind: "operationalNotice", noticeKind: "planChanged",
    title: "Meeting point updated", body: "Meet us at the first venue.",
    instructionRevision: sourceRevision, choices: [{choiceId: "ack",
      label: "Got it", value: {kind: "acknowledge",
        instructionRevision: sourceRevision}}]};
  const intent: Notice = {...base, automation: {kind: "operationalNotice",
    noticeKind: "planChanged", policyVersion: ASSISTANCE_POLICY_VERSION,
    groupId: scope.groupId, settingId: saved.view.own.settingId,
    settingRevision: saved.view.own.revision, sourceId, sourceRevision,
    contentHash: operationalNoticeContentHash(base), routes: [{
      routeId: "catchEventRcs", senderId: h.rcsConfig.senderId}]}};
  const thread = await h.guests.publishMessage(intent, null);
  const messageId = assistanceMessageId(intent);
  const message = (await h.outbox.get(messageId))!;
  const dispatcher = new LiveMessageDispatcher(h.db, () => h.clock.now,
    {access: async () => keys}, (record, signingKeys) =>
      createLiveMessageWorker(h.db, record, signingKeys, () => h.clock.now, {
        rcsEnabled: () => true, whatsappEnabled: () => false,
        rcsCredentials: {access: async () => h.credentials},
        rcsProvider: h.rcsProvider}));
  return {h, settings, scope, saved, base, intent, thread, messageId, message,
    dispatcher};
}

test("a bound plan-change notice enters the shared delivery coordinator",
  async () => {
    const f = await setup();
    assert.deepEqual(parseMessageIntent(f.intent), f.intent);
    assert.equal(hasAutomaticDelivery(f.message), true);
    assert.equal(messageAllowsSender(f.intent, "catchEventRcs",
      f.h.rcsConfig.senderId), true);
    assert.equal(messageAllowsSender(f.intent, "catchEventRcs", "other"),
      false);
    const ids = deliveryWorkIds(f.messageId);
    assert.ok(f.h.fake.read(operationCollections.runs + "/" + ids.runId));
    assert.ok(f.h.fake.read(operationCollections.workItems + "/" +
      ids.workItemId));
    const result = await f.dispatcher.dispatch(f.message,
      f.h.clock.now + 60_000);
    assert.equal(result.kind, "submitted");
    assert.equal(f.h.requests.filter((request) =>
      request.method === "POST").length, 1);
  });

test("automatic notice identity binds source, revision, content and routes",
  async () => {
    const f = await setup();
    for (const changed of [
      {...f.intent, body: "Different body"},
      {...f.intent, permittedRoutes: ["catchEventSms"] as const},
      {...f.intent, instructionRevision: f.intent.instructionRevision + 1},
      {...f.intent, workflow: {...f.intent.workflow,
        kind: "postEventFollowUp" as const}},
    ]) assert.throws(() => parseMessageIntent(changed));
    const {automation, ...prior} = f.intent;
    const followBase: Notice = {...prior, intentId: "follow-up-1",
      workflow: {kind: "postEventFollowUp", occurrenceId: "follow-up-1"},
      noticeKind: "followUp", title: "Thanks for coming",
      body: "Tell us how it went.", instructionRevision: 1, choices: []};
    const follow: Notice = {...followBase, automation: {...automation!,
      noticeKind: "followUp", sourceId: "follow-up-1", sourceRevision: 1,
      contentHash: operationalNoticeContentHash(followBase)}};
    assert.deepEqual(parseMessageIntent(follow), follow);
  });

test("pausing the saved policy withholds a queued operational notice",
  async () => {
    const f = await setup();
    const paused = await f.settings.set("host-1", {...f.scope,
      requestId: randomUUID(), expectedRevision: f.saved.view.ownRevision,
      expectedSourceHash: f.saved.view.sourceHash,
      preference: {kind: "disabled"}});
    assert.equal(paused.view.status, "disabled");
    const result = await f.dispatcher.dispatch(f.message,
      f.h.clock.now + 60_000);
    assert.equal(result.kind, "waiting");
    assert.equal(f.h.requests.filter((request) =>
      request.method === "POST").length, 0);
    assert.equal((await f.h.outbox.get(f.messageId))!.attempts.length, 0);
  });
