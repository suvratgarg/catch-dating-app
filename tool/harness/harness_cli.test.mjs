import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import test from "node:test";
import {
  authoritativeShadowFailure,
  buildShadowReport,
  executeCheckIds,
  main,
  parseArgs,
} from "../harness.mjs";

const graph = JSON.parse(
  fs.readFileSync(new URL("./component_graph.json", import.meta.url), "utf8"),
);
const rootManifest = JSON.parse(
  fs.readFileSync(new URL("../repository_root_manifest.json", import.meta.url), "utf8"),
);

test("check executes by default and dry-run must be explicit", () => {
  assert.equal(parseArgs(["check", "--affected"]).dryRun, false);
  assert.equal(parseArgs(["check", "--affected", "--dry-run"]).dryRun, true);
});

test("captured check execution keeps stdout available for structured JSON", () => {
  const calls = [];
  const execution = executeCheckIds({
    ids: ["docs:version-monotonic"],
    cwd: "/repo",
    runner(executable, args, options) {
      calls.push({executable, args, options});
      return {status: 0, signal: null, stdout: "check output\n", stderr: ""};
    },
  });
  assert.equal(calls.length, 1);
  assert.deepEqual(calls[0].args, [
    "tool/run.mjs",
    "check",
    "docs:version-monotonic",
  ]);
  assert.equal(calls[0].options.shell, false);
  assert.deepEqual(execution, {
    status: 0,
    signal: null,
    stdout: "check output\n",
    stderr: "",
  });
  assert.doesNotThrow(() => JSON.parse(JSON.stringify({execution})));
});

test("check CLI propagates a selected check failure", () => {
  let exitCode = 0;
  let selectedIds = [];
  main({
    args: ["check", "--affected", "--paths", "README.md", "--json"],
    checkExecutor({ids}) {
      selectedIds = ids;
      return {status: 7, signal: null, stdout: "", stderr: "fixture failure"};
    },
    setExitCode(status) {
      exitCode = status;
    },
  });
  assert.deepEqual(selectedIds, ["docs:version-monotonic"]);
  assert.equal(exitCode, 7);
});

test("check CLI executes a selected repository check end to end", () => {
  const result = spawnSync(
    process.execPath,
    ["tool/harness.mjs", "check", "--affected", "--paths", "README.md", "--json"],
    {encoding: "utf8"},
  );
  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.deepEqual(output.plan.operations.checkIds, ["docs:version-monotonic"]);
  assert.equal(output.execution.status, 0);
});

test("shadow reports remain governed by authoritative v1 mapping", () => {
  const report = buildShadowReport({
    changedPaths: ["README.md"],
    graph,
    rootManifest,
    mode: "pr",
  });
  assert.deepEqual(report.v1Plan.unmatchedPaths, ["README.md"]);
  assert.equal(report.v2Plan.complete, true);
  assert.equal(authoritativeShadowFailure(report), true);
});
