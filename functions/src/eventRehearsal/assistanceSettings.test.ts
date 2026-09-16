import {practiceDeliveryReview, repairPracticeDelivery} from
  "./assistanceDelivery";
import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {harness} from "./movementTestFixtures";
import {practicePlan, practiceDeparture} from "./assistanceTestFixtures";
import {practiceSettingsProjection, preparePracticeSettings,
  PracticeSettingsCommand} from "./assistanceSettings";
import {managedPracticeRecipe} from "./assistanceSettingsPlan";
import {configurePracticeAutomation, evaluatePracticeAutomation,
  pausePracticeAutomation} from "./assistanceAutomation";
import {validateControlEventRehearsalCallablePayload as validate} from
  "../shared/generated/validators/controlEventRehearsalInput";

type Harness = ReturnType<typeof harness>;
function review(h: Harness) {
  return practiceSettingsProjection(h.id, h.session, h.authority);
}
function configure(h: Harness) {
  const plan = practicePlan(h.session.virtualNow.toMillis());
  return {kind: "configure" as const, expectedSourceHash: review(h).sourceHash,
    configuration: {routes: plan.routes, responseDeadline: null,
      deliveryPolicy: plan.deliveryPolicy,
      outcomes: [{kind: "delivered" as const}, {kind: "delivered" as const}]}};
}
function save(h: Harness, command: PracticeSettingsCommand) {
  h.session.assistanceSettings = preparePracticeSettings(h.id, h.session,
    h.actors, command, h.authority);
}
function rule(h: Harness, authority: "prepare" | "observe" |
  "executeWithinPolicy" = "executeWithinPolicy", groupId = "event:whole") {
  return {kind: "setRule" as const, expectedSourceHash: review(h).sourceHash,
    groupId, preference: {kind: "configured" as const, template: {
      ...review(h).suggested, setting: {kind: "enabled" as const, authority}}}};
}
function departed(h: Harness, groupId = "event:whole", stopId = "meeting") {
  return new Map([[groupId,
    practiceDeparture(h.session, h.id, stopId, groupId).record]]);
}

test("explicit rules and runtime enroll only after confirmed departure", () => {
  const h = harness(); const before = review(h);
  assert.equal(before.runtime, null);
  assert.equal(before.groups[0].status, "unconfigured");
  assert.equal(before.suggested.setting.kind, "enabled");
  save(h, configure(h));
  assert.equal(managedPracticeRecipe(h.session, h.actors[0],
    departed(h)).kind, "unavailable");
  save(h, rule(h, "prepare"));
  const waiting = evaluatePracticeAutomation(h.session, h.actors[0], []);
  assert.equal(waiting.actor.assistanceAutomation, undefined);
  const prepared = evaluatePracticeAutomation(h.session, h.actors[0], [],
    departed(h));
  assert.equal(prepared.actor.assistanceAutomation?.origin, "eventSettings");
  assert.equal(prepared.messages.length, 0);
  assert.equal(prepared.actor.assistanceAutomation?.evaluation?.policy?.kind,
    "update");
  save(h, rule(h));
  const sent = evaluatePracticeAutomation(h.session, prepared.actor, [],
    departed(h));
  assert.equal(sent.messages.length, 1);
  assert.equal(sent.messages[0].record.attempts.length, 1);
  assert.equal(sent.actor.assistanceAutomation?.nextOutcomeIndex, 1);
  h.actors[0] = sent.actor;
  save(h, {kind: "pause", expectedSourceHash: review(h).sourceHash});
  const paused = evaluatePracticeAutomation(h.session, sent.actor,
    sent.messages, departed(h));
  assert.equal(paused.actor.assistanceAutomation?.status, "enabled");
  assert.deepEqual(paused.actor.assistanceAutomation?.evaluation?.delivery,
    {kind: "paused"});
  save(h, configure(h));
  const resumed = evaluatePracticeAutomation(h.session, paused.actor,
    paused.messages, departed(h));
  assert.equal(resumed.messages[0].record.attempts.length, 1);
  assert.equal(resumed.actor.assistanceAutomation?.nextOutcomeIndex, 1);
});

test("individual pause and explicit recipes survive event settings", () => {
  const h = harness(); save(h, configure(h)); save(h, rule(h));
  const sent = evaluatePracticeAutomation(h.session, h.actors[0], [],
    departed(h));
  const individual = pausePracticeAutomation(h.session, sent.actor);
  save(h, rule(h, "observe"));
  const held = evaluatePracticeAutomation(h.session, individual,
    sent.messages, departed(h));
  assert.deepEqual(held.actor, individual);
  const manual = configurePracticeAutomation(h.session, h.actors[1],
    practicePlan(h.session.virtualNow.toMillis()), [{kind: "accepted"}], [],
    departed(h));
  assert.equal(manual.actor.assistanceAutomation?.origin, undefined);
  assert.equal(manual.messages.length, 1);
  save(h, {kind: "pause", expectedSourceHash: review(h).sourceHash});
  assert.equal(managedPracticeRecipe(h.session, manual.actor,
    departed(h)).kind, "manual");
});

test("group overrides inherit; unassigned guests get no route", () => {
  const h = harness(); h.group(); save(h, configure(h)); save(h, rule(h));
  assert.equal(review(h).groups[1].origin, "event");
  assert.equal(managedPracticeRecipe(h.session, h.actors[0],
    departed(h, "easy", "one")).kind, "unavailable");
  h.arrive(); h.place();
  const current = managedPracticeRecipe(h.session, h.actors[0],
    departed(h, "easy", "one"));
  assert.equal(current.kind, "ready");
  if (current.kind !== "ready") throw new Error("Expected saved group");
  assert.equal(current.plan.guidance.destination.kind, "groupCheckpoint");
  save(h, {kind: "setRule", expectedSourceHash: review(h).sourceHash,
    groupId: "easy", preference: {kind: "disabled"}});
  assert.equal(review(h).groups[1].origin, "group");
  assert.equal(managedPracticeRecipe(h.session, h.actors[0],
    departed(h, "easy", "one")).kind, "disabled");
  save(h, {kind: "setRule", expectedSourceHash: review(h).sourceHash,
    groupId: "easy", preference: {kind: "inherit"}});
  assert.equal(review(h).groups[1].origin, "event");
  assert.equal(review(h).groups[1].status, "configured");
});

test("settings preserve consumed outcomes and unknown delivery", () => {
  const h = harness(); const config = configure(h);
  save(h, {...config,
    configuration: {...config.configuration,
      outcomes: [{kind: "unknown", reason: "timeout"}, {kind: "delivered"}]}});
  save(h, rule(h));
  const first = evaluatePracticeAutomation(h.session, h.actors[0], [],
    departed(h));
  h.actors[0] = first.actor;
  assert.throws(() => save(h, configure(h)), /Consumed practice outcomes/);
  const evidence = first.messages[0].record.attempts;
  save(h, rule(h, "observe"));
  const observe = evaluatePracticeAutomation(h.session, first.actor,
    first.messages, departed(h));
  assert.deepEqual(observe.messages[0].record.attempts, evidence);
  assert.equal(observe.messages[0].record.lifecycle, "superseded");
  assert.equal(observe.actor.assistanceAutomation?.nextOutcomeIndex, 1);
  save(h, rule(h));
  h.session.virtualNow = Timestamp.fromMillis(
    h.session.virtualNow.toMillis() + 120000);
  const resumed = evaluatePracticeAutomation(h.session, observe.actor,
    observe.messages, departed(h));
  assert.equal(resumed.actor.assistanceAutomation?.nextOutcomeIndex, 1);
  assert.equal(resumed.messages.flatMap((m) => m.record.attempts).length, 1);
});

test("settings reject stale sources, foreign targets and timing", () => {
  const h = harness(); const config = configure(h);
  assert.throws(() => save(h, {...config, expectedSourceHash: "0".repeat(64)}),
    {code: "aborted"});
  const selected = rule(h);
  selected.preference.template.config.destination =
    {kind: "fixedPlace", placeId: "foreign", lateEntry: "allowed"};
  assert.throws(() => save(h, selected), /joining destination/);
  assert.throws(() => save(h, {...config,
    configuration: {...config.configuration,
      responseDeadline: h.session.virtualNow.toMillis()}}), /timing/);
  const input = {sessionId: h.id, expectedRevision: h.session.runtimeRevision,
    expectedSetupRevision: 0, clientActionId: "settings-test-1",
    action: "settings", settings: config};
  assert.equal(validate(input), true, JSON.stringify(validate.errors));
  for (const mutation of [{minutes: 1},
    {practiceOperatorId: "practice-staff:pacer"},
    {assistance: {kind: "pauseAutomation", actorId: "actor-1"}},
    {settings: {...config, configuration: {...config.configuration,
      routes: [{routeId: "catchEventSms", senderId: "real-sender"}]}}}]) {
    assert.equal(validate({...input, ...mutation}), false);
  }
  const {expectedSetupRevision, ...missing} = input;
  void expectedSetupRevision;
  assert.equal(validate(missing), false);
});

test("disabled rules retire messages while event updates are paused", () => {
  const h = harness(); save(h, configure(h)); save(h, rule(h));
  const first = evaluatePracticeAutomation(h.session, h.actors[0], [],
    departed(h));
  save(h, {kind: "pause", expectedSourceHash: review(h).sourceHash});
  const off = rule(h);
  const template = {...off.preference.template,
    setting: {kind: "disabled" as const, reason: "hostChoice" as const},
    config: {...off.preference.template.config,
      cutoff: {kind: "time" as const, at: 0}}};
  save(h, {...off, preference: {kind: "configured", template}});
  const stopped = evaluatePracticeAutomation(h.session, first.actor,
    first.messages, departed(h));
  assert.equal(stopped.messages[0].record.lifecycle, "cancelled");
  assert.deepEqual(stopped.messages[0].record.attempts,
    first.messages[0].record.attempts);
  assert.deepEqual(stopped.actor.assistanceAutomation?.evaluation?.policy,
    {kind: "cancelled", reason: "policyDisabled"});
});

test("event edits never replace an individual delivery takeover", () => {
  const h = harness(); const config = configure(h);
  save(h, {...config, configuration: {...config.configuration,
    outcomes: [{kind: "unknown", reason: "timeout"}]}});
  save(h, rule(h));
  const first = evaluatePracticeAutomation(h.session, h.actors[0], [],
    departed(h));
  const message = first.messages[0];
  const row = practiceDeliveryReview(h.session, first.actor, message,
    h.authority.organizer);
  const taken = repairPracticeDelivery(h.session, first.actor, message,
    {kind: "repairDelivery", actorId: first.actor.actorId,
      expectedMessageRevision: row.revision, expectedReviewHash: row.reviewHash,
      payload: {deliveryId: row.messageId, action: "manualHandoff"}},
    h.authority.organizer, h.authority.actorUid, "takeover-action");
  save(h, rule(h, "observe"));
  const after = evaluatePracticeAutomation(h.session, first.actor, [taken],
    departed(h));
  assert.equal(after.messages.length, 1);
  assert.deepEqual(after.messages[0], taken);
  assert.deepEqual(after.actor.assistanceAutomation?.evaluation?.delivery,
    {kind: "stop", reason: "hostStopped"});
});

test("overall attempts cap larger per-channel limits", () => {
  const h = harness(); const command = configure(h);
  command.configuration.deliveryPolicy.maxAttempts = 1;
  command.configuration.deliveryPolicy.maxAttemptsPerRoute = 3;
  save(h, command); save(h, rule(h));
  const sent = evaluatePracticeAutomation(h.session, h.actors[0], [],
    departed(h));
  assert.equal(sent.messages[0].record.attempts.length, 1);
  assert.equal(sent.actor.assistanceAutomation?.plan.deliveryPolicy.maxAttempts,
    1);
  h.session.virtualNow = Timestamp.fromMillis(
    h.session.virtualNow.toMillis() + 60000);
  const again = evaluatePracticeAutomation(h.session, sent.actor,
    sent.messages, departed(h));
  assert.equal(again.messages[0].record.attempts.length, 1);
});
