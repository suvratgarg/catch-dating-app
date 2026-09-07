import assert from "node:assert/strict";
import {mkdtemp, readFile, rm, writeFile} from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {main} from "../src/cli/main.mjs";
import {OperationsEngine} from "../src/platform/engine.mjs";
import {FileOperationsStore} from "../src/platform/storage/file-store.mjs";
import {EventAssistanceWorkflow} from "../src/workflows/event-assistance/workflow.mjs";
import {workflowDescriptor} from "../src/workflows/registry.mjs";

function input() {
  return {
    context: {mode: "live", eventId: "event-1", organizerId: "organizer-1"},
    eventId: "event-1",
    eventOpen: true,
    departureConfirmed: true,
    now: 1000000,
    setting: {
      kind: "enabled",
      authority: "executeWithinPolicy",
      policyVersion: "v1",
    },
    policy: {
      destination: {
        kind: "itineraryStop",
        itineraryId: "itinerary-1",
        permittedStopIds: ["stop-1", "stop-2"],
      },
      cutoff: {kind: "time", at: 2000000},
      maxMessagesPerEpisode: 4,
      minimumMinutesBetweenMessages: 5,
      updateOn: "materialGuidanceChange",
      unanswered: "keepUnknownUntilCutoff",
    },
    guest: {
      attendeeId: "guest-1",
      episodeId: "episode-1",
      admission: "admitted",
      attendance: {
        kind: "known",
        value: {checkedIn: false},
        revision: 1,
        observedAt: 900000,
        source: "host",
      },
      intention: {kind: "unknown"},
      deliveryEligibility: "eligible",
    },
    guidance: {
      kind: "known",
      revision: 1,
      observedAt: 900000,
      source: "host",
      value: {
        revision: 1,
        destination: {
          kind: "itineraryStop",
          itineraryId: "itinerary-1",
          stopId: "stop-1",
        },
        materialKey: "stop-1-revision-1",
        text: "Meet us at the first stop.",
        validUntil: 2000000,
      },
    },
    lastMessage: null,
    messagesThisEpisode: 0,
  };
}

const now = new Date(1_000_000).toISOString();

async function workspace(t) {
  const directory = await mkdtemp(path.join(os.tmpdir(), "catch-assistance-"));
  t.after(() => rm(directory, {recursive: true, force: true}));
  return directory;
}

test("registered factory evaluates the shared policy into meaningful stages", () => {
  const workflow = workflowDescriptor("event-assistance").createWorkflow();
  const ordinary = input();
  const arrived = input();
  arrived.guest.attendeeId = "arrived";
  arrived.guest.attendance.value.checkedIn = true;
  const unknown = input();
  unknown.guest.attendeeId = "unknown";
  unknown.guest.attendance = {kind: "unknown", reason: "sourceUnavailable"};
  const unreachable = input();
  unreachable.guest.attendeeId = "unreachable";
  unreachable.guest.deliveryEligibility = "unreachable";
  const expired = input();
  expired.guest.attendeeId = "expired";
  expired.policy.cutoff.at = expired.now;
  const disabled = input();
  disabled.guest.attendeeId = "disabled";
  disabled.setting = {kind: "disabled", reason: "hostChoice"};
  const plan = workflow.createPlan({
    inputs: [ordinary, arrived, unknown, unreachable, expired, disabled], now,
  });
  const decisions = Object.fromEntries(workflow.project(plan, {runId: "run:1", now})
    .map((item) => [item.raw.input.guest.attendeeId, workflow.review(item, {now})]));
  assert.equal(decisions["guest-1"].primaryStage, "ready");
  assert.equal(decisions.arrived.lifecycleStatus, "resolved");
  assert.equal(decisions.unknown.primaryStage, "waiting");
  assert.equal(decisions.unreachable.owner, "human");
  assert.deepEqual(decisions.unreachable.taskFlags, ["human_review_required"]);
  assert.equal(decisions.expired.lifecycleStatus, "expired");
  assert.equal(decisions.disabled.lifecycleStatus, "cancelled");
  for (const decision of Object.values(decisions)) {
    assert.equal(decision.decisionProvenance.effectDisposition, "shadow_only");
  }
  assert.deepEqual(plan.capabilities, {
    network: false, modelCalls: false, publicWrites: false, ruleDeployment: false,
  });
  assert.equal(workflowDescriptor("supply-intake").capabilities.publicWrites, false);
});

test("plan validation binds inputs, context, policy clock and authority ceiling", () => {
  const workflow = new EventAssistanceWorkflow();
  const plan = workflow.createPlan({inputs: [input()], now});
  for (const mutate of [
    (changed) => { changed.mode = "autonomous"; },
    (changed) => { changed.budgets.publicWrites = 1; },
    (changed) => { changed.capabilities.network = true; },
    (changed) => { changed.inputs[0].guidance.value.text = "Changed"; },
    (changed) => { changed.workflowContract.primaryStages.push("invented"); },
  ]) {
    const changed = structuredClone(plan);
    mutate(changed);
    assert.throws(() => workflow.assertPlan(changed), {code: "ASSISTANCE_PLAN_DRIFT"});
  }
  assert.throws(() => workflow.createPlan({inputs: [input(), input()], now}),
    {code: "DUPLICATE_ASSISTANCE_EPISODE"});
  const other = input();
  other.context.organizerId = "another-organizer";
  assert.throws(() => workflow.createPlan({inputs: [input(), other], now}),
    {code: "ASSISTANCE_CONTEXT_MISMATCH"});
  assert.throws(() => workflow.createPlan({inputs: [input()], now: new Date(0)}),
    {code: "ASSISTANCE_CLOCK_MISMATCH"});
  assert.throws(() => workflow.createPlan({inputs: [{...input(), extra: true}], now}),
    {code: "INVALID_ASSISTANCE_INPUT"});
});

test("same facts produce equivalent rehearsal decisions with isolated message keys", () => {
  const workflow = new EventAssistanceWorkflow();
  const live = input();
  const rehearsal = input();
  rehearsal.context = {mode: "rehearsal", rehearsalId: "practice-1",
    virtualEventId: rehearsal.eventId, clockId: "virtual-1"};
  const evaluate = (snapshot) => {
    const plan = workflow.createPlan({inputs: [snapshot], now});
    return workflow.review(workflow.project(plan, {runId: "run:1", now})[0], {now})
      .decisionProvenance.evaluation;
  };
  const liveDecision = evaluate(live);
  const rehearsalDecision = evaluate(rehearsal);
  assert.notEqual(liveDecision.messageKey, rehearsalDecision.messageKey);
  assert.deepEqual({...liveDecision, messageKey: null},
    {...rehearsalDecision, messageKey: null});
});

test("real operations engine persists and replays the registered workflow", async (t) => {
  const directory = await workspace(t);
  const store = await new FileOperationsStore(directory).initialize();
  const workflow = new EventAssistanceWorkflow();
  const plan = workflow.createPlan({inputs: [input()], now});
  const engine = new OperationsEngine({store, workflow, clock: () => now});
  const result = await engine.start(plan, {requestedRunId: "assistance:1"});
  assert.equal(result.run.status, "completed");
  let items = await store.listWorkItems({runId: result.run.runId});
  assert.equal(items.length, 1);
  assert.equal(items[0].primaryStage, "ready");
  const originalHash = result.run.inventoryHash;
  const restartedStore = await new FileOperationsStore(directory).initialize();
  const restarted = new OperationsEngine({store: restartedStore,
    workflow: new EventAssistanceWorkflow(), clock: () => now});
  const replay = await restarted.start(plan, {requestedRunId: "assistance:1"});
  assert.equal(replay.idempotentReplay, true);
  assert.equal(replay.run.inventoryHash, originalHash);
  items = await restartedStore.listWorkItems({runId: result.run.runId});
  assert.equal(items.length, 1);
  assert.equal(replay.run.budget.consumed.publicWrites, 0);
  assert.equal(replay.run.budget.consumed.networkRequests, 0);
});

test("CLI accepts assistance snapshots and exposes only implemented commands", async (t) => {
  const directory = await workspace(t);
  const inputPath = path.join(directory, "input.json");
  await writeFile(inputPath, JSON.stringify([input()]));
  const flags = ["--workflow", "event-assistance", "--state-dir", directory,
    "--now", now];
  const planned = await main(["plan", ...flags, "--input", inputPath]);
  const planPath = path.join(directory, "plan.json");
  await writeFile(planPath, JSON.stringify(planned.envelope.data.plan));
  const result = await main(["run", ...flags, "--plan", planPath, "--run", "cli:1"]);
  assert.equal(result.envelope.ok, true);
  const queue = await main(["queue", ...flags, "--run", "cli:1"]);
  assert.equal(queue.envelope.ok, true);
  const status = await main(["status", ...flags, "--run", "cli:1"]);
  assert.equal(status.envelope.ok, true);
  const resume = await main(["resume", ...flags, "--run", "cli:1"]);
  assert.equal(resume.envelope.ok, true);
  await assert.rejects(main(["promote", ...flags, "--run", "cli:1"]),
    {code: "WORKFLOW_COMMAND_UNSUPPORTED"});
  assert.deepEqual(JSON.parse(await readFile(inputPath, "utf8")), [input()]);
});
