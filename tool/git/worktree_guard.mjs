import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const TASK_ID = /^[a-z0-9][a-z0-9._-]{2,79}$/u;
const SHA_40 = /^[0-9a-f]{40}$/u;
const DAY_MS = 24 * 60 * 60 * 1000;
const NEW_TASK_BASE_REF = "refs/remotes/origin/main";

export class TaskUsageError extends Error {}

export function taskHelp() {
  return `Usage: node tool/git/worktree_guard.mjs <command> [options]

Commands:
  start   --task-id <id> --base-sha <40-char-sha> --paths <paths>
          [--branch <branch>] [--worktree <path>]
  doctor  [--worktree <path>]
  finish  [--worktree <path>]
          [--abandon --reason <why> [--by <identity>]]
  stale   [--stale-days <days>]

The guard stores one disposable scope claim under Git's common directory for
each active worktree. Claims are removed on successful finish. Explicit
abandonment removes a clean worktree's claim and keeps a local record of who
abandoned it and why. The guard never installs dependencies, runs checks,
pushes branches, removes worktrees, or deletes stale state. Start is for new
tasks and requires --base-sha to match the locally fetched origin/main exactly.`;
}

export function executeTaskCommand({
  args,
  cwd,
  now = () => new Date(),
  runner = runGit,
} = {}) {
  const command = args?.[0] ?? "help";
  if (["help", "--help", "-h"].includes(command)) {
    return {status: 0, result: {operation: "help", help: taskHelp()}};
  }
  const repository = resolveRepository({cwd, runner});
  if (command === "start") {
    return startTask({
      repository,
      options: parseTaskOptions(args.slice(1)),
      now,
      runner,
    });
  }
  if (command === "doctor") {
    return doctorTask({
      repository,
      options: parseTaskOptions(args.slice(1)),
      runner,
    });
  }
  if (command === "finish") {
    return finishTask({
      repository,
      options: parseTaskOptions(args.slice(1)),
      now,
      runner,
    });
  }
  if (command === "stale") {
    return staleTasks({
      repository,
      options: parseTaskOptions(args.slice(1)),
      now,
      runner,
    });
  }
  throw new TaskUsageError(`Unknown task command: ${command}`);
}

export function startTask({repository, options, now = () => new Date(), runner = runGit}) {
  const taskId = requireOption(options, "taskId", "--task-id");
  if (!TASK_ID.test(taskId)) {
    throw new TaskUsageError(
      "--task-id must be 3-80 lowercase letters, digits, dots, underscores, or hyphens.",
    );
  }
  const baseSha = requireOption(options, "baseSha", "--base-sha").toLowerCase();
  if (!SHA_40.test(baseSha)) {
    throw new TaskUsageError("--base-sha must be an exact 40-character commit SHA.");
  }
  const resolvedBase = gitText(repository.primaryRoot, [
    "rev-parse",
    "--verify",
    `${baseSha}^{commit}`,
  ], runner).trim().toLowerCase();
  if (resolvedBase !== baseSha) {
    throw new TaskUsageError(`--base-sha did not resolve exactly: ${baseSha}`);
  }
  const mainResult = runner({
    cwd: repository.primaryRoot,
    args: ["rev-parse", "--verify", `${NEW_TASK_BASE_REF}^{commit}`],
  });
  if (mainResult.status !== 0) {
    throw new TaskUsageError(
      "origin/main is unavailable. Fetch origin main before starting a new task.",
    );
  }
  const mainSha = mainResult.stdout.trim().toLowerCase();
  if (baseSha !== mainSha) {
    throw new TaskUsageError(
      `New task base ${baseSha} must match origin/main ${mainSha}. Fetch origin main and use its exact SHA; continue existing branch work in its existing worktree.`,
    );
  }
  const claimedPaths = normalizeClaimedPaths(options.paths);
  if (claimedPaths.length === 0) {
    throw new TaskUsageError("--paths must contain at least one repository path.");
  }
  const branch = options.branch ?? `codex/${taskId}`;
  const branchCheck = runner({
    cwd: repository.primaryRoot,
    args: ["check-ref-format", "--branch", branch],
  });
  if (branchCheck.status !== 0) {
    throw new TaskUsageError(`Invalid task branch: ${branch}`);
  }
  const worktreePath = path.resolve(
    options.worktree ?? path.join(repository.canonicalWorktreeRoot, taskId),
  );
  assertSafeWorktreeTarget({repository, worktreePath});
  if (fs.existsSync(worktreePath)) {
    throw new TaskUsageError(`Task worktree path already exists: ${worktreePath}`);
  }

  return withClaimsLock(repository, () => {
    const activeClaims = readClaims(repository);
    const overlap = activeClaims.find((claim) =>
      scopeSetsOverlap(claimedPaths, claim.claimedPaths));
    if (overlap != null) {
      throw new TaskUsageError(
        `Task scope overlaps ${overlap.taskId} at ${overlap.worktreePath}.`,
      );
    }

    const createdAt = now().toISOString();
    const claim = {
      taskId,
      baseSha,
      branch,
      worktreePath,
      claimedPaths,
      createdAt,
    };
    const claimPath = writeNewClaim(repository, claim);
    const added = runner({
      cwd: repository.primaryRoot,
      args: ["worktree", "add", "-b", branch, worktreePath, baseSha],
    });
    if (added.status !== 0) {
      const afterFailure = registeredWorktrees(repository, runner);
      if (
        !fs.existsSync(worktreePath) &&
        !afterFailure.some((record) => samePath(record.path, worktreePath))
      ) {
        fs.unlinkSync(claimPath);
      }
      throw new TaskUsageError(
        (added.stderr || added.stdout || "git worktree add failed").trim(),
      );
    }
    const actualHead = gitText(worktreePath, ["rev-parse", "HEAD"], runner).trim();
    if (actualHead !== baseSha) {
      throw new Error(`Created worktree is not at requested base ${baseSha}.`);
    }
    return {
      status: 0,
      result: {
        operation: "start",
        taskId,
        branch,
        baseSha,
        worktreePath,
        claimedPaths,
        claimPath,
      },
    };
  });
}

export function doctorTask({repository, options, runner = runGit}) {
  const worktreePath = path.resolve(options.worktree ?? repository.currentRoot);
  const claim = claimForWorktree(repository, worktreePath);
  const inspection = inspectClaim({repository, claim, runner});
  return {
    status: inspection.blockers.length === 0 ? 0 : 1,
    result: {operation: "doctor", ...inspection},
  };
}

export function finishTask({
  repository,
  options,
  now = () => new Date(),
  runner = runGit,
}) {
  const worktreePath = path.resolve(options.worktree ?? repository.currentRoot);
  return withClaimsLock(repository, () => {
    const claim = claimForWorktree(repository, worktreePath);
    const inspection = inspectClaim({repository, claim, runner});
    if (options.abandon === true) {
      return abandonClaim({repository, claim, inspection, options, now, runner});
    }
    if (options.reason != null || options.by != null) {
      throw new TaskUsageError("--reason and --by require --abandon.");
    }
    const blockers = [...inspection.blockers];
    if (inspection.dirtyPaths.length > 0) blockers.push("uncommitted_changes");
    if (inspection.outOfScopePaths.length > 0) blockers.push("out_of_scope_changes");

    let upstream = null;
    let unpushedCommits = null;
    if (inspection.headSha != null && inspection.headSha !== claim.baseSha) {
      const upstreamResult = runner({
        cwd: claim.worktreePath,
        args: ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"],
      });
      if (upstreamResult.status !== 0) {
        blockers.push("branch_has_no_upstream");
      } else {
        upstream = upstreamResult.stdout.trim();
        const count = runner({
          cwd: claim.worktreePath,
          args: ["rev-list", "--count", `${upstream}..HEAD`],
        });
        if (count.status !== 0 || !/^\d+$/u.test(count.stdout.trim())) {
          blockers.push("unpushed_commit_check_failed");
        } else {
          unpushedCommits = Number(count.stdout.trim());
          if (unpushedCommits > 0) blockers.push("unpushed_commits");
        }
      }
    }

    const uniqueBlockers = [...new Set(blockers)].sort();
    if (uniqueBlockers.length > 0) {
      return {
        status: 1,
        result: {
          operation: "finish",
          ...inspection,
          upstream,
          unpushedCommits,
          blockers: uniqueBlockers,
          finished: false,
        },
      };
    }
    const finishedAt = now().toISOString();
    fs.unlinkSync(claim.claimPath);
    return {
      status: 0,
      result: {
        operation: "finish",
        ...inspection,
        upstream,
        unpushedCommits,
        blockers: [],
        finished: true,
        finishedAt,
        note: "Claim removed. Remove the worktree explicitly with Git when desired.",
      },
    };
  });
}

function abandonClaim({repository, claim, inspection, options, now, runner}) {
  const reason = requireRecordedValue(options.reason, "--reason", 500);
  const abandonedBy = options.by == null
    ? resolveGitIdentity({repository, claim, runner})
    : requireRecordedValue(options.by, "--by", 200);

  if (inspection.dirtyPaths.length > 0) {
    return {
      status: 1,
      result: {
        operation: "finish",
        ...inspection,
        blockers: ["uncommitted_changes"],
        finished: false,
        abandoned: false,
      },
    };
  }

  const abandonedAt = now().toISOString();
  const record = {
    schemaVersion: 1,
    taskId: claim.taskId,
    baseSha: claim.baseSha,
    headSha: inspection.headSha,
    branch: claim.branch,
    worktreePath: claim.worktreePath,
    claimedPaths: claim.claimedPaths,
    createdAt: claim.createdAt,
    abandonedAt,
    abandonedBy,
    reason,
    committedPaths: inspection.committedPaths,
    outOfScopePaths: inspection.outOfScopePaths,
    ignoredInspectionBlockers: inspection.blockers,
  };
  const abandonRecordPath = writeAbandonRecord(repository, record);
  fs.unlinkSync(claim.claimPath);
  return {
    status: 0,
    result: {
      operation: "finish",
      ...inspection,
      blockers: [],
      finished: true,
      abandoned: true,
      abandonedAt,
      abandonedBy,
      reason,
      abandonRecordPath,
      note: "Clean claim abandoned. Review or remove the worktree explicitly with Git.",
    },
  };
}

export function staleTasks({repository, options, now = () => new Date(), runner = runGit}) {
  const staleDays = options.staleDays == null ? 7 : Number(options.staleDays);
  if (!Number.isInteger(staleDays) || staleDays < 0) {
    throw new TaskUsageError("--stale-days must be a non-negative integer.");
  }
  const threshold = now().getTime() - staleDays * DAY_MS;
  const records = registeredWorktrees(repository, runner);
  const claims = readClaims(repository);
  const candidates = [];
  for (const claim of claims) {
    const reasons = [];
    const live = claimIsLive(claim, records);
    if (!live) reasons.push("worktree_missing_or_unregistered");
    if (Date.parse(claim.createdAt) <= threshold) reasons.push("claim_older_than_threshold");
    if (reasons.length > 0) {
      candidates.push({
        taskId: claim.taskId,
        status: "claimed",
        worktreePath: claim.worktreePath,
        branch: claim.branch,
        createdAt: claim.createdAt,
        reasons: [...new Set(reasons)].sort(),
      });
    }
  }
  const claimedPaths = new Set(claims.map((claim) => path.resolve(claim.worktreePath)));
  for (const record of records) {
    const worktreePath = path.resolve(record.path);
    if (
      isInside(repository.canonicalWorktreeRoot, worktreePath) &&
      worktreePath !== repository.canonicalWorktreeRoot &&
      !claimedPaths.has(worktreePath)
    ) {
      candidates.push({
        taskId: null,
        status: "unclaimed",
        worktreePath,
        branch: record.branch,
        createdAt: null,
        reasons: ["registered_worktree_has_no_claim"],
      });
    }
  }
  candidates.sort((left, right) => left.worktreePath.localeCompare(right.worktreePath));
  return {
    status: 0,
    result: {
      operation: "stale",
      staleDays,
      candidates,
      deletionAuthorized: false,
      note: "Report only. Review and clean up with explicit Git commands.",
    },
  };
}

export function inspectClaim({repository, claim, runner = runGit}) {
  const blockers = [];
  const records = registeredWorktrees(repository, runner);
  const record = records.find((entry) => samePath(entry.path, claim.worktreePath));
  if (record == null) blockers.push("worktree_not_registered");
  if (!fs.existsSync(claim.worktreePath)) blockers.push("worktree_missing");
  let dirtyPaths = [];
  let committedPaths = [];
  let changedPaths = [];
  let outOfScopePaths = [];
  let headSha = null;
  let branch = null;
  if (record != null && fs.existsSync(claim.worktreePath)) {
    dirtyPaths = dirtyPathsAt(claim.worktreePath, runner);
    const head = runner({cwd: claim.worktreePath, args: ["rev-parse", "HEAD"]});
    if (head.status === 0) headSha = head.stdout.trim();
    else blockers.push("worktree_head_unavailable");
    if (headSha != null) {
      const ancestor = runner({
        cwd: claim.worktreePath,
        args: ["merge-base", "--is-ancestor", claim.baseSha, "HEAD"],
      });
      if (ancestor.status !== 0) blockers.push("base_not_ancestor_of_head");
      const committed = runner({
        cwd: claim.worktreePath,
        args: ["diff", "--name-only", "-z", `${claim.baseSha}..HEAD`],
      });
      if (committed.status === 0) {
        committedPaths = parseNulPaths(committed.stdout);
      } else {
        blockers.push("committed_change_scan_failed");
      }
    }
    changedPaths = [...new Set([...dirtyPaths, ...committedPaths])].sort();
    outOfScopePaths = changedPaths.filter((changedPath) =>
      !claim.claimedPaths.some((claimedPath) => pathIsWithinScope(changedPath, claimedPath)));
    const branchResult = runner({
      cwd: claim.worktreePath,
      args: ["symbolic-ref", "--quiet", "--short", "HEAD"],
    });
    if (branchResult.status === 0) branch = branchResult.stdout.trim();
    else blockers.push("worktree_detached");
    if (branch != null && branch !== claim.branch) blockers.push("branch_mismatch");
  }
  if (outOfScopePaths.length > 0) blockers.push("out_of_scope_changes");
  return {
    taskId: claim.taskId,
    status: "claimed",
    worktreePath: claim.worktreePath,
    branch,
    expectedBranch: claim.branch,
    baseSha: claim.baseSha,
    headSha,
    claimedPaths: claim.claimedPaths,
    dirtyPaths,
    committedPaths,
    changedPaths,
    outOfScopePaths,
    dirty: dirtyPaths.length > 0,
    blockers: [...new Set(blockers)].sort(),
  };
}

export function normalizeClaimedPaths(values) {
  const normalized = [];
  for (const raw of values ?? []) {
    for (const part of String(raw).split(",")) {
      const value = part.trim().replaceAll("\\", "/").replace(/^\.\//u, "").replace(/\/+$/u, "");
      if (value === "") continue;
      if (
        value.startsWith("/") ||
        /^[A-Za-z]:/u.test(value) ||
        /[\u0000-\u001f*?\[\]]/u.test(value) ||
        value.split("/").some((segment) => ["", ".", "..", ".git"].includes(segment))
      ) {
        throw new TaskUsageError(`Claimed path must be explicit and repository-relative: ${part}`);
      }
      normalized.push(value);
    }
  }
  return [...new Set(normalized)].sort();
}

export function scopeSetsOverlap(left, right) {
  return left.some((leftPath) => right.some((rightPath) =>
    pathIsWithinScope(leftPath, rightPath) || pathIsWithinScope(rightPath, leftPath)));
}

export function parseWorktreePorcelain(source) {
  const records = [];
  let current = null;
  for (const line of String(source).split(/\r?\n/u)) {
    if (line === "") {
      if (current != null) records.push(current);
      current = null;
      continue;
    }
    if (line.startsWith("worktree ")) {
      if (current != null) records.push(current);
      current = {path: line.slice("worktree ".length), branch: null, detached: false};
      continue;
    }
    if (current == null) throw new TaskUsageError(`Malformed worktree record: ${line}`);
    if (line.startsWith("branch ")) {
      const branch = line.slice("branch ".length);
      current.branch = branch.startsWith("refs/heads/")
        ? branch.slice("refs/heads/".length)
        : branch;
    }
    else if (line === "detached") current.detached = true;
    else if (line === "prunable" || line.startsWith("prunable ")) current.prunable = true;
  }
  if (current != null) records.push(current);
  return records;
}

function resolveRepository({cwd, runner}) {
  if (typeof cwd !== "string" || cwd === "") throw new TaskUsageError("Task cwd is required.");
  const currentRoot = gitText(cwd, ["rev-parse", "--show-toplevel"], runner).trim();
  const commonRaw = gitText(cwd, ["rev-parse", "--path-format=absolute", "--git-common-dir"], runner).trim();
  const commonGitDir = path.resolve(commonRaw);
  if (!fs.existsSync(commonGitDir) || !fs.lstatSync(commonGitDir).isDirectory()) {
    throw new TaskUsageError(`Git common directory is unavailable: ${commonGitDir}`);
  }
  const primaryRoot = path.dirname(commonGitDir);
  const canonicalWorktreeRoot = path.join(primaryRoot, ".claude", "worktrees");
  const claimsRoot = path.join(commonGitDir, "catch-worktree-claims");
  return {currentRoot, primaryRoot, commonGitDir, canonicalWorktreeRoot, claimsRoot};
}

function parseTaskOptions(args) {
  const options = {paths: []};
  const values = new Map([
    ["--task-id", "taskId"],
    ["--base-sha", "baseSha"],
    ["--paths", "paths"],
    ["--branch", "branch"],
    ["--worktree", "worktree"],
    ["--stale-days", "staleDays"],
    ["--reason", "reason"],
    ["--by", "by"],
  ]);
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === "--json") continue;
    if (arg === "--abandon") {
      options.abandon = true;
      continue;
    }
    const key = values.get(arg);
    if (key == null) throw new TaskUsageError(`Unknown task option: ${arg}`);
    const value = args[index + 1];
    if (value == null || value.startsWith("--")) {
      throw new TaskUsageError(`${arg} requires a value.`);
    }
    index += 1;
    if (key === "paths") options.paths.push(value);
    else options[key] = value;
  }
  return options;
}

function requireRecordedValue(value, flag, maxLength) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new TaskUsageError(`${flag} is required with --abandon.`);
  }
  const normalized = value.trim();
  if (normalized.length > maxLength || /[\u0000-\u001f\u007f]/u.test(normalized)) {
    throw new TaskUsageError(
      `${flag} must be at most ${maxLength} characters without control characters.`,
    );
  }
  return normalized;
}

function resolveGitIdentity({repository, claim, runner}) {
  const cwd = fs.existsSync(claim.worktreePath)
    ? claim.worktreePath
    : repository.primaryRoot;
  for (const key of ["user.email", "user.name"]) {
    const result = runner({cwd, args: ["config", "--get", key]});
    if (result.status === 0 && result.stdout.trim() !== "") {
      return requireRecordedValue(result.stdout, `git config ${key}`, 200);
    }
  }
  throw new TaskUsageError(
    "--by is required when Git user.email and user.name are unavailable.",
  );
}

function requireOption(options, key, flag) {
  const value = options[key];
  if (typeof value !== "string" || value === "") {
    throw new TaskUsageError(`${flag} is required.`);
  }
  return value;
}

function assertSafeWorktreeTarget({repository, worktreePath}) {
  fs.mkdirSync(path.dirname(repository.canonicalWorktreeRoot), {recursive: true, mode: 0o700});
  for (const candidate of [path.dirname(repository.canonicalWorktreeRoot), repository.canonicalWorktreeRoot]) {
    if (fs.existsSync(candidate) && fs.lstatSync(candidate).isSymbolicLink()) {
      throw new TaskUsageError(`Refusing symlinked task root: ${candidate}`);
    }
  }
  fs.mkdirSync(repository.canonicalWorktreeRoot, {recursive: true, mode: 0o700});
  if (
    !samePath(path.dirname(worktreePath), repository.canonicalWorktreeRoot) ||
    path.basename(worktreePath) === "" ||
    fs.realpathSync(repository.canonicalWorktreeRoot) !==
      path.resolve(repository.canonicalWorktreeRoot)
  ) {
    throw new TaskUsageError(
      `Task worktrees must be direct physical children of ${repository.canonicalWorktreeRoot}.`,
    );
  }
}

function withClaimsLock(repository, callback) {
  ensureClaimsRoot(repository);
  const lockPath = path.join(repository.claimsRoot, ".start-finish.lock");
  let descriptor;
  try {
    descriptor = fs.openSync(lockPath, "wx", 0o600);
  } catch (error) {
    if (error?.code === "EEXIST") {
      throw new TaskUsageError(
        `Another task transition is active. If it crashed, inspect and remove ${lockPath}.`,
      );
    }
    throw error;
  }
  try {
    return callback();
  } finally {
    fs.closeSync(descriptor);
    fs.unlinkSync(lockPath);
  }
}

function ensureClaimsRoot(repository) {
  if (fs.existsSync(repository.claimsRoot) && fs.lstatSync(repository.claimsRoot).isSymbolicLink()) {
    throw new TaskUsageError(`Refusing symlinked claims directory: ${repository.claimsRoot}`);
  }
  fs.mkdirSync(repository.claimsRoot, {recursive: true, mode: 0o700});
}

function writeNewClaim(repository, claim) {
  ensureClaimsRoot(repository);
  const digest = createHash("sha256")
    .update(`${claim.taskId}\0${claim.worktreePath}`)
    .digest("hex")
    .slice(0, 24);
  const claimPath = path.join(repository.claimsRoot, `${digest}.json`);
  const descriptor = fs.openSync(claimPath, "wx", 0o600);
  try {
    fs.writeFileSync(descriptor, `${JSON.stringify(claim, null, 2)}\n`, "utf8");
  } finally {
    fs.closeSync(descriptor);
  }
  return claimPath;
}

function writeAbandonRecord(repository, record) {
  ensureClaimsRoot(repository);
  const recordsRoot = path.join(repository.claimsRoot, "abandoned");
  if (fs.existsSync(recordsRoot) && fs.lstatSync(recordsRoot).isSymbolicLink()) {
    throw new TaskUsageError(`Refusing symlinked abandonment directory: ${recordsRoot}`);
  }
  fs.mkdirSync(recordsRoot, {recursive: true, mode: 0o700});
  const digest = createHash("sha256")
    .update(`${record.taskId}\0${record.worktreePath}\0${record.abandonedAt}\0${record.reason}`)
    .digest("hex")
    .slice(0, 24);
  const recordPath = path.join(recordsRoot, `${digest}.json`);
  const descriptor = fs.openSync(recordPath, "wx", 0o600);
  try {
    fs.writeFileSync(descriptor, `${JSON.stringify(record, null, 2)}\n`, "utf8");
  } finally {
    fs.closeSync(descriptor);
  }
  return recordPath;
}

function readClaims(repository) {
  if (!fs.existsSync(repository.claimsRoot)) return [];
  if (fs.lstatSync(repository.claimsRoot).isSymbolicLink()) {
    throw new TaskUsageError(`Refusing symlinked claims directory: ${repository.claimsRoot}`);
  }
  return fs.readdirSync(repository.claimsRoot)
    .filter((name) => name.endsWith(".json"))
    .sort()
    .map((name) => {
      const claimPath = path.join(repository.claimsRoot, name);
      const stat = fs.lstatSync(claimPath);
      if (!stat.isFile() || stat.isSymbolicLink()) {
        throw new TaskUsageError(`Unsafe task claim: ${claimPath}`);
      }
      let claim;
      try {
        claim = JSON.parse(fs.readFileSync(claimPath, "utf8"));
      } catch {
        throw new TaskUsageError(`Invalid task claim JSON: ${claimPath}`);
      }
      validateClaim(claim, claimPath, repository);
      return {...claim, claimPath};
    });
}

function validateClaim(claim, claimPath, repository) {
  const expectedKeys = [
    "baseSha",
    "branch",
    "claimedPaths",
    "createdAt",
    "taskId",
    "worktreePath",
  ];
  if (
    claim == null ||
    Array.isArray(claim) ||
    Object.keys(claim).sort().join("\0") !== expectedKeys.join("\0") ||
    !TASK_ID.test(claim.taskId ?? "") ||
    !SHA_40.test(claim.baseSha ?? "") ||
    typeof claim.branch !== "string" || claim.branch === "" ||
    typeof claim.worktreePath !== "string" ||
    !samePath(path.dirname(claim.worktreePath), repository.canonicalWorktreeRoot) ||
    !Array.isArray(claim.claimedPaths) ||
    normalizeClaimedPaths(claim.claimedPaths).join("\0") !== claim.claimedPaths.join("\0") ||
    Number.isNaN(Date.parse(claim.createdAt))
  ) {
    throw new TaskUsageError(`Malformed task claim: ${claimPath}`);
  }
}

function claimForWorktree(repository, worktreePath) {
  const matches = readClaims(repository).filter((claim) => samePath(claim.worktreePath, worktreePath));
  if (matches.length === 0) {
    throw new TaskUsageError(`No task claim exists for worktree: ${worktreePath}`);
  }
  if (matches.length > 1) {
    throw new TaskUsageError(`Multiple task claims exist for ${worktreePath}.`);
  }
  return matches[0];
}

function registeredWorktrees(repository, runner) {
  return parseWorktreePorcelain(
    gitText(repository.primaryRoot, ["worktree", "list", "--porcelain"], runner),
  );
}

function claimIsLive(claim, records) {
  return fs.existsSync(claim.worktreePath) &&
    records.some((record) => samePath(record.path, claim.worktreePath));
}

function dirtyPathsAt(worktreePath, runner) {
  const commands = [
    ["diff", "--name-only", "-z"],
    ["diff", "--cached", "--name-only", "-z"],
    ["ls-files", "--others", "--exclude-standard", "-z"],
  ];
  const changed = new Set();
  for (const args of commands) {
    for (const value of parseNulPaths(gitText(worktreePath, args, runner))) changed.add(value);
  }
  return [...changed].sort();
}

function parseNulPaths(source) {
  return String(source)
    .split("\0")
    .filter(Boolean)
    .map((value) => value.replaceAll("\\", "/"))
    .sort();
}

function pathIsWithinScope(candidate, scope) {
  return candidate === scope || candidate.startsWith(`${scope}/`);
}

function isInside(parent, candidate) {
  const relative = path.relative(path.resolve(parent), path.resolve(candidate));
  return relative !== "" && !relative.startsWith("..") && !path.isAbsolute(relative);
}

function samePath(left, right) {
  return path.resolve(left) === path.resolve(right);
}

function gitText(cwd, args, runner) {
  const result = runner({cwd, args});
  if (result.status !== 0) {
    throw new TaskUsageError(
      (result.stderr || result.stdout || `git ${args.join(" ")} failed`).trim(),
    );
  }
  return result.stdout;
}

function runGit({cwd, args}) {
  const result = spawnSync("git", args, {cwd, encoding: "utf8", shell: false});
  return {
    status: result.status,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
}

function printResult(execution) {
  if (execution.result.operation === "help") {
    console.log(execution.result.help);
    return;
  }
  console.log(JSON.stringify(execution.result, null, 2));
}

function main() {
  try {
    const execution = executeTaskCommand({args: process.argv.slice(2), cwd: process.cwd()});
    printResult(execution);
    process.exitCode = execution.status;
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    if (error instanceof TaskUsageError) console.error(taskHelp());
    process.exitCode = 2;
  }
}

if (
  process.argv[1] != null &&
  fileURLToPath(import.meta.url) === path.resolve(process.argv[1])
) {
  main();
}
