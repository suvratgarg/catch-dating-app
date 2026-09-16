import assert from "node:assert/strict";
import test from "node:test";
import {EventCheckpointStore} from "./checkpointStore";
import {departureRosterHarness} from "./departureRosterTestFixtures";
import {progressFixtureManager as manager} from "./groupProgressTestFixtures";
import {eventStaffGrantId} from "../../shared/eventOperatorAuthority";
import {validateEventAssistanceCheckpointCallableResponse} from
  "../../shared/generated/validators/eventAssistanceCheckpointOutput";

async function setup() {
  const h = await departureRosterHarness();
  const input = await h.command();
  const dueAt = h.clock.now + 30_000;
  const result = await h.progress.confirmDeparture(manager, {...input,
    command: {...input.command, payload: {...input.command.payload,
      checkpointRequest: {responsibleOperatorId: manager, dueAt}}}});
  const scope = {context: h.scope.context, groupId: h.scope.groupId,
    checkpointId: "one", progressRevision: result.view.revision};
  const store = new EventCheckpointStore(h.db, () => h.clock.now);
  return {...h, dueAt, scope, store,
    view: async () => (await store.get(manager, scope)).view};
}

test("reporter choices require this group's duty through its original deadline",
  async () => {
    const h = await setup();
    await h.grant("sweep", h.scope.groupId, "sweep", h.dueAt + 1);
    await h.grant("short", h.scope.groupId, "sweep", h.dueAt);
    const result = await h.store.get(manager, h.scope);
    assert.equal(validateEventAssistanceCheckpointCallableResponse(result),
      true);
    const options = result.view.reporterOptions!;
    assert.equal(options.actorUid, manager);
    assert.equal(options.sourceHash, result.view.assignment!.sourceHash);
    assert.equal(options.validUntil, h.clock.now + 1_800_000);
    assert.ok(options.reporters.some((r) => r.operatorId === manager));
    assert.ok(options.reporters.some((r) => r.operatorId === "sweep"));
    assert.ok(!options.reporters.some((r) => r.operatorId === "short"));
    assert.ok(options.reporters.every((r) => r.validUntil > h.dueAt));
    assert.ok(options.reporters.every((r) =>
      Object.keys(r).sort().join() === "displayName,operatorId,validUntil"));
    const staff = await h.store.get("sweep", h.scope);
    assert.equal(staff.view.reporterOptions, null);
  });

test("later expiry removes a choice without changing the departure deadline",
  async () => {
    const h = await setup();
    await h.grant("sweep", h.scope.groupId, "sweep", h.dueAt + 1);
    h.clock.now = h.dueAt + 1;
    const view = await h.view();
    assert.equal(view.request!.dueAt, h.dueAt);
    assert.equal(view.request!.state, "overdue");
    assert.ok(!view.reporterOptions!.reporters.some((r) =>
      r.operatorId === "sweep"));
  });

test("revoked and malformed current staff cannot become reporter choices",
  async () => {
    const h = await setup();
    await h.grant("sweep", h.scope.groupId, "sweep", h.dueAt + 100);
    const path = "eventStaffGrants/" +
      eventStaffGrantId(h.scope.context.eventId, "sweep");
    const grant = await h.read(path);
    await h.put(path, {...grant, status: "revoked"});
    assert.ok(!(await h.view()).reporterOptions!.reporters.some((r) =>
      r.operatorId === "sweep"));
    await h.put(path, {...grant, uid: "wrong"});
    await assert.rejects(h.view());
  });

test("bounded reporter discovery refuses incomplete lists",
  async () => {
    const h = await setup();
    await h.grant("template", h.scope.groupId, "sweep", h.dueAt + 100);
    const original = await h.read("eventStaffGrants/" +
      eventStaffGrantId(h.scope.context.eventId, "template"));
    for (let i = 0; i < 50; i++) {
      const uid = "extra-" + i;
      await h.put("eventStaffGrants/" +
        eventStaffGrantId(h.scope.context.eventId, uid), {...original, uid});
    }
    await assert.rejects(h.view());
  });

test("a backwards read clock cannot authorize a fresh reporter choice",
  async () => {
    const h = await setup();
    let ticks = 0;
    const store = new EventCheckpointStore(h.db,
      () => h.clock.now - ticks++);
    await assert.rejects(store.get(manager, h.scope));
  });
