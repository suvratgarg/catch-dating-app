import assert from "node:assert/strict";
import test from "node:test";
import {
  evaluateCondition,
  type TravelLegEvent,
} from "./momentConditions";
import {planRun, resolveFireDisposition} from "./momentPlanning";
import {
  dressReminder,
  flightDisruptionAlert,
  functionStartReminder,
  lateArrivalGateAlert,
  rsvpDeadlineChase,
  transportReadyNotice,
} from "./momentTemplates";
import type {AnchorFacts} from "./momentModel";

const facts: AnchorFacts = {
  scope: {
    startsAtMillis: 1_000_000,
    endsAtMillis: null,
    cancelled: false,
    rsvpDeadlineAtMillis: 100_000_000,
    revision: 3,
    messagingEnabled: true,
  },
  functions: {
    sangeet: {
      startsAtMillis: 10_000_000,
      endsAtMillis: 10_400_000,
      revision: 7,
      cancelled: false,
    },
    haldi: {
      startsAtMillis: 1_500_000,
      endsAtMillis: 1_800_000,
      revision: 2,
      cancelled: true,
    },
  },
  travelLegs: {
    udrT1: {atMillis: 1_700_000, revision: 4},
  },
};

const armedBy = {approvedByUid: "mgr", approvedAtMillis: 1} as const;

const sangeet = {
  programId: "prog",
  functionId: "sangeet",
  name: "Sangeet",
};
const haldi = {
  programId: "prog",
  functionId: "haldi",
  cancelled: true,
};

test("functionStartReminder defaults to T-15m for attending guests", () => {
  const moment = functionStartReminder(
    sangeet, {connectionId: "conn1", armedBy});
  assert.ok(moment);
  assert.deepEqual(moment, {
    momentId: "prog_sangeet_function_start_reminder",
    scope: {kind: "program", programId: "prog"},
    name: "Sangeet starts soon",
    initiation: {
      kind: "anchored",
      anchorKind: "functionStart",
      anchorId: "sangeet",
      offsetMinutes: -15,
    },
    audience: {
      kind: "functionGuests",
      functionId: "sangeet",
      rsvp: ["attending"],
      householdDedupe: true,
    },
    action: {
      kind: "sendTemplate",
      connectionId: "conn1",
      templateId: "program_function_starting",
      variables: {
        programId: "prog",
        functionId: "sangeet",
        functionName: "Sangeet",
      },
    },
    sense: "audience",
    status: "armed",
    approval: armedBy,
    origin: "organizer",
    revision: 1,
  });
  const result = planRun(moment, facts, 0);
  assert.deepEqual(result.kind === "planned" && result.run, {
    runId: "prog_sangeet_function_start_reminder_7_9100000",
    momentId: "prog_sangeet_function_start_reminder",
    dueAtMillis: 9_100_000,
    anchorRevision: 7,
    status: "planned",
  });
});

test("dressReminder defaults to T-60m with the get-ready template", () => {
  const moment = dressReminder(sangeet, {connectionId: "conn1", armedBy});
  assert.ok(moment);
  assert.equal(moment.momentId, "prog_sangeet_dress_reminder");
  assert.equal(moment.name, "Get ready for Sangeet");
  assert.deepEqual(moment.initiation, {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: -60,
  });
  assert.deepEqual(moment.audience, {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: true,
  });
  assert.deepEqual(moment.action, {
    kind: "sendTemplate", connectionId: "conn1",
    templateId: "program_get_ready",
    variables: {
      programId: "prog", functionId: "sangeet", functionName: "Sangeet",
    },
  });
  const result = planRun(moment, facts, 0);
  assert.equal(result.kind, "planned");
  if (result.kind === "planned") {
    assert.equal(result.run.dueAtMillis, 6_400_000);
  }
});

test("function-scoped factories omit cancelled functions", () => {
  assert.equal(functionStartReminder(haldi, {connectionId: "conn1"}), null);
  assert.equal(dressReminder(haldi, {connectionId: "conn1"}), null);
  assert.equal(lateArrivalGateAlert(haldi), null);
  assert.equal(transportReadyNotice({
    programId: "prog", legId: "udrT1", functionId: "haldi",
    functionCancelled: true,
  }, {connectionId: "conn1"}), null);
  assert.equal(flightDisruptionAlert({
    programId: "prog", legId: "leg9", functionId: "haldi",
    functionCancelled: true,
  }), null);
});

test("transportReadyNotice anchors the departure and its guests", () => {
  const moment = transportReadyNotice({
    programId: "prog", legId: "udrT1", name: "Airport shuttle",
    functionId: "sangeet",
  }, {connectionId: "conn1", armedBy});
  assert.ok(moment);
  assert.equal(moment.momentId, "prog_udrT1_transport_ready");
  assert.equal(moment.name, "Airport shuttle transport ready");
  assert.deepEqual(moment.initiation, {
    kind: "anchored", anchorKind: "travelLegTime",
    anchorId: "udrT1", offsetMinutes: 0,
  });
  assert.deepEqual(moment.audience, {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: true,
  });
  assert.deepEqual(moment.action, {
    kind: "sendTemplate", connectionId: "conn1",
    templateId: "program_transport_ready",
    variables: {
      programId: "prog", legId: "udrT1",
      legName: "Airport shuttle", functionId: "sangeet",
    },
  });
  const result = planRun(moment, facts, 0);
  assert.deepEqual(result.kind === "planned" && result.run, {
    runId: "prog_udrT1_transport_ready_4_1700000",
    momentId: "prog_udrT1_transport_ready",
    dueAtMillis: 1_700_000,
    anchorRevision: 4,
    status: "planned",
  });
});

test("transportReadyNotice without a function falls back to households", () => {
  const moment = transportReadyNotice(
    {programId: "prog", legId: "udrT1"},
    {connectionId: "conn1"});
  assert.ok(moment);
  assert.deepEqual(moment.audience,
    {kind: "households", rsvpPendingOnly: false});
  const scoped = transportReadyNotice({
    programId: "prog", legId: "udrT1", functionId: "sangeet",
  }, {
    connectionId: "conn1", armedBy, offsetMinutes: -10,
    audience: {kind: "staffDuty", duty: "driverDesk", scopeIds: ["udrT1"]},
  });
  assert.ok(scoped);
  assert.deepEqual(scoped.audience,
    {kind: "staffDuty", duty: "driverDesk", scopeIds: ["udrT1"]});
  const result = planRun(scoped, facts, 0);
  assert.equal(result.kind, "planned");
  if (result.kind === "planned") {
    assert.equal(result.run.dueAtMillis, 1_100_000);
  }
});

test("rsvpDeadlineChase chases pending households 24h early", () => {
  const moment = rsvpDeadlineChase(
    {programId: "prog", name: "Meera & Arjun"},
    {connectionId: "conn1", armedBy});
  assert.equal(moment.momentId, "prog_rsvp_deadline_chase");
  assert.equal(moment.name, "Meera & Arjun RSVP deadline reminder");
  assert.deepEqual(moment.initiation, {
    kind: "anchored", anchorKind: "rsvpDeadline", anchorId: null,
    offsetMinutes: -1_440,
  });
  assert.deepEqual(moment.audience,
    {kind: "households", rsvpPendingOnly: true});
  assert.deepEqual(moment.action, {
    kind: "sendTemplate", connectionId: "conn1",
    templateId: "program_rsvp_deadline_reminder",
    variables: {programId: "prog", programName: "Meera & Arjun"},
  });
  const result = planRun(moment, facts, 0);
  assert.equal(result.kind, "planned");
  if (result.kind === "planned") {
    assert.equal(result.run.dueAtMillis, 13_600_000);
    assert.equal(result.run.anchorRevision, 3);
  }
});

test("lateArrivalGateAlert routes staffAttention to the gate duty", () => {
  const moment = lateArrivalGateAlert(sangeet, {armedBy});
  assert.ok(moment);
  assert.equal(moment.momentId, "prog_sangeet_late_arrival_gate_alert");
  assert.deepEqual(moment.initiation, {
    kind: "triggered", triggerKind: "lateArrivalAtHotel",
    functionId: "sangeet",
  });
  assert.deepEqual(moment.audience, {
    kind: "staffDuty", duty: "gateGreeter", scopeIds: ["sangeet"],
  });
  assert.deepEqual(moment.action, {
    kind: "staffAttention", duty: "gateGreeter", severity: "warning",
    titleTemplate: "Late arrival at hotel — escort to Sangeet",
  });
  const arrived: TravelLegEvent = {
    kind: "travelLegReadinessChanged", legId: "leg1", programId: "prog",
    previousReadiness: "enRoute", readiness: "arrived",
    observedAtMillis: 10_100_000,
  };
  const result = evaluateCondition(moment, arrived, facts, 10_100_000);
  assert.deepEqual(result.kind === "fire" && result.run, {
    runId: "prog_sangeet_late_arrival_gate_alert_leg1_arrived",
    momentId: "prog_sangeet_late_arrival_gate_alert",
    dueAtMillis: 10_100_000,
    anchorRevision: 7,
    status: "planned",
    targetFunctionId: "sangeet",
    subjectId: "leg1",
  });
});

test("flightDisruptionAlert escalates to the dispatcher as urgent", () => {
  const moment = flightDisruptionAlert(
    {programId: "prog", legId: "leg9", name: "DEL-UDR leg"}, {armedBy});
  assert.ok(moment);
  assert.equal(moment.momentId, "prog_leg9_flight_disruption_alert");
  assert.deepEqual(moment.initiation, {
    kind: "triggered", triggerKind: "flightDisrupted",
    functionId: null,
  });
  assert.deepEqual(moment.audience, {
    kind: "staffDuty", duty: "transportDispatcher", scopeIds: ["leg9"],
  });
  assert.deepEqual(moment.action, {
    kind: "staffAttention", duty: "transportDispatcher",
    severity: "urgent",
    titleTemplate: "Flight disruption on DEL-UDR leg — rework transport",
  });
  const disrupted: TravelLegEvent = {
    kind: "travelLegFlightStatusChanged", legId: "leg9",
    programId: "prog", previousFlightStatus: "delayed",
    flightStatus: "cancelled", observedAtMillis: 2_100_000,
  };
  const result = evaluateCondition(moment, disrupted, facts, 2_100_000);
  assert.equal(result.kind, "fire");
  if (result.kind === "fire") {
    assert.equal(result.run.runId,
      "prog_leg9_flight_disruption_alert_leg9_cancelled");
    assert.equal(result.run.anchorRevision, 0);
    assert.equal(result.run.targetFunctionId, undefined);
  }
});

test("flightDisruptionAlert carries function context when supplied", () => {
  const moment = flightDisruptionAlert(
    {programId: "prog", legId: "leg9", functionId: "sangeet"}, {armedBy});
  assert.ok(moment);
  assert.deepEqual(moment.initiation, {
    kind: "triggered", triggerKind: "flightDisrupted",
    functionId: "sangeet",
  });
  const disrupted: TravelLegEvent = {
    kind: "travelLegFlightStatusChanged", legId: "leg9",
    programId: "prog", previousFlightStatus: "scheduled",
    flightStatus: "diverted", observedAtMillis: 2_100_000,
  };
  const result = evaluateCondition(moment, disrupted, facts, 2_100_000);
  assert.equal(result.kind, "fire");
  if (result.kind === "fire") {
    assert.equal(result.run.anchorRevision, 7);
    assert.equal(result.run.targetFunctionId, "sangeet");
  }
});

test("options override offsets, audience, templates and status", () => {
  const moment = functionStartReminder(sangeet, {
    connectionId: "conn2",
    offsetMinutes: -30,
    templateId: "tpl_custom",
    variables: {functionName: "The Big Sangeet", extra: "x"},
    rsvp: ["attending", "maybe"],
    householdDedupe: false,
    name: "Custom reminder",
  });
  assert.ok(moment);
  assert.equal(moment.status, "draft");
  assert.equal(moment.approval, null);
  assert.equal(moment.name, "Custom reminder");
  assert.deepEqual(moment.action, {
    kind: "sendTemplate", connectionId: "conn2", templateId: "tpl_custom",
    variables: {
      programId: "prog", functionId: "sangeet",
      functionName: "The Big Sangeet", extra: "x",
    },
  });
  assert.deepEqual(moment.audience, {
    kind: "functionGuests", functionId: "sangeet",
    rsvp: ["attending", "maybe"], householdDedupe: false,
  });
  // A draft template output is well-formed but never plans.
  assert.deepEqual(planRun(moment, facts, 0),
    {kind: "unplannable", reason: "notArmed"});
  const alert = lateArrivalGateAlert(sangeet, {
    duty: "lobbyHost", severity: "info", titleTemplate: "Ping",
    scopeIds: null,
  });
  assert.ok(alert);
  assert.deepEqual(alert.audience,
    {kind: "staffDuty", duty: "lobbyHost", scopeIds: null});
  assert.deepEqual(alert.action, {
    kind: "staffAttention", duty: "lobbyHost", severity: "info",
    titleTemplate: "Ping",
  });
});

test("produced moments pass the fire-time disposition checks", () => {
  const reminder = functionStartReminder(
    sangeet, {connectionId: "conn1", armedBy});
  assert.ok(reminder);
  const planned = planRun(reminder, facts, 0);
  assert.equal(planned.kind, "planned");
  if (planned.kind !== "planned") return;
  assert.equal(
    resolveFireDisposition(planned.run, reminder, facts), "dispatch");
  const silent: AnchorFacts = {...facts, scope: {...facts.scope,
    messagingEnabled: false}};
  assert.equal(
    resolveFireDisposition(planned.run, reminder, silent),
    "skip:messagingDisabled");
  // staffAttention alerts still dispatch while messaging is disabled.
  const gate = lateArrivalGateAlert(sangeet, {armedBy});
  assert.ok(gate);
  assert.equal(
    resolveFireDisposition(planned.run, gate, silent), "dispatch");
});

test("factories are deterministic across calls", () => {
  assert.deepEqual(
    functionStartReminder(sangeet, {connectionId: "conn1"}),
    functionStartReminder(sangeet, {connectionId: "conn1"}));
  assert.deepEqual(
    flightDisruptionAlert({programId: "prog", legId: "leg9"}),
    flightDisruptionAlert({programId: "prog", legId: "leg9"}));
  const other = functionStartReminder(
    {programId: "prog", functionId: "other"}, {connectionId: "conn1"});
  assert.notEqual(other?.momentId,
    functionStartReminder(sangeet, {connectionId: "conn1"})?.momentId);
});

test("factories reject blank ids and fractional offsets", () => {
  assert.throws(() => functionStartReminder(
    {programId: "", functionId: "sangeet"}, {connectionId: "conn1"}),
  RangeError);
  assert.throws(() => functionStartReminder(sangeet,
    {connectionId: "  "}), RangeError);
  assert.throws(() => dressReminder(sangeet,
    {connectionId: "conn1", offsetMinutes: 1.5}), RangeError);
  assert.throws(() => dressReminder(sangeet,
    {connectionId: "conn1", offsetMinutes: NaN}), RangeError);
  assert.throws(() => transportReadyNotice(
    {programId: "prog", legId: ""}, {connectionId: "conn1"}),
  RangeError);
  assert.throws(() => transportReadyNotice(
    {programId: "prog", legId: "udrT1", functionId: " "},
    {connectionId: "conn1"}), RangeError);
  assert.throws(() => rsvpDeadlineChase({programId: ""},
    {connectionId: "conn1"}), RangeError);
  assert.throws(() => lateArrivalGateAlert(
    {programId: "prog", functionId: ""}), RangeError);
  assert.throws(() => flightDisruptionAlert(
    {programId: "prog", legId: ""}), RangeError);
});
