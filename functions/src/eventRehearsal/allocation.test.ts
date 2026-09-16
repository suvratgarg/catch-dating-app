import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventRehearsalActorDocument as Actor,
  EventRehearsalDocument as Session,
} from "../shared/generated/firestoreAdminTypes";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {buildRehearsalActors} from "./engine";
import {practiceAllocationReview, preparePracticeAllocation,
  type PracticeAllocationCommand as Command} from "./allocation";

const now = Timestamp.fromMillis(10_000);

function session(): Session {
  return {
    organizerId: "organizer-1",
    actorCount: 6,
    status: "running",
    setupRevision: 0,
    virtualStartedAt: Timestamp.fromMillis(0),
    virtualNow: now,
  } as Session;
}

function actors(): Actor[] {
  return buildRehearsalActors("session-1", 6, 11,
    Timestamp.fromMillis(0));
}

function propose(
  attendeeIds = ["actor-01"],
  targetUnitId = "table-2",
  expectedAllocationRevision = 0
): Command {
  return {kind: "propose", attendeeIds, targetUnitId,
    expectedAllocationRevision};
}

function publish(proposalId: string, decisionId = "allocation:publish:1"):
  Command {
  return {kind: "publish", proposalId, decisionId};
}

test("practice allocation review begins from synthetic placements", () => {
  const review = practiceAllocationReview(session(), actors());
  assert.equal(review.revision, 0);
  assert.deepEqual(review.unitIds, ["table-1", "table-2"]);
  assert.deepEqual(review.assignments.slice(0, 2), [
    {attendeeId: "actor-01", unitId: "table-1"},
    {attendeeId: "actor-02", unitId: "table-1"},
  ]);
  assert.deepEqual(review.proposals, []);
});

test("Host prepares then publishes a fenced practice allocation", () => {
  const s = session();
  const roster = actors();
  const prepared = preparePracticeAllocation("session-1", s, roster,
    propose(), "host-1", "allocation_0001", now);
  assert.equal(prepared.state.revision, 0);
  assert.equal(prepared.state.proposals[0]?.status, "pending");
  assert.deepEqual(prepared.actors, []);

  const proposalId = prepared.state.proposals[0]!.proposalId;
  const published = preparePracticeAllocation("session-1",
    {...s, allocationState: prepared.state}, roster, publish(proposalId),
    "host-1", "allocation_0002", now);
  assert.equal(published.state.revision, 1);
  assert.equal(published.state.proposals[0]?.status, "published");
  assert.equal(published.state.proposals[0]?.publishedRevision, 1);
  assert.equal(published.actors[0]?.layoutUnitId, "table-2");
  assert.equal(published.actors[0]?.confirmedLayoutUnitId, null);
  assert.equal(published.actors[0]?.guestMoment, "assignment");

  const replay = preparePracticeAllocation("session-1",
    {...s, allocationState: published.state}, roster,
    publish(proposalId), "host-1", "allocation_0003", now);
  assert.equal(replay.replayed, true);
  assert.deepEqual(replay.actors, []);
});

test("publishing one proposal stales alternatives from its revision", () => {
  const s = session();
  const roster = actors();
  const first = preparePracticeAllocation("session-1", s, roster,
    propose(), "host-1", "allocation_0001", now).state;
  const second = preparePracticeAllocation("session-1",
    {...s, allocationState: first}, roster,
    propose(["actor-02"]), "host-1", "allocation_0002", now).state;
  const published = preparePracticeAllocation("session-1",
    {...s, allocationState: second}, roster,
    publish(first.proposals[0]!.proposalId), "host-1",
    "allocation_0003", now).state;
  assert.deepEqual(published.proposals.map((proposal) => proposal.status),
    ["published", "stale"]);
  assert.throws(() => preparePracticeAllocation("session-1",
    {...s, allocationState: published}, roster,
    publish(second.proposals[1]!.proposalId, "allocation:publish:2"),
    "host-1", "allocation_0004", now), isCode("failed-precondition"));
});

test("practice proposals enforce revision and placement constraints", () => {
  const s = session();
  const roster = actors();
  assert.throws(() => preparePracticeAllocation("session-1", s, roster,
    propose(["actor-01"], "table-2", 1), "host-1", "allocation_0001",
    now), isCode("aborted"));
  assert.throws(() => preparePracticeAllocation("session-1", s, roster,
    propose(["actor-01", "actor-02", "actor-03"]), "host-1",
    "allocation_0001", now), isCode("failed-precondition"));
  assert.throws(() => preparePracticeAllocation("session-1", s,
    roster.map((actor) => actor.actorId === "actor-01" ?
      {...actor, status: "noShow" as const} : actor), propose(), "host-1",
    "allocation_0001", now), isCode("failed-precondition"));
  assert.throws(() => preparePracticeAllocation("session-1", s,
    roster.map((actor) => actor.actorId === "actor-01" ?
      {...actor, keepApartActorIds: ["actor-05"]} : actor), propose(),
    "host-1", "allocation_0001", now), isCode("failed-precondition"));
});

test("control callable accepts only the correlated allocation command", () => {
  const payload = {sessionId: "session-1", expectedRevision: 2,
    expectedSetupRevision: 0, clientActionId: "allocation_0001",
    action: "allocation", allocation: propose()};
  assert.equal(validateControlEventRehearsalCallablePayload(payload), true);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, allocation: undefined}), false);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, allocation: {...propose(), proposalId: "wrong"}}), false);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, practiceOperatorId: "practice-staff:lead"}), false);
});

function isCode(code: HttpsError["code"]) {
  return (error: unknown) => error instanceof HttpsError &&
    error.code === code;
}
