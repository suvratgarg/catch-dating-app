import assert from "node:assert/strict";
import test from "node:test";
import {randomUUID} from "node:crypto";
import {readFileSync, writeFileSync} from "node:fs";
import {EventAssistanceRuntimeConfigStore} from "./runtimeConfigStore";
import {setup} from "./liveLateJoinTestHarness";
import {configureRuntime} from "./runtimeConfigTestHarness";
import {rcsTestConfig} from "./rcsTestFixtures";
import {start} from "./whatsappTestHarness";
import type {SmsConfig} from "./smsProtocol";

type Harness = Awaited<ReturnType<typeof setup>>;
async function platformSenders(h: Harness) {
  const rcs = {...rcsTestConfig(),
    activation: {...rcsTestConfig().activation, approvedAt: start - 1000,
      validUntil: start + 3_600_000},
    quote: {...rcsTestConfig().quote, validUntil: start + 3_600_000}};
  const sms: SmsConfig = {schemaVersion: 1, senderId: "fixture-sms",
    revision: 1, provider: "gupshup", senderIdentity: "catchPlatform",
    country: "IN", status: "ready", mask: "CATCHS",
    principalEntityId: "100100100100",
    credentialVersion: "projects/fixture/secrets/SMS/versions/1",
    activation: {useCaseApprovalId: "fixture-use-case",
      senderApprovalId: "fixture-sender", approvedAt: start - 1000,
      validUntil: start + 3_600_000}, maxSegments: 3,
    quote: {revision: 1, currency: "INR", maxMicrosPerSegment: 500_000,
      validUntil: start + 3_600_000},
    templates: [{templateId: "fixture-joining", revision: 1,
      purpose: "joiningUpdate", dltTemplateId: "100200200200",
      status: "approved", parts: [
        {kind: "variable", name: "instruction", maxCharacters: 180},
        {kind: "variable", name: "responseUrl", maxCharacters: 160}]}]};
  await h.write("eventAssistanceSmsSenders/" + sms.senderId, sms);
  await h.write("eventAssistanceRcsSenders/" + rcs.senderId, rcs);
  return {rcs, sms};
}
function request(h: Harness, view: Awaited<ReturnType<
  EventAssistanceRuntimeConfigStore["get"]>>["view"]) {
  const choices = view.senderSetup!.choices.filter((c) =>
    c.availability === "eligible");
  return {context: h.context, requestId: randomUUID(),
    expectedRevision: view.revision, expectedSourceHash: view.sourceHash,
    command: {kind: "configure" as const,
      senderReviews: choices.map(({routeId, senderId, reviewHash}) =>
        ({routeId, senderId, reviewHash})),
      configuration: {options: {...h.options,
        routes: choices.map(({routeId, senderId}) => ({routeId, senderId}))},
      expiresAt: start + 3_600_000, maxEvaluations: 100}}};
}

test("sender review is named, manager-only and read-only", async () => {
  const h = await setup();
  await platformSenders(h);
  await h.write("organizerSenderConnections/foreign",
    {...await h.read(h.senderPath), organizerId: "another-organizer"});
  const store = new EventAssistanceRuntimeConfigStore(h.db, () => h.clock.now);
  const before = h.fake.entries();
  const response = await store.get("host-1", {context: h.context});
  assert.deepEqual(h.fake.entries(), before);
  const choices = response.view.senderSetup!.choices;
  assert.equal(choices.length, 3);
  assert.ok(choices.every((c) => c.availability === "eligible"));
  assert.deepEqual(choices.map((c) => c.displayName),
    ["Catch", "Fixture organizer", "Catch event updates"]);
  assert.deepEqual(choices.map((c) => Object.keys(c).sort()),
    choices.map(() => ["availability", "displayAddress", "displayName",
      "reviewHash", "routeId", "senderId"]));
  assert.doesNotMatch(JSON.stringify(response),
    /secret|credential|principalEntity|providerAccount|templateHash|phoneE164/);
  await assert.rejects(store.get(h.actor.uid, {context: h.context}),
    {code: "permission-denied"});
  await assert.rejects(store.get("host-1", {context: h.context,
    senderCursors: {foreignChannel: "after"}}), {code: "invalid-argument"});
});

test("filtered pages advance and retain saved senders", async () => {
  const h = await setup();
  const {store} = await configureRuntime(h);
  for (let i = 0; i < 22; i++) {
    await h.write("organizerSenderConnections/a-" +
      i.toString().padStart(2, "0"),
    {organizerId: h.context.organizerId, status: "malformed"});
  }
  const first = (await store.get("host-1", {context: h.context})).view;
  assert.deepEqual(first.senderSetup!.choices.map((c) => c.senderId),
    [h.options.routes[0].senderId], "saved sender lies outside the first page");
  assert.equal(first.senderSetup!.nextCursors.organizerEventWhatsapp, "a-19");
  h.fake.remove("organizerSenderConnections/a-19");
  const second = (await store.get("host-1", {context: h.context,
    senderCursors: first.senderSetup!.nextCursors})).view;
  assert.equal(second.senderSetup!.choices.length, 1);
  assert.deepEqual(second.senderSetup!.nextCursors, {});
  assert.equal(second.revision, first.revision);
});

test("configure rejects foreign or stale sender reviews", async () => {
  const h = await setup();
  await platformSenders(h);
  const store = new EventAssistanceRuntimeConfigStore(h.db, () => h.clock.now);
  const initial = (await store.get("host-1", {context: h.context})).view;
  const input = request(h, initial);
  const original = await h.read(h.senderPath);
  await h.write(h.senderPath, {...original, verifiedName: "Changed organizer"});
  const before = h.fake.entries();
  await assert.rejects(store.set("host-1", input), {code: "aborted"});
  assert.deepEqual(h.fake.entries(), before);
  await h.write(h.senderPath, original!);
  await assert.rejects(store.set("host-1", {...input, command: {
    ...input.command, senderReviews: input.command.senderReviews.slice(1),
  }}), {code: "invalid-argument"});
  await h.write(h.senderPath, {...original, organizerId: "other"});
  await assert.rejects(store.set("host-1", input),
    {code: "failed-precondition"});
  await h.write(h.senderPath, original!);
  const saved = await store.set("host-1", input);
  assert.equal(saved.view.status, "configured");
  await h.write(h.senderPath, {...original, status: "disconnected"});
  assert.equal((await store.set("host-1", input)).outcome, "replayed");
  const paused = await store.set("host-1", {...input,
    requestId: randomUUID(), expectedRevision: saved.view.revision,
    command: {kind: "pause"}});
  assert.equal(paused.view.status, "paused");
});

test("sender limits identify approval, template or connection", async () => {
  const h = await setup();
  const {rcs, sms} = await platformSenders(h);
  await h.write("eventAssistanceRcsSenders/" + rcs.senderId,
    {...rcs, quote: {...rcs.quote, validUntil: start}});
  await h.write("eventAssistanceSmsSenders/" + sms.senderId,
    {...sms, templates: sms.templates.map((t) =>
      ({...t, status: "paused"}))});
  await h.write(h.senderPath,
    {...await h.read(h.senderPath), status: "testing"});
  const store = new EventAssistanceRuntimeConfigStore(h.db, () => h.clock.now);
  const view = (await store.get("host-1", {context: h.context})).view;
  assert.deepEqual(view.senderSetup!.choices.map((c) => c.availability),
    ["joiningTemplateMissing", "setupRequired", "approvalExpired"]);
  const template = await h.read(h.templatePath);
  await h.write(h.senderPath,
    {...await h.read(h.senderPath), status: "active"});
  await h.write(h.templatePath, {...template, status: "PAUSED"});
  const next = (await store.get("host-1", {context: h.context})).view;
  assert.equal(next.senderSetup!.choices.find((c) =>
    c.routeId === "organizerEventWhatsapp")!.availability,
  "joiningTemplateMissing");
  assert.equal(next.canConfigure, true);
});

test("approval expiry during configure cannot commit enrollment", async () => {
  const h = await setup();
  const policy = await h.read(h.policyPath);
  await h.write(h.policyPath, {...policy,
    activation: {...h.expected.policy.activation, validUntil: start + 5}});
  let calls = 0;
  const store = new EventAssistanceRuntimeConfigStore(h.db,
    () => ++calls < 3 ? start : start + 5);
  const ordinary = new EventAssistanceRuntimeConfigStore(h.db, () => start);
  const initial = (await ordinary.get("host-1", {context: h.context})).view;
  const before = h.fake.entries();
  await assert.rejects(store.set("host-1", request(h, initial)),
    {code: "failed-precondition"});
  assert.deepEqual(h.fake.entries(), before);
});

test("native sender fixture comes from actual server calls", async () => {
  const h = await setup(undefined, "11111111-2222-4333-8444-555555555555");
  await platformSenders(h);
  const store = new EventAssistanceRuntimeConfigStore(h.db, () => start);
  const initial = await store.get("host-1", {context: h.context});
  const input = {...request(h, initial.view), requestId: "reviewed-senders"};
  const applied = await store.set("host-1", input);
  const configured = await store.get("host-1", {context: h.context});
  const result = {initial, input, applied, configured};
  const file = "../test/event_success/fixtures/runtime_senders.json";
  if (process.env.UPDATE_ASSISTANCE_FIXTURES === "1") {
    writeFileSync(file, JSON.stringify(result, null, 2) + "\n");
  }
  assert.deepEqual(JSON.parse(readFileSync(file, "utf8")), result);
});
