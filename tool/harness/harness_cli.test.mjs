import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  collectKnownCheckIds,
  executeCheckIds,
  formatGithubOutputs,
  main,
  parseArgs,
  projectPlanOutputs,
} from "../harness.mjs";

const graph = JSON.parse(
  fs.readFileSync(new URL("./component_graph.json", import.meta.url), "utf8"),
);

test("check executes by default and dry-run must be explicit", () => {
  assert.equal(parseArgs(["check", "--affected"]).dryRun, false);
  assert.equal(parseArgs(["check", "--affected", "--dry-run"]).dryRun, true);
});

test("Harness check selection distinguishes command safety from check safety", () => {
  const remoteTool = {
    id: "remote-tool",
    status: "active",
    safety: "remote-write-explicit",
    checks: ["node --check tool/example.mjs"],
  };
  assert.deepEqual([...collectKnownCheckIds({tools: [remoteTool]})], []);
  assert.deepEqual(
    [...collectKnownCheckIds({
      tools: [{...remoteTool, checkSafety: "local-readonly"}],
    })],
    ["remote-tool"],
  );
  for (const checkSafety of [
    ["local-readonly"],
    "local-readonly-typo",
    "remote-readonly",
  ]) {
    assert.deepEqual(
      [...collectKnownCheckIds({tools: [{...remoteTool, checkSafety}]})],
      [],
    );
  }
});

test("task CLI dispatches lifecycle commands before planner validation", () => {
  let received = null;
  let exitCode = 0;
  main({
    args: ["task", "reap", "--dry-run", "--json"],
    taskExecutor(input) {
      received = input;
      return {status: 0, result: {operation: "reap", mode: "dry-run"}};
    },
    setExitCode(status) {
      exitCode = status;
    },
  });
  assert.deepEqual(received.args, ["reap", "--dry-run", "--json"]);
  assert.equal(exitCode, 0);
});

test("plan parses an explicit GitHub output destination", () => {
  assert.equal(
    parseArgs(["plan", "--github-output", "/tmp/github-output"]).githubOutput,
    "/tmp/github-output",
  );
});

test("bounded plan outputs contain no changed-path inventory", () => {
  const changedPaths = Array.from(
    {length: 5000},
    (_, index) => `docs/generated-fixture-${index}.md`,
  );
  const plan = {
    mode: "pr",
    full: false,
    complete: true,
    changedPaths,
    operations: {
      ciTargets: ["docs"],
      buildTargets: [],
      releaseRoles: [],
      deployGroups: [],
    },
  };
  const output = formatGithubOutputs(projectPlanOutputs({plan, graph}));
  assert.ok(Buffer.byteLength(output, "utf8") < 4096);
  assert.doesNotMatch(output, /generated-fixture/);
  assert.match(output, /^docs=true$/m);
  assert.match(output, /^flutter=false$/m);
  assert.match(output, /^app_roles=\[\]$/m);
  assert.deepEqual(
    JSON.parse(output.match(/^docs_checkout=(.*)$/m)[1]),
    {
      mode: "sparse",
      fetchDepth: 0,
      coneMode: false,
      timeoutMinutes: 3,
      paths: [
        "/docs/audit_registry/doc_versions.json",
        "/tool/docs/check_doc_version_monotonic.mjs",
      ],
    },
  );
});

test("plan output derives roles and deployment authorization from bounded operations", () => {
  const plan = {
    mode: "main",
    full: false,
    complete: true,
    operations: {
      ciTargets: ["flutter_build_ios", "functions"],
      buildTargets: ["host-ios"],
      releaseRoles: ["host"],
      deployGroups: ["functions"],
    },
  };
  const output = projectPlanOutputs({plan, graph});
  assert.equal(output.flutter_build_ios, true);
  assert.equal(output.flutter_build_android, false);
  assert.equal(output.app_roles, '["host"]');
  assert.equal(output.release_roles, '["host"]');
  assert.equal(output.has_release_roles, true);
  assert.equal(output.deploy_groups, '["functions"]');
  assert.equal(output.deploy_required, true);
});

test("output projection rejects incomplete plans and unsafe multiline values", () => {
  assert.throws(
    () => projectPlanOutputs({
      plan: {
        complete: false,
        operations: {
          ciTargets: [],
          buildTargets: [],
          releaseRoles: [],
          deployGroups: [],
        },
      },
      graph,
    }),
    /incomplete Harness plan/,
  );
  assert.throws(
    () => formatGithubOutputs({docs: "true\nunsafe=value"}),
    /Unsafe GitHub output/,
  );
});

test("output projection rejects an invalid checkout contract", () => {
  const invalidGraph = JSON.parse(JSON.stringify(graph));
  invalidGraph.ciCheckout.default = invalidGraph.ciCheckout.targetOverrides.docs;
  assert.throws(
    () => projectPlanOutputs({
      plan: {
        complete: true,
        mode: "pr",
        full: false,
        operations: {
          ciTargets: ["docs"],
          buildTargets: [],
          releaseRoles: [],
          deployGroups: [],
        },
      },
      graph: invalidGraph,
    }),
    /undeclared targets widen safely/,
  );
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

test("plan CLI fails closed before writing outputs for an unknown path", () => {
  let exitCode = 0;
  const outputPath = `/tmp/catch-harness-output-${process.pid}-${Date.now()}`;
  main({
    args: [
      "plan",
      "--paths",
      "unowned/new.file",
      "--github-output",
      outputPath,
      "--json",
    ],
    setExitCode(status) {
      exitCode = status;
    },
  });
  assert.equal(exitCode, 1);
  assert.equal(fs.existsSync(outputPath), false);
});

test("plan CLI writes parseable bounded outputs for an owned path", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-harness-output-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const outputPath = path.join(directory, "github-output");
  let exitCode = 0;
  main({
    args: [
      "plan",
      "--paths",
      "README.md",
      "--github-output",
      outputPath,
      "--json",
    ],
    setExitCode(status) {
      exitCode = status;
    },
  });
  const outputs = Object.fromEntries(
    fs.readFileSync(outputPath, "utf8")
      .trim()
      .split("\n")
      .map((line) => line.split(/=(.*)/s).slice(0, 2)),
  );
  assert.equal(exitCode, 0);
  assert.equal(outputs.docs, "true");
  assert.equal(outputs.flutter, "false");
  assert.deepEqual(JSON.parse(outputs.app_roles), []);
  assert.equal(outputs.complete, "true");
});
