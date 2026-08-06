import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  assertCapacity,
  assertSafeTaskTarget,
  classifyReapCandidate,
  executeTaskCommand,
  normalizeSparsePaths,
  parseWorktreePorcelain,
  taskSparseAnchorPaths,
} from "./lib/worktree_lifecycle.mjs";

const MIB = 1024 * 1024;

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
  assert.throws(() => normalizeSparsePaths(["lib/**"]), /explicit tracked path/u);
  const paths = normalizeSparsePaths(["lib/user_profile/", "functions/src/index.ts"]);
  assert.ok(paths.includes("/AGENTS.md"));
  assert.ok(paths.includes("/lib/user_profile/"));
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
      availableBytes: 197 * MIB,
      budgetBytes: 256 * MIB,
      reserveBytes: 1024 * MIB,
      estimatedBytes: 40 * MIB,
    }),
    /Insufficient task-worktree capacity/u,
  );
  assert.throws(
    () => assertCapacity({
      availableBytes: 4096 * MIB,
      budgetBytes: 64 * MIB,
      reserveBytes: 1024 * MIB,
      estimatedBytes: 65 * MIB,
    }),
    /exceeds its 64.0 MiB budget/u,
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
      metadata: {schema: "catch.harness-task/v1", status: "terminal"},
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
        metadata: {schema: "catch.harness-task/v1", status: "terminal"},
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
    metadata: {schema: "catch.harness-task/v1", status: "terminal"},
    pushed: true,
    mergedIntoTarget: true,
  };
  for (const mutation of [
    {dirty: true},
    {locked: true},
    {livePid: true, metadata: {schema: "catch.harness-task/v1", status: "active"}},
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
  const fixture = createGitFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  const execution = executeTaskCommand({
    args: [
      "start",
      "--task-id", "profile-slice",
      "--base-sha", baseSha,
      "--stack-parent", "main",
      "--paths", "lib/profile.txt",
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
  assert.equal(metadata.baseSha, baseSha);
  assert.equal(metadata.creatorPid, 4242);
  assert.equal(metadata.stackParent, "main");
  assert.match(git(fixture, ["worktree", "list", "--porcelain"]), /locked catch-task:profile-slice/u);

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
  assert.match(reap.result.reportDigest, /^[0-9a-f]{64}$/u);
  assert.equal(git(fixture, ["worktree", "list", "--porcelain"]), beforeReap);
});

test("low-capacity start refuses before worktree registration", (context) => {
  const fixture = createGitFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "capacity-refusal",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--paths", "lib/profile.txt",
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
  const fixture = createGitFixture(context);
  const baseSha = git(fixture, ["rev-parse", "HEAD"]);
  git(fixture, ["push", "origin", "main:refs/heads/codex/remote-collision"]);
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "remote-collision",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--paths", "lib/profile.txt",
      ],
      cwd: fixture,
    }),
    /Remote task branch already exists/u,
  );
  assert.throws(
    () => executeTaskCommand({
      args: [
        "start",
        "--task-id", "missing-scope",
        "--base-sha", baseSha,
        "--stack-parent", "main",
        "--paths", "lib/proflie.txt",
      ],
      cwd: fixture,
    }),
    /Requested sparse path does not exist/u,
  );
  const listing = git(fixture, ["worktree", "list", "--porcelain"]);
  assert.doesNotMatch(listing, /remote-collision|missing-scope/u);
});

test("task lifecycle root cannot escape through a symlink", (context) => {
  const primaryRoot = fs.mkdtempSync(path.join(testFixtureRoot(), "catch-worktree-symlink-"));
  const outside = fs.mkdtempSync(path.join(testFixtureRoot(), "catch-worktree-outside-"));
  context.after(() => fs.rmSync(primaryRoot, {recursive: true, force: true}));
  context.after(() => fs.rmSync(outside, {recursive: true, force: true}));
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

function createGitFixture(context) {
  const fixture = fs.mkdtempSync(path.join(testFixtureRoot(), "catch-worktree-lifecycle-"));
  const origin = `${fixture}-origin.git`;
  context.after(() => fs.rmSync(fixture, {recursive: true, force: true}));
  context.after(() => fs.rmSync(origin, {recursive: true, force: true}));
  git(fixture, ["init", "-b", "main"]);
  git(fixture, ["config", "user.name", "Catch Test"]);
  git(fixture, ["config", "user.email", "catch-test@example.com"]);
  fs.mkdirSync(path.join(fixture, "lib"), {recursive: true});
  fs.writeFileSync(path.join(fixture, "lib", "profile.txt"), "profile\n");
  fs.writeFileSync(path.join(fixture, "unrelated.txt"), "unrelated\n");
  git(fixture, ["add", "."]);
  git(fixture, ["commit", "-m", "fixture"]);
  git(path.dirname(origin), ["init", "--bare", origin]);
  git(fixture, ["remote", "add", "origin", origin]);
  git(fixture, ["push", "--set-upstream", "origin", "main"]);
  return fixture;
}

function testFixtureRoot() {
  const root = path.join(process.cwd(), ".claude", "test-fixtures");
  fs.mkdirSync(root, {recursive: true});
  return `${root}${path.sep}`;
}

function git(cwd, args) {
  const result = spawnSync("git", args, {cwd, encoding: "utf8", shell: false});
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim();
}
