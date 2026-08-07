import test from "node:test";
import assert from "node:assert/strict";
import {spawn, spawnSync} from "node:child_process";
import {randomUUID} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  supportedToolPlatforms,
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";
import {digestTaskStart} from "./agent/lib/task_input.mjs";
import {
  acquireTaskExecutionLease,
  createTaskAuthorityFile,
  deriveTaskStartContractAtBase,
  readTaskExecutionContext,
  taskPlanningAuthorityBlockers,
  taskProcessIsolationBlockers,
  taskStartContractFromMetadata,
} from "./harness/lib/task_execution_context.mjs";
import {executeTaskCommand} from "./harness/lib/worktree_lifecycle.mjs";

const repositoryRoot = process.cwd();
const sparseExecutableClosure = [
  "/tool/agent/context_pack.mjs",
  "/tool/agent/lib/task_input.mjs",
  "/tool/docs/check_doc_version_monotonic.mjs",
  "/tool/docs/check_doc_version_monotonic.test.mjs",
  "/tool/harness/lib/component_graph.mjs",
  "/tool/harness/lib/task_execution_context.mjs",
  "/tool/harness/lib/worktree_lifecycle.mjs",
  "/tool/harness/lib/task_contract.mjs",
  "/tool/lib/repo_paths.mjs",
  "/tool/lib/repository_snapshot.mjs",
  "/tool/lib/tool_impact.mjs",
  "/tool/lib/tool_platform.mjs",
  "/tool/run.mjs",
];
const materializedSnapshotInputClosure = [
  ...sparseExecutableClosure,
  "/lib/fixture_scope.txt",
  "/tool/agent/check_agent_readiness.mjs",
  "/tool/check_enforcement_integrity.mjs",
  "/tool/check_repository_root_hygiene.mjs",
  "/AGENTS.md",
  "/docs/README.md",
  "/docs/agent_operating_model.md",
  "/docs/agent_regression_ledger.json",
  "/docs/agent_skills/skills_manifest.json",
  "/docs/audit_registry/README.md",
  "/docs/audit_registry/doc_versions.json",
  "/docs/audit_registry/rules.json",
  "/tool/README.md",
  "/tool/tools_manifest.json",
];
const toolPreflightCheckoutClosure = [
  "/tool/",
  "/.github/actions/load-toolchain/action.yml",
  "/functions/package.json",
  "/pubspec.yaml",
  "/.github/workflows/app-build-matrix.yml",
  "/.github/workflows/mobile-internal-release.yml",
  "/.github/workflows/visual-integration-ci.yml",
];
const affectedIndexCheckoutClosure = [
  "/tool/",
  "/.github/actions/load-toolchain/action.yml",
  "/docs/audit_registry/doc_versions.json",
  "/docs/audit_registry/test_inventory.json",
];

function run(args) {
  return spawnSync("node", ["tool/run.mjs", ...args], {
    cwd: process.cwd(),
    encoding: "utf8",
  });
}

test("filtered checks fail when a category matches no tools", () => {
  const result = run(["check", "--category", "definitely-missing"]);
  assert.equal(result.status, 64);
  assert.match(result.stderr, /No active tools matched category definitely-missing/);
});

test("category checks select active tools only", () => {
  const result = run(["list", "--category", "marketing", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const tools = JSON.parse(result.stdout);
  assert.ok(tools.length > 0);
  assert.ok(tools.every((tool) => tool.status === "active"));
});

test("direct checks cannot select inactive tool ids", () => {
  const result = run(["check", "audit:widget-function-migrator"]);
  assert.equal(result.status, 64);
  assert.match(result.stderr, /Unknown or inactive tool ids/u);
});

test("direct checks reject a mixed valid and unknown tool-id selection", () => {
  const result = run(["check", "docs:version-monotonic", "definitely-missing"]);
  assert.equal(result.status, 64);
  assert.match(result.stderr, /Unknown or inactive tool ids: definitely-missing/u);
});

test("platform-specific tools run only on declared operating systems", () => {
  const tool = {id: "fixture:darwin-only", platforms: ["darwin"]};
  assert.equal(toolSupportsPlatform(tool, "darwin"), true);
  assert.equal(toolSupportsPlatform(tool, "linux"), false);
  assert.equal(toolSupportsPlatform({id: "fixture:anywhere"}, "linux"), true);
  assert.deepEqual(validateToolPlatforms(tool), []);
  assert.deepEqual(
    validateToolPlatforms({platforms: ["darwin", "darwin"]}),
    ["platforms must not contain duplicates"],
  );
  assert.deepEqual(
    validateToolPlatforms({platforms: ["plan9"]}),
    ['platforms contains unsupported value "plan9"'],
  );
  assert.deepEqual(
    [...supportedToolPlatforms],
    ["darwin", "linux", "win32"],
  );
});

test("impact routing reports the owning relationship and checks", () => {
  const result = run(["impacted", "--paths", "contracts/firestore/users.schema.json", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("backend-contracts"));
  assert.ok(payload.toolIds.includes("contracts:validate-schemas"));
  assert.ok(payload.ciTargets.includes("contracts"));
  assert.deepEqual(payload.mobileReleaseRoles, []);
  assert.deepEqual(payload.deployGroups, ["backend-contracts"]);
  assert.equal(payload.deployRequired, true);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing includes field inventory for Flutter design consumers", () => {
  const result = run(["impacted", "--paths", "lib/routing/go_router.dart", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("design-system"));
  assert.ok(payload.toolIds.includes("design:flutter-field-surface-inventory"));
  assert.deepEqual(payload.mobileReleaseRoles, ["consumer", "host"]);
  assert.deepEqual(payload.buildTargets, ["consumer-web-smoke", "host-web-smoke"]);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing keeps admin-only work out of Flutter and mobile release lanes", () => {
  const result = run(["impacted", "--paths", "admin/src/app/App.tsx", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.ciTargets.includes("admin"));
  assert.ok(!payload.ciTargets.includes("flutter"));
  assert.deepEqual(payload.mobileReleaseRoles, []);
});

test("impact routing preserves role ownership for independent app packages", () => {
  const result = run([
    "impacted",
    "--paths",
    "apps/host/lib/host_platform_app.dart",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("flutter-app"));
  assert.deepEqual(payload.appRoles, ["host"]);
  assert.deepEqual(payload.mobileReleaseRoles, ["host"]);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing treats ordinary root documentation as owned", () => {
  const result = run(["impacted", "--paths", "README.md", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.deepEqual(payload.ciTargets, ["docs"]);
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("generated localization and notification copy avoid unrelated mobile releases", () => {
  for (const changedPath of [
    "lib/l10n/generated/app_localizations.dart",
    "copy/notifications_en.json",
  ]) {
    const result = run(["impacted", "--paths", changedPath, "--json"]);
    assert.equal(result.status, 0, result.stderr);
    const payload = JSON.parse(result.stdout);
    assert.deepEqual(payload.mobileReleaseRoles, []);
  }
});

test("impact routing fails closed for an unmapped changed path", () => {
  const result = run(["impacted", "--paths", "unowned/example.txt", "--json"]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Unmapped changed paths/);
});

test("impact routing includes untracked files", (context) => {
  const probe = path.join(process.cwd(), "unowned-impact-probe.tmp");
  fs.writeFileSync(probe, "probe\n");
  context.after(() => fs.rmSync(probe, {force: true}));
  const result = run(["impacted", "--json"]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /unowned-impact-probe\.tmp/);
});

test("affected-tool routing selects the checker and mandatory guards", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs,tool/docs/check_doc_version_monotonic.test.mjs",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "affected");
  assert.deepEqual(payload.toolIds, [
    "agent:readiness",
    "docs:version-monotonic",
    "meta:enforcement-integrity",
    "meta:repository-root-hygiene",
    "meta:test-inventory",
  ]);
  assert.deepEqual(payload.unmappedPaths, []);
});

test("shared task-input ownership stays exact and needs only Node setup", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/agent/lib/task_input.mjs",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "affected");
  assert.equal(payload.full, false);
  assert.deepEqual(payload.ownersByPath["tool/agent/lib/task_input.mjs"], [
    "agent:context-pack",
    "agent:harness-v2",
  ]);
  assert.equal(payload.toolIds.length, 7);
  assert.deepEqual(payload.setupRequirements, ["node"]);
  assert.deepEqual(payload.unmappedPaths, []);
  assert.deepEqual(payload.fullReasons, []);
});

test("shared task-phase authority is dual-owned and remains full-control-plane", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/harness/lib/task_execution_context.mjs",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "full");
  assert.equal(payload.full, true);
  assert.deepEqual(
    payload.ownersByPath["tool/harness/lib/task_execution_context.mjs"],
    ["agent:harness-v2", "tool:runner"],
  );
  assert.deepEqual(payload.toolIds, []);
  assert.ok(payload.fullReasons.includes(
    "control-plane path changed: tool/harness/lib/task_execution_context.mjs",
  ));
  assert.deepEqual(payload.unmappedPaths, []);
});

test("affected-tool routing ignores companion files owned by other lanes", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs,docs/audit_registry/passes.jsonl,tool/README.md",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "affected");
  assert.deepEqual(payload.toolLanePaths, [
    "tool/docs/check_doc_version_monotonic.mjs",
  ]);
  assert.deepEqual(payload.ignoredPaths, [
    "docs/audit_registry/passes.jsonl",
    "tool/README.md",
  ]);
});

test("affected-tool routing cannot ignore declared full-impact companions", () => {
  for (const fullPath of ["pubspec.lock", "functions/package-lock.json"]) {
    const result = run([
      "affected-tools",
      "--paths",
      `tool/docs/check_doc_version_monotonic.mjs,${fullPath}`,
      "--json",
    ]);
    assert.equal(result.status, 0, result.stderr);
    const payload = JSON.parse(result.stdout);
    assert.equal(payload.mode, "full");
    assert.ok(
      payload.fullReasons.includes(`control-plane path changed: ${fullPath}`),
    );
  }
});

test("affected-tool routing fails closed for any unmapped lane input", (context) => {
  const temporaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-full-lane-"));
  context.after(() => fs.rmSync(temporaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(temporaryRoot, {
    checkoutPaths: materializedSnapshotInputClosure,
  });
  const result = runNode(temporaryRoot, ["tool/run.mjs",
    "affected-tools",
    "--paths",
    "design/screens/catch.screens.json",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "full");
  assert.deepEqual(payload.unmappedPaths, ["design/screens/catch.screens.json"]);

  const execution = runNode(temporaryRoot, ["tool/run.mjs",
    "affected-tools",
    "--paths",
    "design/screens/catch.screens.json",
    "--check",
  ]);
  assert.equal(execution.status, 1);
  assert.match(execution.stderr, /run the full category matrix/u);
});

test("affected-tool routing keeps control-plane and explicit full runs full", () => {
  for (const args of [
    ["--paths", ".github/workflows/tools-ci.yml"],
    ["--paths", "tool/ci/check_toolchain_consistency.sh"],
    ["--paths", "tool/harness.mjs"],
    ["--paths", "docs/README.md", "--full"],
  ]) {
    const result = run(["affected-tools", ...args, "--json"]);
    assert.equal(result.status, 0, result.stderr);
    assert.equal(JSON.parse(result.stdout).mode, "full");
  }
});

test("affected-tool routing preserves the requested Harness mode", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs",
    "--mode",
    "main",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  assert.equal(JSON.parse(result.stdout).harnessMode, "main");
});

test("active tool entries cannot be vacuous", () => {
  const manifest = JSON.parse(fs.readFileSync("tool/tools_manifest.json", "utf8"));
  const empty = manifest.tools
    .filter((tool) => tool.status === "active")
    .filter((tool) => !Array.isArray(tool.checks) || tool.checks.length === 0)
    .map((tool) => tool.id);
  assert.deepEqual(empty, []);
});

test("tool manifest validation rejects malformed checkSafety", (context) => {
  const temporaryRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-check-safety-"),
  );
  context.after(() => fs.rmSync(temporaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(temporaryRoot, {
    checkoutPaths: materializedSnapshotInputClosure,
  });
  const manifestPath = path.join(temporaryRoot, "tool/tools_manifest.json");
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  manifest.tools.find((tool) => tool.id === "agent:harness-v2").checkSafety = [
    "local-readonly",
  ];
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  runGit(temporaryRoot, ["add", "tool/tools_manifest.json"]);

  const result = runNode(temporaryRoot, [
    "tool/run.mjs",
    "check",
    "--manifest-only",
  ]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /agent:harness-v2: checkSafety must be one of local-readonly/u);
});

test("tool manifest validation binds taskPaths to existing index-view inputs", (context) => {
  const temporaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-paths-"));
  context.after(() => fs.rmSync(temporaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(temporaryRoot, {
    checkoutPaths: materializedSnapshotInputClosure,
  });
  const manifestPath = path.join(temporaryRoot, "tool/tools_manifest.json");
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const tool = manifest.tools.find((entry) => entry.id === "agent:harness-v2");
  tool.taskPaths = ["docs/not-real.json"];
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  runGit(temporaryRoot, ["add", "tool/tools_manifest.json"]);

  const missing = runNode(temporaryRoot, ["tool/run.mjs", "check", "--manifest-only"]);
  assert.equal(missing.status, 1);
  assert.match(missing.stderr, /taskPaths path does not exist: docs\/not-real\.json/u);

  tool.taskPaths = ["docs/audit_registry/test_inventory.json"];
  delete tool.ciRequirements;
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  runGit(temporaryRoot, ["add", "tool/tools_manifest.json"]);
  const fullView = runNode(temporaryRoot, ["tool/run.mjs", "check", "--manifest-only"]);
  assert.equal(fullView.status, 1);
  assert.match(fullView.stderr, /taskPaths requires ciRequirements\.repositoryView index/u);

  tool.taskPaths = {};
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  runGit(temporaryRoot, ["add", "tool/tools_manifest.json"]);
  const malformed = runNode(temporaryRoot, ["tool/run.mjs", "check", "--manifest-only"]);
  assert.equal(malformed.status, 1);
  assert.match(malformed.stderr, /taskPaths must be an array of non-empty strings/u);
});

test("managed workers reject parent, mixed, unplanned, platform, and direct execution atomically", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-phase-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {
    checkoutPaths: materializedSnapshotInputClosure,
  });
  const {metadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = metadata.contextPack.checkIds[0];
  const deferredId = metadata.contextPack.deferredCheckIds.find((id) => id === "audit:registry") ??
    metadata.contextPack.deferredCheckIds[0];
  const manifest = configureTaskPhaseSentinel({
    root: taskRoot,
    allowedId,
    deferredId,
  });
  const unplannedId = manifest.tools.find((tool) =>
    tool.status === "active" &&
    !metadata.contextPack.checkIds.includes(tool.id) &&
    !metadata.contextPack.deferredCheckIds.includes(tool.id))?.id;
  assert.ok(unplannedId);
  const deferredCategory = manifest.tools.find((tool) => tool.id === deferredId).category;
  const sentinelPath = path.join(taskRoot, "task-phase-sentinel.txt");
  const githubOutput = path.join(taskRoot, "task-phase-github-output.txt");

  const cases = [
    {
      args: ["tool/run.mjs", "check", deferredId],
      reason: `parent_deferred_check:${deferredId}`,
    },
    {
      args: ["tool/run.mjs", "check", allowedId, deferredId],
      reason: `parent_deferred_check:${deferredId}`,
    },
    {
      args: ["tool/run.mjs", "check", unplannedId],
      reason: `unplanned_task_check:${unplannedId}`,
    },
    {
      args: ["tool/run.mjs", "check", "--category", deferredCategory],
    },
    {
      args: [
        "tool/run.mjs",
        "impacted",
        "--paths",
        "contracts/firestore/users.schema.json",
        "--check",
      ],
    },
    {
      args: [
        "tool/run.mjs",
        "affected-tools",
        "--paths",
        "tool/docs/check_doc_version_monotonic.mjs",
        "--check",
        "--github-output",
        githubOutput,
      ],
    },
    {
      args: [
        "tool/run.mjs",
        "affected-tools",
        "--paths",
        "tool/docs/check_doc_version_monotonic.mjs",
        "--github-output",
        githubOutput,
      ],
    },
    {
      args: ["tool/run.mjs", "run", deferredId],
      reason: `parent_owned_direct_execution:${deferredId}`,
    },
    {
      args: ["tool/run.mjs", "exec", deferredId],
      reason: `parent_owned_direct_execution:${deferredId}`,
    },
  ];
  for (const fixture of cases) {
    fs.rmSync(sentinelPath, {force: true});
    fs.rmSync(githubOutput, {force: true});
    const result = runNode(taskRoot, fixture.args);
    assert.equal(result.status, 77, result.stderr || result.stdout);
    if (fixture.reason) assert.match(result.stderr, new RegExp(fixture.reason));
    assert.doesNotMatch(result.stdout, /==>/u);
    assert.equal(fs.existsSync(sentinelPath), false, fixture.args.join(" "));
    assert.equal(fs.existsSync(githubOutput), false, fixture.args.join(" "));
    assert.equal(fs.existsSync(path.join(taskRoot, ".dart_tool")), false);
  }

  const manifestOnly = runNode(taskRoot, [
    "tool/run.mjs",
    "check",
    "--manifest-only",
  ]);
  assertSuccessful(manifestOnly);

  const allowed = runNode(taskRoot, [
    "tool/run.mjs",
    "check",
    allowedId,
  ]);
  assertSuccessful(allowed);
  assert.match(allowed.stdout, new RegExp(`==> ${allowedId}`));
  assert.equal(fs.readFileSync(sentinelPath, "utf8"), "child-dispatched\n");
});

test("parent authority rejects coherent worker scope and base forgeries", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-forgery-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {metadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = metadata.contextPack.checkIds[0];
  const originalCheckIds = new Set(metadata.contextPack.checkIds);
  const deferredId = metadata.contextPack.deferredCheckIds[0];
  configureTaskPhaseSentinel({root: taskRoot, allowedId, deferredId});
  const sentinelPath = path.join(taskRoot, "task-phase-sentinel.txt");
  const authorityPath = taskAuthorityPath(taskRoot);
  const authorityBefore = fs.readFileSync(authorityPath, "utf8");
  let forgedCheckId = null;

  writeManagedTaskMetadata(taskRoot, (forged) => {
    forged.baseSha = gitText(taskRoot, ["rev-parse", "HEAD^"]);
    forged.contextPack.sourceSha = forged.baseSha;
    forged.ownedPaths = ["lib/fixture_scope.txt", "tool"];
    forged.plannedImpactPaths = ["tool/run.mjs"];
    const expected = deriveTaskStartContractAtBase({metadata: forged, cwd: taskRoot});
    forgedCheckId = expected.checkIds.find((id) => !originalCheckIds.has(id)) ?? null;
    Object.assign(forged.contextPack, {
      digest: expected.digest,
      checkIds: expected.checkIds,
      deferredCheckIds: expected.deferredCheckIds,
      deferredRegressionIds: expected.deferredRegressionIds,
      supportPaths: expected.supportPaths,
      requiredEntrypoints: expected.requiredEntrypoints,
    });
  });
  assert.ok(forgedCheckId, "forged scope must promote a previously unauthorized check");

  const result = runNode(taskRoot, ["tool/run.mjs", "check", forgedCheckId]);
  assert.equal(result.status, 77, result.stderr || result.stdout);
  assert.match(result.stderr, /task_authority_metadata_mismatch/u);
  assert.doesNotMatch(result.stdout, /==>/u);
  assert.equal(fs.existsSync(sentinelPath), false);
  assert.equal(fs.readFileSync(authorityPath, "utf8"), authorityBefore);
});

test("managed execution requires live registration and the authority-bound worktree lock", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-binding-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {metadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = metadata.contextPack.checkIds[0];
  const deferredId = metadata.contextPack.deferredCheckIds[0];
  configureTaskPhaseSentinel({root: taskRoot, allowedId, deferredId});
  const sentinelPath = path.join(taskRoot, "task-phase-sentinel.txt");

  runGit(primaryRoot, ["worktree", "unlock", taskRoot]);
  const unlocked = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assert.equal(unlocked.status, 77, unlocked.stderr || unlocked.stdout);
  assert.match(unlocked.stderr, /active_worktree_not_locked/u);
  assert.equal(fs.existsSync(sentinelPath), false);

  runGit(primaryRoot, ["worktree", "lock", "--reason", "catch-task:wrong-authority", taskRoot]);
  const wrongReason = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assert.equal(wrongReason.status, 77, wrongReason.stderr || wrongReason.stdout);
  assert.match(wrongReason.stderr, /task_lock_reason_mismatch/u);
  assert.equal(fs.existsSync(sentinelPath), false);

  const missingRegistration = readTaskExecutionContext({
    cwd: taskRoot,
    gitRunner: ({cwd, args}) => args[0] === "worktree"
      ? processResult("")
      : spawnSync("git", args, {cwd, encoding: "utf8"}),
  });
  assert.equal(missingRegistration.kind, "blocked");
  assert.ok(missingRegistration.blockers.includes("task_worktree_not_registered"));

  runGit(primaryRoot, ["worktree", "unlock", taskRoot]);
  runGit(primaryRoot, [
    "worktree",
    "lock",
    "--reason",
    `catch-task:${metadata.taskId}:${metadata.authorityId}`,
    taskRoot,
  ]);
  const allowed = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assertSuccessful(allowed);
  assert.equal(fs.readFileSync(sentinelPath, "utf8"), "child-dispatched\n");
});

test("managed execution rejects live command-definition drift for an allowed id", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-command-drift-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {allowedId, deferredId, taskRoot} = createManagedTaskFixture(primaryRoot);
  configureTaskPhaseSentinel({root: taskRoot, allowedId, deferredId});
  const manifestPath = path.join(taskRoot, "tool", "tools_manifest.json");
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const selected = manifest.tools.find((tool) => tool.id === allowedId);
  const unauthorizedScript = path.join(taskRoot, "tool", "fixtures", "unauthorized_task_command.mjs");
  const unauthorizedSentinel = path.join(taskRoot, "unauthorized-task-command.txt");
  fs.mkdirSync(path.dirname(unauthorizedScript), {recursive: true});
  fs.writeFileSync(
    unauthorizedScript,
    'import fs from "node:fs";\nfs.writeFileSync("unauthorized-task-command.txt", "ran\\n");\n',
  );
  selected.checks = ["node tool/fixtures/unauthorized_task_command.mjs"];
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  runGit(taskRoot, [
    "add",
    "--sparse",
    "tool/tools_manifest.json",
    "tool/fixtures/unauthorized_task_command.mjs",
  ]);

  const result = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assert.equal(result.status, 77, result.stderr || result.stdout);
  assert.match(result.stderr, new RegExp(`task_tool_definition_drift:${allowedId}`));
  assert.equal(fs.existsSync(unauthorizedSentinel), false);

  configureTaskPhaseSentinel({root: taskRoot, allowedId, deferredId});
  const planningManifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  planningManifest.ciImpact.mandatoryCheckIds = [allowedId];
  planningManifest.tools.find((tool) => tool.id === allowedId).impactPaths = [
    "tool/fixtures/promoted_scope.txt",
  ];
  const planningContext = readTaskExecutionContext({cwd: taskRoot});
  assert.deepEqual(
    taskPlanningAuthorityBlockers({
      context: planningContext,
      sources: [{relativePath: "tool/tools_manifest.json", value: planningManifest}],
      cwd: taskRoot,
    }),
    ["task_planning_authority_drift:tool/tools_manifest.json"],
  );
  assert.deepEqual(
    taskProcessIsolationBlockers({context: planningContext, platform: "win32"}),
    ["task_process_group_isolation_unavailable"],
  );
});

test("execution and finish share one lease across the complete child lifetime", async (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-lease-"));
  const synchronizationRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-sync-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  context.after(() => fs.rmSync(synchronizationRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {metadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = metadata.contextPack.checkIds[0];
  const deferredId = metadata.contextPack.deferredCheckIds[0];
  const startedPath = path.join(synchronizationRoot, "started");
  const releasePath = path.join(synchronizationRoot, "release");
  configureTaskPhaseSentinel({
    root: taskRoot,
    allowedId,
    deferredId,
    script: [
      'import fs from "node:fs";',
      'import {spawn} from "node:child_process";',
      "const source = [",
      "  'const fs = require(\\\"node:fs\\\");',",
      "  'const waitArray = new Int32Array(new SharedArrayBuffer(4));',",
      "  'while (!fs.existsSync(process.env.CATCH_TEST_RELEASE)) Atomics.wait(waitArray, 0, 0, 20);',",
      "  'fs.writeFileSync(\\\"task-phase-sentinel.txt\\\", \\\"child-dispatched\\\\n\\\");',",
      "].join('\\n');",
      "const background = spawn(process.execPath, ['-e', source], {",
      "  env: process.env,",
      "  stdio: 'ignore',",
      "});",
      "background.unref();",
      'fs.writeFileSync(process.env.CATCH_TEST_STARTED, "foreground-returned\\n");',
      "",
    ].join("\n"),
  });

  const finishGate = acquireTaskExecutionLease({cwd: taskRoot, owner: "task-finish-test"});
  assert.equal(finishGate.acquired, true);
  const deniedWhileFinishing = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assert.equal(deniedWhileFinishing.status, 77, deniedWhileFinishing.stderr);
  assert.match(deniedWhileFinishing.stderr, /task_execution_lease_active/u);
  assert.equal(fs.existsSync(path.join(taskRoot, "task-phase-sentinel.txt")), false);
  finishGate.release();

  const child = spawn(process.execPath, ["tool/run.mjs", "check", allowedId], {
    cwd: taskRoot,
    env: {
      ...process.env,
      GIT_CONFIG_NOSYSTEM: "1",
      CATCH_TEST_STARTED: startedPath,
      CATCH_TEST_RELEASE: releasePath,
    },
    stdio: ["ignore", "pipe", "pipe"],
  });
  const childResultPromise = collectChildResult(child);
  context.after(() => {
    if (child.exitCode == null) child.kill("SIGKILL");
  });
  await waitForPath(startedPath);
  await new Promise((resolve) => setTimeout(resolve, 100));
  assert.equal(child.exitCode, null, "wrapper must wait for background process-group members");

  const finish = executeTaskCommand({args: ["finish"], cwd: taskRoot});
  assert.equal(finish.status, 1);
  assert.deepEqual(finish.result.blockers, ["task_execution_lease_active"]);
  assert.equal(JSON.parse(fs.readFileSync(taskMetadataPath(taskRoot), "utf8")).status, "active");
  assert.match(
    gitText(primaryRoot, ["worktree", "list", "--porcelain"]),
    new RegExp(`locked catch-task:${metadata.taskId}:${metadata.authorityId}`),
  );

  fs.writeFileSync(releasePath, "release\n");
  const childResult = await childResultPromise;
  assert.equal(childResult.status, 0, childResult.stderr || childResult.stdout);
  assert.equal(fs.existsSync(taskGatePath(taskRoot)), false);
  const afterChild = executeTaskCommand({args: ["finish"], cwd: taskRoot});
  assert.equal(afterChild.result.blockers.includes("task_execution_lease_active"), false);
});

test("a crashed runner cannot release the gate while its check process group survives", async (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-orphan-"));
  const synchronizationRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-orphan-sync-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  context.after(() => fs.rmSync(synchronizationRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {metadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = metadata.contextPack.checkIds[0];
  const deferredId = metadata.contextPack.deferredCheckIds[0];
  const startedPath = path.join(synchronizationRoot, "started");
  const releasePath = path.join(synchronizationRoot, "release");
  const completedPath = path.join(synchronizationRoot, "completed");
  context.after(() => {
    if (fs.existsSync(synchronizationRoot)) fs.writeFileSync(releasePath, "release\n");
  });
  configureTaskPhaseSentinel({
    root: taskRoot,
    allowedId,
    deferredId,
    script: [
      'import fs from "node:fs";',
      'fs.writeFileSync(process.env.CATCH_TEST_STARTED, "started\\n");',
      "const waitArray = new Int32Array(new SharedArrayBuffer(4));",
      "while (!fs.existsSync(process.env.CATCH_TEST_RELEASE)) Atomics.wait(waitArray, 0, 0, 20);",
      'fs.writeFileSync(process.env.CATCH_TEST_COMPLETED, "completed\\n");',
      "",
    ].join("\n"),
  });

  const runner = spawn(process.execPath, ["tool/run.mjs", "check", allowedId], {
    cwd: taskRoot,
    env: {
      ...process.env,
      GIT_CONFIG_NOSYSTEM: "1",
      CATCH_TEST_STARTED: startedPath,
      CATCH_TEST_RELEASE: releasePath,
      CATCH_TEST_COMPLETED: completedPath,
    },
    stdio: ["ignore", "pipe", "pipe"],
  });
  const runnerResultPromise = collectChildResult(runner);
  await waitForPath(startedPath);
  const childRecord = await waitForTaskChildRecord(taskRoot);
  process.kill(childRecord.pid, "SIGKILL");
  await new Promise((resolve) => setTimeout(resolve, 100));
  assert.doesNotThrow(() => process.kill(-childRecord.processGroupId, 0));
  const runnerExitPromise = new Promise((resolve) => runner.once("exit", resolve));
  assert.equal(runner.kill("SIGKILL"), true);
  await runnerExitPromise;

  const recoveryWhileChildRuns = executeTaskCommand({args: ["recover-lease"], cwd: taskRoot});
  assert.equal(recoveryWhileChildRuns.status, 1);
  assert.deepEqual(recoveryWhileChildRuns.result.blockers, ["task_execution_lease_active"]);
  const finishWhileChildRuns = executeTaskCommand({args: ["finish"], cwd: taskRoot});
  assert.equal(finishWhileChildRuns.status, 1);
  assert.deepEqual(finishWhileChildRuns.result.blockers, ["task_execution_lease_active"]);

  fs.writeFileSync(releasePath, "release\n");
  await waitForPath(completedPath);
  const runnerResult = await runnerResultPromise;
  assert.equal(runnerResult.status, null);
  assert.equal(runnerResult.signal, "SIGKILL");
  const recovered = executeTaskCommand({args: ["recover-lease"], cwd: taskRoot});
  assert.equal(recovered.status, 0, JSON.stringify(recovered.result));
  assert.equal(recovered.result.recovered, true);
  assert.equal(fs.existsSync(taskGatePath(taskRoot)), false);
});

test("SIGINT cancels a background-only managed check group and releases the gate", async (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-cancel-"));
  const synchronizationRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-cancel-sync-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  context.after(() => fs.rmSync(synchronizationRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {allowedId, deferredId, taskRoot} = createManagedTaskFixture(primaryRoot);
  const startedPath = path.join(synchronizationRoot, "started");
  configureTaskPhaseSentinel({
    root: taskRoot,
    allowedId,
    deferredId,
    script: [
      'import fs from "node:fs";',
      'import {spawn} from "node:child_process";',
      "const background = spawn(process.execPath, ['-e', 'setInterval(() => {}, 1000)'], {",
      "  stdio: 'ignore',",
      "});",
      "background.unref();",
      'fs.writeFileSync(process.env.CATCH_TEST_STARTED, "foreground-returned\\n");',
      "",
    ].join("\n"),
  });

  const runner = spawn(process.execPath, ["tool/run.mjs", "check", allowedId], {
    cwd: taskRoot,
    env: {
      ...process.env,
      GIT_CONFIG_NOSYSTEM: "1",
      CATCH_TEST_STARTED: startedPath,
    },
    stdio: ["ignore", "pipe", "pipe"],
  });
  const resultPromise = collectChildResult(runner);
  context.after(() => {
    if (runner.exitCode == null) runner.kill("SIGKILL");
  });
  await waitForPath(startedPath);
  const childRecord = await waitForTaskChildRecord(taskRoot);
  await new Promise((resolve) => setTimeout(resolve, 150));
  assert.equal(runner.exitCode, null);
  assert.doesNotThrow(() => process.kill(-childRecord.processGroupId, 0));
  assert.equal(runner.kill("SIGINT"), true);
  const result = await resultPromise;
  assert.equal(result.status, 130, result.stderr || result.stdout);
  assert.equal(result.signal, null);
  assert.equal(fs.existsSync(taskGatePath(taskRoot)), false);
});

test("a failed child releases the task execution lease", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-failed-lease-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {metadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = metadata.contextPack.checkIds[0];
  const deferredId = metadata.contextPack.deferredCheckIds[0];
  configureTaskPhaseSentinel({
    root: taskRoot,
    allowedId,
    deferredId,
    script: "process.exit(9);\n",
  });
  const failed = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assert.equal(failed.status, 9, failed.stderr || failed.stdout);
  assert.equal(fs.existsSync(taskGatePath(taskRoot)), false);

  configureTaskPhaseSentinel({root: taskRoot, allowedId, deferredId});
  const retried = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assertSuccessful(retried);
  assert.equal(fs.existsSync(taskGatePath(taskRoot)), false);
});

test("managed execution rechecks live task state before every child", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-recheck-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {checkoutPaths: materializedSnapshotInputClosure});
  const {allowedId, deferredId, taskRoot} = createManagedTaskFixture(primaryRoot, {
    allowedCheckCount: 2,
  });
  const countPath = path.join(taskRoot, "task-phase-count.txt");
  configureTaskPhaseSentinel({
    root: taskRoot,
    allowedId,
    deferredId,
    allowedCheckCount: 2,
    script: [
      'import fs from "node:fs";',
      'import {spawnSync} from "node:child_process";',
      'const countPath = "task-phase-count.txt";',
      'const count = fs.existsSync(countPath) ? Number(fs.readFileSync(countPath, "utf8")) + 1 : 1;',
      'fs.writeFileSync(countPath, String(count));',
      'if (count === 1) {',
      '  const location = spawnSync("git", ["rev-parse", "--git-path", "catch-task.json"], {encoding: "utf8"});',
      '  const metadataPath = location.stdout.trim();',
      '  const metadata = JSON.parse(fs.readFileSync(metadataPath, "utf8"));',
      '  metadata.status = "finishing";',
      '  fs.writeFileSync(metadataPath, `${JSON.stringify(metadata, null, 2)}\\n`);',
      '}',
      "",
    ].join("\n"),
  });

  const result = runNode(taskRoot, ["tool/run.mjs", "check", allowedId]);
  assert.equal(result.status, 77, result.stderr || result.stdout);
  assert.match(result.stderr, /task_phase_not_active:finishing/u);
  assert.equal(fs.readFileSync(countPath, "utf8"), "1");
  assert.equal(fs.existsSync(taskGatePath(taskRoot)), false);
});

test("canonical task worktrees cannot become unmanaged when metadata is missing", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-missing-task-receipt-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  const taskRoot = path.join(primaryRoot, ".claude", "worktrees", "fixture-task");
  fs.mkdirSync(taskRoot, {recursive: true});
  const metadataPath = path.join(
    primaryRoot,
    ".git",
    "worktrees",
    "fixture-task",
    "catch-task.json",
  );
  const gitRunner = ({args}) => {
    if (args.includes("--show-toplevel")) return processResult(taskRoot);
    if (args.includes("--git-common-dir")) return processResult(path.join(primaryRoot, ".git"));
    if (args.includes("--absolute-git-dir")) {
      return processResult(path.join(primaryRoot, ".git", "worktrees", "fixture-task"));
    }
    if (args.includes("--git-path")) return processResult(metadataPath);
    return processResult("", 1);
  };
  const managed = readTaskExecutionContext({cwd: taskRoot, gitRunner});
  assert.equal(managed.kind, "blocked");
  assert.deepEqual(managed.blockers, ["managed_task_metadata_missing"]);

  const ordinaryMetadata = path.join(primaryRoot, ".git", "catch-task.json");
  const ordinary = readTaskExecutionContext({
    cwd: primaryRoot,
    gitRunner: ({args}) => {
      if (args.includes("--show-toplevel")) return processResult(primaryRoot);
      if (args.includes("--git-common-dir")) return processResult(path.join(primaryRoot, ".git"));
      if (args.includes("--absolute-git-dir")) return processResult(path.join(primaryRoot, ".git"));
      if (args.includes("--git-path")) return processResult(ordinaryMetadata);
      return processResult("", 1);
    },
  });
  assert.equal(ordinary.kind, "unmanaged");
});

test("managed workers fail closed on malformed, legacy, stale, and forged receipts", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-task-receipt-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  createSnapshotFixtureClone(primaryRoot, {
    checkoutPaths: materializedSnapshotInputClosure,
  });

  const {metadata: initialMetadata, taskRoot} = createManagedTaskFixture(primaryRoot);
  const allowedId = initialMetadata.contextPack.checkIds[0];
  const metadataPath = taskMetadataPath(taskRoot);
  const cases = [
    {
      prepare() {
        fs.writeFileSync(metadataPath, "{ definitely not json\n");
      },
      reason: "task_metadata_invalid_json",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.schema = "catch.harness-task/v3";
        }, {recomputeDigest: false});
      },
      reason: "task_metadata_schema_not_current",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.status = "terminal";
        });
      },
      reason: "task_phase_not_active:terminal",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.status = "finishing";
        });
      },
      reason: "task_phase_not_active:finishing",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.contextPack.digest = "f".repeat(64);
        }, {recomputeDigest: false});
      },
      reason: "task_context_digest_mismatch",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.branch = "codex/not-the-current-branch";
        });
      },
      reason: "task_metadata_branch_mismatch",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.baseSha = "f".repeat(40);
          metadata.contextPack.sourceSha = metadata.baseSha;
        });
      },
      reason: "task_base_not_ancestor_of_head",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          const promoted = metadata.contextPack.deferredCheckIds[0];
          metadata.contextPack.deferredCheckIds = metadata.contextPack.deferredCheckIds
            .filter((id) => id !== promoted);
          metadata.contextPack.checkIds = [...metadata.contextPack.checkIds, promoted].sort();
        });
      },
      reason: "task_authority_metadata_mismatch",
    },
    {
      prepare() {
        writeManagedTaskMetadata(taskRoot, (metadata) => {
          metadata.contextPack.requiredEntrypoints = ["tool/not-materialized.mjs"];
        });
      },
      reason: "task_required_entrypoint_missing:tool/not-materialized.mjs",
    },
  ];
  for (const fixture of cases) {
    fixture.prepare();
    const result = runNode(taskRoot, [
      "tool/run.mjs",
      "check",
      allowedId,
    ]);
    assert.equal(result.status, 77, result.stderr || result.stdout);
    assert.match(result.stderr, new RegExp(fixture.reason));
    assert.doesNotMatch(result.stdout, /==>/u);
  }
});

test("index-view tools stay inside the fixed Node-only checkout contract", () => {
  const manifest = JSON.parse(fs.readFileSync("tool/tools_manifest.json", "utf8"));
  const incompatible = manifest.tools
    .filter((tool) => tool.status === "active")
    .filter((tool) => tool.ciRequirements?.repositoryView === "index")
    .filter(
      (tool) => JSON.stringify(tool.ciRequirements.setup) !== '["node"]',
    )
    .map((tool) => ({
      id: tool.id,
      setup: tool.ciRequirements.setup,
    }));
  assert.deepEqual(incompatible, []);
});

test("affected-tool GitHub outputs carry bounded control signals only", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-tool-impact-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  createSnapshotFixtureClone(directory, {checkoutPaths: materializedSnapshotInputClosure});
  const outputPath = path.join(directory, "github-output");
  const result = runNode(directory, ["tool/run.mjs",
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs",
    "--github-output",
    outputPath,
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const output = fs.readFileSync(outputPath, "utf8");
  assert.equal(
    output,
    "tool_mode=affected\naffected=true\nfull=false\n" +
      "repository_view=index\nsetup_requirements=[\"node\"]\n",
  );
  assert.doesNotMatch(output, /docs:version-monotonic/u);
});

test("runner and context pack agree when canonical inputs are materialized or sparse-omitted", (context) => {
  const temporaryRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-snapshot-callsites-"),
  );
  context.after(() => fs.rmSync(temporaryRoot, {recursive: true, force: true}));

  const materializedRoot = path.join(temporaryRoot, "materialized");
  const omittedRoot = path.join(temporaryRoot, "omitted");
  createSnapshotFixtureClone(materializedRoot, {
    checkoutPaths: materializedSnapshotInputClosure,
  });
  createSnapshotFixtureClone(omittedRoot, {
    checkoutPaths: sparseExecutableClosure,
  });

  assert.equal(
    fs.existsSync(path.join(omittedRoot, "tool/tools_manifest.json")),
    false,
    "the sparse fixture must omit the manifest consumed by the runner",
  );
  assert.equal(
    fs.existsSync(path.join(omittedRoot, "docs/audit_registry/rules.json")),
    false,
    "the sparse fixture must omit context-pack rule data",
  );
  assert.equal(
    fs.existsSync(path.join(omittedRoot, "tool/check_enforcement_integrity.mjs")),
    false,
    "the sparse fixture must omit a managed script validated by the runner",
  );

  const materializedManifest = runNode(materializedRoot, [
    "tool/run.mjs",
    "check",
    "--manifest-only",
  ]);
  const omittedManifest = runNode(omittedRoot, [
    "tool/run.mjs",
    "check",
    "--manifest-only",
  ]);
  assertSuccessful(materializedManifest);
  assert.deepEqual(
    comparableProcessResult(omittedManifest),
    comparableProcessResult(materializedManifest),
  );
  assert.equal(omittedManifest.stdout, "Tool manifest validation passed.\n");
  assert.doesNotMatch(omittedManifest.stderr, /missing path|Unmanaged tool script/u);

  const contextArgs = [
    "tool/agent/context_pack.mjs",
    "--task",
    "snapshot-callsite-equivalence",
    "--owned-paths",
    "tool/run.mjs,tool/agent/context_pack.mjs",
    "--json",
  ];
  const materializedContext = runNode(materializedRoot, contextArgs);
  const omittedContext = runNode(omittedRoot, contextArgs);
  assertSuccessful(materializedContext);
  assertSuccessful(omittedContext);
  const normalizedContext = normalizeContextPack(omittedContext.stdout);
  assert.deepEqual(
    normalizedContext,
    normalizeContextPack(materializedContext.stdout),
  );
  assert.ok(
    normalizedContext.ownerDocs.some(
      (entry) => entry.path === "docs/agent_operating_model.md",
    ),
  );
  assert.ok(normalizedContext.activeRules.length > 0);
  assert.ok(normalizedContext.regressionGuards.length > 0);
  assert.equal(normalizedContext.schema, "catch.agent-context-pack/v3");
  assert.ok(
    normalizedContext.taskStart.blockers.includes("task_start_requires_parallel_delegation_mode"),
  );
  assert.equal(
    normalizedContext.taskStart.blockers.includes("source_worktree_not_clean"),
    normalizedContext.sourceClean === false,
  );
  assert.ok(
    normalizedContext.taskStart.deferredRegressionIds.length > 0,
  );
});

test("parallel delegation context mode is lifecycle-complete without an adapter skill", () => {
  const result = runNode(process.cwd(), [
    "tool/agent/context_pack.mjs",
    "--task",
    "parallel-work",
    "--owned-paths",
    "docs/agent_operating_model.md,tool/agent",
    "--planned-impact-paths",
    "docs/agent_operating_model.md,tool/agent",
    "--mode",
    "parallel-delegation",
    "--json",
  ]);
  assertSuccessful(result);
  const pack = JSON.parse(result.stdout);
  assert.equal(pack.mode, "parallel-delegation");
  assert.equal(pack.taskStart.blockers.includes(
    "planned_impact_required_for_owned_directory",
  ), false);
  assert.ok(pack.ownerDocs.some((doc) => doc.path === "docs/agent_operating_model.md"));
  assert.ok(pack.activeRules.some((rule) => rule.id === "AGENT-DELEGATION-001"));
  assert.ok(!pack.skills.some((skill) => skill.skill_id === "catch-parallel-delegation"));
  const commands = pack.commandPlan.map((entry) => entry.command);
  for (const command of [
    "node tool/harness.mjs task start --task-id <task-id> --base-sha <40-character-sha> --stack-parent <ref> --owned-paths <path[,path...]> --context-pack <pack.json> [--budget-mib 256]",
    "node tool/harness.mjs task doctor --worktree <task-worktree>",
    "node tool/harness.mjs task finish --worktree <task-worktree>",
    "node tool/harness.mjs task reap --dry-run [--merged-into origin/main] [--stale-days 7]",
    "node tool/agent/record_delegation_outcome.mjs --help",
  ]) {
    assert.ok(commands.includes(command), command);
  }
  assert.ok(pack.commandPlan.every((entry) => entry.owner && entry.phase));
  assert.equal(
    pack.commandPlan.find((entry) => entry.command.includes("task doctor"))?.owner,
    "worker",
  );
  assert.equal(
    pack.commandPlan.find((entry) => entry.command.includes("task finish"))?.owner,
    "parent",
  );
  assert.ok(pack.commandPlan
    .filter((entry) => entry.command.includes("audit_registry.dart") || entry.command.includes("flutter analyze"))
    .every((entry) => entry.owner === "parent"));
  assert.ok(!commands.some((command) => command.includes("--task parallel-delegation")));
});

test("tool scopes select the tooling router without a documentation fallback", () => {
  const result = runNode(process.cwd(), [
    "tool/agent/context_pack.mjs",
    "--task",
    "task-input-tooling",
    "--owned-paths",
    "tool/agent/lib/task_input.mjs",
    "--json",
  ]);
  assertSuccessful(result);
  const pack = JSON.parse(result.stdout);
  assert.ok(pack.skills.some((skill) => skill.skill_id === "catch-tooling-automation"));
  assert.ok(!pack.skills.some((skill) => skill.skill_id === "catch-doc-hygiene"));
});

test("directory scopes select skills from tracked descendants", () => {
  const result = runNode(process.cwd(), [
    "tool/agent/context_pack.mjs",
    "--task",
    "explore-feature",
    "--owned-paths",
    "lib/explore",
    "--json",
  ]);
  assertSuccessful(result);
  const skillIds = JSON.parse(result.stdout).skills.map((skill) => skill.skill_id);
  assert.ok(skillIds.includes("catch-ui-implementation"), JSON.stringify(skillIds));
  assert.ok(skillIds.includes("catch-contract-change"), JSON.stringify(skillIds));
});

test("broad ownership and narrow planned impact select only the narrow closure", () => {
  const impactPaths = [
    "docs/audit_registry/doc_versions.json",
    "docs/audit_registry/files.jsonl",
    "docs/audit_registry/passes.jsonl",
  ];
  const generate = (ownedPaths) => {
    const result = runNode(process.cwd(), [
      "tool/agent/context_pack.mjs",
      "--task",
      "audit-receipt-slice",
      "--owned-paths",
      ownedPaths.join(","),
      "--planned-impact-paths",
      impactPaths.join(","),
      "--mode",
      "parallel-delegation",
      "--json",
    ]);
    assertSuccessful(result);
    return JSON.parse(result.stdout);
  };
  const broad = generate(["docs/audit_registry"]);
  const exact = generate(impactPaths);
  assert.deepEqual(broad.scope, {
    ownedPaths: ["docs/audit_registry"],
    plannedImpactPaths: impactPaths,
    note: "Owned paths are the write ceiling; planned impacts select checks and constrain the actual diff.",
  });
  assert.deepEqual(broad.taskStart.ownedPaths, ["docs/audit_registry"]);
  assert.deepEqual(broad.taskStart.plannedImpactPaths, impactPaths);
  assert.deepEqual(
    broad.skills.map((entry) => entry.skill_id),
    exact.skills.map((entry) => entry.skill_id),
  );
  assert.deepEqual(
    broad.regressionGuards.map((entry) => entry.id),
    exact.regressionGuards.map((entry) => entry.id),
  );
  assert.deepEqual(
    broad.checkPlan.task.map((entry) => entry.id),
    exact.checkPlan.task.map((entry) => entry.id),
  );
  assert.deepEqual(
    broad.checkPlan.integration.map((entry) => entry.id),
    exact.checkPlan.integration.map((entry) => entry.id),
  );
});

test("parallel directory ownership requires an explicit planned impact", () => {
  const result = runNode(process.cwd(), [
    "tool/agent/context_pack.mjs",
    "--task",
    "explicit-impact",
    "--owned-paths",
    "docs/audit_registry",
    "--mode",
    "parallel-delegation",
    "--json",
  ]);
  assertSuccessful(result);
  const pack = JSON.parse(result.stdout);
  assert.ok(pack.taskStart.blockers.includes("planned_impact_required_for_owned_directory"));
  assert.equal(pack.taskStart.complete, false);
});

test("context-pack CLI rejects retired ambiguous path spellings", () => {
  for (const args of [
    ["--task", "retired-owned-alias", "--paths", "docs", "--json"],
    ["--task", "retired-singular-alias", "--path", "docs/README.md", "--json"],
    ["--task", "retired-impact-alias", "--owned-paths", "docs", "--impact-paths", "docs/README.md", "--json"],
    ["--task", "retired-positional-alias", "docs/README.md", "--json"],
  ]) {
    const result = runNode(process.cwd(), ["tool/agent/context_pack.mjs", ...args]);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /Unknown argument|Unexpected positional/u);
  }
});

test("planned future leaves are valid only beneath the owned boundary", () => {
  const generate = (impactPath) => {
    const result = runNode(process.cwd(), [
      "tool/agent/context_pack.mjs",
      "--task",
      "future-impact",
      "--owned-paths",
      "docs",
      "--planned-impact-paths",
      impactPath,
      "--mode",
      "parallel-delegation",
      "--json",
    ]);
    assertSuccessful(result);
    return JSON.parse(result.stdout);
  };
  const future = generate("docs/future-impact.md");
  assert.equal(future.taskStart.blockers.some((entry) =>
    entry.startsWith("planned_impact_")), false, JSON.stringify(future.taskStart.blockers));
  const outside = generate("lib/explore/explore_page.dart");
  assert.ok(outside.taskStart.blockers.includes(
    "planned_impact_outside_owned_scope:lib/explore/explore_page.dart",
  ));
});

test("context-pack output writes the full artifact but prints a compact receipt", (context) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-context-output-"));
  context.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const output = path.join(directory, "pack.json");
  const result = runNode(process.cwd(), [
    "tool/agent/context_pack.mjs",
    "--task",
    "compact-output",
    "--owned-paths",
    "tool/agent/lib/task_input.mjs",
    "--json",
    "--output",
    output,
  ]);
  assertSuccessful(result);
  const receipt = JSON.parse(result.stdout);
  const pack = JSON.parse(fs.readFileSync(output, "utf8"));
  assert.equal(receipt.output, output);
  assert.equal(receipt.task, pack.task);
  assert.equal(receipt.digest, pack.taskStart.digest);
  assert.equal(receipt.blockerCount, pack.taskStart.blockers.length);
  assert.deepEqual(receipt.blockers, pack.taskStart.blockers.slice(0, 10));
  assert.equal(receipt.blockersTruncated, pack.taskStart.blockers.length > 10);
  assert.ok(result.stdout.length < 500, result.stdout.length);
  assert.ok(fs.statSync(output).size > result.stdout.length * 10);
});

test("context packs mark invalid task ids and unmaterializable scopes incomplete", () => {
  const cases = [
    {
      args: ["--mode", "parallel-delegation", "--json"],
      blockers: ["invalid_task_id", "task_scope_empty"],
    },
    {
      args: [
        "--task", "Not A Harness Id",
        "--owned-paths", "docs",
        "--mode", "parallel-delegation",
        "--json",
      ],
      blockers: ["invalid_task_id"],
    },
    {
      args: [
        "--task", "missing-scope",
        "--owned-paths", "definitely/not/a/repository/path",
        "--mode", "parallel-delegation",
        "--json",
      ],
      blockers: ["task_scope_path_missing:definitely/not/a/repository/path"],
    },
  ];
  for (const fixture of cases) {
    const result = runNode(process.cwd(), ["tool/agent/context_pack.mjs", ...fixture.args]);
    assertSuccessful(result);
    const pack = JSON.parse(result.stdout);
    assert.equal(pack.taskStart.complete, false);
    for (const blocker of fixture.blockers) assert.ok(pack.taskStart.blockers.includes(blocker));
  }
});

test("tool preflight checkout closure runs the pin guard without product files", (context) => {
  const temporaryRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-tool-preflight-"),
  );
  context.after(() => fs.rmSync(temporaryRoot, {recursive: true, force: true}));

  createSparseClone(temporaryRoot, toolPreflightCheckoutClosure);

  for (const relativePath of [
    "tool/ci/check_toolchain_consistency.sh",
    ".github/actions/load-toolchain/action.yml",
    "functions/package.json",
    "pubspec.yaml",
    ".github/workflows/app-build-matrix.yml",
    ".github/workflows/mobile-internal-release.yml",
    ".github/workflows/visual-integration-ci.yml",
  ]) {
    assert.equal(
      fs.existsSync(path.join(temporaryRoot, relativePath)),
      true,
      `${relativePath} must be materialized by the preflight closure`,
    );
  }
  assertRepresentativeProductFilesOmitted(temporaryRoot);

  const result = spawnSync(
    "bash",
    ["tool/ci/check_toolchain_consistency.sh"],
    {cwd: temporaryRoot, encoding: "utf8"},
  );
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.match(result.stdout, /CI toolchain pins are consistent\./u);
});

test("affected index checkout closure executes the complete bounded guard set", (context) => {
  const temporaryRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-affected-index-"),
  );
  context.after(() => fs.rmSync(temporaryRoot, {recursive: true, force: true}));

  createSparseClone(temporaryRoot, affectedIndexCheckoutClosure);

  for (const relativePath of [
    "tool/run.mjs",
    ".github/actions/load-toolchain/action.yml",
    "docs/audit_registry/doc_versions.json",
    "docs/audit_registry/test_inventory.json",
  ]) {
    assert.equal(
      fs.existsSync(path.join(temporaryRoot, relativePath)),
      true,
      `${relativePath} must be materialized by the affected index closure`,
    );
  }
  assertRepresentativeProductFilesOmitted(temporaryRoot);

  const result = runNode(temporaryRoot, [
    "tool/run.mjs",
    "affected-tools",
    "--paths",
    "tool/docs/check_doc_version_monotonic.mjs",
    "--check",
  ]);
  assertSuccessful(result);
  for (const toolId of [
    "agent:readiness",
    "docs:version-monotonic",
    "meta:enforcement-integrity",
    "meta:repository-root-hygiene",
    "meta:test-inventory",
  ]) {
    assert.match(result.stdout, new RegExp(`==> ${toolId}`));
  }
});

function createSnapshotFixtureClone(destination, {checkoutPaths}) {
  createSparseClone(destination, checkoutPaths);

  for (const relativePath of [
    "tool/run.mjs",
    "tool/agent/context_pack.mjs",
    "tool/agent/lib/task_input.mjs",
    "tool/docs/check_doc_version_monotonic.mjs",
    "tool/harness/lib/task_contract.mjs",
    "tool/harness/lib/task_execution_context.mjs",
    "tool/harness/lib/worktree_lifecycle.mjs",
    "tool/lib/tool_impact.mjs",
  ]) {
    const destinationPath = path.join(destination, relativePath);
    fs.mkdirSync(path.dirname(destinationPath), {recursive: true});
    fs.copyFileSync(path.join(repositoryRoot, relativePath), destinationPath);
  }
}

function createSparseClone(destination, checkoutPaths) {
  runGit(repositoryRoot, [
    "clone",
    "--shared",
    "--no-checkout",
    repositoryRoot,
    destination,
  ]);
  runGit(destination, ["sparse-checkout", "init", "--no-cone"]);
  runGit(destination, [
    "sparse-checkout",
    "set",
    "--no-cone",
    "--",
    ...checkoutPaths,
  ]);
  runGit(destination, ["checkout", "--detach", "HEAD"]);
}

function assertRepresentativeProductFilesOmitted(root) {
  for (const relativePath of [
    "lib/main.dart",
    "website/package.json",
    "admin/package.json",
  ]) {
    assert.equal(
      fs.existsSync(path.join(root, relativePath)),
      false,
      `${relativePath} must remain sparse-omitted`,
    );
  }
}

function runGit(cwd, args) {
  const result = spawnSync("git", args, {cwd, encoding: "utf8"});
  assert.equal(
    result.status,
    0,
    `git ${args.join(" ")} failed:\n${result.stderr || result.stdout}`,
  );
}

function createManagedTaskFixture(primaryRoot, {allowedCheckCount = 1} = {}) {
  runGit(primaryRoot, ["config", "user.name", "Catch Test"]);
  runGit(primaryRoot, ["config", "user.email", "catch-test@example.com"]);
  runGit(primaryRoot, ["switch", "-c", "fixture-primary"]);
  fs.mkdirSync(path.join(primaryRoot, "lib"), {recursive: true});
  fs.writeFileSync(path.join(primaryRoot, "lib", "fixture_scope.txt"), "fixture scope\n");
  runGit(primaryRoot, [
    "add",
    "--sparse",
    "lib/fixture_scope.txt",
    "tool/run.mjs",
    "tool/harness/lib/task_execution_context.mjs",
    "tool/harness/lib/worktree_lifecycle.mjs",
  ]);
  runGit(primaryRoot, ["commit", "-m", "fixture current task authority"]);
  const taskId = "fixture-task-phase-authority";
  const branch = `codex/${taskId}`;
  const provisionalBaseSha = gitText(primaryRoot, ["rev-parse", "HEAD"]);
  const provisionalMetadata = {
    taskId,
    baseSha: provisionalBaseSha,
    ownedPaths: ["lib/fixture_scope.txt", "tool"],
    plannedImpactPaths: ["lib/fixture_scope.txt"],
    contextPack: {
      mode: "parallel-delegation",
      taskInputSchema: "catch.harness-task-input/v2",
    },
  };
  const provisional = deriveTaskStartContractAtBase({
    metadata: provisionalMetadata,
    cwd: primaryRoot,
  });
  const allowedId = provisional.checkIds[0];
  const deferredId = provisional.deferredCheckIds[0];
  assert.ok(allowedId);
  assert.ok(deferredId);
  const sentinelManifest = configureTaskPhaseSentinel({
    root: primaryRoot,
    allowedId,
    deferredId,
    allowedCheckCount,
  });
  runGit(primaryRoot, ["commit", "-m", "fixture authorized sentinel command"]);
  const taskRoot = path.join(primaryRoot, ".claude", "worktrees", taskId);
  fs.mkdirSync(path.dirname(taskRoot), {recursive: true});
  runGit(primaryRoot, ["worktree", "add", "-b", branch, taskRoot, "HEAD"]);
  const baseSha = gitText(taskRoot, ["rev-parse", "HEAD"]);
  const metadata = {
    schema: "catch.harness-task/v5",
    status: "active",
    authorityId: randomUUID(),
    worktreeAdminId: path.basename(gitText(taskRoot, ["rev-parse", "--absolute-git-dir"])),
    taskId,
    baseSha,
    stackParent: "fixture-primary",
    stackParentSha: baseSha,
    branch,
    worktreePath: taskRoot,
    sparsePaths: materializedSnapshotInputClosure,
    ownedPaths: ["lib/fixture_scope.txt", "tool"],
    plannedImpactPaths: ["lib/fixture_scope.txt"],
    contextPack: {
      packSchema: "catch.agent-context-pack/v3",
      taskInputSchema: "catch.harness-task-input/v2",
      mode: "parallel-delegation",
      sourceSha: baseSha,
    },
    budgetAllocatedBytes: 1024 * 1024 * 1024,
    reserveAllocatedBytes: 1,
    estimatedTrackedLogicalBytes: 1,
    projectedInitialAllocatedBytes: 1,
    initialMaterializedLogicalBytes: 1,
    initialMaterializedAllocatedBytes: 1,
    creatorPid: process.pid,
    createdAt: new Date().toISOString(),
  };
  const expected = deriveTaskStartContractAtBase({metadata, cwd: taskRoot});
  Object.assign(metadata.contextPack, {
    digest: expected.digest,
    checkIds: expected.checkIds,
    deferredCheckIds: expected.deferredCheckIds,
    deferredRegressionIds: expected.deferredRegressionIds,
    supportPaths: expected.supportPaths,
    requiredEntrypoints: expected.requiredEntrypoints,
  });
  fs.writeFileSync(taskMetadataPath(taskRoot), `${JSON.stringify(metadata, null, 2)}\n`, {
    encoding: "utf8",
    flag: "wx",
  });
  createTaskAuthorityFile({cwd: taskRoot, metadata});
  runGit(primaryRoot, [
    "worktree",
    "lock",
    "--reason",
    `catch-task:${taskId}:${metadata.authorityId}`,
    taskRoot,
  ]);
  return {allowedId, deferredId, manifest: sentinelManifest, metadata, primaryRoot, taskRoot};
}

function writeManagedTaskMetadata(
  root,
  mutate = () => {},
  {recomputeDigest = true} = {},
) {
  const authority = JSON.parse(fs.readFileSync(taskAuthorityPath(root), "utf8"));
  const metadata = {
    schema: "catch.harness-task/v5",
    status: "active",
    ...structuredClone(authority.payload),
  };
  mutate(metadata);
  if (recomputeDigest && metadata.schema === "catch.harness-task/v5") {
    const {digest: _digest, ...payload} = taskStartContractFromMetadata(metadata);
    metadata.contextPack.digest = digestTaskStart(payload);
  }
  fs.writeFileSync(taskMetadataPath(root), `${JSON.stringify(metadata, null, 2)}\n`);
  return metadata;
}

function configureTaskPhaseSentinel({
  root,
  allowedId,
  deferredId,
  allowedCheckCount = 1,
  script = 'import fs from "node:fs";\nfs.writeFileSync("task-phase-sentinel.txt", "child-dispatched\\n");\n',
}) {
  const manifestPath = path.join(root, "tool", "tools_manifest.json");
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const command = "node tool/fixtures/task_phase_sentinel.mjs";
  const allowed = manifest.tools.find((tool) => tool.id === allowedId);
  const deferred = manifest.tools.find((tool) => tool.id === deferredId);
  assert.ok(allowed, allowedId);
  assert.ok(deferred, deferredId);
  allowed.checks = Array.from({length: allowedCheckCount}, () => command);
  allowed.command = command;
  deferred.checks = [command];
  deferred.command = command;
  deferred.platforms = [process.platform === "darwin" ? "linux" : "darwin"];
  const sentinelScript = path.join(root, "tool", "fixtures", "task_phase_sentinel.mjs");
  fs.mkdirSync(path.dirname(sentinelScript), {recursive: true});
  fs.writeFileSync(sentinelScript, script);
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  runGit(root, [
    "add",
    "--sparse",
    "tool/tools_manifest.json",
    "tool/fixtures/task_phase_sentinel.mjs",
  ]);
  return manifest;
}

function taskMetadataPath(root) {
  return path.resolve(root, gitText(root, ["rev-parse", "--git-path", "catch-task.json"]));
}

function taskAuthorityPath(root) {
  return path.join(
    path.resolve(root, gitText(root, ["rev-parse", "--git-common-dir"])),
    "catch-harness",
    "tasks",
    path.basename(gitText(root, ["rev-parse", "--absolute-git-dir"])),
    "authority.json",
  );
}

function taskGatePath(root) {
  return path.join(path.dirname(taskAuthorityPath(root)), "gate");
}

async function waitForPath(targetPath, timeoutMs = 5000) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (fs.existsSync(targetPath)) return;
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
  throw new Error(`Timed out waiting for ${targetPath}`);
}

async function waitForTaskChildRecord(taskRoot, timeoutMs = 5000) {
  const gatePath = taskGatePath(taskRoot);
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    try {
      const owner = JSON.parse(fs.readFileSync(path.join(gatePath, "owner.json"), "utf8"));
      const childrenPath = path.join(gatePath, `generation-${owner.token}`, "children");
      if (fs.existsSync(childrenPath)) {
        const entry = fs.readdirSync(childrenPath).find((name) => name.endsWith(".json"));
        if (entry) return JSON.parse(fs.readFileSync(path.join(childrenPath, entry), "utf8"));
      }
    } catch {
      // The gate can be between atomic generations while the runner starts or exits.
    }
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
  throw new Error(`Timed out waiting for a task child record in ${gatePath}`);
}

function collectChildResult(child) {
  let stdout = "";
  let stderr = "";
  child.stdout.on("data", (chunk) => {
    stdout += chunk;
  });
  child.stderr.on("data", (chunk) => {
    stderr += chunk;
  });
  return new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("close", (status, signal) => resolve({status, signal, stdout, stderr}));
  });
}

function gitText(cwd, args) {
  const result = spawnSync("git", args, {cwd, encoding: "utf8"});
  assert.equal(
    result.status,
    0,
    `git ${args.join(" ")} failed:\n${result.stderr || result.stdout}`,
  );
  return result.stdout.trim();
}

function processResult(stdout, status = 0) {
  return {status, stdout: `${stdout}\n`, stderr: ""};
}

function runNode(cwd, args) {
  const env = {...process.env, GIT_CONFIG_NOSYSTEM: "1"};
  delete env.NODE_TEST_CONTEXT;
  return spawnSync(process.execPath, args, {
    cwd,
    encoding: "utf8",
    env,
  });
}

function assertSuccessful(result) {
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.equal(result.signal, null);
  assert.equal(result.stderr, "");
}

function comparableProcessResult(result) {
  return {
    status: result.status,
    signal: result.signal,
    stdout: result.stdout,
    stderr: result.stderr,
  };
}

function normalizeContextPack(source) {
  const payload = JSON.parse(source);
  delete payload.generatedAt;
  return payload;
}
