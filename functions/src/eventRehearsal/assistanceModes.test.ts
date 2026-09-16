import assert from "node:assert/strict";
import test from "node:test";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {buildRehearsalActors} from "./engine";
import {configurePracticeAutomation, evaluatePracticeAutomation} from
  "./assistanceAutomation";
import {practiceInput, publishPracticeMessage} from "./assistanceRuntime";
import {practiceSession, practicePlan, practiceDeparture} from
  "./assistanceTestFixtures";

test("practice modes preserve the rule and delivery script", () => {
  const session = practiceSession();
  const actor = buildRehearsalActors("practice-modes", 2, 1,
    session.virtualNow)[0];
  const base = practicePlan(session.virtualNow.toMillis());
  const departures = new Map([["event:whole",
    practiceDeparture(session, actor.sessionId).record]]);
  const modes = ["observe", "prepare", "executeWithinPolicy"] as const;
  for (const authority of modes) {
    const plan = {...base, setting: {kind: "enabled" as const, authority}};
    const input = practiceInput(session, actor, plan, [], undefined,
      departures);
    assert.deepEqual(input.setting,
      {...plan.setting, policyVersion: "rehearsal:v1"});
    const result = configurePracticeAutomation(session, actor, plan,
      [{kind: "delivered"}], [], departures);
    const evaluation = result.actor.assistanceAutomation!.evaluation!;
    assert.equal(evaluation.policy!.kind, "update");
    const executable = authority === "executeWithinPolicy";
    assert.equal(result.messages.length, executable ? 1 : 0);
    assert.equal(result.actor.assistanceAutomation!.nextOutcomeIndex,
      executable ? 1 : 0);
    assert.deepEqual(result.actor.assistanceAutomation!.plan.setting,
      plan.setting);
    if (!executable) {
      assert.deepEqual(evaluation.delivery, {kind: "notApplicable"});
      assert.throws(() => publishPracticeMessage(session, actor, plan, [],
        departures), /Practice outreach is held/);
      const again = evaluatePracticeAutomation(session, result.actor,
        result.messages, departures);
      assert.equal(again.actor.assistanceAutomation!.nextOutcomeIndex, 0);
      assert.equal(again.messages.length, 0);
    }
  }
  const off = configurePracticeAutomation(session, actor, {...base,
    setting: {kind: "disabled", reason: "hostChoice"}},
  [{kind: "delivered"}], [], departures);
  assert.deepEqual(off.actor.assistanceAutomation!.evaluation!.policy,
    {kind: "cancelled", reason: "policyDisabled"});
  assert.equal(off.messages.length, 0);
  assert.equal(off.actor.assistanceAutomation!.nextOutcomeIndex, 0);
  const legacy = configurePracticeAutomation(session, actor, base,
    [{kind: "delivered"}], [], departures);
  assert.equal(legacy.actor.assistanceAutomation!.nextOutcomeIndex, 1);
  assert.equal("setting" in legacy.actor.assistanceAutomation!.plan, false);
});

test("prepare retires prior work without another attempt", () => {
  const session = practiceSession();
  const actor = buildRehearsalActors("practice-modes", 2, 1,
    session.virtualNow)[0];
  const plan = practicePlan(session.virtualNow.toMillis());
  const departures = new Map([["event:whole",
    practiceDeparture(session, actor.sessionId).record]]);
  const before = configurePracticeAutomation(session, actor, plan,
    [{kind: "unknown", reason: "timeout"}], [], departures);
  const after = configurePracticeAutomation(session, before.actor,
    {...plan, setting: {kind: "enabled", authority: "prepare"}},
    [{kind: "delivered"}], before.messages, departures);
  assert.equal(after.messages.length, 1);
  assert.equal(after.messages[0].record.lifecycle, "superseded");
  assert.deepEqual(after.messages[0].record.attempts,
    before.messages[0].record.attempts);
  assert.equal(after.actor.assistance!.latestMessageId, null);
  assert.equal(after.actor.assistanceAutomation!.nextOutcomeIndex, 0);
});

test("callable modes reject a supplied live policy version", () => {
  const session = practiceSession();
  const plan = practicePlan(session.virtualNow.toMillis());
  const input = (setting: unknown) => ({sessionId: "practice-modes",
    expectedRevision: 1, expectedSetupRevision: 0,
    clientActionId: "mode-review-1",
    action: "assistance", assistance: {kind: "configureAutomation",
      actorId: "actor-1", plan: {...plan, setting},
      outcomes: [{kind: "delivered"}]}});
  for (const authority of ["observe", "prepare", "executeWithinPolicy"]) {
    assert.equal(validateControlEventRehearsalCallablePayload(
      input({kind: "enabled", authority})), true);
  }
  assert.equal(validateControlEventRehearsalCallablePayload(
    input({kind: "disabled", reason: "hostChoice"})), true);
  for (const setting of [null, {kind: "enabled", authority: "sendNow"},
    {kind: "enabled", authority: "executeWithinPolicy", policyVersion: "live"},
    {kind: "disabled", reason: "providerPaused"}]) {
    assert.equal(validateControlEventRehearsalCallablePayload(input(setting)),
      false);
  }
});
