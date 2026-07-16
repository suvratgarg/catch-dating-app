import assert from "node:assert/strict";
import test from "node:test";
import {createCliClock, main} from "../src/cli/main.mjs";

test("CLI uses a live system clock unless an explicit deterministic time is supplied", () => {
  let systemNow = "2026-07-14T00:00:00.000Z";
  const liveClock = createCliClock(undefined, () => new Date(systemNow));
  assert.equal(liveClock().toISOString(), "2026-07-14T00:00:00.000Z");
  systemNow = "2026-07-14T00:02:00.000Z";
  assert.equal(liveClock().toISOString(), "2026-07-14T00:02:00.000Z");

  const fixedClock = createCliClock("2026-07-14T03:00:00.000Z", () => {
    throw new Error("fixed clock must not read system time");
  });
  assert.equal(fixedClock().toISOString(), "2026-07-14T03:00:00.000Z");
  assert.equal(fixedClock().toISOString(), "2026-07-14T03:00:00.000Z");
  assert.throws(() => createCliClock("not-a-time"), {code: "INVALID_ARGUMENT"});
});

test("CLI dispatches plan creation through the registered workflow factory",
  async () => {
    const calls = [];
    const registry = [{
      workflowId: "fixture-workflow",
      commands: ["plan"],
      createWorkflow: ({repoRoot}) => ({
        workflowId: "fixture-workflow",
        createPlan: async (input) => {
          calls.push({repoRoot, input});
          return {
            schemaVersion: 1,
            workflowId: "fixture-workflow",
            planId: "fixture-plan",
          };
        },
      }),
    }];
    const result = await main([
      "plan",
      "--workflow",
      "fixture-workflow",
      "--through",
      "2026-07-28",
    ], {
      workflowRegistry: registry,
      systemClock: () => new Date("2026-07-14T00:00:00.000Z"),
    });
    assert.equal(result.envelope.data.plan.workflowId, "fixture-workflow");
    assert.equal(calls.length, 1);
    assert.equal(calls[0].input.through, "2026-07-28");
    await assert.rejects(main([
      "learn",
      "status",
      "--workflow",
      "fixture-workflow",
    ], {workflowRegistry: registry}), {
      code: "WORKFLOW_COMMAND_UNSUPPORTED",
    });
  });
