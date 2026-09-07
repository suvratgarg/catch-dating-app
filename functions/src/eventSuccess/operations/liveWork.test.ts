import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import test from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore, Timestamp} from "firebase-admin/firestore";
import {operationCollections} from "../../operations/collections";
import {operationResourceLeaseId} from
  "../../operations/firestoreLeaseRepository";
import {validateOperationWorkItem} from "../../operations/validation";
import {LiveAssistanceWorkStore} from "./liveWorkStore";
import {LiveWork, liveWorkIds, readLiveWorkRecords} from "./liveWorkRecords";
import {EVENT_ASSISTANCE_MESSAGES} from "./firestoreMessageOutbox";
import {guestCollections, guestIdentity} from "./guestRecords";
import {setup} from "./liveLateJoinTestHarness";
import {start} from "./whatsappTestHarness";

async function workHarness(db?: Firestore) {
  const h = await setup(db);
  const store = new LiveAssistanceWorkStore(h.db, () => h.clock.now);
  const input = {scope: h.scope, options: h.options,
    expiresAt: start + 3_600_000, maxEvaluations: 100};
  const ids = liveWorkIds(input.scope);
  const acquire = (ownerId = "worker-1") => store.operations.acquireLease({
    leaseId: operationResourceLeaseId("work_item", ids.workItemId),
    resourceId: ids.workItemId, resourceType: "work_item", ownerId,
    idempotencyKey: randomUUID(),
    acquiredAt: new Date(h.clock.now).toISOString(),
    expiresAt: new Date(h.clock.now + 60_000).toISOString()});
  const advance = async () => store.evaluate(ids.workItemId,
    (await store.get(ids.workItemId)).item.revision, await acquire());
  return {...h, input, ids, work: store, acquire, advance};
}

test("live work initialization is atomic and retains frozen episode options",
  async () => {
    const h = await workHarness();
    const before = h.fake.entries();
    h.fake.failNextCommit = true;
    await assert.rejects(h.work.start(h.input), /interruption/);
    assert.deepEqual(h.fake.entries(), before);
    const first = await h.work.start(h.input);
    assert.equal(first.item.revision, 0);
    assert.equal(first.payload.checkpoint.dueAt, start);
    assert.equal((await h.work.start(h.input)).replayed, true);
    await assert.rejects(h.work.start({...h.input, maxEvaluations: 2}),
      {code: "work_configuration_conflict"});
    h.clock.now = h.input.expiresAt + 1;
    assert.equal((await h.work.start(h.input)).replayed, true,
      "a lost start response remains replayable after the event");
    assert.equal((await h.work.get(h.ids.workItemId)).item.revision, 0);
  });

test("live work rejects missing participation, foreign scope and rehearsal",
  async () => {
    for (const variant of ["missing", "foreign", "oldEpisode", "expiry",
      "rehearsal", "duplicateRoute"] as const) {
      const h = await workHarness();
      const input: typeof h.input = structuredClone(h.input);
      if (variant === "missing") {
        h.fake.remove(guestCollections.guests + "/" +
          guestIdentity(h.context, h.scope.attendeeId));
      }
      if (variant === "foreign") input.scope.context.organizerId = "another";
      if (variant === "oldEpisode") input.scope.episodeId = "old";
      if (variant === "expiry") input.expiresAt += 1;
      if (variant === "rehearsal") {
        (input.scope as unknown as {context: object}).context =
          {mode: "rehearsal", rehearsalId: "practice",
            virtualEventId: "virtual", clockId: "clock"};
      }
      if (variant === "duplicateRoute") {
        input.options.routes.push({...input.options.routes[0]});
      }
      const before = h.fake.entries();
      await assert.rejects(h.work.start(input), variant);
      assert.deepEqual(h.fake.entries(), before);
    }
  });

test("publication, run, checkpoint and receipt survive interruption together",
  async () => {
    const h = await workHarness();
    await h.work.start(h.input);
    const lease = await h.acquire();
    const before = h.fake.entries();
    h.fake.failNextCommit = true;
    await assert.rejects(h.work.evaluate(h.ids.workItemId, 0, lease),
      /interruption/);
    assert.deepEqual(h.fake.entries(), before);
    const first = await h.work.evaluate(h.ids.workItemId, 0, lease);
    assert.equal(first.kind, "committed");
    assert.equal(first.run.revision, 1);
    assert.equal(first.item.revision, 1);
    assert.equal(first.payload.checkpoint.evaluations, 1);
    const published = first.payload.checkpoint.publication!;
    assert.ok(published);
    assert.ok(await h.read(EVENT_ASSISTANCE_MESSAGES + "/" +
      published.messageId));
    assert.ok(await h.read(guestCollections.threads + "/" +
      published.threadId));
    assert.equal(first.run.counters.published, 1);
    assert.equal(first.run.counters.processed, 1);
    assert.ok(first.payload.checkpoint.dueAt! > start);
    h.clock.now += 60_000;
    const after = h.fake.entries();
    const restarted = new LiveAssistanceWorkStore(h.db, () => h.clock.now);
    assert.equal((await restarted.evaluate(h.ids.workItemId, 0, lease)).kind,
      "replayed");
    assert.deepEqual(h.fake.entries(), after);
  });

test("signals wake waiting work once and old evaluations remain replayable",
  async () => {
    const h = await workHarness();
    await h.work.start(h.input);
    const lease = await h.acquire();
    await h.work.evaluate(h.ids.workItemId, 0, lease);
    h.clock.now += 1000;
    const idle = await h.work.evaluate(h.ids.workItemId, 1, lease);
    assert.equal(idle.kind, "idle");
    const oldMessage = idle.payload.checkpoint.publication!.messageId;
    const wake = await h.work.wake(h.ids.workItemId, 1, "departure-2", lease);
    assert.equal(wake.payload.checkpoint.dueAt, h.clock.now);
    assert.equal(wake.payload.checkpoint.evaluations, 1);
    await h.progress.confirm("two");
    const next = await h.work.evaluate(h.ids.workItemId, 2, lease);
    assert.notEqual(next.payload.checkpoint.publication!.messageId, oldMessage);
    assert.equal(next.run.counters.published, 2);
    const before = h.fake.entries();
    const duplicate = await h.work.wake(h.ids.workItemId, 3,
      "departure-2", lease);
    assert.equal(duplicate.kind, "replayed");
    assert.equal(duplicate.item.revision, 3);
    assert.equal((await h.work.evaluate(h.ids.workItemId, 0, lease)).kind,
      "replayed");
    assert.deepEqual(h.fake.entries(), before);
    await assert.rejects(h.work.wake(h.ids.workItemId, 1, "new", lease),
      {code: "revision_conflict"});
  });

test("cooldown and unanswered deadlines persist exact future evaluation times",
  async () => {
    const h = await workHarness();
    await h.configure({...h.template, config: {...h.template.config,
      unanswered: "hostReviewAtDeadline"}});
    const input = {...h.input, options: {...h.options,
      responseDeadline: start + 900_000}};
    await h.work.start(input);
    const lease = await h.acquire();
    const first = await h.work.evaluate(h.ids.workItemId, 0, lease);
    assert.equal(first.payload.checkpoint.dueAt, start + 900_000);
    const published = await h.publisher.publish(h.scope, input.options);
    assert.ok(published.kind === "published");
    const delivery = await h.delivery(published);
    assert.equal((await delivery.claim()).kind, "claimed");
    await h.progress.confirm("two");
    await h.work.wake(h.ids.workItemId, 1, "departure", lease);
    const throttled = await h.work.evaluate(h.ids.workItemId, 2, lease);
    assert.equal(throttled.payload.checkpoint.dueAt, start + 600_000);
    assert.equal(throttled.payload.checkpoint.observation?.kind, "decision");
    h.clock.now = start + 900_000;
    const deadline = await h.work.evaluate(h.ids.workItemId, 3,
      await h.acquire());
    assert.equal(deadline.item.primaryStage, "host_review");
    assert.deepEqual(deadline.item.taskFlags, ["human_review_required"]);
  });

test("work cap holds for review; expiry can still close an overdue item",
  async () => {
    const h = await workHarness();
    await h.work.start({...h.input, maxEvaluations: 1});
    let lease = await h.acquire();
    await h.work.evaluate(h.ids.workItemId, 0, lease);
    await h.work.wake(h.ids.workItemId, 1, "change", lease);
    const capped = await h.work.evaluate(h.ids.workItemId, 2, lease);
    assert.deepEqual(capped.payload.checkpoint.observation,
      {kind: "evaluationLimit"});
    assert.equal(capped.payload.checkpoint.evaluations, 1);
    assert.deepEqual(capped.item.taskFlags, ["human_review_required"]);
    assert.equal(capped.payload.checkpoint.dueAt, h.input.expiresAt);
    const wake = await h.work.wake(h.ids.workItemId, 3, "more-change", lease);
    assert.equal(wake.payload.checkpoint.dueAt, h.input.expiresAt);
    assert.equal((await h.work.evaluate(h.ids.workItemId, 4, lease)).kind,
      "idle");
    h.clock.now = h.input.expiresAt + 1;
    lease = await h.acquire("replacement");
    const closed = await h.work.evaluate(h.ids.workItemId, 4, lease);
    assert.equal(closed.run.status, "completed");
    assert.equal(closed.item.lifecycleStatus, "terminal");
    assert.equal(closed.payload.checkpoint.dueAt, null);
    assert.equal(closed.run.counters.published, 1);
    assert.equal((await h.work.wake(h.ids.workItemId, 5, "late", lease)).kind,
      "idle");
    assert.deepEqual(await h.work.listDue(10), []);
  });

test("disabled policy and missing deadlines are explicit persisted outcomes",
  async () => {
    for (const state of ["disabled", "deadline"] as const) {
      const h = await workHarness();
      await h.work.start(h.input);
      await h.configure(state === "disabled" ? "disabled" :
        {...h.template, config: {...h.template.config,
          unanswered: "hostReviewAtDeadline"}});
      const before = h.fake.entries().filter(([path]) =>
        path.startsWith(EVENT_ASSISTANCE_MESSAGES + "/"));
      const result = await h.work.evaluate(h.ids.workItemId, 0,
        await h.acquire());
      assert.deepEqual(result.payload.checkpoint.observation,
        state === "disabled" ? {kind: "sourceNotReady", reason: "disabled"} :
          {kind: "responseDeadlineMissing"});
      assert.equal(result.payload.checkpoint.publication, null);
      assert.deepEqual(h.fake.entries().filter(([path]) =>
        path.startsWith(EVENT_ASSISTANCE_MESSAGES + "/")), before);
    }
  });

test("expiry before first evaluation closes work without consulting providers",
  async () => {
    const h = await workHarness();
    await h.work.start(h.input);
    h.clock.now = h.input.expiresAt;
    h.fake.remove(h.senderPath);
    const result = await h.work.evaluate(h.ids.workItemId, 0,
      await h.acquire());
    assert.equal(result.run.status, "completed");
    assert.equal(result.payload.checkpoint.evaluations, 0);
    assert.deepEqual(result.payload.checkpoint.observation,
      {kind: "workExpired"});
    assert.equal(result.payload.checkpoint.publication, null);
  });

test("replaced leases and clocks expiring during preparation leave no effects",
  async () => {
    for (const boundary of ["fence", "clock"] as const) {
      const h = await workHarness();
      await h.work.start(h.input);
      const lease = await h.acquire();
      if (boundary === "fence") {
        h.clock.now += 60_000;
        await h.acquire("replacement");
      } else {
        h.fake.beforeRead = (path) => {
          if (path === operationCollections.leases + "/" + lease.leaseId) {
            h.clock.now += 60_000;
          }
        };
      }
      const before = h.fake.entries();
      await assert.rejects(h.work.evaluate(h.ids.workItemId, 0, lease));
      assert.deepEqual(h.fake.entries(), before);
    }
  });

test("strict live-work binding rejects shadow runs and checkpoint drift",
  async () => {
    const h = await workHarness();
    const original = await h.work.start(h.input);
    assert.ok(validateOperationWorkItem(original.item).ok);
    const damaged = structuredClone(original.item);
    (damaged.normalizedPayload as unknown as LiveWork).checkpoint.dueAt = null;
    assert.throws(() => readLiveWorkRecords(original.run, damaged,
      damaged.workItemId, start));
    assert.throws(() => readLiveWorkRecords({...original.run, mode: "shadow"},
      original.item, original.item.workItemId, start));
    assert.throws(() => readLiveWorkRecords({...original.run, revision: 1},
      original.item, original.item.workItemId, start));
    damaged.normalizedPayload = {...original.item.normalizedPayload,
      unexpectedProviderAuthority: true};
    assert.equal(validateOperationWorkItem(damaged).ok, false);
    const lease = await h.acquire();
    const committed = await h.work.evaluate(h.ids.workItemId, 0, lease);
    await h.write(operationCollections.workItems + "/" + h.ids.workItemId,
      {...committed.item, warningCodes: ["tampered"]});
    await assert.rejects(h.work.evaluate(h.ids.workItemId, 0, lease),
      {code: "action_checkpoint_drift"});
  });

test("bounded due discovery excludes waiting and completed work", async () => {
  const h = await workHarness();
  await h.work.start(h.input);
  assert.deepEqual(await h.work.listDue(1),
    [{workItemId: h.ids.workItemId, revision: 0}]);
  await h.work.evaluate(h.ids.workItemId, 0, await h.acquire());
  assert.deepEqual(await h.work.listDue(10), []);
  for (const limit of [0, 101, 1.5]) {
    await assert.rejects(h.work.listDue(limit));
  }
});

test("Firestore serializes live checkpoints and queries persisted due work", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST, timeout: 60_000,
}, async () => {
  assert.match(process.env.FIRESTORE_EMULATOR_HOST ?? "",
    /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/);
  const app = initializeApp({projectId: "demo-catch-rules"}, randomUUID());
  try {
    const h = await workHarness(getFirestore(app));
    const starts = await Promise.all([h.work.start(h.input),
      h.work.start(h.input)]);
    assert.equal(starts.filter((s) => s.replayed).length, 1);
    const due = await h.work.listDue(100);
    assert.ok(due.some((i) => i.workItemId === h.ids.workItemId));
    const lease = await h.acquire();
    const results = await Promise.all([
      h.work.evaluate(h.ids.workItemId, 0, lease),
      h.work.evaluate(h.ids.workItemId, 0, lease)]);
    assert.equal(results.filter((r) => r.kind === "committed").length, 1);
    assert.equal(results.filter((r) => r.kind === "replayed").length, 1);
    assert.ok(!(await h.work.listDue(100)).some((i) =>
      i.workItemId === h.ids.workItemId));
    await h.write(h.attendeePath, {...await h.read(h.attendeePath),
      status: "checkedIn", checkedInAt: Timestamp.fromMillis(start),
      checkedInBy: "host-1", attendanceRevision: 1});
    await h.work.wake(h.ids.workItemId, 1, "check-in", lease);
    const closed = await h.work.evaluate(h.ids.workItemId, 2, lease);
    assert.equal(closed.item.outcome, "resolved");
    assert.equal(closed.payload.checkpoint.dueAt, null);
    const receipts = await getFirestore(app).collection(
      operationCollections.actionReceipts).where("workItemId", "==",
      h.ids.workItemId).get();
    assert.equal(receipts.size, 3);
  } finally {
    await deleteApp(app);
  }
});
