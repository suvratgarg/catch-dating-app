import assert from "node:assert/strict";
import test from "node:test";
import {planManualRun, planRun} from "./momentPlanning";
import {
  armMoment,
  pauseMoment,
  resumeMoment,
  reviseMoment,
  sameScope,
  scopeId,
  validateMomentDefinition,
  type AnchorFacts,
  type MomentDefinition,
  type MomentInvariantViolation,
} from "./momentModel";

const programMoment: MomentDefinition = {
  momentId: "m1",
  scope: {kind: "program", programId: "prog"},
  name: "Sangeet starts soon",
  initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: -15,
  },
  sense: "audience",
  audience: {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: true,
  },
  action: {
    kind: "sendTemplate", connectionId: "conn1", templateId: "tpl",
    variables: {},
  },
  status: "draft",
  approval: null,
  origin: "organizer",
  revision: 1,
};

const eventMoment: MomentDefinition = {
  momentId: "e1",
  scope: {kind: "event", eventId: "ev1"},
  name: "Event starts soon",
  initiation: {
    kind: "anchored", anchorKind: "scopeStart", anchorId: null,
    offsetMinutes: -15,
  },
  sense: "individual",
  audience: {kind: "eventParticipants", statuses: ["signedUp"]},
  action: {kind: "push", notificationType: "eventReminder",
    preferenceKey: "eventReminders"},
  status: "draft",
  approval: null,
  origin: "systemDefault",
  revision: 1,
};

const facts: AnchorFacts = {
  scope: {
    startsAtMillis: 1_000_000, endsAtMillis: 1_600_000,
    rsvpDeadlineAtMillis: null, revision: 3, messagingEnabled: true,
    cancelled: false,
  },
  functions: {},
  travelLegs: {},
};

const approval = {approvedByUid: "mgr", approvedAtMillis: 42};

test("valid program and event definitions have no violations", () => {
  assert.deepEqual(validateMomentDefinition(programMoment), []);
  assert.deepEqual(validateMomentDefinition(eventMoment), []);
});

test("axis invariants catch illegal combinations", () => {
  const subjects: Array<[MomentDefinition,
    MomentInvariantViolation]> = [
      [{...programMoment, audience: {kind: "subject"}},
        "subjectRequiresTriggered"],
      [{...programMoment, initiation: {
        kind: "triggered", triggerKind: "flightDisrupted", functionId: null,
      }, scope: {kind: "event", eventId: "ev"}},
      "triggeredRequiresProgramScope"],
      [{...eventMoment, initiation: {
        kind: "anchored", anchorKind: "functionStart", anchorId: "f",
        offsetMinutes: 0,
      }}, "anchorNotLegalForScope"],
      [{...programMoment, audience:
      {kind: "eventParticipants", statuses: ["signedUp"]}},
      "audienceNotLegalForScope"],
      [{...eventMoment, audience: {kind: "households",
        rsvpPendingOnly: true}}, "audienceNotLegalForScope"],
      [{...programMoment, initiation: {kind: "manual"},
        sense: "individual"}, "manualRequiresAudienceSense"],
      [{...programMoment, status: "armed", approval: null},
        "armedRequiresApproval"],
    ];
  for (const [moment, expected] of subjects) {
    const violations = validateMomentDefinition(moment);
    assert.ok(violations.includes(expected),
      `${expected} expected in ${violations}`);
  }
});

test("arming approves the rule once and bumps revision", () => {
  const result = armMoment(programMoment, approval);
  assert.equal(result.kind, "ok");
  if (result.kind !== "ok") return;
  assert.equal(result.moment.status, "armed");
  assert.deepEqual(result.moment.approval, approval);
  assert.equal(result.moment.revision, 2);
  // Re-arming an armed moment is rejected; done moments are terminal.
  assert.equal(armMoment(result.moment, approval).kind, "rejected");
  const done = armMoment({...programMoment, status: "done"}, approval);
  assert.deepEqual(done.kind === "rejected" && done.reason, "alreadyDone");
});

test("arming an invalid definition fails closed", () => {
  const illegal = {...programMoment,
    audience: {kind: "subject" as const}};
  const result = armMoment(illegal, approval);
  assert.equal(result.kind, "rejected");
  if (result.kind === "rejected") {
    assert.ok(result.violations?.includes("subjectRequiresTriggered"));
  }
});

test("pause/resume keeps approval; revision invalidates it", () => {
  const armed = armMoment(programMoment, approval);
  if (armed.kind !== "ok") assert.fail("expected ok");
  const paused = pauseMoment(armed.moment);
  assert.equal(paused.kind, "ok");
  if (paused.kind !== "ok") assert.fail();
  assert.equal(pauseMoment(programMoment).kind, "rejected");
  const resumed = resumeMoment(paused.moment);
  if (resumed.kind !== "ok") assert.fail();
  assert.deepEqual(resumed.moment.approval, approval);
  assert.equal(resumed.moment.status, "armed");

  const revised = reviseMoment(resumed.moment, {name: "New name"});
  if (revised.kind !== "ok") assert.fail();
  assert.equal(revised.moment.status, "draft");
  assert.equal(revised.moment.approval, null);
  const badRevise = reviseMoment(resumed.moment,
    {audience: {kind: "subject"}});
  assert.equal(badRevise.kind, "rejected");
});

test("scheduled initiation plans at an absolute time", () => {
  const scheduled: MomentDefinition = {...programMoment,
    initiation: {kind: "scheduled", atMillis: 2_000_000},
    status: "armed", approval};
  const planned = planRun(scheduled, facts, 0);
  assert.equal(planned.kind, "planned");
  if (planned.kind === "planned") {
    assert.equal(planned.run.dueAtMillis, 2_000_000);
    assert.equal(planned.run.runId, "m1_0_2000000");
  }
});

test("manual initiation never auto-plans; planManualRun is keyed", () => {
  const manual: MomentDefinition = {...programMoment,
    initiation: {kind: "manual"}, status: "armed", approval};
  assert.deepEqual(planRun(manual, facts, 0),
    {kind: "unplannable", reason: "manualInitiation"});
  const run = planManualRun(manual, "req-9", 5_000);
  assert.equal(run.kind, "planned");
  if (run.kind === "planned") {
    assert.equal(run.run.dueAtMillis, 5_000);
    assert.equal(run.run.runId, "m1_manual_req-9");
  }
  assert.throws(() => planManualRun(manual, " ", 5_000), RangeError);
  assert.deepEqual(planManualRun({...manual, status: "draft"},
    "req", 5_000), {kind: "unplannable", reason: "notArmed"});
});

test("scope helpers compare by kind and id", () => {
  assert.equal(scopeId(programMoment.scope), "prog");
  assert.ok(sameScope(programMoment.scope,
    {kind: "program", programId: "prog"}));
  assert.ok(!sameScope(programMoment.scope,
    {kind: "event", eventId: "prog"}));
});
