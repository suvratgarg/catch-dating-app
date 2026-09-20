import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventRehearsalActorDocument as Actor,
  EventRehearsalDocument as Session,
} from "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {buildRehearsalActors} from "./engine";
import {practiceOutcomeReview, preparePracticeOutcome} from "./outcomes";

type Command = NonNullable<Control["outcome"]>;
type UnitOutcome = "none" | "completion" | "score" | "rank";

function session(unitOutcome: UnitOutcome = "completion"): Session {
  return {
    status: "running",
    virtualNow: Timestamp.fromMillis(10_000),
    setup: {durationMinutes: 120, moduleIds: ["pods"], unitOutcome},
  } as Session;
}

function actors(): Actor[] {
  return buildRehearsalActors("session-1", 8, 11,
    Timestamp.fromMillis(0));
}

function command(
  unitId = "table-1",
  round = 0,
  outcome: Command["outcome"] = {kind: "completion", completed: true},
  expectedOutcomeRevision = 0
): Command {
  return {unitId, round, outcome, expectedOutcomeRevision};
}

test("practice outcome review begins with current synthetic units", () => {
  assert.deepEqual(practiceOutcomeReview(session(), actors()), {
    unitOutcome: "completion",
    revision: 0,
    unitIds: ["table-1", "table-2"],
    records: [],
  });
});

test("practice outcomes are revisioned and correctable", () => {
  const s = session();
  const first = preparePracticeOutcome(s, actors(), command(), "host-1",
    "outcome-1");
  assert.equal(first.revision, 1);
  assert.equal(first.records[0]?.outcome.kind, "completion");
  const corrected = preparePracticeOutcome({...s, unitOutcomes: first},
    actors(), command("table-1", 0,
      {kind: "completion", completed: false}, 1),
    "host-1", "outcome-2");
  assert.equal(corrected.revision, 2);
  assert.equal(corrected.records.length, 1);
  assert.deepEqual(corrected.records[0]?.outcome,
    {kind: "completion", completed: false});
  assert.equal(corrected.records[0]?.stateRevision, 2);
});

test("practice outcomes fence stale, missing, and mismatched writes", () => {
  const s = session();
  assert.throws(() => preparePracticeOutcome(s, actors(),
    command("table-3"), "host-1", "outcome-1"), isCode("not-found"));
  assert.throws(() => preparePracticeOutcome(s, actors(),
    command("table-1", 0, {kind: "score", score: 3}),
    "host-1", "outcome-1"), isCode("invalid-argument"));
  assert.throws(() => preparePracticeOutcome(s, actors(),
    command("table-1", 0, {kind: "completion", completed: true}, 1),
    "host-1", "outcome-1"), isCode("aborted"));
  assert.throws(() => preparePracticeOutcome(session("none"), actors(),
    command(), "host-1", "outcome-1"), isCode("failed-precondition"));
});

test("practice outcome rounds require every current unit in order", () => {
  const s = session();
  const first = preparePracticeOutcome(s, actors(), command(), "host-1",
    "outcome-1");
  assert.throws(() => preparePracticeOutcome({...s, unitOutcomes: first},
    actors(), command("table-1", 1,
      {kind: "completion", completed: true}, 1),
    "host-1", "outcome-2"), isCode("failed-precondition"));
  const full = preparePracticeOutcome({...s, unitOutcomes: first}, actors(),
    command("table-2", 0, {kind: "completion", completed: true}, 1),
    "host-1", "outcome-2");
  const next = preparePracticeOutcome({...s, unitOutcomes: full}, actors(),
    command("table-1", 1, {kind: "completion", completed: true}, 2),
    "host-1", "outcome-3");
  assert.equal(next.records.at(-1)?.round, 1);
});

test("practice rank outcomes require valid unique positions", () => {
  const s = session("rank");
  assert.throws(() => preparePracticeOutcome(s, actors(),
    command("table-1", 0, {kind: "rank", rank: 3}),
    "host-1", "outcome-1"), isCode("invalid-argument"));
  const first = preparePracticeOutcome(s, actors(),
    command("table-1", 0, {kind: "rank", rank: 1}),
    "host-1", "outcome-1");
  assert.throws(() => preparePracticeOutcome({...s, unitOutcomes: first},
    actors(), command("table-2", 0, {kind: "rank", rank: 1}, 1),
    "host-1", "outcome-2"), isCode("invalid-argument"));
});

test("control callable accepts only a correlated outcome command", () => {
  const payload = {sessionId: "session-1", expectedRevision: 2,
    expectedSetupRevision: 0, clientActionId: "outcome_0001",
    action: "outcome", outcome: command()};
  assert.equal(validateControlEventRehearsalCallablePayload(payload), true);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, outcome: undefined}), false);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, assistance: {}}), false);
});

function isCode(code: HttpsError["code"]) {
  return (error: unknown) => error instanceof HttpsError &&
    error.code === code;
}
