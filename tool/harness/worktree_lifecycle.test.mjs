import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test, {after} from "node:test";
import {
  assertCapacity,
  assertSafeTaskTarget,
  classifyReapCandidate,
  executeTaskCommand,
  normalizeSparsePaths,
  parseWorktreePorcelain,
  taskHelp,
  taskSparseAnchorPaths,
} from "./lib/worktree_lifecycle.mjs";
import {taskCommandTemplates} from "./lib/task_contract.mjs";
import {
  buildTaskStartContract,
  CONTEXT_PACK_SCHEMA_V3,
  deriveTaskCheckSelection,
  digestTaskStart,
  resolveStructuredCheckPlan,
  TASK_INPUT_SCHEMA_V1,
  TASK_START_MODE,
} from "../agent/lib/task_input.mjs";
import {
  acquireTaskExecutionLease,
  recoverStaleTaskExecutionLease,
  registerTaskExecutionChild,
  TASK_EXECUTION_CHILD_SCHEMA_V1,
} from "./lib/task_execution_context.mjs";

const MIB = 1024 * 1024;
const TEST_CLAUDE_ROOT = path.join(process.cwd(), ".claude");
const TEST_FIXTURE_PARENT = path.join(TEST_CLAUDE_ROOT, "test-fixtures");
const closedOwnedFixturePaths = new Set();
let processFixtureSession = null;

test("task help derives every lifecycle command from the canonical contract", () => {
  const help = taskHelp();
  for (const command of Object.values(taskCommandTemplates)) {
    assert.equal(help.split(command).length - 1, 1, command);
  }
  assert.equal(help.match(/task recover-lease/gu)?.length, 1);
});

pruneSharedFixtureParents();
after(() => {
  if (processFixtureSession) {
    removeOwnedEmptyDirectory(processFixtureSession);
    processFixtureSession = null;
  }
  pruneSharedFixtureParents();
});

test("worktree porcelain preserves lifecycle safety fields", () => {
  assert.deepEqual(
    parseWorktreePorcelain(`worktree /repo
HEAD aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
branch refs/heads/main

worktree /repo/.claude/worktrees/task
HEAD bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
detached
locked catch-task:task

worktree /private/tmp/stale
HEAD cccccccccccccccccccccccccccccccccccccccc
branch refs/heads/codex/stale
prunable gitdir file points to non-existent location
`),
    [
      {
        path: "/repo",
        head: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        branchRef: "refs/heads/main",
        bare: false,
        detached: false,
        locked: false,
        prunable: false,
      },
      {
        path: "/repo/.claude/worktrees/task",
        head: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        bare: false,
        detached: true,
        locked: true,
        lockReason: "catch-task:task",
        prunable: false,
      },
      {
        path: "/private/tmp/stale",
        head: "cccccccccccccccccccccccccccccccccccccccc",
        branchRef: "refs/heads/codex/stale",
        bare: false,
        detached: false,
        locked: false,
        prunable: true,
        prunableReason: "gitdir file points to non-existent location",
      },
    ],
  );
});

test("task paths are canonical and sparse paths cannot escape", () => {
  assert.throws(
    () => assertSafeTaskTarget({targetPath: "/private/tmp/catch-task", primaryRoot: "/repo"}),
    /OS-temp task worktree path/u,
  );
  assert.throws(
    () => assertSafeTaskTarget({targetPath: "/repo/other/task", primaryRoot: "/repo"}),
    /must be children/u,
  );
  assert.throws(
    () => assertSafeTaskTarget({
      targetPath: path.join(os.tmpdir(), "catch-task"),
      primaryRoot: path.join(os.tmpdir(), "catch-primary"),
    }),
    /OS-temp task worktree path/u,
  );
  assert.throws(() => normalizeSparsePaths(["../outside"]), /repository-relative/u);
  assert.throws(() => normalizeSparsePaths(["lib/**"]), /repository-relative and explicit/u);
  const paths = normalizeSparsePaths(["lib/user_profile/", "functions/src/index.ts"]);
  assert.ok(paths.includes("/AGENTS.md"));
  assert.ok(paths.includes("/analysis_options.yaml"));
  assert.ok(paths.includes("/apps/consumer/pubspec.yaml"));
  assert.ok(paths.includes("/apps/host/pubspec.yaml"));
  assert.ok(paths.includes("/assets/"));
  assert.ok(paths.includes("/packages/catch_ui_lints/"));
  assert.ok(paths.includes("/packages/phosphor_flutter/"));
  assert.ok(paths.includes("/pubspec.lock"));
  assert.ok(paths.includes("/pubspec.yaml"));
  assert.ok(paths.includes("/lib/user_profile"));
  assert.ok(paths.includes("/functions/src/index.ts"));

  for (const entrypoint of ["check_agent_readiness.mjs", "context_pack.mjs"]) {
    const source = fs.readFileSync(
      new URL(`../agent/${entrypoint}`, import.meta.url),
      "utf8",
    );
    const imports = [...source.matchAll(/from\s+["'](\.[^"']+)["']/gu)]
      .map((match) => path.posix.normalize(`/tool/agent/${match[1]}`));
    assert.ok(imports.length > 0);
    for (const importedPath of imports) {
      assert.ok(
        taskSparseAnchorPaths.some((anchor) =>
          anchor.endsWith("/")
            ? importedPath.startsWith(anchor)
            : importedPath === anchor,
        ),
        `${entrypoint} import is missing from the task sparse closure: ${importedPath}`,
      );
    }
  }
});

test("capacity preflight fails before a worktree can consume the reserve", () => {
  assert.throws(
    () => assertCapacity({
      availableAllocatedBytes: 197 * MIB,
      budgetAllocatedBytes: 256 * MIB,
      reserveAllocatedBytes: 1024 * MIB,
      projectedInitialAllocatedBytes: 40 * MIB,
    }),
    /Insufficient task-worktree capacity/u,
  );
  assert.throws(
    () => assertCapacity({
      availableAllocatedBytes: 4096 * MIB,
      budgetAllocatedBytes: 64 * MIB,
      reserveAllocatedBytes: 1024 * MIB,
      projectedInitialAllocatedBytes: 65 * MIB,
    }),
    /exceeds its 64.0 MiB allocated budget/u,
  );
});

test("closure-aware start materializes exact command support and records v5 authority", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {taskId: "closure-aware", baseSha});
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "closure-aware",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib/profile.txt",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  assert.equal(execution.status, 0);
  assert.equal(execution.result.metadata.schema, "catch.harness-task/v5");
  assert.match(execution.result.metadata.authorityId, /^[0-9a-f-]{36}$/u);
  assert.equal(execution.result.metadata.worktreeAdminId, "closure-aware");
  assert.deepEqual(execution.result.metadata.ownedPaths, ["lib/profile.txt"]);
  assert.deepEqual(execution.result.metadata.plannedImpactPaths, ["lib/profile.txt"]);
  assert.equal(Object.hasOwn(execution.result.metadata, "requestedSparsePaths"), false);
  assert.deepEqual(execution.result.metadata.contextPack.checkIds, [
    "agent:readiness",
    "fixture:check",
  ]);
  assert.deepEqual(execution.result.metadata.contextPack.deferredCheckIds, [
    "agent:harness-v2",
    "agent:record-delegation",
  ]);
  const target = execution.result.metadata.worktreePath;
  assert.equal(fs.readFileSync(path.join(target, "tool", "check.mjs"), "utf8"), "export const ok = true;\n");
  assert.equal(fs.existsSync(path.join(target, "unrelated.txt")), false);
  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));

  fs.unlinkSync(path.join(target, "tool", "check.mjs"));
  const missingDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(missingDoctor.status, 1);
  assert.ok(missingDoctor.result.blockers.includes(
    "required_command_entrypoint_missing:tool/check.mjs",
  ));
  const missingFinish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(missingFinish.status, 1);
  assert.ok(missingFinish.result.blockers.includes(
    "required_command_entrypoint_missing:tool/check.mjs",
  ));
});

test("closure-aware start rejects stale, tampered, and missing entrypoints before registration", (context) => {
  const fixture = createClosureFixture(context, {entrypoint: "tool/missing.mjs"});
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  const pack = writeContextPack(fixture, {
    taskId: "missing-entrypoint",
    baseSha,
    entrypoint: "tool/missing.mjs",
  });
  const common = [
    "start",
    "--task-id", "missing-entrypoint",
    "--base-sha", baseSha,
    "--stack-parent", "main",
    "--owned-paths", "lib/profile.txt",
    "--context-pack", ".task-pack.json",
  ];
  assert.throws(
    () => executeTaskCommand({args: common, cwd: fixture}),
    /Required command entrypoint is not a regular tracked file/u,
  );
  assert.doesNotMatch(git(fixture, ["worktree", "list", "--porcelain"]), /missing-entrypoint/u);
  assert.equal(git(fixture, ["branch", "--list", "codex/missing-entrypoint"]), "");

  pack.taskStart.digest = "0".repeat(64);
  fs.writeFileSync(path.join(fixture, ".task-pack.json"), `${JSON.stringify(pack, null, 2)}\n`);
  assert.throws(
    () => executeTaskCommand({args: common, cwd: fixture}),
    /context_pack_closure_mismatch|context_pack_digest_mismatch/u,
  );
});

test("new starts cannot bypass the context-pack contract", (context) => {
  const fixture = createGitFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "retired-path-flag",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--paths", "lib/profile.txt",
      ],
      cwd: fixture,
    }),
    /Unsupported start option: --paths/u,
  );
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "pack-required",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--owned-paths", "lib/profile.txt",
      ],
      cwd: fixture,
    }),
    /--context-pack is required/u,
  );
  assert.doesNotMatch(
    git(fixture, ["worktree", "list", "--porcelain"]),
    /retired-path-flag|pack-required/u,
  );
});

test("support-only command paths remain read-only through doctor and finish", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {taskId: "owned-scope", baseSha});
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "owned-scope",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib/profile.txt/",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  const target = execution.result.metadata.worktreePath;
  assert.deepEqual(execution.result.metadata.ownedPaths, ["lib/profile.txt"]);
  fs.appendFileSync(path.join(target, "tool", "check.mjs"), "// support edit\n");
  git(target, ["add", "tool/check.mjs"]);
  git(target, ["commit", "-m", "edit support only path"]);
  git(target, ["push"]);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("out_of_owned_scope:tool/check.mjs"));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("out_of_owned_scope:tool/check.mjs"));
});

test("broad ownership permits only the narrower planned impact", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {
    taskId: "narrow-impact",
    baseSha,
    ownedPath: "lib",
    plannedImpactPath: "lib/profile.txt",
  });
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "narrow-impact",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  const target = execution.result.metadata.worktreePath;
  assert.deepEqual(execution.result.metadata.ownedPaths, ["lib"]);
  assert.deepEqual(execution.result.metadata.plannedImpactPaths, ["lib/profile.txt"]);
  fs.writeFileSync(path.join(target, "lib", "other.txt"), "changed\n");
  git(target, ["add", "lib/other.txt"]);
  git(target, ["commit", "-m", "unplanned owned change"]);
  git(target, ["push"]);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("unplanned_impact:lib/other.txt"));
  assert.equal(doctor.result.blockers.includes("out_of_owned_scope:lib/other.txt"), false);
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("unplanned_impact:lib/other.txt"));
});

test("a missing planned path is an exact future leaf, not a directory wildcard", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {
    taskId: "future-leaf",
    baseSha,
    ownedPath: "lib",
    plannedImpactPath: "lib/new-entry",
  });
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "future-leaf",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  const target = execution.result.metadata.worktreePath;
  fs.writeFileSync(path.join(target, "lib", "new-entry"), "planned exact leaf\n");
  git(target, ["add", "lib/new-entry"]);
  git(target, ["commit", "-m", "planned exact leaf"]);
  git(target, ["push"]);
  const exactDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(exactDoctor.status, 0, JSON.stringify(exactDoctor.result));

  fs.unlinkSync(path.join(target, "lib", "new-entry"));
  fs.mkdirSync(path.join(target, "lib", "new-entry"));
  fs.writeFileSync(path.join(target, "lib", "new-entry", "nested.txt"), "nested\n");
  git(target, ["add", "--all", "lib/new-entry"]);
  git(target, ["commit", "-m", "nested unplanned change"]);
  git(target, ["push"]);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("unplanned_impact:lib/new-entry/nested.txt"));
});

test("an existing planned directory does not authorize unselected future descendants", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {
    taskId: "planned-tree",
    baseSha,
    ownedPath: "lib",
    plannedImpactPath: "lib",
    selectionImpactPaths: ["lib", "lib/other.txt", "lib/profile.txt"],
  });
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "planned-tree",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  const target = execution.result.metadata.worktreePath;
  fs.mkdirSync(path.join(target, "lib", "new-area"));
  fs.writeFileSync(path.join(target, "lib", "new-area", "new.txt"), "new\n");
  git(target, ["add", "lib/new-area/new.txt"]);
  git(target, ["commit", "-m", "unselected future descendant"]);
  git(target, ["push"]);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("unplanned_impact:lib/new-area/new.txt"));
});

test("planned impact outside ownership is refused before worktree registration", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {
    taskId: "outside-impact",
    baseSha,
    ownedPath: "lib/profile.txt",
    plannedImpactPath: "unrelated.txt",
  });
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "outside-impact",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--owned-paths", "lib/profile.txt",
        "--context-pack", ".task-pack.json",
      ],
      cwd: fixture,
    }),
    /planned_impact_outside_owned_scope:unrelated\.txt/u,
  );
  assert.doesNotMatch(git(fixture, ["worktree", "list", "--porcelain"]), /outside-impact/u);
});

test("malformed v5 receipt arrays block doctor and finish without changing state", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {taskId: "malformed-receipt", baseSha});
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "malformed-receipt",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib/profile.txt",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  const target = execution.result.metadata.worktreePath;
  const metadataPath = git(target, ["rev-parse", "--git-path", "catch-task.json"]);
  const metadata = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  metadata.contextPack.checkIds = "fixture:check";
  fs.writeFileSync(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("invalid_context_pack_receipt"));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("invalid_context_pack_receipt"));
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "active");
});

test("malformed v5 planned-impact receipts block doctor and finish", (context) => {
  const {metadata, metadataPath, target} = createStartedTask(context, "malformed-impact");
  fs.writeFileSync(metadataPath, `${JSON.stringify({
    ...metadata,
    plannedImpactPaths: ["lib/profile.txt", "lib/profile.txt"],
  }, null, 2)}\n`);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("context_pack_receipt_mismatch") ||
    doctor.result.blockers.includes("invalid_planned_impact_receipt"));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "active");
});

test("context packs cannot escape through a symlinked ancestor", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  const pack = writeContextPack(fixture, {taskId: "pack-symlink", baseSha});
  const outside = fs.mkdtempSync(path.join(createFixtureSession(), "outside-pack-"));
  context.after(() => cleanupOwnedFixtureChildren(processFixtureSession, [outside]));
  fs.writeFileSync(path.join(outside, "pack.json"), `${JSON.stringify(pack, null, 2)}\n`);
  fs.symlinkSync(outside, path.join(fixture, "pack-link"));
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "pack-symlink",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--owned-paths", "lib/profile.txt",
        "--context-pack", "pack-link/pack.json",
      ],
      cwd: fixture,
    }),
    /Context pack must be inside the invoking worktree/u,
  );
});

test("reap classification never treats weak evidence as deletion authority", () => {
  const shared = {
    path: "/repo/.claude/worktrees/task",
    dirty: false,
    locked: false,
    prunable: false,
    detached: false,
    livePid: false,
    ageDays: 20,
    metadata: null,
  };
  assert.deepEqual(
    classifyReapCandidate({
      worktree: {...shared, pushed: null, mergedIntoTarget: false},
      primaryRoot: "/repo",
      currentWorktree: "/repo/.claude/worktrees/current",
      canonicalRoot: "/repo/.claude/worktrees",
    }).classification,
    "blocked",
  );
  const legacy = classifyReapCandidate({
    worktree: {...shared, pushed: true, mergedIntoTarget: false},
    primaryRoot: "/repo",
    currentWorktree: "/repo/.claude/worktrees/current",
    canonicalRoot: "/repo/.claude/worktrees",
  });
  assert.equal(legacy.classification, "blocked");
  assert.ok(legacy.warnings.includes("legacy_missing_task_metadata"));
  assert.notEqual(legacy.classification, "safe_to_delete");
  const review = classifyReapCandidate({
    worktree: {
      ...shared,
      metadata: validV1Metadata(),
      pushed: true,
      mergedIntoTarget: false,
    },
    primaryRoot: "/repo",
    currentWorktree: "/repo/.claude/worktrees/current",
    canonicalRoot: "/repo/.claude/worktrees",
  });
  assert.equal(review.classification, "owner_review");
  assert.equal(
    classifyReapCandidate({
      worktree: {
        ...shared,
        metadata: validV1Metadata(),
        pushed: true,
        mergedIntoTarget: false,
        ignoredInspectionAvailable: false,
      },
      primaryRoot: "/repo",
      currentWorktree: "/repo/.claude/worktrees/current",
      canonicalRoot: "/repo/.claude/worktrees",
    }).classification,
    "blocked",
  );
  assert.equal(
    classifyReapCandidate({
      worktree: {...shared, pushed: true, mergedIntoTarget: false, remotelyPreserved: false},
      primaryRoot: "/repo",
      currentWorktree: "/repo/.claude/worktrees/current",
      canonicalRoot: "/repo/.claude/worktrees",
    }).classification,
    "blocked",
  );
  const malformedStorage = classifyReapCandidate({
    worktree: {
      ...shared,
      metadata: {
        schema: "catch.harness-task/v2",
        status: "terminal",
        budgetAllocatedBytes: "unknown",
      },
      pushed: true,
      mergedIntoTarget: true,
      ignoredInspectionAvailable: true,
    },
    primaryRoot: "/repo",
    currentWorktree: "/repo/.claude/worktrees/current",
    canonicalRoot: "/repo/.claude/worktrees",
  });
  assert.equal(malformedStorage.classification, "blocked");
  assert.ok(malformedStorage.reasons.includes("invalid_storage_metrics"));
});

test("reap refuses dirty, live, temp, current, and locked worktrees", () => {
  const base = {
    path: "/repo/.claude/worktrees/task",
    dirty: false,
    locked: false,
    prunable: false,
    detached: false,
    livePid: false,
    ageDays: 20,
    metadata: validV1Metadata(),
    pushed: true,
    mergedIntoTarget: true,
  };
  for (const mutation of [
    {dirty: true},
    {locked: true},
    {livePid: true, metadata: validV1Metadata("active")},
    {path: "/private/tmp/task"},
  ]) {
    const result = classifyReapCandidate({
      worktree: {...base, ...mutation},
      primaryRoot: "/repo",
      currentWorktree: "/repo/.claude/worktrees/current",
      canonicalRoot: "/repo/.claude/worktrees",
    });
    assert.notEqual(result.classification, "owner_review", JSON.stringify(mutation));
  }
  assert.equal(
    classifyReapCandidate({
      worktree: base,
      primaryRoot: "/repo",
      currentWorktree: base.path,
      canonicalRoot: "/repo/.claude/worktrees",
    }).classification,
    "retain",
  );
});

test("start uses an explicit sparse worktree and records local task metadata", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {taskId: "profile-slice", baseSha});
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "profile-slice",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib/profile.txt",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
    now: () => new Date("2026-08-06T12:00:00.000Z"),
    pid: 4242,
  });
  assert.equal(execution.status, 0);
  const target = path.join(fs.realpathSync(fixture), ".claude", "worktrees", "profile-slice");
  assert.equal(execution.result.metadata.worktreePath, target);
  assert.equal(fs.readFileSync(path.join(target, "lib", "profile.txt"), "utf8"), "profile\n");
  assert.equal(fs.existsSync(path.join(target, "unrelated.txt")), false);
  const metadataPath = git(target, ["rev-parse", "--git-path", "catch-task.json"]);
  const metadata = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  assert.equal(metadata.schema, "catch.harness-task/v5");
  assert.equal(metadata.baseSha, baseSha);
  assert.equal(metadata.creatorPid, 4242);
  assert.equal(metadata.stackParent, "main");
  assert.equal(metadata.budgetAllocatedBytes, 64 * MIB);
  assert.equal(metadata.reserveAllocatedBytes, MIB);
  assert.ok(metadata.estimatedTrackedLogicalBytes > 0);
  assert.ok(metadata.projectedInitialAllocatedBytes > metadata.estimatedTrackedLogicalBytes);
  assert.ok(metadata.initialMaterializedLogicalBytes > 0);
  assert.ok(metadata.initialMaterializedAllocatedBytes > 0);
  for (const ambiguousKey of ["estimatedTrackedBytes", "materializedBytes", "sizeBytes"]) {
    assert.equal(Object.hasOwn(metadata, ambiguousKey), false, ambiguousKey);
  }
  assert.deepEqual(
    Object.keys(execution.result.capacity).sort(),
    [
      "availableAllocatedBytes",
      "budgetAllocatedBytes",
      "projectedInitialAllocatedBytes",
      "requiredAllocatedBytes",
      "reserveAllocatedBytes",
    ],
  );
  assert.match(git(fixture, ["worktree", "list", "--porcelain"]), /locked catch-task:profile-slice/u);
  const authorityPath = path.join(
    path.resolve(target, git(target, ["rev-parse", "--git-common-dir"])),
    "catch-harness",
    "tasks",
    metadata.worktreeAdminId,
    "authority.json",
  );
  const authorityBefore = fs.readFileSync(authorityPath, "utf8");
  assert.equal(fs.lstatSync(authorityPath).mode & 0o222, 0);

  const lowCapacityDoctor = executeTaskCommand({
    args: ["doctor"],
    cwd: target,
    statfs: () => ({bavail: 0, bsize: MIB}),
  });
  assert.equal(lowCapacityDoctor.status, 1);
  assert.ok(lowCapacityDoctor.result.blockers.includes("filesystem_reserve_exhausted"));

  const sharedDependencyTarget = path.join(fixture, "shared-node-modules");
  fs.mkdirSync(sharedDependencyTarget);
  fs.symlinkSync(sharedDependencyTarget, path.join(target, "node_modules"));
  const sharedDependencyDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(sharedDependencyDoctor.status, 1);
  assert.ok(sharedDependencyDoctor.result.blockers.includes("shared_dependency_symlink:node_modules"));
  fs.unlinkSync(path.join(target, "node_modules"));

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));
  assert.equal(doctor.result.healthy, true);
  assert.ok(doctor.result.availableAllocatedBytes > 0);
  assert.equal(Object.hasOwn(doctor.result, "availableBytes"), false);
  assert.equal(Object.hasOwn(doctor.result.worktree, "sizeBytes"), false);
  assert.equal(
    doctor.result.worktree.materializedAllocatedBytes,
    metadata.initialMaterializedAllocatedBytes,
  );
  assert.equal(doctor.result.worktree.materializedAllocatedDeltaBytes, 0);

  fs.writeFileSync(path.join(target, "lib", "profile.txt"), "dirty\n");
  const dirtyFinish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(dirtyFinish.status, 1);
  assert.ok(dirtyFinish.result.blockers.includes("dirty"));

  git(target, ["add", "lib/profile.txt"]);
  git(target, ["commit", "-m", "task change"]);
  const unpushedFinish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(unpushedFinish.status, 1);
  assert.ok(unpushedFinish.result.blockers.includes("unpushed_unique_commits"));
  assert.ok(unpushedFinish.result.blockers.includes("remote_head_not_preserved"));
  git(target, ["push"]);

  const unlockFailureRunner = (command, args, options) => {
    if (command === "git" && args[0] === "worktree" && args[1] === "unlock") {
      return {status: 1, stdout: "", stderr: "injected unlock failure"};
    }
    return spawnSync(command, args, options);
  };
  assert.throws(
    () => executeTaskCommand({args: ["finish"], cwd: target, runner: unlockFailureRunner}),
    /injected unlock failure/u,
  );
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "finishing");
  const interruptedDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(interruptedDoctor.status, 1);
  assert.ok(interruptedDoctor.result.blockers.includes("finish_transition_incomplete"));
  git(fixture, ["worktree", "unlock", target]);

  const finish = executeTaskCommand({
    args: ["finish"],
    cwd: target,
    now: () => new Date("2026-08-06T13:00:00.000Z"),
  });
  assert.equal(finish.status, 0, JSON.stringify(finish.result));
  assert.equal(finish.result.readyForHandoff, true);
  assert.equal(finish.result.deletionAuthorized, false);
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "terminal");
  assert.equal(fs.readFileSync(authorityPath, "utf8"), authorityBefore);
  assert.doesNotMatch(git(fixture, ["worktree", "list", "--porcelain"]), /locked catch-task:profile-slice/u);

  const beforeReap = git(fixture, ["worktree", "list", "--porcelain"]);
  const reap = executeTaskCommand({
    args: ["reap", "--dry-run", "--stale-days", "7"],
    cwd: fixture,
    now: () => new Date("2026-08-20T13:00:00.000Z"),
  });
  assert.equal(reap.status, 0);
  assert.equal(reap.result.deletionAuthorized, false);
  assert.equal(reap.result.counts.owner_review, 1);
  assert.equal(
    reap.result.ownerReviewAllocatedBytes,
    reap.result.worktrees.find((item) => item.path === target).materializedAllocatedBytes,
  );
  assert.equal(Object.hasOwn(reap.result, "ownerReviewBytes"), false);
  assert.equal(Object.hasOwn(reap.result.legacyReview, "bytes"), false);
  assert.match(reap.result.reportDigest, /^[0-9a-f]{64}$/u);
  assert.equal(git(fixture, ["worktree", "list", "--porcelain"]), beforeReap);
});

test("legacy v1 task metadata remains readable without inventing an allocated baseline", (context) => {
  const {fixture, metadata, metadataPath, target} = createStartedTask(context, "legacy-v1");
  const legacyMetadata = {
    ...metadata,
    schema: "catch.harness-task/v1",
    budgetMiB: metadata.budgetAllocatedBytes / MIB,
    reserveMiB: metadata.reserveAllocatedBytes / MIB,
    estimatedTrackedBytes: metadata.estimatedTrackedLogicalBytes,
    materializedBytes: metadata.initialMaterializedLogicalBytes,
  };
  for (const key of [
    "budgetAllocatedBytes",
    "reserveAllocatedBytes",
    "estimatedTrackedLogicalBytes",
    "projectedInitialAllocatedBytes",
    "initialMaterializedLogicalBytes",
    "initialMaterializedAllocatedBytes",
    "ownedPaths",
    "plannedImpactPaths",
  ]) delete legacyMetadata[key];
  delete legacyMetadata.contextPack;
  fs.writeFileSync(metadataPath, `${JSON.stringify(legacyMetadata, null, 2)}\n`);
  relockLegacyTask({fixture, target, taskId: "legacy-v1"});

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));
  assert.equal(doctor.result.worktree.materializedAllocatedDeltaBytes, null);

  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 0, JSON.stringify(finish.result));
  assert.equal(finish.result.readyForHandoff, true);
  const persisted = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  assert.equal(persisted.schema, "catch.harness-task/v1");
  assert.equal(Object.hasOwn(persisted, "initialMaterializedAllocatedBytes"), false);
});

test("legacy v2 task metadata remains readable and keeps its schema", (context) => {
  const {fixture, metadata, metadataPath, target} = createStartedTask(context, "legacy-v2");
  const legacyMetadata = {...metadata, schema: "catch.harness-task/v2"};
  delete legacyMetadata.contextPack;
  delete legacyMetadata.ownedPaths;
  delete legacyMetadata.plannedImpactPaths;
  fs.writeFileSync(metadataPath, `${JSON.stringify(legacyMetadata, null, 2)}\n`);
  relockLegacyTask({fixture, target, taskId: "legacy-v2"});

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 0, JSON.stringify(finish.result));
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).schema, "catch.harness-task/v2");
});

test("legacy v3 task metadata preserves its original context and owned-scope semantics", (context) => {
  const {fixture, metadata, metadataPath, target} = createStartedTask(context, "legacy-v3");
  const legacyPayload = {
    schema: TASK_INPUT_SCHEMA_V1,
    taskId: metadata.taskId,
    mode: metadata.contextPack.mode,
    baseSha: metadata.baseSha,
    scopePaths: metadata.ownedPaths,
    checkIds: metadata.contextPack.checkIds,
    requiredEntrypoints: metadata.contextPack.requiredEntrypoints,
    supportPaths: metadata.contextPack.supportPaths,
    deferredCheckIds: metadata.contextPack.deferredCheckIds,
    deferredRegressionIds: metadata.contextPack.deferredRegressionIds,
    complete: true,
    blockers: [],
  };
  const legacyMetadata = {
    ...metadata,
    schema: "catch.harness-task/v3",
    requestedSparsePaths: metadata.ownedPaths.map((entry) => `/${entry}`),
    contextPack: {
      ...metadata.contextPack,
      packSchema: "catch.agent-context-pack/v2",
      taskInputSchema: TASK_INPUT_SCHEMA_V1,
      digest: digestTaskStart(legacyPayload),
    },
  };
  delete legacyMetadata.ownedPaths;
  delete legacyMetadata.plannedImpactPaths;
  fs.writeFileSync(metadataPath, `${JSON.stringify(legacyMetadata, null, 2)}\n`);
  relockLegacyTask({fixture, target, taskId: "legacy-v3"});

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 0, JSON.stringify(finish.result));
  const persisted = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  assert.equal(persisted.schema, "catch.harness-task/v3");
  assert.equal(Object.hasOwn(persisted, "plannedImpactPaths"), false);
});

test("legacy v4 task metadata closes without synthesizing v5 authority", (context) => {
  const {fixture, metadata, metadataPath, target} = createStartedTask(context, "legacy-v4");
  const commonPath = path.resolve(target, git(target, ["rev-parse", "--git-common-dir"]));
  const authorityPath = path.join(
    commonPath,
    "catch-harness",
    "tasks",
    metadata.worktreeAdminId,
    "authority.json",
  );
  const legacyMetadata = {...metadata, schema: "catch.harness-task/v4"};
  delete legacyMetadata.authorityId;
  delete legacyMetadata.worktreeAdminId;
  fs.writeFileSync(metadataPath, `${JSON.stringify(legacyMetadata, null, 2)}\n`);
  relockLegacyTask({fixture, target, taskId: "legacy-v4"});

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));
  assert.equal(fs.existsSync(authorityPath), false);
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 0, JSON.stringify(finish.result));
  const persisted = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  assert.equal(persisted.schema, "catch.harness-task/v4");
  assert.equal(persisted.status, "terminal");
  assert.equal(fs.existsSync(authorityPath), false);
  assert.doesNotMatch(
    git(fixture, ["worktree", "list", "--porcelain"]),
    /locked catch-task:legacy-v4/u,
  );
});

test("finish owns the task gate before inspection and through unlock", (context) => {
  const {fixture, metadata, target} = createStartedTask(context, "finish-gate-order");
  const commonPath = path.resolve(target, git(target, ["rev-parse", "--git-common-dir"]));
  const gatePath = path.join(
    commonPath,
    "catch-harness",
    "tasks",
    metadata.worktreeAdminId,
    "gate",
  );
  const observed = {inspection: false, unlock: false};
  const gateObservingRunner = (command, args, options) => {
    if (command === "git" && args[0] === "worktree" && args[1] === "list") {
      observed.inspection ||= fs.existsSync(gatePath);
    }
    if (command === "git" && args[0] === "worktree" && args[1] === "unlock") {
      observed.unlock ||= fs.existsSync(gatePath);
    }
    return spawnSync(command, args, options);
  };

  const finish = executeTaskCommand({
    args: ["finish"],
    cwd: target,
    runner: gateObservingRunner,
  });
  assert.equal(finish.status, 0, JSON.stringify(finish.result));
  assert.deepEqual(observed, {inspection: true, unlock: true});
  assert.equal(fs.existsSync(gatePath), false);
});

test("malformed v2 storage measurements fail closed", (context) => {
  const {metadata, metadataPath, target} = createStartedTask(context, "malformed-storage");
  const malformed = {
    ...metadata,
    schema: "catch.harness-task/v2",
    initialMaterializedAllocatedBytes: "unknown",
  };
  delete malformed.contextPack;
  fs.writeFileSync(metadataPath, `${JSON.stringify(malformed, null, 2)}\n`);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("invalid_storage_metrics"));
  assert.equal(doctor.result.worktree.materializedAllocatedDeltaBytes, null);

  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("invalid_storage_metrics"));
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "active");
});

test("doctor and finish enforce the same allocated-byte budget", (context) => {
  const {metadata, metadataPath, target} = createStartedTask(context, "allocated-budget");
  fs.writeFileSync(metadataPath, `${JSON.stringify({
    ...metadata,
    budgetAllocatedBytes: 1,
  }, null, 2)}\n`);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("materialized_allocated_budget_exceeded"));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("materialized_allocated_budget_exceeded"));
});

test("finish cannot bypass task-integrity blockers reported by doctor", (context) => {
  const {metadata, metadataPath, target} = createStartedTask(context, "integrity-parity");
  fs.writeFileSync(metadataPath, `${JSON.stringify({
    ...metadata,
    worktreePath: "/wrong/task/path",
  }, null, 2)}\n`);
  git(target, ["sparse-checkout", "add", "/unrelated.txt"]);

  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("metadata_path_mismatch"));
  assert.ok(doctor.result.blockers.includes("sparse_checkout_metadata_mismatch"));
  const finish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("metadata_path_mismatch"));
  assert.ok(finish.result.blockers.includes("sparse_checkout_metadata_mismatch"));
});

test("task-boundary diff inspection fails closed in doctor and finish", (context) => {
  const {metadataPath, target} = createStartedTask(context, "diff-unavailable");
  const failedDiffRunner = (command, args, options) => {
    if (command === "git" && args[0] === "diff") {
      return {status: 1, stdout: "", stderr: "injected diff failure"};
    }
    return spawnSync(command, args, options);
  };
  const doctor = executeTaskCommand({args: ["doctor"], cwd: target, runner: failedDiffRunner});
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("task_diff_unavailable"));
  const finish = executeTaskCommand({args: ["finish"], cwd: target, runner: failedDiffRunner});
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("task_diff_unavailable"));
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "active");
});

test("ignored payload must be inspectable and known before doctor or finish", (context) => {
  const {fixture, metadataPath, target} = createStartedTask(context, "ignored-payload");
  const excludePath = path.resolve(
    fixture,
    git(fixture, ["rev-parse", "--git-path", "info/exclude"]),
  );
  fs.appendFileSync(excludePath, "\n.scratch/\nnode_modules/\n");

  fs.mkdirSync(path.join(target, "node_modules"));
  fs.writeFileSync(path.join(target, "node_modules", "cache.txt"), "generated\n");
  const allowlistedDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(allowlistedDoctor.status, 0, JSON.stringify(allowlistedDoctor.result));
  assert.equal(allowlistedDoctor.result.worktree.unknownIgnoredPathCount, 0);
  fs.rmSync(path.join(target, "node_modules"), {recursive: true});

  fs.mkdirSync(path.join(target, ".scratch"));
  fs.writeFileSync(path.join(target, ".scratch", "payload.txt"), "local-only\n");
  const unknownDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(unknownDoctor.status, 1);
  assert.ok(unknownDoctor.result.blockers.includes("unknown_ignored_payload"));
  const unknownFinish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(unknownFinish.status, 1);
  assert.ok(unknownFinish.result.blockers.includes("unknown_ignored_payload"));
  assert.equal(JSON.parse(fs.readFileSync(metadataPath, "utf8")).status, "active");
  fs.rmSync(path.join(target, ".scratch"), {recursive: true});

  const failedIgnoredInspectionRunner = (command, args, options) => {
    if (command === "git" && args[0] === "status" && args.includes("--ignored=matching")) {
      return {status: 1, stdout: "", stderr: "injected ignored inspection failure"};
    }
    return spawnSync(command, args, options);
  };
  const unavailableDoctor = executeTaskCommand({
    args: ["doctor"],
    cwd: target,
    runner: failedIgnoredInspectionRunner,
  });
  assert.equal(unavailableDoctor.status, 1);
  assert.ok(unavailableDoctor.result.blockers.includes("ignored_payload_inspection_unavailable"));
  const unavailableFinish = executeTaskCommand({
    args: ["finish"],
    cwd: target,
    runner: failedIgnoredInspectionRunner,
  });
  assert.equal(unavailableFinish.status, 1);
  assert.ok(unavailableFinish.result.blockers.includes("ignored_payload_inspection_unavailable"));

  const recoveredDoctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(recoveredDoctor.status, 0, JSON.stringify(recoveredDoctor.result));
});

test("finish distinguishes an unavailable origin query from an unpreserved head", (context) => {
  const {target} = createStartedTask(context, "remote-query");
  const unavailableRemoteRunner = (command, args, options) => {
    if (command === "git" && args[0] === "ls-remote") {
      return {status: 128, stdout: "", stderr: "injected network failure"};
    }
    return spawnSync(command, args, options);
  };
  const finish = executeTaskCommand({
    args: ["finish"],
    cwd: target,
    runner: unavailableRemoteRunner,
  });
  assert.equal(finish.status, 1);
  assert.ok(finish.result.blockers.includes("remote_head_query_unavailable"));
  assert.equal(finish.result.blockers.includes("remote_head_not_preserved"), false);
  assert.deepEqual(finish.result.remoteVerification, {
    available: false,
    branch: "codex/remote-query",
    expectedHead: git(target, ["rev-parse", "HEAD"]),
    remoteHead: null,
    matched: false,
    error: "origin_head_query_failed",
  });
});

test("stale task execution leases require explicit PID-safe recovery", (context) => {
  const {target} = createStartedTask(context, "stale-execution-lease");
  const liveLease = acquireTaskExecutionLease({cwd: target, owner: "live-test"});
  assert.equal(liveLease.acquired, true);
  const liveRecovery = executeTaskCommand({args: ["recover-lease"], cwd: target});
  assert.equal(liveRecovery.status, 1);
  assert.deepEqual(liveRecovery.result.blockers, ["task_execution_lease_active"]);
  liveLease.release();

  const staleLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "stale-test",
    pid: 999999,
  });
  assert.equal(staleLease.acquired, true);
  const blockedFinish = executeTaskCommand({args: ["finish"], cwd: target});
  assert.equal(blockedFinish.status, 1);
  assert.deepEqual(blockedFinish.result.blockers, ["task_execution_lease_stale"]);
  const recovered = executeTaskCommand({args: ["recover-lease"], cwd: target});
  assert.equal(recovered.status, 0, JSON.stringify(recovered.result));
  assert.equal(recovered.result.recovered, true);
  assert.deepEqual(recovered.result.blockers, []);
  const doctor = executeTaskCommand({args: ["doctor"], cwd: target});
  assert.equal(doctor.status, 0, JSON.stringify(doctor.result));

  const racedLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "registration-race-test",
    pid: 999999,
  });
  assert.equal(racedLease.acquired, true);
  let racedChildPath = null;
  let concurrentRecovery = null;
  const racedRecovery = recoverStaleTaskExecutionLease({
    cwd: target,
    beforeChildDirectoryRemoval: ({childrenPath, leaseToken}) => {
      concurrentRecovery = recoverStaleTaskExecutionLease({cwd: target});
      racedChildPath = path.join(childrenPath, "in-flight-child.json");
      fs.writeFileSync(racedChildPath, `${JSON.stringify({
        schema: TASK_EXECUTION_CHILD_SCHEMA_V1,
        token: "in-flight-child",
        leaseToken,
        pid: process.pid,
        processGroupId: null,
        createdAt: new Date().toISOString(),
      })}\n`);
    },
  });
  assert.equal(racedRecovery.recovered, false);
  assert.deepEqual(racedRecovery.blockers, ["task_execution_lease_active"]);
  assert.equal(concurrentRecovery?.recovered, false);
  assert.deepEqual(concurrentRecovery?.blockers, ["task_execution_lease_transition_active"]);
  assert.equal(fs.existsSync(path.join(racedLease.leasePath, "owner.json")), true);
  assert.equal(fs.existsSync(markTransitionClaimDead(racedLease)), true);
  fs.unlinkSync(racedChildPath);
  const recoveredAfterRace = recoverStaleTaskExecutionLease({cwd: target});
  assert.equal(recoveredAfterRace.recovered, true);
  assert.equal(fs.existsSync(racedLease.leasePath), false);

  const interruptedLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "transition-crash-test",
    pid: 999999,
  });
  assert.equal(interruptedLease.acquired, true);
  assert.throws(
    () => recoverStaleTaskExecutionLease({
      cwd: target,
      afterChildDirectoryRemoval: () => {
        throw new Error("injected transition crash");
      },
    }),
    /injected transition crash/u,
  );
  assert.equal(fs.existsSync(interruptedLease.leasePath), true);
  assert.equal(fs.existsSync(markTransitionClaimDead(interruptedLease)), true);
  const recoveredAfterCrash = recoverStaleTaskExecutionLease({cwd: target});
  assert.equal(recoveredAfterCrash.recovered, true);
  assert.equal(fs.existsSync(interruptedLease.leasePath), false);

  const oldGenerationLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "generation-aba-test",
    pid: 999999,
  });
  assert.equal(oldGenerationLease.acquired, true);
  const oldChildrenPath = path.join(
    oldGenerationLease.leasePath,
    `generation-${oldGenerationLease.lease.token}`,
    "children",
  );
  const delayedChildStagingPath = path.join(
    path.dirname(oldGenerationLease.leasePath),
    "delayed-old-generation-child.json",
  );
  const delayedTransitionStagingPath = path.join(
    path.dirname(oldGenerationLease.leasePath),
    "delayed-old-generation-transition",
  );
  fs.writeFileSync(delayedChildStagingPath, "{}\n");
  fs.mkdirSync(delayedTransitionStagingPath);
  fs.writeFileSync(path.join(delayedTransitionStagingPath, "owner.json"), "{}\n");
  let replacementLease = null;
  const retiredOldGeneration = recoverStaleTaskExecutionLease({
    cwd: target,
    afterGateRetirement: () => {
      replacementLease = acquireTaskExecutionLease({
        cwd: target,
        owner: "generation-aba-replacement",
      });
      assert.equal(replacementLease.acquired, true);
      assert.throws(
        () => fs.renameSync(
          delayedChildStagingPath,
          path.join(oldChildrenPath, "late-child.json"),
        ),
        (error) => error?.code === "ENOENT",
      );
      assert.throws(
        () => fs.renameSync(
          delayedTransitionStagingPath,
          path.join(path.dirname(oldChildrenPath), "transition"),
        ),
        (error) => error?.code === "ENOENT",
      );
      assert.deepEqual(
        fs.readdirSync(path.join(
          replacementLease.leasePath,
          `generation-${replacementLease.lease.token}`,
          "children",
        )),
        [],
      );
    },
  });
  assert.equal(retiredOldGeneration.recovered, true);
  assert.equal(fs.existsSync(delayedChildStagingPath), true);
  fs.unlinkSync(delayedChildStagingPath);
  assert.equal(fs.existsSync(delayedTransitionStagingPath), true);
  fs.unlinkSync(path.join(delayedTransitionStagingPath, "owner.json"));
  fs.rmdirSync(delayedTransitionStagingPath);
  assert.equal(
    JSON.parse(fs.readFileSync(path.join(replacementLease.leasePath, "owner.json"), "utf8")).token,
    replacementLease.lease.token,
  );
  replacementLease.release();
  assert.equal(fs.existsSync(replacementLease.leasePath), false);

  const symlinkLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "lease-symlink-test",
    pid: 999999,
  });
  assert.equal(symlinkLease.acquired, true);
  const displacedGatePath = `${symlinkLease.leasePath}.unsafe-target`;
  fs.renameSync(symlinkLease.leasePath, displacedGatePath);
  fs.symlinkSync(displacedGatePath, symlinkLease.leasePath);
  symlinkLease.release();
  assert.equal(fs.existsSync(path.join(
    displacedGatePath,
    `generation-${symlinkLease.lease.token}`,
    "transition",
  )), false);
  const symlinkRecovery = recoverStaleTaskExecutionLease({cwd: target});
  assert.equal(symlinkRecovery.recovered, false);
  assert.deepEqual(symlinkRecovery.blockers, ["task_execution_lease_invalid"]);
  assert.equal(fs.existsSync(path.join(displacedGatePath, "owner.json")), true);
  fs.unlinkSync(symlinkLease.leasePath);
  fs.renameSync(displacedGatePath, symlinkLease.leasePath);
  const recoveredAfterSymlink = recoverStaleTaskExecutionLease({cwd: target});
  assert.equal(recoveredAfterSymlink.recovered, true);
  assert.equal(fs.existsSync(symlinkLease.leasePath), false);

  const malformedLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "lease-layout-test",
    pid: 999999,
  });
  assert.equal(malformedLease.acquired, true);
  const roguePath = path.join(
    malformedLease.leasePath,
    `generation-${malformedLease.lease.token}`,
    "rogue",
  );
  fs.writeFileSync(roguePath, "must survive failed recovery\n");
  const malformedRecovery = recoverStaleTaskExecutionLease({cwd: target});
  assert.equal(malformedRecovery.recovered, false);
  assert.deepEqual(malformedRecovery.blockers, ["task_execution_lease_invalid"]);
  assert.equal(fs.readFileSync(roguePath, "utf8"), "must survive failed recovery\n");
  fs.unlinkSync(roguePath);
  const recoveredAfterLayoutRepair = recoverStaleTaskExecutionLease({cwd: target});
  assert.equal(recoveredAfterLayoutRepair.recovered, true);
  assert.equal(fs.existsSync(malformedLease.leasePath), false);
});

test("task execution publication races preserve the winning generation and claim", (context) => {
  const {target} = createStartedTask(context, "execution-publication-races");

  const publisherLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "publisher-race",
    pid: 999999,
  });
  assert.equal(publisherLease.acquired, true);
  let losingTransitionStagingPath = null;
  let nestedPublisherPaused = false;
  const publisherRace = recoverStaleTaskExecutionLease({
    cwd: target,
    beforeTransitionPublish: ({stagingPath}) => {
      losingTransitionStagingPath = stagingPath;
      try {
        recoverStaleTaskExecutionLease({
          cwd: target,
          afterChildDirectoryRemoval: () => {
            throw new Error("pause winning publisher");
          },
        });
      } catch (error) {
        nestedPublisherPaused = error?.message === "pause winning publisher";
      }
    },
  });
  assert.equal(nestedPublisherPaused, true);
  assert.equal(publisherRace.recovered, false);
  assert.deepEqual(publisherRace.blockers, ["task_execution_lease_transition_active"]);
  assert.equal(fs.existsSync(losingTransitionStagingPath), false);
  assert.equal(fs.existsSync(markTransitionClaimDead(publisherLease)), true);
  assert.equal(recoverStaleTaskExecutionLease({cwd: target}).recovered, true);

  const claimantLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "claimant-race",
    pid: 999999,
  });
  assert.equal(claimantLease.acquired, true);
  assert.throws(
    () => recoverStaleTaskExecutionLease({
      cwd: target,
      afterChildDirectoryRemoval: () => {
        throw new Error("seed dead claim");
      },
    }),
    /seed dead claim/u,
  );
  markTransitionClaimDead(claimantLease);
  let nestedClaimantPaused = false;
  const claimantRace = recoverStaleTaskExecutionLease({
    cwd: target,
    beforeTransitionClaim: () => {
      try {
        recoverStaleTaskExecutionLease({
          cwd: target,
          afterChildDirectoryRemoval: () => {
            throw new Error("pause winning claimant");
          },
        });
      } catch (error) {
        nestedClaimantPaused = error?.message === "pause winning claimant";
      }
    },
  });
  assert.equal(nestedClaimantPaused, true);
  assert.equal(claimantRace.recovered, false);
  assert.deepEqual(claimantRace.blockers, ["task_execution_lease_transition_active"]);
  const claimantTransitionPath = markTransitionClaimDead(claimantLease);
  assert.equal(
    fs.readdirSync(claimantTransitionPath).filter((entry) => entry.startsWith("claim-")).length,
    1,
  );
  assert.equal(recoverStaleTaskExecutionLease({cwd: target}).recovered, true);

  const retiringLease = acquireTaskExecutionLease({
    cwd: target,
    owner: "child-publisher-race",
  });
  assert.equal(retiringLease.acquired, true);
  let replacementLease = null;
  let childStagingPath = null;
  const registration = registerTaskExecutionChild({
    leasePath: retiringLease.leasePath,
    leaseToken: retiringLease.lease.token,
    pid: process.pid,
    processGroupId: null,
    beforePublish: ({stagingPath}) => {
      childStagingPath = stagingPath;
      retiringLease.release();
      replacementLease = acquireTaskExecutionLease({
        cwd: target,
        owner: "child-publisher-replacement",
      });
    },
  });
  assert.equal(registration.registered, false);
  assert.equal(registration.blocker, "task_execution_child_registration_failed");
  assert.equal(fs.existsSync(childStagingPath), false);
  assert.equal(replacementLease?.acquired, true);
  assert.deepEqual(fs.readdirSync(path.join(
    replacementLease.leasePath,
    `generation-${replacementLease.lease.token}`,
    "children",
  )), []);
  replacementLease.release();
  assert.equal(fs.existsSync(replacementLease.leasePath), false);
});

test("low-capacity start refuses before worktree registration", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {taskId: "capacity-refusal", baseSha});
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "capacity-refusal",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--owned-paths", "lib/profile.txt",
        "--context-pack", ".task-pack.json",
      ],
      cwd: fixture,
      statfs: () => ({bavail: 197, bsize: MIB}),
    }),
    /Insufficient task-worktree capacity/u,
  );
  const listing = git(fixture, ["worktree", "list", "--porcelain"]);
  assert.doesNotMatch(listing, /capacity-refusal/u);
  assert.equal(fs.existsSync(path.join(fixture, ".claude", "worktrees", "capacity-refusal")), false);
});

test("start refuses remote branch collisions and missing sparse paths before registration", (context) => {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  git(fixture, ["push", "origin", "main:refs/heads/codex/remote-collision"]);
  writeContextPack(fixture, {taskId: "remote-collision", baseSha});
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "remote-collision",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--owned-paths", "lib/profile.txt",
        "--context-pack", ".task-pack.json",
      ],
      cwd: fixture,
    }),
    /Remote task branch already exists/u,
  );
  writeContextPack(fixture, {
    taskId: "missing-scope",
    baseSha,
    scopePath: "lib/proflie.txt",
  });
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "missing-scope",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--owned-paths", "lib/proflie.txt",
        "--context-pack", ".task-pack.json",
      ],
      cwd: fixture,
    }),
    /task_scope_path_missing:lib\/proflie\.txt/u,
  );
  const listing = git(fixture, ["worktree", "list", "--porcelain"]);
  assert.doesNotMatch(listing, /remote-collision|missing-scope/u);
});

test("task lifecycle root cannot escape through a symlink", (context) => {
  const session = createFixtureSession();
  const primaryRoot = fs.mkdtempSync(path.join(session, "catch-worktree-symlink-"));
  const outside = fs.mkdtempSync(path.join(session, "catch-worktree-outside-"));
  context.after(() => cleanupOwnedFixtureChildren(session, [primaryRoot, outside]));
  fs.mkdirSync(path.join(primaryRoot, ".claude"));
  fs.symlinkSync(outside, path.join(primaryRoot, ".claude", "worktrees"));
  assert.throws(
    () => assertSafeTaskTarget({
      targetPath: path.join(primaryRoot, ".claude", "worktrees", "task"),
      primaryRoot,
    }),
    /symlinked task lifecycle root/u,
  );
});

test("fixture cleanup removes only empty owned directories and never follows payload", (context) => {
  const sandbox = fs.mkdtempSync(path.join(os.tmpdir(), "catch-fixture-cleanup-"));
  context.after(() => fs.rmSync(sandbox, {recursive: true, force: true}));

  const empty = path.join(sandbox, "empty");
  fs.mkdirSync(empty);
  removeOwnedEmptyDirectory(empty);
  assert.equal(fs.existsSync(empty), false);

  const nonempty = path.join(sandbox, "nonempty");
  fs.mkdirSync(nonempty);
  fs.writeFileSync(path.join(nonempty, "sentinel.txt"), "preserve\n");
  assert.throws(() => removeOwnedEmptyDirectory(nonempty), /not empty/u);
  assert.equal(fs.readFileSync(path.join(nonempty, "sentinel.txt"), "utf8"), "preserve\n");

  const regularFile = path.join(sandbox, "file");
  fs.writeFileSync(regularFile, "preserve\n");
  assert.throws(() => removeOwnedEmptyDirectory(regularFile), /ordinary directory/u);
  assert.equal(fs.readFileSync(regularFile, "utf8"), "preserve\n");

  const outside = path.join(sandbox, "outside");
  const link = path.join(sandbox, "link");
  fs.mkdirSync(outside);
  fs.writeFileSync(path.join(outside, "sentinel.txt"), "outside\n");
  fs.symlinkSync(outside, link);
  assert.throws(() => removeOwnedEmptyDirectory(link), /ordinary directory/u);
  assert.equal(fs.readFileSync(path.join(outside, "sentinel.txt"), "utf8"), "outside\n");

  const dangling = path.join(sandbox, "dangling");
  fs.symlinkSync(path.join(sandbox, "missing-target"), dangling);
  assert.throws(() => removeOwnedEmptyDirectory(dangling), /ordinary directory/u);
  assert.equal(fs.lstatSync(dangling).isSymbolicLink(), true);

  const shared = path.join(sandbox, "shared");
  fs.mkdirSync(shared);
  fs.mkdirSync(path.join(shared, "legitimate-sibling"));
  assert.equal(removeSharedDirectoryIfEmpty(shared), false);
  assert.equal(fs.existsSync(path.join(shared, "legitimate-sibling")), true);
});

test("focused lifecycle fixtures remove every child path owned by this process", () => {
  assert.ok(closedOwnedFixturePaths.size > 0);
  for (const ownedPath of closedOwnedFixturePaths) {
    assert.equal(lstatOrNull(ownedPath), null, ownedPath);
  }
  assert.equal(fs.lstatSync(processFixtureSession).isDirectory(), true);
});

function createStartedTask(context, taskId) {
  const fixture = createClosureFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  writeContextPack(fixture, {taskId, baseSha});
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", taskId,
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--owned-paths", "lib/profile.txt",
      "--context-pack", ".task-pack.json",
      "--budget-mib", "64",
      "--reserve-mib", "1",
    ],
    cwd: fixture,
    statfs: () => ({bavail: 4096, bsize: MIB}),
  });
  assert.equal(execution.status, 0);
  const target = path.join(fs.realpathSync(fixture), ".claude", "worktrees", taskId);
  const metadataPath = git(target, ["rev-parse", "--git-path", "catch-task.json"]);
  return {
    fixture,
    target,
    metadataPath,
    metadata: JSON.parse(fs.readFileSync(metadataPath, "utf8")),
  };
}

function relockLegacyTask({fixture, target, taskId}) {
  const commonPath = path.resolve(target, git(target, ["rev-parse", "--git-common-dir"]));
  const adminId = path.basename(git(target, ["rev-parse", "--absolute-git-dir"]));
  const authorityPath = path.join(
    commonPath,
    "catch-harness",
    "tasks",
    adminId,
    "authority.json",
  );
  if (fs.existsSync(authorityPath)) {
    fs.chmodSync(authorityPath, 0o600);
    fs.unlinkSync(authorityPath);
    fs.rmdirSync(path.dirname(authorityPath));
  }
  git(fixture, ["worktree", "unlock", target]);
  git(fixture, ["worktree", "lock", "--reason", `catch-task:${taskId}`, target]);
}

function createGitFixture(context) {
  const session = createFixtureSession();
  const fixture = fs.mkdtempSync(path.join(session, "catch-worktree-lifecycle-"));
  const origin = `${fixture}-origin.git`;
  context.after(() => cleanupOwnedFixtureChildren(session, [fixture, origin]));
  git(fixture, ["init", "-b", "main"]);
  git(fixture, ["config", "user.name", "Catch Test"]);
  git(fixture, ["config", "user.email", "catch-test@example.com"]);
  fs.mkdirSync(path.join(fixture, "lib"), {recursive: true});
  fs.writeFileSync(path.join(fixture, "lib", "profile.txt"), "profile\n");
  fs.writeFileSync(path.join(fixture, "lib", "other.txt"), "other\n");
  fs.writeFileSync(path.join(fixture, "unrelated.txt"), "unrelated\n");
  git(fixture, ["add", "."]);
  git(fixture, ["commit", "-m", "fixture"]);
  git(path.dirname(origin), ["init", "--bare", origin]);
  git(fixture, ["remote", "add", "origin", origin]);
  git(fixture, ["push", "--set-upstream", "origin", "main"]);
  return fixture;
}

function createClosureFixture(context, {entrypoint = "tool/check.mjs"} = {}) {
  const fixture = createGitFixture(context);
  fs.mkdirSync(path.join(fixture, "tool"), {recursive: true});
  fs.mkdirSync(path.join(fixture, "docs", "agent_skills"), {recursive: true});
  const manifest = closureManifest(entrypoint);
  fs.writeFileSync(
    path.join(fixture, "tool", "tools_manifest.json"),
    `${JSON.stringify(manifest, null, 2)}\n`,
  );
  if (entrypoint === "tool/check.mjs") {
    fs.writeFileSync(path.join(fixture, "tool", "check.mjs"), "export const ok = true;\n");
  }
  fs.writeFileSync(
    path.join(fixture, "docs", "agent_skills", "skills_manifest.json"),
    `${JSON.stringify({skills: fixtureSkills()}, null, 2)}\n`,
  );
  fs.writeFileSync(
    path.join(fixture, "docs", "agent_regression_ledger.json"),
    `${JSON.stringify({entries: []}, null, 2)}\n`,
  );
  git(fixture, ["add", "tool", "docs"]);
  git(fixture, ["commit", "-m", "add closure fixture"]);
  git(fixture, ["push"]);
  return fixture;
}

function writeContextPack(
  fixture,
  {
    taskId,
    baseSha,
    entrypoint = "tool/check.mjs",
    ownedPath = "lib/profile.txt",
    plannedImpactPath = ownedPath,
    selectionImpactPaths = [plannedImpactPath],
    scopePath,
  },
) {
  if (scopePath != null) {
    ownedPath = scopePath;
    plannedImpactPath = scopePath;
    selectionImpactPaths = [scopePath];
  }
  const manifest = closureManifest(entrypoint);
  const selection = deriveTaskCheckSelection({
    task: taskId,
    mode: TASK_START_MODE,
    impactPaths: selectionImpactPaths,
    skills: fixtureSkills(),
    regressions: [],
  });
  const checkPlan = resolveStructuredCheckPlan({
    manifest,
    requestedChecks: selection.requests,
  });
  const taskStart = buildTaskStartContract({
    taskId,
    mode: TASK_START_MODE,
    sourceSha: baseSha,
    ownedPaths: [ownedPath],
    plannedImpactPaths: [plannedImpactPath],
    checkPlan,
    sourceClean: true,
    blockers: checkPlan.blockers,
    deferredRegressionIds: selection.deferredRegressionIds,
  });
  const pack = {
    schema: CONTEXT_PACK_SCHEMA_V3,
    sourceSha: baseSha,
    sourceClean: true,
    task: taskId,
    mode: TASK_START_MODE,
    scope: {ownedPaths: [ownedPath], plannedImpactPaths: [plannedImpactPath]},
    skills: selection.matchedSkills,
    regressionGuards: selection.matchedRegressions,
    checkPlan,
    taskStart,
  };
  fs.writeFileSync(path.join(fixture, ".task-pack.json"), `${JSON.stringify(pack, null, 2)}\n`);
  return pack;
}

function closureManifest(entrypoint) {
  return {
    tools: [
      {
        id: "agent:readiness",
        status: "active",
        path: entrypoint,
        safety: "local-readonly",
        checks: [`node ${entrypoint}`],
        ciRequirements: {repositoryView: "index", setup: ["node"]},
      },
      {
        id: "agent:harness-v2",
        status: "active",
        path: entrypoint,
        safety: "local-readonly",
        checks: [`node ${entrypoint}`],
      },
      {
        id: "agent:record-delegation",
        status: "active",
        path: entrypoint,
        safety: "local-readonly",
        checks: [`node ${entrypoint}`],
      },
      {
        id: "fixture:check",
        status: "active",
        path: entrypoint,
        safety: "local-readonly",
        checks: [`node ${entrypoint}`],
        ciRequirements: {repositoryView: "index", setup: ["node"]},
      },
    ],
  };
}

function fixtureSkills() {
  return [{
    skill_id: "fixture-skill",
    applies_to: ["lib/profile.txt"],
    required_tools: ["fixture:check"],
  }];
}

function markTransitionClaimDead(lease) {
  const transitionPath = path.join(
    lease.leasePath,
    `generation-${lease.lease.token}`,
    "transition",
  );
  const claimName = fs.readdirSync(transitionPath)
    .find((entry) => entry.startsWith("claim-"));
  assert.ok(claimName);
  const deadClaimPath = path.join(
    transitionPath,
    claimName.replace(/^claim-[0-9]+-/u, "claim-999999-"),
  );
  fs.renameSync(path.join(transitionPath, claimName), deadClaimPath);
  return transitionPath;
}

function createFixtureSession() {
  if (processFixtureSession) return processFixtureSession;
  for (let attempt = 0; attempt < 4; attempt += 1) {
    try {
      ensureFixtureParents();
      processFixtureSession = fs.mkdtempSync(
        path.join(TEST_FIXTURE_PARENT, `worktree-lifecycle-${process.pid}-`),
      );
      return processFixtureSession;
    } catch (error) {
      if (!new Set(["ENOENT", "EINVAL"]).has(error?.code)) throw error;
    }
  }
  throw new Error(`Unable to create fixture session under ${TEST_FIXTURE_PARENT}`);
}

function cleanupOwnedFixtureChildren(session, ownedChildren) {
  assert.equal(session, processFixtureSession);
  for (const child of ownedChildren) fs.rmSync(child, {recursive: true, force: true});
  for (const child of ownedChildren) closedOwnedFixturePaths.add(child);
}

function ensureFixtureParents() {
  for (let attempt = 0; attempt < 4; attempt += 1) {
    ensureOrdinaryDirectory(TEST_CLAUDE_ROOT);
    try {
      ensureOrdinaryDirectory(TEST_FIXTURE_PARENT);
      return;
    } catch (error) {
      if (error?.code !== "ENOENT") throw error;
    }
  }
  throw new Error(`Unable to create shared fixture parent ${TEST_FIXTURE_PARENT}`);
}

function ensureOrdinaryDirectory(targetPath) {
  for (let attempt = 0; attempt < 4; attempt += 1) {
    let stat = lstatOrNull(targetPath);
    if (!stat) {
      try {
        fs.mkdirSync(targetPath);
      } catch (error) {
        if (error?.code === "EEXIST") continue;
        throw error;
      }
      stat = lstatOrNull(targetPath);
    }
    if (!stat) continue;
    if (stat.isSymbolicLink() || !stat.isDirectory()) {
      throw new Error(`Fixture path must be an ordinary directory: ${targetPath}`);
    }
    return;
  }
  const error = new Error(`Fixture directory disappeared during creation: ${targetPath}`);
  error.code = "ENOENT";
  throw error;
}

function removeOwnedEmptyDirectory(targetPath) {
  const stat = lstatOrNull(targetPath);
  if (!stat) {
    throw new Error(`Owned fixture directory disappeared before cleanup: ${targetPath}`);
  }
  if (stat.isSymbolicLink() || !stat.isDirectory()) {
    throw new Error(`Owned fixture path is not an ordinary directory: ${targetPath}`);
  }
  if (fs.readdirSync(targetPath).length > 0) {
    throw new Error(`Owned fixture directory is not empty: ${targetPath}`);
  }
  fs.rmdirSync(targetPath);
}

function removeSharedDirectoryIfEmpty(targetPath) {
  const stat = lstatOrNull(targetPath);
  if (!stat) return false;
  if (stat.isSymbolicLink() || !stat.isDirectory()) {
    throw new Error(`Shared fixture path is not an ordinary directory: ${targetPath}`);
  }
  try {
    fs.rmdirSync(targetPath);
    return true;
  } catch (error) {
    if (error?.code === "ENOTEMPTY" || error?.code === "EEXIST") return false;
    if (error?.code === "ENOENT") return false;
    throw error;
  }
}

function lstatOrNull(targetPath) {
  try {
    return fs.lstatSync(targetPath);
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

function pruneSharedFixtureParents() {
  removeSharedDirectoryIfEmpty(TEST_FIXTURE_PARENT);
  removeSharedDirectoryIfEmpty(TEST_CLAUDE_ROOT);
}

function validV1Metadata(status = "terminal") {
  return {
    schema: "catch.harness-task/v1",
    status,
    budgetMiB: 64,
    reserveMiB: 1024,
  };
}

function git(cwd, args) {
  const result = spawnSync("git", args, {cwd, encoding: "utf8", shell: false});
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim();
}
