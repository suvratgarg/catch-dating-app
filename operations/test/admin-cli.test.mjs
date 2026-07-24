import assert from "node:assert/strict";
import test from "node:test";
import {loadAdminActionCatalog} from "../src/admin/action-catalog.mjs";
import {main, runAction} from "../src/admin-cli/main.mjs";
import {OperationsError} from "../src/platform/errors.mjs";

test("admin CLI contract-loop covers every declared workflow action", async () => {
  const result = await main(["loop", "--all"]);
  const catalog = await loadAdminActionCatalog();
  assert.equal(result.envelope.data.workflows.length, catalog.workflows.length);
  assert.equal(
    result.envelope.data.workflows.flatMap((workflow) => workflow.steps).length,
    catalog.workflows.reduce((total, workflow) =>
      total + workflow.actions.length, 0)
  );
  assert.ok(result.envelope.data.workflows.every((workflow) =>
    workflow.steps.every((step) => step.result === "schema-valid")));
});

test("admin CLI keeps mutations dry-run by default", async () => {
  const catalog = await loadAdminActionCatalog();
  let calls = 0;
  const result = await runAction({
    catalog,
    actionId: "events.update",
    flags: {example: true},
    repoRoot: process.cwd(),
    dependencies: {client: {invoke: async () => { calls += 1; }}},
  });
  assert.equal(result.mode, "dry-run");
  assert.equal(calls, 0);
  assert.equal(result.confirmationRequired, "action-and-target");
});

test("admin CLI requires both action and target confirmation", async () => {
  const catalog = await loadAdminActionCatalog();
  await assert.rejects(runAction({
    catalog,
    actionId: "events.update",
    flags: {example: true, apply: true, confirm: "events.update"},
    repoRoot: process.cwd(),
    dependencies: {client: {invoke: async () => ({})}},
  }), {code: "ADMIN_ACTION_TARGET_CONFIRMATION_REQUIRED"});
});

test("admin CLI does not invoke an action when its start receipt fails",
  async () => {
    const catalog = await loadAdminActionCatalog();
    const receipts = [];
    let actionCalls = 0;
    const client = {
      async invoke(callable) {
        if (callable === "adminRecordActionExecution") {
          throw new Error("receipt unavailable");
        }
        actionCalls += 1;
        return {};
      },
    };
    await assert.rejects(runAction({
      catalog,
      actionId: "overview.get",
      flags: {},
      repoRoot: process.cwd(),
      dependencies: {
        client,
        receiptStore: {put: async (receipt) => {
          receipts.push(receipt);
          return "/fixture/start-failure.json";
        }},
      },
    }), (error) => {
      assert.equal(error.code, "ADMIN_ACTION_RECEIPT_START_FAILED");
      assert.equal(error.details.actionCompleted, false);
      return true;
    });
    assert.equal(actionCalls, 0);
    assert.equal(receipts[0].remoteReceiptStatus, "not-started");
  });

test("admin CLI records start and success around one live action", async () => {
  const catalog = await loadAdminActionCatalog();
  const calls = [];
  const receipts = [];
  const client = {
    async invoke(callable, payload) {
      calls.push({callable, payload});
      if (callable === "adminGetOverview") return {generatedAt: "fixture"};
      return {executionId: payload.executionId, status: payload.status};
    },
  };
  const result = await runAction({
    catalog,
    actionId: "overview.get",
    flags: {},
    repoRoot: process.cwd(),
    dependencies: {
      client,
      now: () => new Date("2026-07-23T00:00:00.000Z"),
      receiptStore: {put: async (receipt) => {
        receipts.push(receipt);
        return "/fixture/receipt.json";
      }},
    },
  });
  assert.equal(result.mode, "live");
  assert.deepEqual(calls.map((call) => call.callable), [
    "adminRecordActionExecution",
    "adminGetOverview",
    "adminRecordActionExecution",
  ]);
  assert.deepEqual(calls.filter((call) =>
    call.callable === "adminRecordActionExecution")
    .map((call) => call.payload.status), ["started", "succeeded"]);
  assert.equal(receipts[0].status, "succeeded");
  assert.equal(result.remotelyVisible, true);
});

test("admin CLI records a failed terminal receipt without masking the error",
  async () => {
    const catalog = await loadAdminActionCatalog();
    const statuses = [];
    const receipts = [];
    const client = {
      async invoke(callable, payload) {
        if (callable === "adminRecordActionExecution") {
          statuses.push(payload.status);
          return {};
        }
        throw Object.assign(new Error("denied"), {
          code: "ADMIN_CALLABLE_PERMISSION_DENIED",
          details: {},
          exitCode: 1,
        });
      },
    };
    await assert.rejects(runAction({
      catalog,
      actionId: "overview.get",
      flags: {},
      repoRoot: process.cwd(),
      dependencies: {
        client,
        receiptStore: {put: async (receipt) => {
          receipts.push(receipt);
          return "/fixture/failure.json";
        }},
      },
    }), {code: "INTERNAL_ERROR"});
    assert.deepEqual(statuses, ["started", "failed"]);
    assert.equal(receipts[0].status, "failed");
  });

test("admin CLI marks ambiguous transport outcomes indeterminate", async () => {
  const catalog = await loadAdminActionCatalog();
  const statuses = [];
  const receipts = [];
  const client = {
    async invoke(callable, payload) {
      if (callable === "adminRecordActionExecution") {
        statuses.push(payload.status);
        return {};
      }
      throw new OperationsError(
        "ADMIN_CALLABLE_TIMEOUT",
        "The callable result was not received."
      );
    },
  };
  await assert.rejects(runAction({
    catalog,
    actionId: "overview.get",
    flags: {},
    repoRoot: process.cwd(),
    dependencies: {
      client,
      receiptStore: {put: async (receipt) => {
        receipts.push(receipt);
        return "/fixture/indeterminate.json";
      }},
    },
  }), (error) => {
    assert.equal(error.code, "ADMIN_CALLABLE_TIMEOUT");
    assert.equal(error.details.actionCompleted, null);
    assert.equal(error.details.remoteReceiptStatus, "indeterminate");
    return true;
  });
  assert.deepEqual(statuses, ["started", "indeterminate"]);
  assert.equal(receipts[0].status, "indeterminate");
});

test("admin CLI preserves local success when the terminal remote receipt fails",
  async () => {
    const catalog = await loadAdminActionCatalog();
    const receipts = [];
    let receiptCalls = 0;
    const client = {
      async invoke(callable) {
        if (callable === "adminRecordActionExecution") {
          receiptCalls += 1;
          if (receiptCalls === 2) throw new Error("receipt unavailable");
          return {};
        }
        return {generatedAt: "fixture"};
      },
    };
    await assert.rejects(runAction({
      catalog,
      actionId: "overview.get",
      flags: {},
      repoRoot: process.cwd(),
      dependencies: {
        client,
        receiptStore: {put: async (receipt) => {
          receipts.push(receipt);
          return "/fixture/partial-receipt.json";
        }},
      },
    }), (error) => {
      assert.equal(error.code, "ADMIN_ACTION_RECEIPT_INCOMPLETE");
      assert.equal(error.details.actionCompleted, true);
      return true;
    });
    assert.equal(receipts[0].status, "succeeded");
    assert.equal(receipts[0].remoteReceiptStatus, "started-only");
  });
