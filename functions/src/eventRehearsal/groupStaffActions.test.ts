import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {departure, report} from "./movementTestFixtures";
import {closeout, reassign} from "./movementManagementTestFixtures";
import {room, role, roleRead, roleMove, assign, pacer, sweep, receiver} from
  "./groupStaffTestFixtures";
import {practiceMembershipView, transferPracticeMembership} from "./membership";
import {practiceAccountabilityView, resolvePracticeAccountability} from
  "./accountability";
import {applyPracticeHostCommand} from "./assistanceTransactions";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {PracticeCaseAuthority} from "./assistanceCases";
import type {Harness} from "./groupStaffTestFixtures";
type Transfer = Extract<NonNullable<Control["assistance"]>,
  {kind: "transferGroup"}>;

function transfer(h: Harness, authority: PracticeCaseAuthority,
  decision: Transfer["payload"]["decision"]) {
  const row = practiceMembershipView(h.session, h.actors[0], authority);
  h.actors[0] = transferPracticeMembership(h.session, h.actors[0], {
    kind: "transferGroup", actorId: row.attendeeId,
    expectedSourceHash: row.sourceHash, payload: {attendeeId: row.attendeeId,
      episodeId: row.episodeId!, expectedParticipationRevision:
        row.participationRevision, expectedMembershipRevision: row.revision,
      decision}}, authority, "transfer_action");
}
function resolve(h: Harness, authority: PracticeCaseAuthority, i = 0) {
  const row = practiceAccountabilityView(h.session, h.actors[i], authority);
  const command = {kind: "resolveAccountability" as const,
    actorId: row.attendeeId, expectedSourceHash: row.sourceHash,
    ...(row.groupId ? {groupId: row.groupId} : {}),
    payload: {attendeeId: row.attendeeId, episodeId: row.episodeId!,
      disposition: "departed" as const}};
  h.actors[i] = resolvePracticeAccountability(h.session, h.actors[i], command,
    authority);
}

test("a sweep can report and resolve guests but cannot depart or " +
  "transfer", async () => {
  const h = room(); const lead = role(h); const tail = role(h, sweep);
  let view = await roleRead(h, tail);
  await assert.rejects(roleMove(h, departure(view), tail),
    {code: "permission-denied"});
  const first = departure(view, h.actors.map((a) => a.actorId), true);
  if (first.kind !== "confirmDeparture") throw new Error("Expected departure");
  first.payload.checkpointRequest!.responsibleOperatorId = sweep;
  await assert.rejects(roleMove(h, first, lead),
    {code: "permission-denied"});
  await roleMove(h, first, h.authority);
  view = await roleRead(h, tail);
  await roleMove(h, report(view, [h.actors[0].actorId]), tail);
  assert.equal((await roleRead(h, tail)).checkpoint!.report!.reportedBy, sweep);
  assert.deepEqual(practiceMembershipView(h.session, h.actors[0], tail).actions,
    []);
  assert.throws(() => transfer(h, tail, {kind: "leave"}),
    {code: "permission-denied"});
  const beforeStatus = h.actors[1].status;
  resolve(h, tail, 1);
  assert.equal(h.actors[1].visit!.resolution!.resolvedBy, sweep);
  view = await roleRead(h, tail);
  await assert.rejects(roleMove(h, closeout(view), lead),
    {code: "permission-denied"});
  await roleMove(h, closeout(view), tail);
  assert.equal((await roleRead(h, tail)).checkpoint!.request!.state,
    "closedOut");
  assert.equal(h.actors[1].status, beforeStatus);
  await assert.rejects(roleMove(h, closeout(await roleRead(h, tail), "reopen"),
    lead), {code: "permission-denied"});
  await roleMove(h, closeout(await roleRead(h, tail), "reopen"), tail);
  await assert.rejects(roleMove(h, reassign(await roleRead(h, tail)), tail),
    {code: "permission-denied"});
});

test("only the named receiving pacer accepts, then old group loses " +
  "visit scope", () => {
  const h = room(); const sender = role(h); const receiving = role(h, receiver);
  transfer(h, sender, {kind: "propose", from: "easy", to: "fast",
    receivingOperatorId: receiver, expiresAtMillis: 61000});
  const transferId = h.actors[0].groupMembership!.transfer!.transferId;
  assert.equal(h.actors[0].groupMembership!.accepted!.groupId, "easy");
  assert.equal(practiceAccountabilityView(h.session, h.actors[0], receiving)
    .canResolve, false);
  assert.throws(() => transfer(h, h.authority, {kind: "accept", transferId}),
    {code: "permission-denied"});
  assert.throws(() => transfer(h, sender, {kind: "accept", transferId}),
    {code: "permission-denied"});
  transfer(h, receiving, {kind: "accept", transferId});
  assert.equal(h.actors[0].groupMembership!.accepted!.groupId, "fast");
  assert.equal(h.actors[0].groupMembership!.accepted!.responsibleOperatorId,
    receiver);
  assert.equal(practiceAccountabilityView(h.session, h.actors[0], sender)
    .canResolve, false);
  assert.throws(() => resolve(h, sender), {code: "failed-precondition"});
  resolve(h, receiving);
  assert.equal(h.actors[0].visit!.resolution!.resolvedBy, receiver);
  assert.equal(h.actors[1].groupMembership!.accepted!.groupId, "easy");
});

test("a target needs current group duty and may lose it before " +
  "acceptance", () => {
  const h = room();
  assert.throws(() => transfer(h, role(h), {kind: "propose", from: "easy",
    to: "fast", receivingOperatorId: sweep, expiresAtMillis: 61000}),
  {code: "permission-denied"});
  assign(h, receiver, "fast", "pacer", 2000);
  transfer(h, role(h), {kind: "propose", from: "easy", to: "fast",
    receivingOperatorId: receiver, expiresAtMillis: 61000});
  h.session.virtualNow = Timestamp.fromMillis(2000);
  const transferId = h.actors[0].groupMembership!.transfer!.transferId;
  assert.throws(() => transfer(h, role(h, receiver),
    {kind: "accept", transferId}),
  {code: "permission-denied"});
  assert.equal(h.actors[0].groupMembership!.accepted!.groupId, "easy");
});

test("checkpoint responsibility requires duty beyond the original " +
  "deadline", async () => {
  const h = room(); assign(h, sweep, "easy", "sweep", 2000);
  const initial = await roleRead(h);
  const first = departure(initial, h.actors.map((a) => a.actorId), true);
  if (first.kind !== "confirmDeparture") throw new Error("Expected departure");
  first.payload.checkpointRequest!.responsibleOperatorId = sweep;
  await assert.rejects(roleMove(h, first, h.authority),
    {code: "failed-precondition"});
  assign(h, sweep, "easy", "sweep");
  await roleMove(h, first, h.authority);
  const view = await roleRead(h);
  await assert.rejects(roleMove(h, reassign(view, receiver), h.authority),
    {code: "permission-denied"});
  assign(h, sweep, "easy", "sweep", 2000);
  h.session.virtualNow = Timestamp.fromMillis(2000);
  assert.equal((await roleRead(h)).checkpoint!.request!.ownerAvailability,
    "needsReassignment");
  await assert.rejects(roleRead(h, role(h, sweep)),
    {code: "permission-denied"});
  await roleMove(h, reassign(await roleRead(h), pacer), h.authority);
  assert.equal((await roleRead(h)).checkpoint!.request!.dueAt,
    first.payload.checkpointRequest!.dueAt);
});

test("group duties do not authorize rehearsal provider or " +
  "automation actions", async () => {
  const h = room();
  await assert.rejects(h.db.runTransaction((tx) => applyPracticeHostCommand(
    h.db, tx, h.session, h.actors[0], {kind: "pauseAutomation",
      actorId: h.actors[0].actorId}, role(h))), {code: "permission-denied"});
});
