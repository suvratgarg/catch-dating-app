import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {room, assign, role, roleRead, roleMove, sweep, receiver} from
  "./groupStaffTestFixtures";
import {departure, report} from "./movementTestFixtures";
import {reassign} from "./movementManagementTestFixtures";

async function setup() {
  const h = room();
  const before = await roleRead(h, h.authority);
  const command = departure(before, h.actors.map((a) => a.actorId), true);
  await roleMove(h, command, h.authority);
  return {...h, current: () => roleRead(h, h.authority)};
}

test("practice choices require the original group and deadline",
  async () => {
    const h = await setup();
    const dueAt = (await h.current()).checkpoint!.request!.dueAt;
    assign(h, "practice-staff:short", "easy", "sweep", dueAt);
    assign(h, "practice-staff:valid", "easy", "sweep", dueAt + 1);
    const options = (await h.current()).checkpoint!.reporterOptions!;
    assert.equal(options.actorUid, h.authority.actorUid);
    const ids = options.reporters.map((r) => r.operatorId);
    assert.ok(ids.includes(sweep));
    assert.ok(ids.includes("practice-staff:valid"));
    assert.ok(!ids.includes("practice-staff:short"));
    assert.ok(!ids.includes(receiver));
    assert.equal((await roleRead(h, role(h, sweep))).checkpoint!
      .reporterOptions, null);
    const before = await h.current();
    const command = reassign(before, "practice-staff:valid");
    h.session.virtualNow = Timestamp.fromMillis(dueAt + 1);
    assert.ok(!(await h.current()).checkpoint!.reporterOptions!.reporters
      .some((r) => r.operatorId === "practice-staff:valid"));
    await assert.rejects(roleMove(h, command, h.authority));
    assert.equal((await h.current()).checkpoint!.request!.dueAt, dueAt);
  });

test("complete reports and exhausted sessions offer no choices",
  async () => {
    const h = await setup();
    const before = await h.current();
    const reportCommand = report(before, h.actors.map((a) => a.actorId));
    await roleMove(h, reportCommand, h.authority);
    assert.equal((await h.current()).checkpoint!.reporterOptions, null);
    await roleMove(h, report(await h.current(), [], "Correction"), h.authority);
    assert.ok((await h.current()).checkpoint!.reporterOptions);
    h.session.actionCount = 500;
    assert.equal((await h.current()).checkpoint!.reporterOptions, null);
  });


test("shortening the current reporter duty requires reassignment", async () => {
  const h = await setup();
  await roleMove(h, reassign(await h.current(), sweep), h.authority);
  const dueAt = (await h.current()).checkpoint!.request!.dueAt;
  assign(h, sweep, "easy", "sweep", dueAt);
  const checkpoint = (await h.current()).checkpoint!;
  assert.equal(checkpoint.request!.ownerAvailability, "needsReassignment");
  assert.equal(checkpoint.request!.dueAt, dueAt);
  assert.ok(!checkpoint.reporterOptions!.reporters.some((r) =>
    r.operatorId === sweep));
});
