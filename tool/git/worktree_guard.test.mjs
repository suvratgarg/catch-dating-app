import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  executeTaskCommand,
  TaskUsageError,
} from "./worktree_guard.mjs";

test("start requires an exact SHA and a direct repository-owned target", (context) => {
  const fixture = createRepository(context);

  assert.throws(
    () => guard(fixture.root, [
      "start",
      "--task-id", "short-base",
      "--base-sha", fixture.baseSha.slice(0, 12),
      "--paths", "owned",
    ]),
    (error) => error instanceof TaskUsageError && /exact 40-character/u.test(error.message),
  );
  assert.throws(
    () => guard(fixture.root, [
      "start",
      "--task-id", "missing-base",
      "--base-sha", "f".repeat(40),
      "--paths", "owned",
    ]),
    TaskUsageError,
  );

  const nestedTarget = path.join(
    fixture.root,
    ".claude",
    "worktrees",
    "nested",
    "not-a-direct-child",
  );
  assert.throws(
    () => guard(fixture.root, [
      "start",
      "--task-id", "nested-target",
      "--base-sha", fixture.baseSha,
      "--paths", "owned",
      "--worktree", nestedTarget,
    ]),
    (error) => error instanceof TaskUsageError && /direct physical children/u.test(error.message),
  );
  assert.equal(fs.existsSync(nestedTarget), false);
  assert.deepEqual(claimFiles(fixture.root), []);
});

test("start creates a full exact-base worktree and never pushes or sets an upstream", (context) => {
  const fixture = createRepository(context);
  const gitCalls = [];
  const execution = guard(fixture.root, [
    "start",
    "--task-id", "exact-start",
    "--base-sha", fixture.baseSha,
    "--paths", "owned",
  ], {runner: recordingGitRunner(gitCalls)});

  assert.equal(execution.status, 0);
  const worktree = execution.result.worktreePath;
  assert.equal(path.dirname(worktree), path.join(fixture.root, ".claude", "worktrees"));
  assert.equal(gitText(worktree, ["rev-parse", "HEAD"]), fixture.baseSha);
  assert.equal(gitText(worktree, ["branch", "--show-current"]), "codex/exact-start");
  assert.equal(fs.existsSync(path.join(worktree, "owned", "allowed.txt")), true);
  assert.equal(fs.existsSync(path.join(worktree, "outside.txt")), true);
  assert.notEqual(gitResult(worktree, [
    "rev-parse",
    "--abbrev-ref",
    "--symbolic-full-name",
    "@{upstream}",
  ]).status, 0);
  assert.equal(gitCalls.some((args) => args[0] === "push"), false);
  assert.equal(gitCalls.some((args) => args[0] === "sparse-checkout"), false);
  assert.equal(gitCalls.some((args) => args[0] === "submodule"), false);

  const commonDir = gitText(fixture.root, [
    "rev-parse",
    "--path-format=absolute",
    "--git-common-dir",
  ]);
  assert.equal(
    path.dirname(execution.result.claimPath),
    path.join(commonDir, "catch-worktree-claims"),
  );
  const claim = JSON.parse(fs.readFileSync(execution.result.claimPath, "utf8"));
  assert.deepEqual(Object.keys(claim).sort(), [
    "baseSha",
    "branch",
    "claimedPaths",
    "createdAt",
    "taskId",
    "worktreePath",
  ]);
});

test("start refuses overlapping claims and permits disjoint worktrees", (context) => {
  const fixture = createRepository(context);
  start(fixture, "owns-directory", ["owned"]);

  assert.throws(
    () => start(fixture, "nested-overlap", ["owned/future.txt"]),
    (error) => error instanceof TaskUsageError && /overlaps owns-directory/u.test(error.message),
  );
  assert.equal(
    fs.existsSync(path.join(fixture.root, ".claude", "worktrees", "nested-overlap")),
    false,
  );

  const disjoint = start(fixture, "disjoint-file", ["outside.txt"]);
  assert.equal(disjoint.status, 0);
  assert.equal(claimFiles(fixture.root).length, 2);
});

test("doctor reports staged, unstaged, and untracked paths without treating in-scope dirt as authority", (context) => {
  const fixture = createRepository(context);
  const execution = start(fixture, "dirty-doctor", ["owned"]);
  const worktree = execution.result.worktreePath;

  fs.appendFileSync(path.join(worktree, "owned", "allowed.txt"), "unstaged\n");
  fs.writeFileSync(path.join(worktree, "owned", "staged.txt"), "staged\n");
  git(worktree, ["add", "owned/staged.txt"]);
  fs.writeFileSync(path.join(worktree, "outside-untracked.txt"), "outside\n");

  const doctor = guard(worktree, ["doctor"]);
  assert.equal(doctor.status, 1);
  assert.equal(doctor.result.dirty, true);
  assert.deepEqual(doctor.result.dirtyPaths, [
    "outside-untracked.txt",
    "owned/allowed.txt",
    "owned/staged.txt",
  ]);
  assert.deepEqual(doctor.result.committedPaths, []);
  assert.deepEqual(doctor.result.outOfScopePaths, ["outside-untracked.txt"]);
  assert.ok(doctor.result.blockers.includes("out_of_scope_changes"));
});

test("doctor detects committed out-of-scope changes while keeping committed in-scope work clean", (context) => {
  const outsideFixture = createRepository(context);
  const outsideExecution = start(outsideFixture, "committed-outside", ["owned"]);
  const outsideWorktree = outsideExecution.result.worktreePath;
  fs.appendFileSync(path.join(outsideWorktree, "outside.txt"), "outside commit\n");
  commitAll(outsideWorktree, "outside change");

  const outsideDoctor = guard(outsideWorktree, ["doctor"]);
  assert.equal(outsideDoctor.status, 1);
  assert.equal(outsideDoctor.result.dirty, false);
  assert.deepEqual(outsideDoctor.result.dirtyPaths, []);
  assert.deepEqual(outsideDoctor.result.committedPaths, ["outside.txt"]);
  assert.deepEqual(outsideDoctor.result.outOfScopePaths, ["outside.txt"]);

  const insideFixture = createRepository(context);
  const insideExecution = start(insideFixture, "committed-inside", ["owned"]);
  const insideWorktree = insideExecution.result.worktreePath;
  fs.appendFileSync(path.join(insideWorktree, "owned", "allowed.txt"), "inside commit\n");
  commitAll(insideWorktree, "inside change");
  const insideDoctor = guard(insideWorktree, ["doctor"]);
  assert.equal(insideDoctor.status, 0);
  assert.equal(insideDoctor.result.dirty, false);
  assert.deepEqual(insideDoctor.result.committedPaths, ["owned/allowed.txt"]);
  assert.deepEqual(insideDoctor.result.outOfScopePaths, []);
});

test("doctor and finish refuse a head that no longer descends from the exact base", (context) => {
  const fixture = createRepository(context);
  const execution = start(fixture, "ancestry-loss", ["owned"]);
  const worktree = execution.result.worktreePath;
  const tree = gitText(worktree, ["write-tree"]);
  const unrelated = gitText(worktree, ["commit-tree", tree, "-m", "unrelated root"]);
  git(worktree, ["reset", "--hard", unrelated]);

  const doctor = guard(worktree, ["doctor"]);
  assert.equal(doctor.status, 1);
  assert.ok(doctor.result.blockers.includes("base_not_ancestor_of_head"));
  const finish = guard(worktree, ["finish"]);
  assert.equal(finish.status, 1);
  assert.equal(finish.result.finished, false);
  assert.ok(finish.result.blockers.includes("base_not_ancestor_of_head"));
  assert.equal(fs.existsSync(execution.result.claimPath), true);
});

test("finish refuses uncommitted, upstream-less, and unpushed unique work", (context) => {
  const fixture = createRepository(context);
  const execution = start(fixture, "finish-blockers", ["owned"]);
  const worktree = execution.result.worktreePath;

  fs.appendFileSync(path.join(worktree, "owned", "allowed.txt"), "dirty\n");
  const dirty = guard(worktree, ["finish"]);
  assert.equal(dirty.status, 1);
  assert.ok(dirty.result.blockers.includes("uncommitted_changes"));
  assert.equal(fs.existsSync(execution.result.claimPath), true);

  git(worktree, ["reset", "--hard", "HEAD"]);
  fs.appendFileSync(path.join(worktree, "owned", "allowed.txt"), "committed\n");
  commitAll(worktree, "unique work");
  const noUpstream = guard(worktree, ["finish"]);
  assert.equal(noUpstream.status, 1);
  assert.ok(noUpstream.result.blockers.includes("branch_has_no_upstream"));

  git(worktree, ["branch", "--set-upstream-to", "origin/main"]);
  const unpushed = guard(worktree, ["finish"]);
  assert.equal(unpushed.status, 1);
  assert.ok(unpushed.result.blockers.includes("unpushed_commits"));
  assert.equal(unpushed.result.unpushedCommits, 1);
  assert.equal(fs.existsSync(execution.result.claimPath), true);
});

test("finish permits an unchanged branch without an upstream and removes only its claim", (context) => {
  const fixture = createRepository(context);
  const execution = start(fixture, "no-op-finish", ["owned"]);
  const worktree = execution.result.worktreePath;

  const finish = guard(worktree, ["finish"]);
  assert.equal(finish.status, 0);
  assert.equal(finish.result.finished, true);
  assert.equal(finish.result.upstream, null);
  assert.equal(fs.existsSync(execution.result.claimPath), false);
  assert.equal(fs.existsSync(worktree), true);
  assert.match(gitText(fixture.root, ["worktree", "list", "--porcelain"]), new RegExp(escapeRegex(worktree), "u"));
});

test("finish accepts pushed work, removes its claim, and leaves Git worktree cleanup explicit", (context) => {
  const fixture = createRepository(context);
  const execution = start(fixture, "pushed-finish", ["owned"]);
  const worktree = execution.result.worktreePath;
  fs.appendFileSync(path.join(worktree, "owned", "allowed.txt"), "pushed\n");
  commitAll(worktree, "pushed work");
  git(worktree, [
    "push",
    "--set-upstream",
    "origin",
    "HEAD:refs/heads/codex/pushed-finish",
  ]);

  const finish = guard(worktree, ["finish"]);
  assert.equal(finish.status, 0);
  assert.equal(finish.result.finished, true);
  assert.equal(finish.result.unpushedCommits, 0);
  assert.equal(finish.result.upstream, "origin/codex/pushed-finish");
  assert.equal(fs.existsSync(execution.result.claimPath), false);
  assert.equal(fs.existsSync(worktree), true);
  assert.equal(gitText(worktree, ["rev-parse", "HEAD"]), gitText(
    fixture.remote,
    ["rev-parse", "refs/heads/codex/pushed-finish"],
  ));
});

test("a failed worktree add rolls back its claim without deleting unrelated Git state", (context) => {
  const fixture = createRepository(context);
  git(fixture.root, ["branch", "codex/branch-collision", fixture.baseSha]);
  const branchesBefore = gitText(fixture.root, ["branch", "--format=%(refname)"]);

  assert.throws(
    () => guard(fixture.root, [
      "start",
      "--task-id", "branch-collision",
      "--base-sha", fixture.baseSha,
      "--paths", "owned",
    ]),
    TaskUsageError,
  );

  assert.deepEqual(claimFiles(fixture.root), []);
  assert.equal(
    fs.existsSync(path.join(fixture.root, ".claude", "worktrees", "branch-collision")),
    false,
  );
  assert.equal(gitText(fixture.root, ["branch", "--format=%(refname)"]), branchesBefore);
});

test("stale reports old claims and unclaimed worktrees without deleting either", (context) => {
  const fixture = createRepository(context);
  const old = new Date("2026-01-01T00:00:00.000Z");
  const current = new Date("2026-01-10T00:00:00.000Z");
  const claimed = start(fixture, "old-claim", ["owned"], {now: () => old});
  const unclaimedPath = path.join(fixture.root, ".claude", "worktrees", "unclaimed");
  git(fixture.root, [
    "worktree",
    "add",
    "-b",
    "codex/unclaimed",
    unclaimedPath,
    fixture.baseSha,
  ]);
  const claimBefore = fs.readFileSync(claimed.result.claimPath, "utf8");
  const worktreesBefore = gitText(fixture.root, ["worktree", "list", "--porcelain"]);

  const report = guard(fixture.root, ["stale", "--stale-days", "1"], {
    now: () => current,
  });
  assert.equal(report.status, 0);
  assert.equal(report.result.deletionAuthorized, false);
  assert.ok(report.result.candidates.some((candidate) =>
    candidate.taskId === "old-claim" &&
    candidate.reasons.includes("claim_older_than_threshold")));
  assert.ok(report.result.candidates.some((candidate) =>
    candidate.status === "unclaimed" && candidate.worktreePath === unclaimedPath));

  assert.equal(fs.readFileSync(claimed.result.claimPath, "utf8"), claimBefore);
  assert.equal(fs.existsSync(claimed.result.worktreePath), true);
  assert.equal(fs.existsSync(unclaimedPath), true);
  assert.equal(gitText(fixture.root, ["worktree", "list", "--porcelain"]), worktreesBefore);
});

function createRepository(context) {
  const container = fs.realpathSync(
    fs.mkdtempSync(path.join(os.tmpdir(), "catch-worktree-guard-")),
  );
  const root = path.join(container, "repo");
  const remote = path.join(container, "origin.git");
  fs.mkdirSync(root);
  context.after(() => fs.rmSync(container, {recursive: true, force: true}));

  git(container, ["init", "--bare", remote]);
  git(container, ["init", "--initial-branch=main", root]);
  git(root, ["config", "user.name", "Catch Worktree Test"]);
  git(root, ["config", "user.email", "worktree-test@catch.local"]);
  git(root, ["config", "commit.gpgsign", "false"]);
  git(root, ["config", "branch.autoSetupMerge", "false"]);
  git(root, ["remote", "add", "origin", remote]);

  fs.mkdirSync(path.join(root, "owned"));
  fs.writeFileSync(path.join(root, "owned", "allowed.txt"), "base\n");
  fs.writeFileSync(path.join(root, "outside.txt"), "outside base\n");
  fs.writeFileSync(path.join(root, ".gitignore"), ".claude/worktrees/\n");
  commitAll(root, "base");
  git(root, ["push", "--set-upstream", "origin", "main"]);
  return {baseSha: gitText(root, ["rev-parse", "HEAD"]), container, remote, root};
}

function start(fixture, taskId, claimedPaths, {now, runner} = {}) {
  return guard(fixture.root, [
    "start",
    "--task-id", taskId,
    "--base-sha", fixture.baseSha,
    "--paths", claimedPaths.join(","),
  ], {now, runner});
}

function guard(cwd, args, options = {}) {
  return executeTaskCommand({cwd, args, ...options});
}

function commitAll(cwd, message) {
  git(cwd, ["add", "--all"]);
  git(cwd, ["commit", "-m", message]);
}

function claimFiles(root) {
  const claimsRoot = path.join(root, ".git", "catch-worktree-claims");
  if (!fs.existsSync(claimsRoot)) return [];
  return fs.readdirSync(claimsRoot)
    .filter((name) => name.endsWith(".json"))
    .sort();
}

function recordingGitRunner(calls) {
  return ({cwd, args}) => {
    calls.push([...args]);
    return gitResult(cwd, args);
  };
}

function gitText(cwd, args) {
  const result = gitResult(cwd, args);
  assert.equal(
    result.status,
    0,
    `git ${args.join(" ")} failed:\n${result.stderr || result.stdout}`,
  );
  return result.stdout.trim();
}

function git(cwd, args) {
  gitText(cwd, args);
}

function gitResult(cwd, args) {
  const result = spawnSync("git", args, {
    cwd,
    encoding: "utf8",
    shell: false,
  });
  if (result.error) throw result.error;
  return {
    status: result.status,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}
