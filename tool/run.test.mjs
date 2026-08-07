import test from "node:test";
import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  supportedToolPlatforms,
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";

const repositoryRoot = process.cwd();
const sparseExecutableClosure = [
  "/tool/agent/context_pack.mjs",
  "/tool/agent/lib/task_input.mjs",
  "/tool/docs/check_doc_version_monotonic.mjs",
  "/tool/harness/lib/component_graph.mjs",
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

test("affected-tool routing fails closed for any unmapped lane input", () => {
  const result = run([
    "affected-tools",
    "--paths",
    "design/screens/catch.screens.json",
    "--json",
  ]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.mode, "full");
  assert.deepEqual(payload.unmappedPaths, ["design/screens/catch.screens.json"]);

  const execution = run([
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
  const outputPath = path.join(directory, "github-output");
  const result = run([
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
    "--paths",
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
    "--paths",
    "docs/agent_operating_model.md,tool/agent",
    "--impact-paths",
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
    "node tool/harness.mjs task start --task-id <task-id> --base-sha <40-character-sha> --stack-parent <ref> --paths <path[,path...]> --context-pack <pack.json> [--budget-mib 256]",
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
    "--paths",
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
    "--paths",
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
      "--paths",
      ownedPaths.join(","),
      "--impact-paths",
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
    "--paths",
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

test("planned future leaves are valid only beneath the owned boundary", () => {
  const generate = (impactPath) => {
    const result = runNode(process.cwd(), [
      "tool/agent/context_pack.mjs",
      "--task",
      "future-impact",
      "--paths",
      "docs",
      "--impact-paths",
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
    "--paths",
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
        "--paths", "docs",
        "--mode", "parallel-delegation",
        "--json",
      ],
      blockers: ["invalid_task_id"],
    },
    {
      args: [
        "--task", "missing-scope",
        "--paths", "definitely/not/a/repository/path",
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
