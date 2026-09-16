import {reassign, closeout, resolve, ready} from
  "./movementManagementTestFixtures";
import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync, writeFileSync} from "node:fs";
import {randomUUID} from "node:crypto";
import * as admin from "firebase-admin";
import {operationContentHash as hash} from "../operations/durableActions";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {departure, report} from "./movementTestFixtures";
import {practiceMovementSource} from "./movementSource";
import {parsePracticeMovement} from "./movementRecords";

for (const group of [false, true]) {
  test("reassignment preserves evidence for " +
    (group ? "pace group" : "itinerary"),
  async () => {
    const h = await ready(group);
    const before = await h.current();
    const pendingReport = report(before, [h.actors[0].actorId]);
    const actorHash = hash(JSON.parse(JSON.stringify(h.actors)));
    await h.execute(reassign(before));
    const after = await h.current();
    assert.deepEqual(after.selected?.departure, before.selected?.departure);
    assert.equal(after.checkpoint?.sourceHash, before.checkpoint?.sourceHash);
    assert.equal(after.checkpoint?.revision, 0);
    assert.equal(after.checkpoint?.request?.responsibleOperatorId, "host-1");
    assert.equal(after.checkpoint?.request?.dueAt,
      before.checkpoint?.request?.dueAt);
    assert.equal(after.selected?.assignment?.reason,
      "Taking over the report.");
    assert.equal(hash(JSON.parse(JSON.stringify(h.actors))), actorHash);
    await h.execute(pendingReport);
    await assert.rejects(h.execute(reassign(before)), {code: "aborted"});
    const current = await h.current();
    await assert.rejects(h.execute(reassign(current)),
      {code: "failed-precondition"});
    await assert.rejects(h.execute(reassign(current, "outsider")),
      {code: "permission-denied"});
  });
}

test("only a report plus post-departure dispositions can close the request",
  async () => {
    const h = await ready();
    let r = await h.current();
    resolve(h);
    await assert.rejects(h.execute(closeout(await h.current())),
      {code: "failed-precondition"});
    await h.execute(report(r, [h.actors[0].actorId]));
    r = await h.current();
    assert.deepEqual(r.checkpoint?.closeout?.eligibility, {kind: "ready"});
    const observations = report(r, h.actors.map((a) => a.actorId));
    const actorHash = hash(JSON.parse(JSON.stringify(h.actors)));
    await h.execute(closeout(r));
    const closed = await h.current();
    assert.equal(closed.checkpoint?.request?.state, "closedOut");
    assert.equal(closed.checkpoint?.request?.ownerAvailability, "notRequired");
    assert.equal(closed.checkpoint?.sourceHash, r.checkpoint?.sourceHash);
    assert.deepEqual(closed.selected?.report, r.selected?.report);
    assert.equal(closed.selected?.report?.accountedFor.length, 1);
    assert.equal(hash(JSON.parse(JSON.stringify(h.actors))), actorHash);
    await assert.rejects(h.execute(reassign(closed)),
      {code: "failed-precondition"});
    await assert.rejects(h.execute(closeout(closed)),
      {code: "failed-precondition"});
    await h.execute(closeout(closed, "reopen"));
    assert.equal((await h.current()).checkpoint?.request?.state, "discrepancy");
    await h.execute(observations);
    r = await h.current();
    assert.deepEqual(r.checkpoint?.closeout?.state, {kind: "superseded"});
    await assert.rejects(h.execute(closeout(r, "reopen")),
      {code: "failed-precondition"});
    await assert.rejects(h.execute(reassign(r)), {code: "failed-precondition"});
  });

test("closure becomes reviewable again when visit or resolution proof changes",
  async () => {
    const h = await ready();
    await h.execute(report(await h.current(), [h.actors[0].actorId]));
    const unresolved = await h.current();
    assert.deepEqual(unresolved.checkpoint?.closeout?.eligibility,
      {kind: "unavailable", reason: "unresolvedMembers",
        attendeeIds: [h.actors[1].actorId]});
    const arrivalHash = unresolved.checkpoint!.sourceHash;
    resolve(h);
    assert.equal((await h.current()).checkpoint?.sourceHash, arrivalHash);
    await assert.rejects(h.execute(closeout(unresolved)), {code: "aborted"});
    await h.execute(closeout(await h.current()));
    resolve(h, 1, "returned");
    assert.deepEqual((await h.current()).checkpoint?.closeout?.state,
      {kind: "needsReview", reason: "dispositionChanged"});
    await h.execute(closeout(await h.current()));
    h.leave(1); h.arrive(1);
    const changed = await h.current();
    assert.equal(changed.checkpoint?.request?.state, "discrepancy");
    await assert.rejects(h.execute(closeout(changed)),
      {code: "failed-precondition"});
    await h.execute(closeout(changed, "reopen"));
    assert.deepEqual((await h.current()).checkpoint?.closeout?.state,
      {kind: "reopened"});
  });

test("old legs, completion, setup changes and original deadlines stay explicit",
  async () => {
    const h = await ready();
    await h.execute(report(await h.current(), [h.actors[0].actorId]));
    resolve(h);
    await h.execute(closeout(await h.current()));
    await h.execute(departure(await h.current(), []));
    const scope = {...h.scope, progressRevision: 1};
    h.session.status = "complete";
    h.session.virtualNow = admin.firestore.Timestamp.fromMillis(100000);
    const r = await h.read(scope);
    await h.execute(closeout(r, "reopen"));
    await h.execute(reassign(await h.read(scope)));
    assert.equal((await h.read(scope)).checkpoint?.request?.dueAt, 61000);
    assert.equal((await h.current()).selected?.assignment, undefined);
    const before = await h.read(scope);
    h.session.setup.locationName += " changed";
    await assert.rejects(h.execute(closeout(before)), {code: "aborted"});
    const after = await h.read(scope);
    assert.equal(after.checkpoint?.request?.state, "sourceUnavailable");
    await assert.rejects(h.execute(closeout(after)),
      {code: "failed-precondition"});
  });

test("a resolution from before a later departure cannot close its checkpoint",
  async () => {
    const h = await ready();
    resolve(h);
    h.session.virtualNow = admin.firestore.Timestamp.fromMillis(2000);
    await h.execute(departure(await h.current(),
      h.actors.map((a) => a.actorId), true));
    await h.execute(report(await h.current(), [h.actors[0].actorId]));
    const r = await h.current();
    if (r.checkpoint?.availability.kind !== "ready") assert.fail("No roster");
    assert.deepEqual(r.checkpoint.availability.members[1].disposition,
      {kind: "unavailable", reason: "beforeDeparture"});
    await assert.rejects(h.execute(closeout(r)), {code: "failed-precondition"});
    resolve(h);
    await h.execute(closeout(await h.current()));
    assert.equal((await h.current()).checkpoint?.request?.state, "closedOut");
  });

test("stored management cannot forge roster coverage, time or revision",
  async () => {
    const h = await ready();
    await h.execute(reassign(await h.current()));
    await h.execute(report(await h.current(), [h.actors[0].actorId]));
    resolve(h); await h.execute(closeout(await h.current()));
    const record = (await h.current()).selected!;
    const source = practiceMovementSource(h.id, h.session, h.scope.groupId);
    for (const mutate of [
      (r: typeof record) => {
 r.assignment!.assignedAt = -1;
      },
      (r: typeof record) => {
 r.assignment!.previousResponsibleOperatorId = "bad";
      },
      (r: typeof record) => {
 r.closeout!.previousRevision = 20;
      },
      (r: typeof record) => {
 r.closeout!.operationId = r.assignment!.operationId;
      },
      (r: typeof record) => {
        if (r.closeout!.decision.kind === "close") {
          r.closeout!.decision.dispositions[0].attendeeId = "outsider";
        }
      },
      (r: typeof record) => {
        if (r.closeout!.decision.kind === "close") {
          r.closeout!.decision.report.rosterHash = "a".repeat(64);
        }
      },
    ]) {
      const copy = structuredClone(record); mutate(copy);
      assert.throws(() => parsePracticeMovement(copy, source));
    }
    const commands = [reassign(await h.current()), closeout(await h.current())];
    for (const command of commands) {
      const input = {sessionId: h.id, expectedSetupRevision: 0,
        expectedRevision: h.session.runtimeRevision,
        clientActionId: randomUUID(),
        action: "movement", movement: command};
      assert.equal(validateControlEventRehearsalCallablePayload(input), true);
      assert.equal(validateControlEventRehearsalCallablePayload({...input,
        movement: {...command, payload: {...command.payload, dueAt: 1000}}}),
      false);
    }
  });

test("native checkpoint management fixtures use actual execution evidence",
  async () => {
    const h = await ready();
    const samples: Record<string, unknown> = {};
    const sample = async (name: string) => {
      const review = await h.current();
      samples[name] = JSON.parse(JSON.stringify({review, session: {
        id: h.id, ...h.session,
        virtualStartedAtMillis: h.session.virtualStartedAt.toMillis(),
        virtualNowMillis: h.session.virtualNow.toMillis(),
        expiresAtMillis: h.session.expiresAt.toMillis()}, actors: h.actors}));
    };
    await sample("departed");
    await h.execute(reassign(await h.current()), "assignment_0001");
    await sample("reassigned");
    await h.execute(report(await h.current(), [h.actors[0].actorId]),
      "report_0001");
    await sample("partial");
    resolve(h); await sample("resolved");
    await h.execute(closeout(await h.current()), "closeout_0001");
    await sample("closed");
    resolve(h, 1, "returned"); await sample("needsReview");
    await h.execute(closeout(await h.current(), "reopen"), "closeout_0002");
    await sample("reopened");
    await h.execute(closeout(await h.current()), "closeout_0003");
    await h.execute(report(await h.current(), h.actors.map((a) => a.actorId)),
      "report_0002");
    await sample("complete");
    const path = "../test/event_rehearsal/fixtures/checkpoint_management.json";
    if (process.env.UPDATE_REHEARSAL_MOVEMENT_FIXTURE === "1") {
      writeFileSync(path, JSON.stringify(samples, null, 2) + "\n");
    }
    assert.deepEqual(JSON.parse(readFileSync(path, "utf8")), samples);
  });
