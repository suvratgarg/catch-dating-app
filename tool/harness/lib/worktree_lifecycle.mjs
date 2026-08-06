import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {createHash} from "node:crypto";

const MIB = 1024 * 1024;
const DEFAULT_BUDGET_MIB = 256;
const DEFAULT_RESERVE_MIB = 1024;
const DEFAULT_STALE_DAYS = 7;
const TEMP_ROOTS = [...new Set([
  "/tmp",
  "/private/tmp",
  "/var/tmp",
  "/private/var/tmp",
  os.tmpdir(),
].map((entry) => resolvePhysicalPath(entry)))];

export const taskSparseAnchorPaths = Object.freeze([
  "/AGENTS.md",
  "/docs/README.md",
  "/docs/agent_operating_model.md",
  "/docs/agent_regression_ledger.json",
  "/docs/agent_skills/",
  "/docs/audit_registry/doc_versions.json",
  "/docs/audit_registry/rules.json",
  "/tool/agent/",
  "/tool/architecture/check_dependency_direction.mjs",
  "/tool/docs/check_doc_version_monotonic.mjs",
  "/tool/harness.mjs",
  "/tool/harness/",
  "/tool/lib/",
  "/tool/README.md",
  "/tool/test_inventory.mjs",
  "/tool/tools_manifest.json",
]);

export const taskCommandTemplates = Object.freeze({
  start: "node tool/harness.mjs task start --task-id <task-id> --base-sha <40-character-sha> --stack-parent <ref> --paths <path[,path...]> [--budget-mib 256]",
  doctor: "node tool/harness.mjs task doctor --worktree <task-worktree>",
  finish: "node tool/harness.mjs task finish --worktree <task-worktree>",
  reap: "node tool/harness.mjs task reap --dry-run [--merged-into origin/main] [--stale-days 7]",
});

export class TaskUsageError extends Error {}

export function parseWorktreePorcelain(source) {
  const records = [];
  let current = null;
  for (const line of String(source).split(/\r?\n/u)) {
    if (line === "") {
      if (current) records.push(current);
      current = null;
      continue;
    }
    const separator = line.indexOf(" ");
    const key = separator === -1 ? line : line.slice(0, separator);
    const value = separator === -1 ? true : line.slice(separator + 1);
    if (key === "worktree") {
      if (current) records.push(current);
      current = {path: value, bare: false, detached: false, locked: false, prunable: false};
      continue;
    }
    if (!current) throw new Error(`Malformed worktree porcelain line: ${line}`);
    if (key === "HEAD") current.head = value;
    else if (key === "branch") current.branchRef = value;
    else if (key === "bare") current.bare = true;
    else if (key === "detached") current.detached = true;
    else if (key === "locked") {
      current.locked = true;
      current.lockReason = value === true ? null : value;
    } else if (key === "prunable") {
      current.prunable = true;
      current.prunableReason = value === true ? null : value;
    }
  }
  if (current) records.push(current);
  return records;
}

export function isOsTempPath(targetPath) {
  const resolved = resolvePhysicalPath(targetPath);
  return TEMP_ROOTS.some((root) => resolved === root || resolved.startsWith(`${root}${path.sep}`));
}

export function isInsidePath(parentPath, candidatePath) {
  const relative = path.relative(path.resolve(parentPath), path.resolve(candidatePath));
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

export function assertSafeTaskTarget({targetPath, primaryRoot}) {
  const canonicalRoot = path.join(path.resolve(primaryRoot), ".claude", "worktrees");
  for (const candidate of [path.dirname(canonicalRoot), canonicalRoot]) {
    if (fs.existsSync(candidate) && fs.lstatSync(candidate).isSymbolicLink()) {
      throw new TaskUsageError(`Refusing symlinked task lifecycle root: ${candidate}`);
    }
  }
  if (isOsTempPath(targetPath)) {
    throw new TaskUsageError(`Refusing OS-temp task worktree path: ${targetPath}`);
  }
  const physicalRoot = resolvePhysicalPath(canonicalRoot);
  const physicalTarget = resolvePhysicalPath(targetPath);
  if (!isInsidePath(physicalRoot, physicalTarget) || physicalTarget === physicalRoot) {
    throw new TaskUsageError(`Task worktrees must be children of ${canonicalRoot}.`);
  }
}

export function normalizeSparsePaths(values) {
  const normalized = new Set(taskSparseAnchorPaths);
  for (const value of normalizeExplicitSparsePaths(values)) normalized.add(value);
  return [...normalized].sort();
}

function normalizeExplicitSparsePaths(values) {
  const normalized = new Set();
  for (const rawValue of values ?? []) {
    const value = String(rawValue).trim().replaceAll("\\", "/");
    if (!value) continue;
    if (path.posix.isAbsolute(value) || value.split("/").includes("..")) {
      throw new TaskUsageError(`Sparse path must be repository-relative: ${rawValue}`);
    }
    if (/[*?\[\]]/u.test(value) || value === ".git" || value.startsWith(".git/")) {
      throw new TaskUsageError(`Sparse path must be an explicit tracked path: ${rawValue}`);
    }
    normalized.add(`/${value.replace(/^\.\//u, "")}`);
  }
  return [...normalized].sort();
}

export function availableBytesFromStatfs(stat) {
  const availableBlocks = stat.bavail ?? stat.bfree;
  return Number(availableBlocks) * Number(stat.bsize);
}

export function assertCapacity({availableBytes, budgetBytes, reserveBytes, estimatedBytes}) {
  if (!Number.isFinite(availableBytes) || availableBytes < 0) {
    throw new Error("Unable to determine available filesystem capacity.");
  }
  if (estimatedBytes > budgetBytes) {
    throw new Error(
      `Sparse task estimate ${formatMiB(estimatedBytes)} exceeds its ${formatMiB(budgetBytes)} budget.`,
    );
  }
  const requiredBytes = reserveBytes + budgetBytes;
  if (availableBytes < requiredBytes) {
    throw new Error(
      `Insufficient task-worktree capacity: ${formatMiB(availableBytes)} available; ` +
      `${formatMiB(requiredBytes)} required (${formatMiB(reserveBytes)} reserve + ` +
      `${formatMiB(budgetBytes)} task budget).`,
    );
  }
  return {availableBytes, requiredBytes, budgetBytes, reserveBytes, estimatedBytes};
}

export function classifyReapCandidate({
  worktree,
  primaryRoot,
  currentWorktree,
  canonicalRoot,
  staleDays = DEFAULT_STALE_DAYS,
}) {
  const reasons = [];
  const warnings = [];
  const worktreePath = path.resolve(worktree.path);
  if (worktreePath === path.resolve(primaryRoot)) reasons.push("primary_worktree");
  if (worktreePath === path.resolve(currentWorktree)) reasons.push("current_worktree");
  if (worktree.locked) reasons.push("locked");
  if (isOsTempPath(worktreePath)) reasons.push("os_temp_path");
  if (!isInsidePath(canonicalRoot, worktreePath) && !worktree.prunable) reasons.push("outside_canonical_root");
  if (worktree.dirty === true) reasons.push("dirty");
  if (worktree.dirty == null && !worktree.prunable) reasons.push("cleanliness_unknown");
  if (worktree.metadata?.status !== "terminal" && worktree.livePid === true) reasons.push("live_creator_pid");
  if (!worktree.metadata && !worktree.prunable) reasons.push("missing_terminal_metadata");
  if (worktree.metadata && worktree.metadata.status !== "terminal") reasons.push(`task_${worktree.metadata.status ?? "state_unknown"}`);
  if (worktree.ignoredInspectionAvailable === false) reasons.push("ignored_payload_inspection_unavailable");
  if ((worktree.unknownIgnoredPathCount ?? 0) > 0) reasons.push("unknown_ignored_payload");
  if (worktree.ageDays != null && worktree.ageDays < staleDays) reasons.push("recent");
  if (worktree.ageDays == null && !worktree.prunable) reasons.push("age_unknown");

  const preserved = worktree.remotelyPreserved ??
    (worktree.pushed === true || worktree.mergedIntoTarget === true);
  if (!preserved && !worktree.prunable) reasons.push("remote_preservation_unproven");
  if (worktree.pushed !== true && worktree.mergedIntoTarget === true) {
    warnings.push("upstream_missing_but_head_is_in_merge_target");
  }
  if (worktree.mergedIntoTarget !== true && worktree.pushed === true) {
    warnings.push("pushed_but_merge_not_proven");
  }
  if (!worktree.metadata && !worktree.prunable) warnings.push("legacy_missing_task_metadata");
  if (worktree.detached) warnings.push("detached_head");

  if (worktree.prunable && !worktree.locked) {
    return {classification: "owner_review", reasons: ["prunable_registration"], warnings};
  }
  if (reasons.length > 0) {
    const retainedOnly = reasons.every((reason) => [
      "primary_worktree",
      "current_worktree",
      "live_creator_pid",
      "recent",
      "task_active",
      "task_finishing",
    ].includes(reason));
    return {classification: retainedOnly ? "retain" : "blocked", reasons, warnings};
  }
  return {
    classification: "owner_review",
    reasons: ["clean_stale_and_remotely_preserved"],
    warnings,
  };
}

export function executeTaskCommand({
  args,
  cwd,
  runner = spawnSync,
  statfs = fs.statfsSync,
  now = () => new Date(),
  pid = process.pid,
} = {}) {
  const options = parseTaskArgs(args ?? []);
  const context = resolveRepositoryContext({cwd: cwd ?? process.cwd(), runner});
  if (options.command === "start") {
    return startTask({options, context, runner, statfs, now, pid});
  }
  if (options.command === "doctor") {
    return doctorTask({options, context, runner, statfs});
  }
  if (options.command === "finish") {
    return finishTask({options, context, runner, now});
  }
  if (options.command === "reap") {
    return reapTasks({options, context, runner, now});
  }
  throw new TaskUsageError(`Unknown harness task command "${options.command}".`);
}

function parseTaskArgs(args) {
  const command = args[0] ?? "help";
  if (["help", "--help", "-h"].includes(command)) {
    throw new TaskUsageError("Harness task command is required.");
  }
  const supported = {
    start: new Set(["--task-id", "--base-sha", "--stack-parent", "--branch", "--paths", "--budget-mib", "--reserve-mib", "--json"]),
    doctor: new Set(["--worktree", "--json"]),
    finish: new Set(["--worktree", "--json"]),
    reap: new Set(["--dry-run", "--merged-into", "--stale-days", "--json"]),
  }[command];
  if (!supported) return {command};
  for (let index = 1; index < args.length; index += 1) {
    const token = args[index];
    if (!token.startsWith("--")) throw new TaskUsageError(`Unexpected task argument: ${token}`);
    if (!supported.has(token)) throw new TaskUsageError(`Unsupported ${command} option: ${token}`);
    if (["--dry-run", "--json"].includes(token)) continue;
    if (args[index + 1] == null || args[index + 1].startsWith("--")) {
      throw new TaskUsageError(`${token} requires a value.`);
    }
    index += 1;
  }
  if (command === "start") {
    const taskId = requiredValue(args, "--task-id");
    const baseSha = requiredValue(args, "--base-sha");
    if (!/^[a-z0-9][a-z0-9._-]{2,79}$/u.test(taskId)) {
      throw new TaskUsageError("--task-id must be 3-80 lowercase letters, digits, dots, underscores, or hyphens.");
    }
    if (!/^[0-9a-f]{40}$/u.test(baseSha)) {
      throw new TaskUsageError("--base-sha must be an explicit full 40-character commit SHA.");
    }
    const requestedPaths = requiredValue(args, "--paths").split(",").filter(Boolean);
    if (requestedPaths.length === 0) throw new TaskUsageError("--paths must select at least one repository path.");
    const branch = valueAfter(args, "--branch") ?? `codex/${taskId}`;
    if (!/^codex\/[A-Za-z0-9._/-]+$/u.test(branch) || branch.includes("..")) {
      throw new TaskUsageError("Task branch must use the codex/ prefix and a valid ref name.");
    }
    const requestedSparsePaths = normalizeExplicitSparsePaths(requestedPaths);
    return {
      command,
      taskId,
      baseSha,
      stackParent: requiredValue(args, "--stack-parent"),
      branch,
      requestedSparsePaths,
      sparsePaths: normalizeSparsePaths(requestedPaths),
      budgetMiB: positiveNumber(valueAfter(args, "--budget-mib") ?? DEFAULT_BUDGET_MIB, "--budget-mib"),
      reserveMiB: positiveNumber(valueAfter(args, "--reserve-mib") ?? DEFAULT_RESERVE_MIB, "--reserve-mib"),
    };
  }
  if (command === "reap") {
    if (!args.includes("--dry-run")) {
      throw new TaskUsageError("reap is report-only and requires explicit --dry-run.");
    }
    return {
      command,
      dryRun: true,
      mergedInto: valueAfter(args, "--merged-into") ?? "origin/main",
      staleDays: positiveNumber(valueAfter(args, "--stale-days") ?? DEFAULT_STALE_DAYS, "--stale-days"),
    };
  }
  return {command, worktree: valueAfter(args, "--worktree")};
}

function resolveRepositoryContext({cwd, runner}) {
  const currentWorktree = gitText({cwd, args: ["rev-parse", "--show-toplevel"], runner});
  const commonDir = path.resolve(
    currentWorktree,
    gitText({cwd, args: ["rev-parse", "--git-common-dir"], runner}),
  );
  const primaryRoot = path.basename(commonDir) === ".git" ? path.dirname(commonDir) : currentWorktree;
  return {
    currentWorktree: path.resolve(currentWorktree),
    commonDir,
    primaryRoot: path.resolve(primaryRoot),
    canonicalRoot: path.join(path.resolve(primaryRoot), ".claude", "worktrees"),
  };
}

function startTask({options, context, runner, statfs, now, pid}) {
  const targetPath = path.join(context.canonicalRoot, options.taskId);
  assertSafeTaskTarget({targetPath, primaryRoot: context.primaryRoot});
  if (fs.existsSync(targetPath)) throw new Error(`Task worktree path already exists: ${targetPath}`);
  const branchRef = `refs/heads/${options.branch}`;
  if (gitStatus({cwd: context.primaryRoot, args: ["show-ref", "--verify", "--quiet", branchRef], runner}) === 0) {
    throw new Error(`Task branch already exists: ${options.branch}`);
  }
  gitText({
    cwd: context.primaryRoot,
    args: ["cat-file", "-e", `${options.baseSha}^{commit}`],
    runner,
    allowEmpty: true,
  });
  const stackParentSha = gitText({
    cwd: context.primaryRoot,
    args: ["rev-parse", `${options.stackParent}^{commit}`],
    runner,
  });
  if (stackParentSha !== options.baseSha) {
    throw new Error(
      `Stack parent ${options.stackParent} resolves to ${stackParentSha}, not explicit base ${options.baseSha}.`,
    );
  }
  gitText({cwd: context.primaryRoot, args: ["remote", "get-url", "origin"], runner});
  const remoteCollision = gitResult({
    cwd: context.primaryRoot,
    args: ["ls-remote", "--exit-code", "--heads", "origin", `refs/heads/${options.branch}`],
    runner,
    tolerateFailure: true,
  });
  if (remoteCollision.status === 0) throw new Error(`Remote task branch already exists: origin/${options.branch}`);
  if (remoteCollision.status !== 2) {
    throw new Error("Unable to prove that the remote task branch is unused.");
  }
  validateRequestedSparsePaths({
    cwd: context.primaryRoot,
    baseSha: options.baseSha,
    requestedSparsePaths: options.requestedSparsePaths,
    runner,
  });
  const estimatedTrackedBytes = estimateTrackedBytes({
    cwd: context.primaryRoot,
    baseSha: options.baseSha,
    sparsePaths: options.sparsePaths,
    runner,
  });
  const estimatedBytes = estimatedTrackedBytes + 32 * MIB;
  const capacity = assertCapacity({
    availableBytes: availableBytesFromStatfs(statfs(context.primaryRoot)),
    budgetBytes: options.budgetMiB * MIB,
    reserveBytes: options.reserveMiB * MIB,
    estimatedBytes,
  });

  let registered = false;
  try {
    gitText({
      cwd: context.primaryRoot,
      args: ["worktree", "add", "--no-checkout", "-b", options.branch, targetPath, options.baseSha],
      runner,
      allowEmpty: true,
    });
    registered = true;
    gitText({
      cwd: targetPath,
      args: ["sparse-checkout", "set", "--no-cone", "--stdin"],
      runner,
      input: `${options.sparsePaths.join("\n")}\n`,
      allowEmpty: true,
    });
    gitText({cwd: targetPath, args: ["checkout", "--force", options.branch], runner, allowEmpty: true});
    const actualBytes = directorySize(targetPath);
    if (actualBytes > capacity.budgetBytes) {
      throw new Error(
        `Materialized task worktree ${formatMiB(actualBytes)} exceeds its ${formatMiB(capacity.budgetBytes)} budget.`,
      );
    }
    const metadataPath = gitText({cwd: targetPath, args: ["rev-parse", "--git-path", "catch-task.json"], runner});
    const metadata = {
      schema: "catch.harness-task/v1",
      status: "active",
      taskId: options.taskId,
      baseSha: options.baseSha,
      stackParent: options.stackParent,
      stackParentSha,
      branch: options.branch,
      worktreePath: targetPath,
      sparsePaths: options.sparsePaths,
      requestedSparsePaths: options.requestedSparsePaths,
      budgetMiB: options.budgetMiB,
      reserveMiB: options.reserveMiB,
      estimatedTrackedBytes,
      materializedBytes: actualBytes,
      creatorPid: pid,
      createdAt: now().toISOString(),
    };
    fs.writeFileSync(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`, {encoding: "utf8", flag: "wx"});
    gitText({
      cwd: context.primaryRoot,
      args: ["worktree", "lock", "--reason", `catch-task:${options.taskId}`, targetPath],
      runner,
      allowEmpty: true,
    });
    gitText({
      cwd: targetPath,
      args: [
        "push",
        "--set-upstream",
        `--force-with-lease=refs/heads/${options.branch}:`,
        "origin",
        options.branch,
      ],
      runner,
      allowEmpty: true,
    });
    return {status: 0, result: {operation: "start", created: true, capacity, metadata}};
  } catch (error) {
    if (registered) {
      runIgnoringFailure({cwd: context.primaryRoot, args: ["worktree", "unlock", targetPath], runner});
      runIgnoringFailure({cwd: context.primaryRoot, args: ["worktree", "remove", "--force", targetPath], runner});
      runIgnoringFailure({cwd: context.primaryRoot, args: ["branch", "-D", options.branch], runner});
    }
    throw error;
  }
}

function doctorTask({options, context, runner, statfs}) {
  const targetPath = resolveTargetWorktree(options.worktree, context.currentWorktree);
  const record = findWorktreeRecord({targetPath, context, runner});
  const inspection = inspectSingleWorktree({targetPath, context, runner, record, mergedInto: null});
  const blockers = [];
  if (isOsTempPath(targetPath)) blockers.push("os_temp_path");
  if (!isInsidePath(context.canonicalRoot, targetPath)) blockers.push("outside_canonical_root");
  if (!inspection.metadata) blockers.push("missing_task_metadata");
  if (inspection.metadata && !["active", "finishing", "terminal"].includes(inspection.metadata.status)) {
    blockers.push("invalid_task_state");
  }
  if (inspection.metadata?.status === "active" && !inspection.locked) blockers.push("active_worktree_not_locked");
  if (inspection.metadata?.status === "finishing") blockers.push("finish_transition_incomplete");
  if (inspection.metadata?.status === "terminal" && inspection.locked) blockers.push("terminal_worktree_still_locked");
  if (["active", "finishing"].includes(inspection.metadata?.status) &&
      inspection.lockReason !== `catch-task:${inspection.metadata.taskId}`) {
    blockers.push("task_lock_reason_mismatch");
  }
  if (inspection.metadata && path.resolve(inspection.metadata.worktreePath) !== targetPath) {
    blockers.push("metadata_path_mismatch");
  }
  if (inspection.metadata && inspection.metadata.branch !== inspection.branch) blockers.push("metadata_branch_mismatch");
  if (inspection.metadata && inspection.sparsePaths == null) blockers.push("sparse_checkout_missing");
  if (inspection.metadata && inspection.sparsePaths && !sameStringSet(
    inspection.metadata.sparsePaths,
    inspection.sparsePaths,
  )) blockers.push("sparse_checkout_metadata_mismatch");
  if (inspection.sizeBytes == null) blockers.push("materialized_size_unknown");
  if (inspection.metadata?.budgetMiB && inspection.sizeBytes > inspection.metadata.budgetMiB * MIB) {
    blockers.push("materialized_budget_exceeded");
  }
  if (inspection.metadata && inspection.metadata.baseSha && !isAncestor({
    cwd: targetPath,
    ancestor: inspection.metadata.baseSha,
    descendant: "HEAD",
    runner,
  })) blockers.push("base_not_ancestor_of_head");
  blockers.push(...inspection.dependencyHazards);
  const capacity = availableBytesFromStatfs(statfs(targetPath));
  if (inspection.metadata?.reserveMiB && capacity < inspection.metadata.reserveMiB * MIB) {
    blockers.push("filesystem_reserve_exhausted");
  }
  return {
    status: blockers.length === 0 ? 0 : 1,
    result: {operation: "doctor", healthy: blockers.length === 0, blockers, availableBytes: capacity, worktree: inspection},
  };
}

function finishTask({options, context, runner, now}) {
  const targetPath = resolveTargetWorktree(options.worktree, context.currentWorktree);
  const record = findWorktreeRecord({targetPath, context, runner});
  const inspection = inspectSingleWorktree({targetPath, context, runner, record, mergedInto: null});
  const blockers = [];
  if (!inspection.metadata) blockers.push("missing_task_metadata");
  if (inspection.metadata && !["active", "finishing"].includes(inspection.metadata.status)) {
    blockers.push("task_not_active");
  }
  const finishingUnlocked = inspection.metadata?.status === "finishing" && !inspection.locked;
  if (!inspection.locked && !finishingUnlocked) blockers.push("worktree_not_locked");
  if (inspection.metadata && inspection.locked &&
      inspection.lockReason !== `catch-task:${inspection.metadata.taskId}`) {
    blockers.push("task_lock_reason_mismatch");
  }
  if (inspection.metadata && inspection.metadata.branch !== inspection.branch) blockers.push("metadata_branch_mismatch");
  if (!inspection.branch) blockers.push("detached_head");
  if (inspection.dirty !== false) blockers.push(inspection.dirty ? "dirty" : "cleanliness_unknown");
  if (!inspection.upstream) blockers.push("missing_upstream");
  if (inspection.ahead !== 0) blockers.push(inspection.ahead == null ? "push_state_unknown" : "unpushed_unique_commits");
  if (inspection.branch && remoteBranchHead({cwd: targetPath, branch: inspection.branch, runner}) !== inspection.head) {
    blockers.push("remote_head_not_preserved");
  }
  blockers.push(...inspection.dependencyHazards);
  if (blockers.length === 0) {
    const metadataPath = gitText({cwd: targetPath, args: ["rev-parse", "--git-path", "catch-task.json"], runner});
    const finishingMetadata = {
      ...inspection.metadata,
      status: "finishing",
      terminalHead: inspection.head,
      terminalUpstream: inspection.upstream,
      finishStartedAt: inspection.metadata.finishStartedAt ?? now().toISOString(),
    };
    fs.writeFileSync(metadataPath, `${JSON.stringify(finishingMetadata, null, 2)}\n`, "utf8");
    if (inspection.locked) {
      gitText({
        cwd: context.primaryRoot,
        args: ["worktree", "unlock", targetPath],
        runner,
        allowEmpty: true,
      });
    }
    const metadata = {
      ...finishingMetadata,
      status: "terminal",
      finishedAt: now().toISOString(),
    };
    fs.writeFileSync(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`, "utf8");
    inspection.metadata = metadata;
    inspection.locked = false;
  }
  return {
    status: blockers.length === 0 ? 0 : 1,
    result: {
      operation: "finish",
      readyForHandoff: blockers.length === 0,
      deletionAuthorized: false,
      blockers,
      worktree: inspection,
    },
  };
}

function reapTasks({options, context, runner, now}) {
  const source = gitText({cwd: context.primaryRoot, args: ["worktree", "list", "--porcelain"], runner});
  const remoteSnapshot = loadRemoteHeads({cwd: context.primaryRoot, runner});
  const mergeTargetExists = gitStatus({
    cwd: context.primaryRoot,
    args: ["rev-parse", "--verify", "--quiet", `${options.mergedInto}^{commit}`],
    runner,
  }) === 0;
  const mergeTargetSha = mergeTargetExists
    ? gitText({cwd: context.primaryRoot, args: ["rev-parse", `${options.mergedInto}^{commit}`], runner})
    : null;
  const mergeTargetRemoteRef = remoteHeadRef(options.mergedInto);
  const mergeTargetFresh = Boolean(
    mergeTargetSha && mergeTargetRemoteRef && remoteSnapshot.heads.get(mergeTargetRemoteRef) === mergeTargetSha,
  );
  const worktrees = parseWorktreePorcelain(source).map((record) => {
    const inspection = inspectSingleWorktree({
      targetPath: record.path,
      context,
      runner,
      record,
      mergedInto: mergeTargetExists ? options.mergedInto : null,
      now,
    });
    const upstreamRef = remoteHeadRef(inspection.upstream);
    const upstreamFresh = Boolean(
      upstreamRef && inspection.upstreamSha && remoteSnapshot.heads.get(upstreamRef) === inspection.upstreamSha,
    );
    inspection.remoteSnapshotAvailable = remoteSnapshot.available;
    inspection.upstreamFresh = upstreamFresh;
    inspection.remotelyPreserved = Boolean(
      (inspection.pushed === true && upstreamFresh) ||
      (inspection.mergedIntoTarget === true && mergeTargetFresh),
    );
    return {
      ...inspection,
      ...classifyReapCandidate({
        worktree: inspection,
        primaryRoot: context.primaryRoot,
        currentWorktree: context.currentWorktree,
        canonicalRoot: context.canonicalRoot,
        staleDays: options.staleDays,
      }),
    };
  });
  const counts = Object.fromEntries(
    ["owner_review", "blocked", "retain"].map((classification) => [
      classification,
      worktrees.filter((item) => item.classification === classification).length,
    ]),
  );
  const ownerReviewBytes = worktrees
    .filter((item) => item.classification === "owner_review")
    .reduce((sum, item) => sum + (item.sizeBytes ?? 0), 0);
  const legacyReviewCandidates = worktrees.filter((item) =>
    !item.metadata &&
    item.prunable !== true &&
    item.dirty === false &&
    item.remotelyPreserved === true &&
    (item.headAgeDays ?? 0) >= options.staleDays &&
    !isOsTempPath(item.path) &&
    isInsidePath(context.canonicalRoot, item.path) &&
    item.ignoredInspectionAvailable === true &&
    (item.unknownIgnoredPathCount ?? 0) === 0
  );
  const result = {
    operation: "reap",
    mode: "dry-run",
    deletionAuthorized: false,
    mergedInto: options.mergedInto,
    mergeTargetExists,
    mergeTargetFresh,
    remoteSnapshot: {
      available: remoteSnapshot.available,
      headCount: remoteSnapshot.heads.size,
      error: remoteSnapshot.error,
    },
    staleDays: options.staleDays,
    counts,
    ownerReviewBytes,
    legacyReview: {
      deletionAuthorized: false,
      reason: "activity_and_terminal_ownership_unknown",
      count: legacyReviewCandidates.length,
      bytes: legacyReviewCandidates.reduce((sum, item) => sum + (item.sizeBytes ?? 0), 0),
      paths: legacyReviewCandidates.map((item) => item.path),
    },
    worktrees,
  };
  result.reportDigest = createHash("sha256").update(JSON.stringify(result)).digest("hex");
  return {status: 0, result};
}

function inspectSingleWorktree({targetPath, context, runner, record = {}, mergedInto, now = () => new Date()}) {
  const resolved = path.resolve(targetPath);
  const exists = fs.existsSync(resolved);
  const prunable = record.prunable === true;
  const inspection = {
    path: resolved,
    head: record.head ?? null,
    branchRef: record.branchRef ?? null,
    branch: record.branchRef?.replace(/^refs\/heads\//u, "") ?? null,
    detached: record.detached === true,
    locked: record.locked === true,
    lockReason: record.lockReason ?? null,
    prunable,
    prunableReason: record.prunableReason ?? null,
    exists,
    dirty: null,
    upstream: null,
    upstreamSha: null,
    ahead: null,
    behind: null,
    pushed: null,
    mergedIntoTarget: null,
    ageDays: null,
    headAgeDays: null,
    metadata: null,
    livePid: null,
    dependencyHazards: [],
    ignoredPathCount: 0,
    ignoredPathSample: [],
    ignoredInspectionAvailable: null,
    unknownIgnoredPathCount: 0,
    unknownIgnoredPathSample: [],
    sparsePaths: null,
    sizeBytes: exists ? allocatedDirectorySize(resolved) : 0,
  };
  if (!exists || prunable) return inspection;
  const status = gitResult({cwd: resolved, args: ["status", "--porcelain"], runner, tolerateFailure: true});
  if (status.status === 0) inspection.dirty = status.stdout.trim().length > 0;
  const ignored = gitResult({
    cwd: resolved,
    args: ["status", "--porcelain", "--ignored=matching", "--untracked-files=all"],
    runner,
    tolerateFailure: true,
  });
  if (ignored.status === 0) {
    inspection.ignoredInspectionAvailable = true;
    const ignoredPaths = ignored.stdout
      .split(/\r?\n/u)
      .filter((line) => line.startsWith("!! "))
      .map((line) => line.slice(3))
      .sort();
    const unknownIgnoredPaths = ignoredPaths.filter((entry) => !isAllowlistedIgnoredPath(entry));
    inspection.ignoredPathCount = ignoredPaths.length;
    inspection.ignoredPathSample = ignoredPaths.slice(0, 20);
    inspection.unknownIgnoredPathCount = unknownIgnoredPaths.length;
    inspection.unknownIgnoredPathSample = unknownIgnoredPaths.slice(0, 20);
  } else {
    inspection.ignoredInspectionAvailable = false;
  }
  const branch = gitResult({cwd: resolved, args: ["branch", "--show-current"], runner, tolerateFailure: true});
  if (branch.status === 0 && branch.stdout.trim()) inspection.branch = branch.stdout.trim();
  inspection.detached = !inspection.branch;
  const head = gitResult({cwd: resolved, args: ["rev-parse", "HEAD"], runner, tolerateFailure: true});
  if (head.status === 0) inspection.head = head.stdout.trim();
  const upstream = gitResult({
    cwd: resolved,
    args: ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"],
    runner,
    tolerateFailure: true,
  });
  if (upstream.status === 0 && upstream.stdout.trim()) {
    inspection.upstream = upstream.stdout.trim();
    const upstreamHead = gitResult({cwd: resolved, args: ["rev-parse", "@{upstream}"], runner, tolerateFailure: true});
    if (upstreamHead.status === 0) inspection.upstreamSha = upstreamHead.stdout.trim();
    const counts = gitResult({
      cwd: resolved,
      args: ["rev-list", "--left-right", "--count", "@{upstream}...HEAD"],
      runner,
      tolerateFailure: true,
    });
    if (counts.status === 0) {
      const [behind, ahead] = counts.stdout.trim().split(/\s+/u).map(Number);
      inspection.behind = behind;
      inspection.ahead = ahead;
      inspection.pushed = ahead === 0;
    }
  }
  if (mergedInto && inspection.head) {
    inspection.mergedIntoTarget = isAncestor({
      cwd: resolved,
      ancestor: inspection.head,
      descendant: mergedInto,
      runner,
    });
  }
  const commitTime = gitResult({cwd: resolved, args: ["show", "-s", "--format=%ct", "HEAD"], runner, tolerateFailure: true});
  if (commitTime.status === 0 && /^\d+$/u.test(commitTime.stdout.trim())) {
    inspection.headAgeDays = Math.max(0, (now().getTime() / 1000 - Number(commitTime.stdout.trim())) / 86400);
  }
  inspection.metadata = readTaskMetadata({cwd: resolved, runner});
  const activityValue = inspection.metadata?.status === "terminal"
    ? inspection.metadata.finishedAt
    : inspection.metadata?.createdAt;
  const activityTime = activityValue ? Date.parse(activityValue) : NaN;
  if (Number.isFinite(activityTime)) {
    inspection.ageDays = Math.max(0, (now().getTime() - activityTime) / 86400000);
  }
  if (inspection.metadata?.creatorPid != null) inspection.livePid = isProcessLive(inspection.metadata.creatorPid);
  inspection.dependencyHazards = findDependencyHazards(resolved);
  const sparse = gitResult({cwd: resolved, args: ["sparse-checkout", "list"], runner, tolerateFailure: true});
  if (sparse.status === 0) inspection.sparsePaths = sparse.stdout.split(/\r?\n/u).filter(Boolean).sort();
  return inspection;
}

function findWorktreeRecord({targetPath, context, runner}) {
  const source = gitText({cwd: context.primaryRoot, args: ["worktree", "list", "--porcelain"], runner});
  const record = parseWorktreePorcelain(source)
    .find((candidate) => path.resolve(candidate.path) === path.resolve(targetPath));
  if (!record) throw new Error(`Path is not a registered worktree: ${targetPath}`);
  return record;
}

function readTaskMetadata({cwd, runner}) {
  const location = gitResult({cwd, args: ["rev-parse", "--git-path", "catch-task.json"], runner, tolerateFailure: true});
  if (location.status !== 0 || !fs.existsSync(location.stdout.trim())) return null;
  try {
    const value = JSON.parse(fs.readFileSync(location.stdout.trim(), "utf8"));
    return value?.schema === "catch.harness-task/v1" ? value : null;
  } catch {
    return null;
  }
}

function findDependencyHazards(worktreePath) {
  const candidates = new Set([
    path.join(worktreePath, "node_modules"),
    path.join(worktreePath, ".dart_tool"),
    path.join(worktreePath, "build"),
    path.join(worktreePath, "ios", "Pods"),
    path.join(worktreePath, "macos", "Pods"),
  ]);
  for (const owner of ["admin", "functions", "operations", "website", "packages"]) {
    const ownerPath = path.join(worktreePath, owner);
    if (!fs.existsSync(ownerPath) || !fs.lstatSync(ownerPath).isDirectory()) continue;
    candidates.add(path.join(ownerPath, "node_modules"));
    candidates.add(path.join(ownerPath, ".dart_tool"));
    if (owner === "packages") {
      for (const child of fs.readdirSync(ownerPath)) {
        candidates.add(path.join(ownerPath, child, "node_modules"));
        candidates.add(path.join(ownerPath, child, ".dart_tool"));
      }
    }
  }
  const hazards = [];
  for (const candidate of candidates) {
    if (!fs.existsSync(candidate)) continue;
    const stat = fs.lstatSync(candidate);
    if (stat.isSymbolicLink()) {
      hazards.push(`shared_dependency_symlink:${path.relative(worktreePath, candidate)}`);
      continue;
    }
    const resolved = fs.realpathSync(candidate);
    if (!isInsidePath(worktreePath, resolved)) {
      hazards.push(`dependency_outside_worktree:${path.relative(worktreePath, candidate)}`);
    }
  }
  return hazards.sort();
}

function isAllowlistedIgnoredPath(relativePath) {
  const normalized = relativePath.replaceAll("\\", "/").replace(/^\.\//u, "");
  if (/(^|\/)(?:node_modules|\.dart_tool|\.idea|build|Pods|coverage|storybook-static)(?:\/|$)/u.test(normalized)) {
    return true;
  }
  return /(^|\/)\.flutter-plugins-dependencies$/u.test(normalized);
}

function estimateTrackedBytes({cwd, baseSha, sparsePaths, runner}) {
  const requestedPaths = sparsePaths.map((entry) => entry.replace(/^\//u, "").replace(/\/$/u, ""));
  const result = gitResult({
    cwd,
    args: ["ls-tree", "-r", "-l", "-z", baseSha, "--", ...requestedPaths],
    runner,
  });
  let total = 0;
  for (const record of result.stdout.split("\0")) {
    const match = record.match(/^\d+\s+\w+\s+[0-9a-f]+\s+(\d+)\t/u);
    if (match) total += Number(match[1]);
  }
  return total;
}

function validateRequestedSparsePaths({cwd, baseSha, requestedSparsePaths, runner}) {
  const existingDirectories = new Set();
  for (const candidate of requestedSparsePaths.filter((entry) => entry.endsWith("/"))) {
    const relative = candidate.replace(/^\//u, "").replace(/\/$/u, "");
    if (gitStatus({cwd, args: ["cat-file", "-e", `${baseSha}:${relative}`], runner}) === 0) {
      existingDirectories.add(candidate);
    }
  }
  for (const candidate of requestedSparsePaths) {
    const relative = candidate.replace(/^\//u, "").replace(/\/$/u, "");
    if (gitStatus({cwd, args: ["cat-file", "-e", `${baseSha}:${relative}`], runner}) === 0) continue;
    const selectedParent = [...existingDirectories].some((directory) => candidate.startsWith(directory));
    if (!selectedParent) {
      throw new Error(
        `Requested sparse path does not exist at ${baseSha} and has no explicitly selected existing parent: ${candidate}`,
      );
    }
  }
}

function remoteBranchHead({cwd, branch, runner}) {
  const result = gitResult({
    cwd,
    args: ["ls-remote", "--heads", "origin", `refs/heads/${branch}`],
    runner,
    tolerateFailure: true,
  });
  if (result.status !== 0) return null;
  const match = result.stdout.trim().match(/^([0-9a-f]{40})\s/u);
  return match?.[1] ?? null;
}

function loadRemoteHeads({cwd, runner}) {
  const result = gitResult({cwd, args: ["ls-remote", "--heads", "origin"], runner, tolerateFailure: true});
  const heads = new Map();
  if (result.status === 0) {
    for (const line of result.stdout.split(/\r?\n/u)) {
      const match = line.match(/^([0-9a-f]{40})\s+(refs\/heads\/[^\s]+)$/u);
      if (match) heads.set(match[2], match[1]);
    }
  }
  return {
    available: result.status === 0,
    heads,
    error: result.status === 0 ? null : "origin_head_snapshot_unavailable",
  };
}

function remoteHeadRef(value) {
  if (!value) return null;
  if (value.startsWith("refs/remotes/origin/")) return `refs/heads/${value.slice("refs/remotes/origin/".length)}`;
  if (value.startsWith("origin/")) return `refs/heads/${value.slice("origin/".length)}`;
  return null;
}

function isAncestor({cwd, ancestor, descendant, runner}) {
  return gitStatus({cwd, args: ["merge-base", "--is-ancestor", ancestor, descendant], runner}) === 0;
}

function isProcessLive(pid) {
  if (!Number.isInteger(Number(pid)) || Number(pid) <= 0) return null;
  try {
    process.kill(Number(pid), 0);
    return true;
  } catch (error) {
    if (error?.code === "ESRCH") return false;
    if (error?.code === "EPERM") return true;
    return null;
  }
}

function directorySize(targetPath) {
  const stat = fs.lstatSync(targetPath);
  if (stat.isSymbolicLink() || !stat.isDirectory()) return stat.size;
  let total = stat.size;
  for (const entry of fs.readdirSync(targetPath)) total += directorySize(path.join(targetPath, entry));
  return total;
}

function allocatedDirectorySize(targetPath) {
  const result = spawnSync("du", ["-sk", targetPath], {encoding: "utf8", shell: false});
  if (result.status !== 0) return null;
  const match = result.stdout.match(/^(\d+)\s/u);
  return match ? Number(match[1]) * 1024 : null;
}

function resolvePhysicalPath(targetPath) {
  const resolved = path.resolve(targetPath);
  let existing = resolved;
  const suffix = [];
  while (!fs.existsSync(existing)) {
    const parent = path.dirname(existing);
    if (parent === existing) return resolved;
    suffix.unshift(path.basename(existing));
    existing = parent;
  }
  let physical;
  try {
    physical = fs.realpathSync(existing);
  } catch {
    physical = existing;
  }
  return path.join(physical, ...suffix);
}

function resolveTargetWorktree(value, fallback) {
  const target = path.resolve(value ?? fallback);
  if (!fs.existsSync(target)) throw new Error(`Worktree does not exist: ${target}`);
  return target;
}

function gitText({cwd, args, runner, input, allowEmpty = false}) {
  const result = gitResult({cwd, args, runner, input});
  const value = result.stdout.trim();
  if (!allowEmpty && !value) throw new Error(`git ${args.join(" ")} returned no value.`);
  return value;
}

function gitStatus({cwd, args, runner}) {
  return gitResult({cwd, args, runner, tolerateFailure: true}).status;
}

function gitResult({cwd, args, runner, input, tolerateFailure = false}) {
  const result = runner("git", args, {cwd, encoding: "utf8", shell: false, input});
  if (result.error) throw result.error;
  if (result.status !== 0 && !tolerateFailure) {
    throw new Error((result.stderr || result.stdout || `git ${args.join(" ")} failed`).trim());
  }
  return {status: result.status, stdout: result.stdout ?? "", stderr: result.stderr ?? ""};
}

function runIgnoringFailure({cwd, args, runner}) {
  runner("git", args, {cwd, encoding: "utf8", shell: false});
}

function requiredValue(args, flag) {
  const value = valueAfter(args, flag);
  if (value == null) throw new TaskUsageError(`${flag} is required.`);
  return value;
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  return index === -1 ? null : args[index + 1];
}

function positiveNumber(value, flag) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) throw new TaskUsageError(`${flag} must be a positive number.`);
  return parsed;
}

function sameStringSet(left, right) {
  return JSON.stringify([...new Set(left)].sort()) === JSON.stringify([...new Set(right)].sort());
}

function formatMiB(bytes) {
  return `${(bytes / MIB).toFixed(1)} MiB`;
}

export function taskHelp() {
  return `Harness task lifecycle:\n  ${Object.values(taskCommandTemplates).join("\n  ")}\n\nTask worktrees are sparse, remotely preserved, locked, and live under .claude/worktrees/. Reap never deletes.`;
}
