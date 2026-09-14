import {readFileSync, writeFileSync} from "node:fs";
import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {operationContentHash as hash} from "../operations/durableActions";
import {ready, closeout, checkpointVisit} from
  "./movementManagementTestFixtures";
import {departure, report} from "./movementTestFixtures";
import {assign, role, roleRead, sweep, room, receiver} from
  "./groupStaffTestFixtures";
import {preparePracticeMovementCommand} from "./movement";
import {practiceMembershipView, transferPracticeMembership} from "./membership";
import {practiceAccountabilityView} from "./accountability";
import type {Decision} from "../eventSuccess/operations/membershipDecisions";

for (const group of [false, true]) {
  test("checkpoint visit outcome preserves original arrivals: group=" + group,
    async () => {
      const h = await ready(group);
      await h.execute(report(await h.current(), [h.actors[0].actorId]));
      const before = await h.current();
      const untouched = hash(JSON.parse(JSON.stringify(h.actors[0])));
      const attendance = h.actors[1].visit!.attendanceRevision;
      const status = h.actors[1].status;
      await h.execute(checkpointVisit(before, h.actors[1].actorId));
      const after = await h.current();
      assert.deepEqual(after.selected, before.selected);
      assert.equal(after.checkpoint!.accountabilityReviews![1].disposition,
        "departed");
      assert.deepEqual(after.checkpoint!.closeout!.eligibility,
        {kind: "ready"});
      assert.equal(hash(JSON.parse(JSON.stringify(h.actors[0]))), untouched);
      assert.equal(h.actors[1].status, status);
      assert.equal(h.actors[1].visit!.attendanceRevision, attendance);
      await h.execute(closeout(after));
      assert.equal((await h.current()).checkpoint!.request!.state, "closedOut");
    });
}

test("new visits and replaced actors cannot inherit old checkpoint actions",
  async () => {
    for (const replace of [false, true]) {
      const h = await ready();
      const id = h.actors[1].actorId;
      const pending = checkpointVisit(await h.current(), id);
      if (replace) h.actors[1].createdAt = Timestamp.fromMillis(1);
      else {
        h.leave(1); h.arrive(1);
      }
      const before = hash(JSON.parse(JSON.stringify(h.actors)));
      await assert.rejects(h.execute(pending), {code: "aborted"});
      const row = (await h.current()).checkpoint!.accountabilityReviews![1];
      assert.deepEqual(row.availability,
        {kind: "unavailable", reason: "visitChanged"});
      assert.equal(row.canResolve, false);
      await assert.rejects(h.execute(checkpointVisit(await h.current(), id)),
        {code: "failed-precondition"});
      assert.equal(hash(JSON.parse(JSON.stringify(h.actors))), before);
    }
  });

test("older departures remain scoped and later decisions invalidate reviews",
  async () => {
    const h = await ready();
    const first = await h.current();
    const id = h.actors[1].actorId;
    const pending = checkpointVisit(first, id);
    const next = departure(first, h.actors.map((a) => a.actorId), true);
    if (next.kind !== "confirmDeparture") throw new Error("Departure expected");
    next.payload.destination = first.progress.destinations[1].target;
    await h.execute(next);
    await h.execute(pending);
    const older = await h.read({...h.scope, progressRevision: 1});
    assert.equal(older.checkpoint!.accountabilityReviews![1].disposition,
      "departed");
    await assert.rejects(h.execute(pending), {code: "aborted"});
    const wrong = checkpointVisit(older, id);
    wrong.payload.checkpointId = "two";
    await assert.rejects(h.execute(wrong), {code: "failed-precondition"});
    assert.equal((await h.current()).progress.revision, 2);
  });

test("current original-group duties govern the visit action", async () => {
  const h = await ready(true);
  assign(h, sweep, "easy", "sweep", 2000);
  const authority = role(h, sweep);
  const current = await roleRead(h, authority, h.scope);
  const command = checkpointVisit(current, h.actors[1].actorId);
  assert.equal(current.checkpoint!.accountabilityReviews![1].canResolve, true);
  h.session.virtualNow = Timestamp.fromMillis(2000);
  await assert.rejects(h.db.runTransaction((tx) =>
    preparePracticeMovementCommand(h.db, tx, h.id, h.session, h.actors,
      command, authority, "scoped_visit_1")), {code: "permission-denied"});
});

test("failed checkpoint visit commits preserve actors and recorded movement",
  async () => {
    const h = await ready();
    const before = hash(JSON.parse(JSON.stringify(h.actors)));
    const current = await h.current();
    h.fake.failNextCommit = true;
    await assert.rejects(h.execute(checkpointVisit(current,
      h.actors[1].actorId)));
    assert.equal(hash(JSON.parse(JSON.stringify(h.actors))), before);
    assert.deepEqual((await h.current()).selected, current.selected);
  });

test("native checkpoint visit fixtures retain original scoped outcomes",
  async () => {
    const h = await ready();
    await h.execute(report(await h.current(), [h.actors[0].actorId]),
      "report_visit_fixture");
    const samples: Record<string, unknown> = {};
    const sample = async (name: string) => {
      samples[name] = JSON.parse(JSON.stringify({review: await h.current(),
        session: {id: h.id, ...h.session,
          virtualStartedAtMillis: h.session.virtualStartedAt.toMillis(),
          virtualNowMillis: h.session.virtualNow.toMillis(),
          expiresAtMillis: h.session.expiresAt.toMillis()}, actors: h.actors}));
    };
    await sample("initial");
    const modules = h.session.setup.moduleIds;
    h.session.setup.moduleIds = modules.filter((m) => m !== "accountability");
    await sample("withoutSweep");
    h.session.setup.moduleIds = modules;
    await h.execute(checkpointVisit(await h.current(), h.actors[1].actorId),
      "checkpoint_visit_fixture");
    await sample("resolved");
    await h.execute(checkpointVisit(await h.current(), h.actors[1].actorId,
      "unresolved"), "checkpoint_visit_clear");
    await sample("unresolved");
    h.leave(1); h.arrive(1); h.session.runtimeRevision++;
    await sample("newVisit");
    const path = "../test/event_rehearsal/fixtures/checkpoint_visits.json";
    if (process.env.UPDATE_REHEARSAL_CHECKPOINT_VISIT_FIXTURE === "1") {
      writeFileSync(path, JSON.stringify(samples, null, 2) + "\n");
    }
    assert.deepEqual(JSON.parse(readFileSync(path, "utf8")), samples);
  });

test("transferred guests remain resolvable by the original group sweep",
  async () => {
    const h = room();
    await h.execute(departure(await h.read({groupId: "easy"}),
      h.actors.map((a) => a.actorId), true));
    const scope = {groupId: "easy", progressRevision: 1};
    await h.execute(report(await h.read(scope), [h.actors[0].actorId]));
    const transfer = (decision: Decision, authority = h.authority) => {
      const row = practiceMembershipView(h.session, h.actors[1], authority);
      h.actors[1] = transferPracticeMembership(h.session, h.actors[1], {
        kind: "transferGroup", actorId: row.attendeeId,
        expectedSourceHash: row.sourceHash,
        payload: {attendeeId: row.attendeeId, episodeId: row.episodeId!,
          expectedMembershipRevision: row.revision,
          expectedParticipationRevision: row.participationRevision, decision}},
      authority, "transfer_checkpoint_" + row.revision);
      h.session.runtimeRevision++; h.session.actionCount++;
    };
    transfer({kind: "propose", from: "easy", to: "fast",
      receivingOperatorId: receiver, expiresAtMillis: 5000});
    transfer({kind: "accept",
      transferId: h.actors[1].groupMembership!.transfer!.transferId},
    role(h, receiver));
    assert.equal(h.actors[1].groupMembership?.accepted?.groupId, "fast");
    const authority = role(h, sweep);
    assert.equal(practiceAccountabilityView(h.session, h.actors[1],
      authority).canResolve, false);
    const original = await roleRead(h, authority, scope);
    assert.equal(original.checkpoint!.accountabilityReviews![1].canResolve,
      true);
    const pending = checkpointVisit(original, h.actors[1].actorId);
    const change = await h.db.runTransaction(async (tx) => {
      const change = await preparePracticeMovementCommand(h.db, tx, h.id,
        h.session, h.actors, pending, authority, "original_sweep_visit");
      change.commit(); return change;
    });
    for (const actor of change.actorChanges ?? []) {
      h.actors[h.actors.findIndex((a) => a.actorId === actor.actorId)] = actor;
    }
    h.session.runtimeRevision++; h.session.actionCount++;
    const after = await roleRead(h, authority, scope);
    assert.equal(after.checkpoint!.accountabilityReviews![1].disposition,
      "departed");
    assert.deepEqual(after.selected, original.selected);
    assert.equal(h.actors[1].groupMembership?.accepted?.groupId, "fast");
  });

test("legacy actors without visit proof remain readable but cannot resolve",
  async () => {
    const h = await ready();
    delete h.actors[1].visit;
    const current = await h.current();
    const row = current.checkpoint!.accountabilityReviews![1];
    assert.equal(row.canResolve, false);
    assert.deepEqual(row.availability,
      {kind: "unavailable", reason: "visitChanged"});
    await assert.rejects(h.execute(checkpointVisit(current,
      h.actors[1].actorId)), {code: "failed-precondition"});
    assert.equal(h.actors[1].visit, undefined);
  });

test("checkpoint visits do not require enabling the general sweep module",
  async () => {
    const h = await ready();
    h.session.setup.moduleIds = h.session.setup.moduleIds.filter((m) =>
      m !== "accountability");
    await h.execute(report(await h.current(), [h.actors[0].actorId]));
    assert.equal(practiceAccountabilityView(h.session, h.actors[1])
      .canResolve, false);
    const before = await h.current();
    assert.equal(before.checkpoint!.accountabilityReviews![1].canResolve, true);
    await h.execute(checkpointVisit(before, h.actors[1].actorId));
    const after = await h.current();
    assert.equal(after.checkpoint!.accountabilityReviews![1].disposition,
      "departed");
    assert.deepEqual(after.checkpoint!.closeout!.eligibility, {kind: "ready"});
    assert.deepEqual(after.selected, before.selected);
  });
