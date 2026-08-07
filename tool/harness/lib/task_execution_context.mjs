import fs from "node:fs";
import path from "node:path";
import {spawn, spawnSync} from "node:child_process";
import {createHash, randomUUID} from "node:crypto";
import {pathToFileURL} from "node:url";
import {
  buildTaskStartContract,
  CONTEXT_PACK_SCHEMA_V3,
  deriveTaskCheckSelection,
  digestTaskStart,
  isCanonicalTaskPath,
  isValidTaskId,
  normalizeTaskScopePaths,
  resolveStructuredCheckPlan,
  TASK_INPUT_SCHEMA_V2,
  TASK_START_MODE,
} from "../../agent/lib/task_input.mjs";

export const TASK_EXECUTION_DENIED_EXIT_CODE = 77;
export const TASK_METADATA_SCHEMA_V5 = "catch.harness-task/v5";
export const TASK_AUTHORITY_SCHEMA_V1 = "catch.harness-task-authority/v1";
export const TASK_EXECUTION_CHILD_SCHEMA_V1 =
  "catch.harness-task-execution-child/v1";
export const TASK_EXECUTION_TRANSITION_SCHEMA_V1 =
  "catch.harness-task-execution-transition/v1";
export const TASK_EXECUTION_TRANSITION_CLAIM_SCHEMA_V1 =
  "catch.harness-task-execution-transition-claim/v1";

const TASK_STATES = new Set(["active", "finishing", "terminal"]);
const SHA_PATTERN = /^[0-9a-f]{40}$/u;
const REGRESSION_ID_PATTERN = /^REG-[A-Z0-9-]+$/u;
const UUID_V4_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/u;
const TASK_EXECUTION_CLAIM_NAME_PATTERN =
  /^claim-([1-9][0-9]*)-([0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})$/u;

export function readTaskExecutionContext({
  cwd,
  gitRunner = defaultGitRunner,
  validateBaseAuthority = true,
}) {
  const repository = readRepositoryIdentity({cwd, gitRunner});
  if (repository.blockers.length > 0) {
    return blockedContext({blockers: repository.blockers, metadataPath: null});
  }
  const file = readTaskMetadataFile({cwd, gitRunner});
  if (file.kind === "blocked") {
    return blockedContext({blockers: file.blockers, metadataPath: file.metadataPath});
  }
  const {metadataPath} = file;
  if (file.kind === "missing") {
    if (isStrictlyInsidePath(repository.canonicalTaskRoot, repository.worktreePath)) {
      return blockedContext({
        blockers: ["managed_task_metadata_missing"],
        metadataPath,
      });
    }
    return {kind: "unmanaged", metadata: null, metadataPath, blockers: []};
  }
  const {metadata} = file;
  const worktrees = gitRunner({cwd, args: ["worktree", "list", "--porcelain"]});
  let worktreeRecords = null;
  if (worktrees.status === 0) {
    try {
      worktreeRecords = parseWorktreePorcelain(worktrees.stdout);
    } catch {
      worktreeRecords = null;
    }
  }
  const worktreeRecord = worktreeRecords?.find((record) =>
    physicalPath(record.path) === repository.worktreePath) ?? null;
  const branch = gitRunner({cwd, args: ["symbolic-ref", "--quiet", "--short", "HEAD"]});
  const ancestry = typeof metadata?.baseSha === "string"
    ? gitRunner({cwd, args: ["merge-base", "--is-ancestor", metadata.baseSha, "HEAD"]})
    : {status: 1, stdout: "", stderr: ""};
  const blockers = taskExecutionMetadataBlockers({
    metadata,
    worktreePath: repository.worktreePath,
    currentBranch: branch.status === 0 ? branch.stdout.trim() : null,
    baseIsAncestor: ancestry.status === 0,
    worktreeRegistryAvailable: worktreeRecords != null,
    worktreeRegistered: worktreeRecord != null,
    worktreeLocked: worktreeRecord?.locked === true,
    worktreeLockReason: worktreeRecord?.lockReason ?? null,
    liveWorktreeAdminId: repository.worktreeAdminId,
  });
  const authorityFile = readTaskAuthorityFile({repository});
  if (authorityFile.kind !== "present") {
    blockers.push(...authorityFile.blockers);
  } else {
    try {
      if (!sameValue(
        taskExecutionAuthorityFromMetadata(metadata),
        authorityFile.authority.payload,
      )) blockers.push("task_authority_metadata_mismatch");
    } catch {
      blockers.push("task_authority_metadata_unavailable");
    }
  }
  if (validateBaseAuthority && blockers.length === 0) {
    try {
      const expected = deriveTaskStartContractAtBase({
        metadata: authorityFile.authority.payload,
        cwd: repository.worktreePath,
        gitRunner,
      });
      if (!sameValue(taskStartContractFromMetadata(authorityFile.authority.payload), expected)) {
        blockers.push("task_context_base_authority_mismatch");
      }
    } catch {
      blockers.push("task_context_base_authority_unavailable");
    }
  }
  if (blockers.length > 0) {
    return blockedContext({blockers, metadata, metadataPath});
  }
  return {kind: "managed", metadata, metadataPath, blockers: []};
}

export function readTaskMetadataFile({cwd, gitRunner = defaultGitRunner}) {
  const location = gitRunner({cwd, args: ["rev-parse", "--git-path", "catch-task.json"]});
  if (location.status !== 0) {
    return {
      kind: "blocked",
      metadata: null,
      metadataPath: null,
      blockers: ["task_metadata_location_unavailable"],
    };
  }
  const rawPath = location.stdout.trim();
  if (rawPath === "") {
    return {
      kind: "blocked",
      metadata: null,
      metadataPath: null,
      blockers: ["task_metadata_location_empty"],
    };
  }
  const metadataPath = path.isAbsolute(rawPath) ? rawPath : path.resolve(cwd, rawPath);
  const stat = lstatOrNull(metadataPath);
  if (stat == null) return {kind: "missing", metadata: null, metadataPath, blockers: []};
  if (stat.isSymbolicLink() || !stat.isFile()) {
    return {
      kind: "blocked",
      metadata: null,
      metadataPath,
      blockers: ["task_metadata_not_regular_file"],
    };
  }
  try {
    return {
      kind: "present",
      metadata: JSON.parse(fs.readFileSync(metadataPath, "utf8")),
      metadataPath,
      blockers: [],
    };
  } catch {
    return {
      kind: "blocked",
      metadata: null,
      metadataPath,
      blockers: ["task_metadata_invalid_json"],
    };
  }
}

export function taskExecutionMetadataBlockers({
  metadata,
  worktreePath,
  validateMaterialization = true,
  validateLiveGit = true,
  currentBranch = null,
  baseIsAncestor = false,
  worktreeRegistryAvailable = false,
  worktreeRegistered = false,
  worktreeLocked = false,
  worktreeLockReason = null,
  liveWorktreeAdminId = null,
}) {
  const blockers = [];
  if (metadata == null || typeof metadata !== "object" || Array.isArray(metadata)) {
    return ["task_metadata_invalid_shape"];
  }
  if (metadata.schema !== TASK_METADATA_SCHEMA_V5) {
    blockers.push("task_metadata_schema_not_current");
  }
  if (!TASK_STATES.has(metadata.status)) blockers.push("task_metadata_state_invalid");
  if (!isValidTaskId(metadata.taskId)) blockers.push("task_metadata_task_id_invalid");
  if (!SHA_PATTERN.test(metadata.baseSha ?? "")) blockers.push("task_metadata_base_sha_invalid");
  if (typeof metadata.branch !== "string" || metadata.branch === "") {
    blockers.push("task_metadata_branch_invalid");
  }
  if (validateLiveGit && currentBranch !== metadata.branch) {
    blockers.push(currentBranch == null
      ? "task_current_branch_unavailable"
      : "task_metadata_branch_mismatch");
  }
  if (validateLiveGit && baseIsAncestor !== true) {
    blockers.push("task_base_not_ancestor_of_head");
  }
  if (validateLiveGit && !worktreeRegistryAvailable) {
    blockers.push("task_worktree_registry_unavailable");
  } else if (validateLiveGit && !worktreeRegistered) {
    blockers.push("task_worktree_not_registered");
  } else if (validateLiveGit && metadata.status === "active" && !worktreeLocked) {
    blockers.push("active_worktree_not_locked");
  } else if (validateLiveGit && metadata.status === "active" &&
      worktreeLockReason !== `catch-task:${metadata.taskId}:${metadata.authorityId}`) {
    blockers.push("task_lock_reason_mismatch");
  }
  if (typeof metadata.authorityId !== "string" ||
      !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/u.test(
        metadata.authorityId,
      )) {
    blockers.push("task_metadata_authority_id_invalid");
  }
  if (typeof metadata.worktreeAdminId !== "string" || metadata.worktreeAdminId === "") {
    blockers.push("task_metadata_worktree_admin_id_invalid");
  } else if (validateLiveGit && metadata.worktreeAdminId !== liveWorktreeAdminId) {
    blockers.push("task_authority_registration_mismatch");
  }
  if (typeof metadata.worktreePath !== "string" || metadata.worktreePath === "" ||
      physicalPath(metadata.worktreePath) !== physicalPath(worktreePath)) {
    blockers.push("task_metadata_path_mismatch");
  }

  let ownedPaths = [];
  let plannedImpactPaths = [];
  try {
    ownedPaths = normalizeTaskScopePaths(metadata.ownedPaths);
    if (!sameStringArray(ownedPaths, metadata.ownedPaths)) {
      blockers.push("task_metadata_owned_paths_invalid");
    }
  } catch {
    blockers.push("task_metadata_owned_paths_invalid");
  }
  try {
    plannedImpactPaths = normalizeTaskScopePaths(metadata.plannedImpactPaths);
    if (plannedImpactPaths.length === 0 ||
        !sameStringArray(plannedImpactPaths, metadata.plannedImpactPaths)) {
      blockers.push("task_metadata_planned_impact_paths_invalid");
    }
  } catch {
    blockers.push("task_metadata_planned_impact_paths_invalid");
  }
  if (ownedPaths.length > 0 && plannedImpactPaths.some((impactPath) =>
    !ownedPaths.some((ownedPath) =>
      impactPath === ownedPath || impactPath.startsWith(`${ownedPath}/`)))) {
    blockers.push("task_metadata_planned_impact_outside_owned_paths");
  }

  const receipt = metadata.contextPack;
  if (receipt == null || typeof receipt !== "object" || Array.isArray(receipt)) {
    blockers.push("task_context_receipt_invalid");
    return uniqueSorted(blockers);
  }
  if (receipt.packSchema !== CONTEXT_PACK_SCHEMA_V3 ||
      receipt.taskInputSchema !== TASK_INPUT_SCHEMA_V2 ||
      receipt.mode !== TASK_START_MODE ||
      receipt.sourceSha !== metadata.baseSha) {
    blockers.push("task_context_receipt_contract_mismatch");
  }
  for (const field of [
    "checkIds",
    "deferredCheckIds",
    "deferredRegressionIds",
    "supportPaths",
    "requiredEntrypoints",
  ]) {
    if (!isUniqueStringArray(receipt[field])) {
      blockers.push(`task_context_receipt_${field}_invalid`);
    }
  }
  if (isUniqueStringArray(receipt.checkIds) && isUniqueStringArray(receipt.deferredCheckIds)) {
    const deferred = new Set(receipt.deferredCheckIds);
    if (receipt.checkIds.some((id) => deferred.has(id))) {
      blockers.push("task_context_check_ownership_overlap");
    }
  }
  if (isUniqueStringArray(receipt.deferredRegressionIds) &&
      receipt.deferredRegressionIds.some((id) => !REGRESSION_ID_PATTERN.test(id))) {
    blockers.push("task_context_deferred_regression_id_invalid");
  }
  for (const field of ["supportPaths", "requiredEntrypoints"]) {
    if (isUniqueStringArray(receipt[field]) &&
        receipt[field].some((entry) => !isCanonicalTaskPath(entry))) {
      blockers.push(`task_context_receipt_${field}_invalid`);
    }
  }
  if (validateMaterialization && isUniqueStringArray(receipt.requiredEntrypoints)) {
    for (const relativePath of receipt.requiredEntrypoints) {
      if (!isCanonicalTaskPath(relativePath) || !isMaterializedTaskPath({
        worktreePath,
        relativePath,
        kind: "file",
      })) {
        blockers.push(`task_required_entrypoint_missing:${relativePath}`);
      }
    }
  }
  if (validateMaterialization && isUniqueStringArray(receipt.supportPaths)) {
    for (const relativePath of receipt.supportPaths) {
      if (!isCanonicalTaskPath(relativePath) || !isMaterializedTaskPath({
        worktreePath,
        relativePath,
        kind: "any",
      })) {
        blockers.push(`task_support_path_missing:${relativePath}`);
      }
    }
  }
  if (typeof receipt.digest !== "string" || !/^[0-9a-f]{64}$/u.test(receipt.digest)) {
    blockers.push("task_context_digest_invalid");
  } else if (blockers.length === 0) {
    const contract = taskStartContractFromMetadata(metadata);
    const {digest: _digest, ...payload} = contract;
    if (receipt.digest !== digestTaskStart(payload)) {
      blockers.push("task_context_digest_mismatch");
    }
  }
  return uniqueSorted(blockers);
}

export function taskStartContractFromMetadata(metadata) {
  const receipt = metadata.contextPack;
  return {
    schema: receipt.taskInputSchema,
    taskId: metadata.taskId,
    mode: receipt.mode,
    baseSha: metadata.baseSha,
    ownedPaths: metadata.ownedPaths,
    plannedImpactPaths: metadata.plannedImpactPaths,
    checkIds: receipt.checkIds,
    requiredEntrypoints: receipt.requiredEntrypoints,
    supportPaths: receipt.supportPaths,
    deferredCheckIds: receipt.deferredCheckIds,
    deferredRegressionIds: receipt.deferredRegressionIds,
    complete: true,
    blockers: [],
    digest: receipt.digest,
  };
}

export function taskExecutionAuthorityFromMetadata(metadata) {
  return {
    authorityId: metadata.authorityId,
    worktreeAdminId: metadata.worktreeAdminId,
    taskId: metadata.taskId,
    baseSha: metadata.baseSha,
    stackParent: metadata.stackParent,
    stackParentSha: metadata.stackParentSha,
    branch: metadata.branch,
    worktreePath: physicalPath(metadata.worktreePath),
    sparsePaths: metadata.sparsePaths,
    ownedPaths: metadata.ownedPaths,
    plannedImpactPaths: metadata.plannedImpactPaths,
    contextPack: metadata.contextPack,
    budgetAllocatedBytes: metadata.budgetAllocatedBytes,
    reserveAllocatedBytes: metadata.reserveAllocatedBytes,
    estimatedTrackedLogicalBytes: metadata.estimatedTrackedLogicalBytes,
    projectedInitialAllocatedBytes: metadata.projectedInitialAllocatedBytes,
    initialMaterializedLogicalBytes: metadata.initialMaterializedLogicalBytes,
    initialMaterializedAllocatedBytes: metadata.initialMaterializedAllocatedBytes,
    creatorPid: metadata.creatorPid,
    createdAt: metadata.createdAt,
  };
}

export function createTaskAuthorityFile({cwd, metadata, gitRunner = defaultGitRunner}) {
  const repository = readRepositoryIdentity({cwd, gitRunner});
  if (repository.blockers.length > 0 || repository.worktreeAdminId == null) {
    throw new Error("Task authority requires a registered linked-worktree administrative ID.");
  }
  const authorityPath = taskAuthorityPath({repository});
  const authorityDirectory = ensureTaskControlDirectory(repository);
  const directoryStat = fs.lstatSync(authorityDirectory);
  if (directoryStat.isSymbolicLink() || !directoryStat.isDirectory()) {
    throw new Error(`Task authority directory is unsafe: ${authorityDirectory}`);
  }
  const payload = taskExecutionAuthorityFromMetadata(metadata);
  const authority = {
    schema: TASK_AUTHORITY_SCHEMA_V1,
    payload,
    digest: digestStableValue(payload),
  };
  const fd = fs.openSync(authorityPath, "wx", 0o400);
  try {
    fs.writeFileSync(fd, `${JSON.stringify(authority, null, 2)}\n`, "utf8");
    fs.fsyncSync(fd);
  } finally {
    fs.closeSync(fd);
  }
  fs.chmodSync(authorityPath, 0o400);
  return {authority, authorityPath};
}

export function removeTaskAuthorityFile({cwd, gitRunner = defaultGitRunner}) {
  const repository = readRepositoryIdentity({cwd, gitRunner});
  if (repository.blockers.length > 0 || repository.worktreeAdminId == null) return;
  const authorityPath = taskAuthorityPath({repository});
  try {
    fs.chmodSync(authorityPath, 0o600);
    fs.unlinkSync(authorityPath);
  } catch (error) {
    if (error?.code !== "ENOENT") throw error;
  }
  try {
    fs.rmdirSync(path.dirname(authorityPath));
  } catch (error) {
    if (!["ENOENT", "ENOTEMPTY"].includes(error?.code)) throw error;
  }
}

export function acquireTaskExecutionLease({
  cwd,
  owner,
  gitRunner = defaultGitRunner,
  pid = process.pid,
  now = () => new Date(),
}) {
  const repository = readRepositoryIdentity({cwd, gitRunner});
  if (repository.blockers.length > 0 || repository.worktreeAdminId == null) {
    return {acquired: false, blockers: ["task_execution_lease_location_unavailable"]};
  }
  const taskControlDirectory = ensureTaskControlDirectory(repository);
  const leasePath = path.join(taskControlDirectory, "gate");
  const ownerPath = path.join(leasePath, "owner.json");
  const lease = {
    schema: "catch.harness-task-execution-lease/v1",
    token: randomUUID(),
    owner,
    pid,
    createdAt: now().toISOString(),
  };
  const stagingPath = path.join(taskControlDirectory, `gate.pending-${lease.token}`);
  const stagingOwnerPath = path.join(stagingPath, "owner.json");
  const generationPath = taskLeaseGenerationPath(stagingPath, lease.token);
  try {
    fs.mkdirSync(stagingPath, {mode: 0o700});
    fs.mkdirSync(generationPath, {mode: 0o700});
    fs.mkdirSync(path.join(generationPath, "children"), {mode: 0o700});
    writeJsonFileExclusive(stagingOwnerPath, lease);
    fs.renameSync(stagingPath, leasePath);
    let released = false;
    return {
      acquired: true,
      blockers: [],
      lease,
      leasePath,
      release() {
        if (released) return;
        released = true;
        const current = readJsonFileOrNull(ownerPath);
        if (current?.token === lease.token) {
          const transition = createTaskLeaseTransition({
            leasePath,
            leaseToken: lease.token,
            operation: "releasing",
          });
          if (!transition.created) return;
          finalizeExecutionLeaseRemoval({
            leasePath,
            leaseToken: lease.token,
            transition: transition.record,
            claim: transition.claim,
          });
        }
      },
    };
  } catch (error) {
    try {
      fs.unlinkSync(stagingOwnerPath);
    } catch {
      // The staging owner may not have been written yet.
    }
    try {
      fs.rmdirSync(path.join(generationPath, "children"));
    } catch {
      // A failed staging child directory may not exist or may already be gone.
    }
    try {
      fs.rmdirSync(generationPath);
    } catch {
      // A failed staging generation directory may not exist or may already be gone.
    }
    try {
      fs.rmdirSync(stagingPath);
    } catch {
      // A failed staging path remains non-authoritative.
    }
    if (!["EEXIST", "ENOTEMPTY"].includes(error?.code)) throw error;
    const existing = readJsonFileOrNull(ownerPath);
    const blocker = executionLeaseBlocker({leasePath, lease: existing});
    return {
      acquired: false,
      blockers: [blocker],
      lease: existing,
      leasePath,
    };
  }
}

export function registerTaskExecutionChild({
  leasePath,
  leaseToken,
  pid = process.pid,
  processGroupId = process.platform === "win32" ? null : process.pid,
  now = () => new Date(),
  beforePublish = () => {},
}) {
  if (!isOrdinaryDirectory(leasePath)) {
    return {registered: false, blocker: "task_execution_lease_changed"};
  }
  const ownerPath = path.join(leasePath, "owner.json");
  const owner = readJsonFileOrNull(ownerPath);
  if (!isValidExecutionLease(owner) || owner.token !== leaseToken ||
      taskLeaseTransitionActive(leasePath, leaseToken)) {
    return {registered: false, blocker: "task_execution_lease_changed"};
  }
  const generationPath = taskLeaseGenerationPath(leasePath, leaseToken);
  if (!isOrdinaryDirectory(generationPath)) {
    return {registered: false, blocker: "task_execution_lease_changed"};
  }
  const childrenPath = path.join(generationPath, "children");
  const record = {
    schema: TASK_EXECUTION_CHILD_SCHEMA_V1,
    token: randomUUID(),
    leaseToken,
    pid,
    processGroupId,
    createdAt: now().toISOString(),
  };
  if (!isValidExecutionLeaseChild(record)) {
    return {registered: false, blocker: "task_execution_child_invalid"};
  }
  const childPath = path.join(childrenPath, `${pid}-${record.token}.json`);
  const stagingPath = path.join(
    path.dirname(leasePath),
    `gate.child.pending-${leaseToken}-${record.token}.json`,
  );
  try {
    writeJsonFileExclusive(stagingPath, record);
    beforePublish({stagingPath, childPath, record});
    fs.renameSync(stagingPath, childPath);
  } catch {
    try {
      fs.unlinkSync(stagingPath);
    } catch {
      // Only this registration attempt can own its unique staging path.
    }
    return {registered: false, blocker: "task_execution_child_registration_failed"};
  }
  const confirmed = readJsonFileOrNull(ownerPath);
  if (confirmed?.token !== leaseToken || taskLeaseTransitionActive(leasePath, leaseToken)) {
    try {
      fs.unlinkSync(childPath);
    } catch {
      // A transition owner may already have claimed the child record.
    }
    return {registered: false, blocker: "task_execution_lease_changed"};
  }
  return {
    registered: true,
    blocker: null,
    record,
    childPath,
    ownerPid: owner.pid,
  };
}

export function recoverStaleTaskExecutionLease({
  cwd,
  gitRunner = defaultGitRunner,
  beforeChildDirectoryRemoval = () => {},
  afterChildDirectoryRemoval = () => {},
  afterGateRetirement = () => {},
  beforeTransitionPublish = () => {},
  beforeTransitionClaim = () => {},
}) {
  const repository = readRepositoryIdentity({cwd, gitRunner});
  if (repository.blockers.length > 0 || repository.worktreeAdminId == null) {
    return {recovered: false, blockers: ["task_execution_lease_location_unavailable"]};
  }
  const leasePath = path.join(taskControlPath({repository}), "gate");
  const ownerPath = path.join(leasePath, "owner.json");
  if (!fs.existsSync(leasePath)) {
    return {recovered: false, blockers: ["task_execution_lease_missing"], leasePath};
  }
  if (!isOrdinaryDirectory(leasePath)) {
    return {recovered: false, blockers: ["task_execution_lease_invalid"], leasePath};
  }
  const existing = readJsonFileOrNull(ownerPath);
  if (existing == null && isEmptyOrdinaryDirectory(leasePath)) {
    fs.rmdirSync(leasePath);
    return {recovered: true, blockers: [], lease: null, leasePath};
  }
  if (!isValidExecutionLease(existing)) {
    return {recovered: false, blockers: ["task_execution_lease_invalid"], leasePath};
  }
  const existingTransition = readTaskLeaseTransition(leasePath, existing.token);
  if (existingTransition.kind === "invalid") {
    return {recovered: false, blockers: ["task_execution_lease_invalid"], leasePath};
  }
  if (existingTransition.kind === "present") {
    const childState = readExecutionLeaseChildren({
      leasePath,
      leaseToken: existing.token,
    });
    if (childState.invalid) {
      return {recovered: false, blockers: ["task_execution_lease_invalid"], leasePath};
    }
    if (childState.live.length > 0 || isProcessLive(existing.pid)) {
      return {
        recovered: false,
        blockers: ["task_execution_lease_active"],
        lease: existing,
        leasePath,
      };
    }
    if (existingTransition.claim != null && isProcessLive(existingTransition.claim.pid)) {
      return {
        recovered: false,
        blockers: ["task_execution_lease_transition_active"],
        lease: existing,
        leasePath,
      };
    }
    const claimed = claimTaskLeaseTransition({
      leasePath,
      transition: existingTransition,
      beforeRename: beforeTransitionClaim,
    });
    if (!claimed.claimed) {
      return {
        recovered: false,
        blockers: [claimed.blocker],
        lease: existing,
        leasePath,
      };
    }
    const removal = finalizeExecutionLeaseRemoval({
      leasePath,
      leaseToken: existing.token,
      transition: existingTransition.record,
      claim: claimed.claim,
      beforeChildDirectoryRemoval,
      afterChildDirectoryRemoval,
      afterGateRetirement,
    });
    return removal.removed
      ? {recovered: true, blockers: [], lease: existing, leasePath}
      : {
          recovered: false,
          blockers: [removal.blocker],
          lease: existing,
          leasePath,
        };
  }
  const leaseBlocker = executionLeaseBlocker({leasePath, lease: existing});
  if (leaseBlocker !== "task_execution_lease_stale") {
    return {recovered: false, blockers: [leaseBlocker], lease: existing, leasePath};
  }
  const transition = createTaskLeaseTransition({
    leasePath,
    leaseToken: existing.token,
    operation: "recovering",
    beforePublish: beforeTransitionPublish,
  });
  if (!transition.created) {
    return {
      recovered: false,
      blockers: [transition.blocker],
      leasePath,
    };
  }
  const confirmed = readJsonFileOrNull(ownerPath);
  if (confirmed?.token !== existing.token) {
    return {recovered: false, blockers: ["task_execution_lease_changed"], leasePath};
  }
  const removal = finalizeExecutionLeaseRemoval({
    leasePath,
    leaseToken: existing.token,
    transition: transition.record,
    claim: transition.claim,
    beforeChildDirectoryRemoval,
    afterChildDirectoryRemoval,
    afterGateRetirement,
  });
  if (!removal.removed) {
    return {
      recovered: false,
      blockers: [removal.blocker],
      lease: existing,
      leasePath,
    };
  }
  return {recovered: true, blockers: [], lease: existing, leasePath};
}

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

export function deriveTaskStartContractAtBase({
  metadata,
  cwd,
  gitRunner = defaultGitRunner,
}) {
  const baseSha = metadata.baseSha;
  const manifest = readJsonAtCommit({cwd, baseSha, relativePath: "tool/tools_manifest.json", gitRunner});
  const selection = deriveTaskSelectionAtCommit({
    cwd,
    baseSha,
    taskId: metadata.taskId,
    mode: metadata.contextPack.mode,
    impactPaths: metadata.plannedImpactPaths,
    gitRunner,
  });
  const checkPlan = resolveStructuredCheckPlan({
    manifest,
    requestedChecks: selection.requests,
  });
  return buildTaskStartContract({
    taskId: metadata.taskId,
    mode: metadata.contextPack.mode,
    sourceSha: baseSha,
    ownedPaths: metadata.ownedPaths,
    plannedImpactPaths: metadata.plannedImpactPaths,
    checkPlan,
    sourceClean: true,
    blockers: checkPlan.blockers,
    deferredRegressionIds: selection.deferredRegressionIds,
    schema: metadata.contextPack.taskInputSchema,
  });
}

export function deriveTaskSelectionAtCommit({
  cwd,
  baseSha,
  taskId,
  mode,
  impactPaths,
  gitRunner = defaultGitRunner,
}) {
  if (mode !== TASK_START_MODE) {
    throw new Error(`Task context pack mode must be ${TASK_START_MODE}.`);
  }
  const skills = readJsonAtCommit({
    cwd,
    baseSha,
    relativePath: "docs/agent_skills/skills_manifest.json",
    gitRunner,
  });
  if (!Array.isArray(skills?.skills)) {
    throw new Error("Task skill authority is malformed at the base SHA.");
  }
  return deriveTaskCheckSelection({
    task: taskId,
    mode,
    impactPaths: expandSelectionPathsAtCommit({
      cwd,
      baseSha,
      scopePaths: impactPaths,
      gitRunner,
    }),
    skills: skills.skills,
    regressions: [],
  });
}

export function authorizeTaskCheckIds(context, checkIds) {
  if (context.kind === "unmanaged") return {allowed: true, denied: [], blockers: []};
  if (context.kind === "blocked") {
    return {allowed: false, denied: [], blockers: context.blockers};
  }
  if (context.metadata.status !== "active") {
    return {
      allowed: false,
      denied: [],
      blockers: [`task_phase_not_active:${context.metadata.status}`],
    };
  }
  const worker = new Set(context.metadata.contextPack.checkIds);
  const parent = new Set(context.metadata.contextPack.deferredCheckIds);
  const denied = [...new Set(checkIds)].sort().flatMap((id) => {
    if (worker.has(id)) return [];
    return [{id, reason: parent.has(id) ? "parent_deferred_check" : "unplanned_task_check"}];
  });
  return {allowed: denied.length === 0, denied, blockers: []};
}

export function taskProcessIsolationBlockers({context, platform = process.platform}) {
  return context.kind === "managed" && platform === "win32"
    ? ["task_process_group_isolation_unavailable"]
    : [];
}

export function taskToolDefinitionBlockers({
  context,
  tools,
  cwd,
  gitRunner = defaultGitRunner,
}) {
  if (context.kind !== "managed") return context.kind === "blocked" ? context.blockers : [];
  let manifest;
  try {
    manifest = readJsonAtCommit({
      cwd,
      baseSha: context.metadata.baseSha,
      relativePath: "tool/tools_manifest.json",
      gitRunner,
    });
  } catch {
    return ["task_tool_definition_authority_unavailable"];
  }
  if (!Array.isArray(manifest?.tools)) return ["task_tool_definition_authority_invalid"];
  const baseTools = new Map(manifest.tools.map((tool) => [tool.id, tool]));
  return uniqueSorted(tools.flatMap((tool) => {
    const baseTool = baseTools.get(tool.id);
    if (baseTool == null) return [`task_tool_definition_missing:${tool.id}`];
    return sameValue(taskToolExecutionSignature(tool), taskToolExecutionSignature(baseTool))
      ? []
      : [`task_tool_definition_drift:${tool.id}`];
  }));
}

export function taskPlanningAuthorityBlockers({
  context,
  sources,
  cwd,
  gitRunner = defaultGitRunner,
}) {
  if (context.kind !== "managed") return context.kind === "blocked" ? context.blockers : [];
  const blockers = [];
  for (const {relativePath, value} of sources) {
    try {
      const authority = readJsonAtCommit({
        cwd,
        baseSha: context.metadata.baseSha,
        relativePath,
        gitRunner,
      });
      if (!sameValue(value, authority)) blockers.push(`task_planning_authority_drift:${relativePath}`);
    } catch {
      blockers.push(`task_planning_authority_unavailable:${relativePath}`);
    }
  }
  return uniqueSorted(blockers);
}

function taskToolExecutionSignature(tool) {
  return {
    id: tool.id,
    status: tool.status,
    path: tool.path,
    safety: tool.safety ?? null,
    checkSafety: tool.checkSafety ?? null,
    platforms: tool.platforms ?? null,
    checks: tool.checks ?? null,
  };
}

function defaultGitRunner({cwd, args}) {
  return spawnSync("git", args, {cwd, encoding: "utf8"});
}

function readRepositoryIdentity({cwd, gitRunner}) {
  const worktree = gitRunner({cwd, args: ["rev-parse", "--show-toplevel"]});
  const common = gitRunner({cwd, args: ["rev-parse", "--git-common-dir"]});
  const gitDirectory = gitRunner({cwd, args: ["rev-parse", "--absolute-git-dir"]});
  const blockers = [];
  if (worktree.status !== 0 || worktree.stdout.trim() === "") {
    blockers.push("task_worktree_root_unavailable");
  }
  if (common.status !== 0 || common.stdout.trim() === "") {
    blockers.push("task_git_common_dir_unavailable");
  }
  if (gitDirectory.status !== 0 || gitDirectory.stdout.trim() === "") {
    blockers.push("task_git_directory_unavailable");
  }
  if (blockers.length > 0) return {blockers};
  const worktreePath = physicalPath(worktree.stdout.trim());
  const commonPath = physicalPath(path.resolve(cwd, common.stdout.trim()));
  const gitDirectoryPath = physicalPath(gitDirectory.stdout.trim());
  const worktreeAdminRoot = physicalPath(path.join(commonPath, "worktrees"));
  const adminRelative = path.relative(worktreeAdminRoot, gitDirectoryPath);
  const worktreeAdminId = adminRelative !== "" &&
      !adminRelative.startsWith("..") &&
      !path.isAbsolute(adminRelative) &&
      !adminRelative.includes(path.sep)
    ? adminRelative
    : null;
  return {
    blockers: [],
    worktreePath,
    commonPath,
    gitDirectoryPath,
    worktreeAdminId,
    canonicalTaskRoot: physicalPath(path.join(path.dirname(commonPath), ".claude", "worktrees")),
  };
}

function readTaskAuthorityFile({repository}) {
  if (repository.worktreeAdminId == null) {
    return {
      kind: "blocked",
      authority: null,
      authorityPath: null,
      blockers: ["task_worktree_admin_id_unavailable"],
    };
  }
  const authorityPath = taskAuthorityPath({repository});
  const stat = lstatOrNull(authorityPath);
  if (stat == null) {
    return {kind: "missing", authority: null, authorityPath, blockers: ["task_authority_missing"]};
  }
  if (stat.isSymbolicLink() || !stat.isFile()) {
    return {
      kind: "blocked",
      authority: null,
      authorityPath,
      blockers: ["task_authority_not_regular_file"],
    };
  }
  if ((stat.mode & 0o222) !== 0) {
    return {
      kind: "blocked",
      authority: null,
      authorityPath,
      blockers: ["task_authority_file_mutable"],
    };
  }
  try {
    const authority = JSON.parse(fs.readFileSync(authorityPath, "utf8"));
    if (authority?.schema !== TASK_AUTHORITY_SCHEMA_V1 ||
        authority.payload == null ||
        authority.digest !== digestStableValue(authority.payload)) {
      return {
        kind: "blocked",
        authority,
        authorityPath,
        blockers: ["task_authority_invalid"],
      };
    }
    return {kind: "present", authority, authorityPath, blockers: []};
  } catch {
    return {
      kind: "blocked",
      authority: null,
      authorityPath,
      blockers: ["task_authority_invalid_json"],
    };
  }
}

function taskAuthorityPath({repository}) {
  return path.join(taskControlPath({repository}), "authority.json");
}

function taskControlPath({repository}) {
  return path.join(
    repository.commonPath,
    "catch-harness",
    "tasks",
    repository.worktreeAdminId,
  );
}

function ensureTaskControlDirectory(repository) {
  let current = repository.commonPath;
  for (const segment of ["catch-harness", "tasks", repository.worktreeAdminId]) {
    current = path.join(current, segment);
    const stat = lstatOrNull(current);
    if (stat == null) {
      fs.mkdirSync(current, {mode: 0o700});
      continue;
    }
    if (stat.isSymbolicLink() || !stat.isDirectory()) {
      throw new Error(`Task control directory is unsafe: ${current}`);
    }
  }
  return current;
}

export function readJsonAtCommit({
  cwd,
  baseSha,
  relativePath,
  gitRunner = defaultGitRunner,
}) {
  const result = gitRunner({cwd, args: ["show", `${baseSha}:${relativePath}`]});
  if (result.status !== 0) throw new Error(`Unable to read ${relativePath} at ${baseSha}.`);
  return JSON.parse(result.stdout);
}

export function expandSelectionPathsAtCommit({
  cwd,
  baseSha,
  scopePaths,
  gitRunner = defaultGitRunner,
}) {
  const result = gitRunner({
    cwd,
    args: ["ls-tree", "-r", "--name-only", "-z", baseSha, "--", ...scopePaths],
  });
  if (result.status !== 0) throw new Error("Unable to expand task selection paths.");
  return normalizeTaskScopePaths([
    ...scopePaths,
    ...result.stdout.split("\0").filter(Boolean),
  ]);
}

function blockedContext({blockers, metadata = null, metadataPath}) {
  return {
    kind: "blocked",
    metadata,
    metadataPath,
    blockers: uniqueSorted(blockers),
  };
}

function lstatOrNull(targetPath) {
  try {
    return fs.lstatSync(targetPath);
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

function physicalPath(targetPath) {
  const resolved = path.resolve(targetPath);
  try {
    return fs.realpathSync(resolved);
  } catch {
    return resolved;
  }
}

function isMaterializedTaskPath({worktreePath, relativePath, kind}) {
  const root = physicalPath(worktreePath);
  const absolutePath = path.join(worktreePath, relativePath);
  const stat = lstatOrNull(absolutePath);
  if (stat == null || stat.isSymbolicLink()) return false;
  if (kind === "file" && !stat.isFile()) return false;
  if (kind === "any" && !stat.isFile() && !stat.isDirectory()) return false;
  const resolved = physicalPath(absolutePath);
  const relative = path.relative(root, resolved);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

function isStrictlyInsidePath(parentPath, candidatePath) {
  const relative = path.relative(physicalPath(parentPath), physicalPath(candidatePath));
  return relative !== "" && !relative.startsWith("..") && !path.isAbsolute(relative);
}

function isUniqueStringArray(value) {
  return Array.isArray(value) &&
    value.every((entry) => typeof entry === "string" && entry !== "") &&
    new Set(value).size === value.length;
}

function sameStringArray(left, right) {
  return Array.isArray(left) && Array.isArray(right) &&
    left.length === right.length && left.every((entry, index) => entry === right[index]);
}

function uniqueSorted(values) {
  return [...new Set(values)].sort();
}

function sameValue(left, right) {
  return stableStringify(left) === stableStringify(right);
}

function digestStableValue(value) {
  return createHash("sha256").update(stableStringify(value)).digest("hex");
}

function readJsonFileOrNull(filePath) {
  try {
    const stat = fs.lstatSync(filePath);
    if (stat.isSymbolicLink() || !stat.isFile()) return null;
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return null;
  }
}

function isValidExecutionLease(value) {
  return value?.schema === "catch.harness-task-execution-lease/v1" &&
    UUID_V4_PATTERN.test(value.token ?? "") &&
    typeof value.owner === "string" && value.owner !== "" &&
    Number.isInteger(Number(value.pid)) && Number(value.pid) > 0 &&
    Number.isFinite(Date.parse(value.createdAt));
}

function isValidExecutionLeaseChild(value) {
  return value?.schema === TASK_EXECUTION_CHILD_SCHEMA_V1 &&
    typeof value.token === "string" && value.token !== "" &&
    typeof value.leaseToken === "string" && value.leaseToken !== "" &&
    Number.isInteger(Number(value.pid)) && Number(value.pid) > 0 &&
    (value.processGroupId == null ||
      (Number.isInteger(Number(value.processGroupId)) && Number(value.processGroupId) > 0)) &&
    Number.isFinite(Date.parse(value.createdAt));
}

function executionLeaseBlocker({leasePath, lease}) {
  if (!isOrdinaryDirectory(leasePath)) return "task_execution_lease_invalid";
  if (!isValidExecutionLease(lease)) return "task_execution_lease_invalid";
  const transition = readTaskLeaseTransition(leasePath, lease.token);
  if (transition.kind === "invalid") return "task_execution_lease_invalid";
  if (transition.kind === "present") {
    const childState = readExecutionLeaseChildren({
      leasePath,
      leaseToken: transition.record.leaseToken,
    });
    if (childState.invalid) return "task_execution_lease_invalid";
    return isProcessLive(lease.pid) || isProcessLive(transition.claim.pid) ||
        childState.live.length > 0
      ? "task_execution_lease_active"
      : "task_execution_lease_stale";
  }
  const childState = readExecutionLeaseChildren({leasePath, leaseToken: lease.token});
  if (childState.invalid) return "task_execution_lease_invalid";
  return isProcessLive(lease.pid) || childState.live.length > 0
    ? "task_execution_lease_active"
    : "task_execution_lease_stale";
}

function readExecutionLeaseChildren({leasePath, leaseToken}) {
  if (!isOrdinaryDirectory(leasePath)) {
    return {invalid: true, live: [], records: []};
  }
  const generationPath = taskLeaseGenerationPath(leasePath, leaseToken);
  if (!isOrdinaryDirectory(generationPath)) {
    return {invalid: true, live: [], records: []};
  }
  const childrenPath = path.join(generationPath, "children");
  let entries;
  try {
    const stat = fs.lstatSync(childrenPath);
    if (stat.isSymbolicLink() || !stat.isDirectory()) {
      return {invalid: true, live: [], records: []};
    }
    entries = fs.readdirSync(childrenPath).sort();
  } catch (error) {
    return {invalid: true, live: [], records: []};
  }
  const records = [];
  for (const entry of entries) {
    const childPath = path.join(childrenPath, entry);
    const record = readJsonFileOrNull(childPath);
    if (!entry.endsWith(".json") || !isValidExecutionLeaseChild(record) ||
        record.leaseToken !== leaseToken) {
      return {invalid: true, live: [], records};
    }
    records.push({childPath, record});
  }
  return {
    invalid: false,
    records,
    live: records.filter(({record}) => isExecutionLeaseChildLive(record)),
  };
}

function isExecutionLeaseChildLive(record) {
  if (process.platform !== "win32" && record.processGroupId != null) {
    try {
      process.kill(-Number(record.processGroupId), 0);
      return true;
    } catch (error) {
      if (error?.code === "ESRCH") return false;
      return true;
    }
  }
  return isProcessLive(record.pid);
}

function taskLeaseTransitionActive(leasePath, leaseToken) {
  return readTaskLeaseLayout(leasePath, leaseToken).kind !== "ordinary";
}

function createTaskLeaseTransition({
  leasePath,
  leaseToken,
  operation,
  pid = process.pid,
  now = () => new Date(),
  beforePublish = () => {},
}) {
  const transitionToken = randomUUID();
  const claimToken = randomUUID();
  const taskControlDirectory = path.dirname(leasePath);
  const generationPath = taskLeaseGenerationPath(leasePath, leaseToken);
  const layout = readTaskLeaseLayout(leasePath, leaseToken);
  if (layout.kind !== "ordinary") {
    return {
      created: false,
      blocker: layout.kind === "transition"
        ? "task_execution_lease_transition_active"
        : "task_execution_lease_invalid",
      record: null,
      claim: null,
      transitionPath: path.join(generationPath, "transition"),
    };
  }
  const transitionPath = path.join(generationPath, "transition");
  const stagingPath = path.join(
    taskControlDirectory,
    `gate.transition.pending-${transitionToken}`,
  );
  const stagingOwnerPath = path.join(stagingPath, "owner.json");
  const claimName = taskLeaseClaimName({pid, token: claimToken});
  const stagingClaimPath = path.join(stagingPath, claimName);
  const stagingClaimReceiptPath = path.join(stagingClaimPath, "transition.json");
  const record = {
    schema: TASK_EXECUTION_TRANSITION_SCHEMA_V1,
    token: transitionToken,
    operation,
    leaseToken,
    createdAt: now().toISOString(),
  };
  const claimReceipt = {
    schema: TASK_EXECUTION_TRANSITION_CLAIM_SCHEMA_V1,
    transitionToken,
  };
  try {
    fs.mkdirSync(stagingPath, {mode: 0o700});
    writeJsonFileExclusive(stagingOwnerPath, record);
    fs.mkdirSync(stagingClaimPath, {mode: 0o700});
    writeJsonFileExclusive(stagingClaimReceiptPath, claimReceipt);
    beforePublish({stagingPath, transitionPath, record});
    fs.renameSync(stagingPath, transitionPath);
    return {
      created: true,
      blocker: null,
      record,
      claim: {pid, token: claimToken, claimPath: path.join(transitionPath, claimName)},
      transitionPath,
    };
  } catch (error) {
    removeTransitionStagingPath({
      stagingPath,
      stagingOwnerPath,
      stagingClaimPath,
      stagingClaimReceiptPath,
    });
    if (!["EEXIST", "ENOTEMPTY", "ENOENT"].includes(error?.code)) throw error;
    return {
      created: false,
      blocker: error?.code === "ENOENT"
        ? "task_execution_lease_changed"
        : "task_execution_lease_transition_active",
      record: null,
      transitionPath,
    };
  }
}

function readTaskLeaseTransition(leasePath, leaseToken) {
  const layout = readTaskLeaseLayout(leasePath, leaseToken);
  if (layout.kind === "invalid") {
    return {kind: "invalid", record: null, claim: null};
  }
  if (layout.kind === "ordinary") return {kind: "missing", record: null, claim: null};
  const transitionPath = layout.transitionPath;
  const record = readJsonFileOrNull(path.join(transitionPath, "owner.json"));
  if (!isValidTaskLeaseTransition(record) || record.leaseToken !== leaseToken) {
    return {kind: "invalid", record: null, claim: null};
  }
  let entries;
  try {
    entries = fs.readdirSync(transitionPath).sort();
  } catch {
    return {kind: "invalid", record: null, claim: null};
  }
  const claimNames = entries.filter((entry) => entry.startsWith("claim-"));
  if (entries.length !== 2 || !entries.includes("owner.json") || claimNames.length !== 1) {
    return {kind: "invalid", record: null, claim: null};
  }
  const claim = parseTaskLeaseClaim({
    claimPath: path.join(transitionPath, claimNames[0]),
    transitionToken: record.token,
  });
  if (claim == null) return {kind: "invalid", record: null, claim: null};
  return {kind: "present", record, claim, transitionPath};
}

function readTaskLeaseLayout(leasePath, leaseToken) {
  if (!isOrdinaryDirectory(leasePath)) return {kind: "invalid"};
  const generationPath = taskLeaseGenerationPath(leasePath, leaseToken);
  if (!isOrdinaryDirectory(generationPath)) return {kind: "invalid"};
  try {
    if (!sameStringArray(
      fs.readdirSync(leasePath).sort(),
      [`generation-${leaseToken}`, "owner.json"].sort(),
    )) return {kind: "invalid"};
    const generationEntries = fs.readdirSync(generationPath).sort();
    if (sameStringArray(generationEntries, ["children"]) &&
        isOrdinaryDirectory(path.join(generationPath, "children"))) {
      return {kind: "ordinary", generationPath};
    }
    if (sameStringArray(generationEntries, ["children", "transition"]) &&
        isOrdinaryDirectory(path.join(generationPath, "children")) &&
        isOrdinaryDirectory(path.join(generationPath, "transition"))) {
      return {
        kind: "transition",
        generationPath,
        transitionPath: path.join(generationPath, "transition"),
      };
    }
    return {kind: "invalid"};
  } catch {
    return {kind: "invalid"};
  }
}

function isValidTaskLeaseTransition(value) {
  return value?.schema === TASK_EXECUTION_TRANSITION_SCHEMA_V1 &&
    ["recovering", "releasing"].includes(value.operation) &&
    UUID_V4_PATTERN.test(value.token ?? "") &&
    UUID_V4_PATTERN.test(value.leaseToken ?? "") &&
    Number.isFinite(Date.parse(value.createdAt));
}

function claimTaskLeaseTransition({
  leasePath,
  transition,
  pid = process.pid,
  beforeRename = () => {},
}) {
  const current = readTaskLeaseTransition(leasePath, transition.record.leaseToken);
  if (current.kind !== "present" || current.record.token !== transition.record.token) {
    return {claimed: false, blocker: "task_execution_lease_changed", claim: null};
  }
  if (isProcessLive(current.claim.pid)) {
    return {
      claimed: false,
      blocker: "task_execution_lease_transition_active",
      claim: current.claim,
    };
  }
  const token = randomUUID();
  const claimPath = path.join(
    current.transitionPath,
    taskLeaseClaimName({pid, token}),
  );
  try {
    beforeRename({currentClaim: current.claim, claimPath, transition: current.record});
    fs.renameSync(current.claim.claimPath, claimPath);
  } catch (error) {
    if (error?.code !== "ENOENT") throw error;
    const raced = readTaskLeaseTransition(leasePath, transition.record.leaseToken);
    return {
      claimed: false,
      blocker: raced.kind === "present" && isProcessLive(raced.claim.pid)
        ? "task_execution_lease_transition_active"
        : "task_execution_lease_changed",
      claim: raced.kind === "present" ? raced.claim : null,
    };
  }
  return {claimed: true, blocker: null, claim: {pid, token, claimPath}};
}

function finalizeExecutionLeaseRemoval({
  leasePath,
  leaseToken,
  transition,
  claim,
  beforeChildDirectoryRemoval = () => {},
  afterChildDirectoryRemoval = () => {},
  afterGateRetirement = () => {},
}) {
  if (!isOrdinaryDirectory(leasePath)) {
    return {removed: false, blocker: "task_execution_lease_invalid"};
  }
  const childrenPath = path.join(taskLeaseGenerationPath(leasePath, leaseToken), "children");
  const owner = readJsonFileOrNull(path.join(leasePath, "owner.json"));
  const currentTransition = readTaskLeaseTransition(leasePath, leaseToken);
  if (owner?.token !== leaseToken || currentTransition.kind !== "present" ||
      currentTransition.record.token !== transition.token ||
      currentTransition.record.operation !== transition.operation ||
      currentTransition.claim.token !== claim.token ||
      currentTransition.claim.pid !== claim.pid) {
    return {removed: false, blocker: "task_execution_lease_changed"};
  }
  let childState = readExecutionLeaseChildren({leasePath, leaseToken});
  if (childState.invalid) {
    return {removed: false, blocker: "task_execution_lease_invalid"};
  }
  if (childState.live.length > 0) {
    return {removed: false, blocker: "task_execution_lease_active"};
  }
  beforeChildDirectoryRemoval({childrenPath, leaseToken});
  childState = readExecutionLeaseChildren({leasePath, leaseToken});
  if (childState.invalid) {
    return {removed: false, blocker: "task_execution_lease_invalid"};
  }
  if (childState.live.length > 0) {
    return {removed: false, blocker: "task_execution_lease_active"};
  }
  afterChildDirectoryRemoval({leasePath, leaseToken, transition});
  const confirmedOwner = readJsonFileOrNull(path.join(leasePath, "owner.json"));
  const confirmedTransition = readTaskLeaseTransition(leasePath, leaseToken);
  if (confirmedOwner?.token !== leaseToken || confirmedTransition.kind !== "present" ||
      confirmedTransition.record.token !== transition.token ||
      confirmedTransition.claim.token !== claim.token ||
      confirmedTransition.claim.pid !== claim.pid) {
    return {removed: false, blocker: "task_execution_lease_changed"};
  }
  const retiredLeasePath = path.join(
    path.dirname(leasePath),
    `gate.retired-${leaseToken}-${randomUUID()}`,
  );
  try {
    fs.renameSync(leasePath, retiredLeasePath);
  } catch (error) {
    if (error?.code === "ENOENT") {
      return {removed: false, blocker: "task_execution_lease_changed"};
    }
    throw error;
  }
  afterGateRetirement({retiredLeasePath, leasePath, leaseToken, transition});
  const cleanupPending = !removeRetiredExecutionLease({
    retiredLeasePath,
    leaseToken,
    transition,
    claim,
  });
  return {removed: true, blocker: null, cleanupPending, retiredLeasePath};
}

function removeTransitionStagingPath({
  stagingPath,
  stagingOwnerPath,
  stagingClaimPath,
  stagingClaimReceiptPath,
}) {
  try {
    fs.unlinkSync(stagingClaimReceiptPath);
  } catch {
    // The caller only removes its unique, non-authoritative staging files.
  }
  try {
    fs.rmdirSync(stagingClaimPath);
  } catch {
    // The claim directory may never have been created.
  }
  try {
    fs.unlinkSync(stagingOwnerPath);
  } catch {
    // The transition receipt may never have been created.
  }
  try {
    fs.rmdirSync(stagingPath);
  } catch {
    // The staging directory may already have been published or removed.
  }
}

function removeRetiredExecutionLease({retiredLeasePath, leaseToken, transition, claim}) {
  try {
    const generationPath = taskLeaseGenerationPath(retiredLeasePath, leaseToken);
    const childrenPath = path.join(generationPath, "children");
    if (!isOrdinaryDirectory(retiredLeasePath) || !isOrdinaryDirectory(generationPath) ||
        !isOrdinaryDirectory(childrenPath)) return false;
    if (!sameStringArray(
      fs.readdirSync(retiredLeasePath).sort(),
      [`generation-${leaseToken}`, "owner.json"].sort(),
    )) return false;
    if (!sameStringArray(
      fs.readdirSync(generationPath).sort(),
      ["children", "transition"],
    )) return false;
    const owner = readJsonFileOrNull(path.join(retiredLeasePath, "owner.json"));
    const retiredTransition = readTaskLeaseTransition(retiredLeasePath, leaseToken);
    const childState = readExecutionLeaseChildren({
      leasePath: retiredLeasePath,
      leaseToken,
    });
    if (!isValidExecutionLease(owner) || owner.token !== leaseToken ||
        retiredTransition.kind !== "present" ||
        retiredTransition.record.token !== transition.token ||
        retiredTransition.claim.token !== claim.token || childState.invalid) return false;
    for (const {childPath} of childState.records) {
      fs.unlinkSync(childPath);
    }
    fs.rmdirSync(childrenPath);
    const transitionPath = path.join(generationPath, "transition");
    fs.unlinkSync(path.join(transitionPath, path.basename(claim.claimPath), "transition.json"));
    fs.rmdirSync(path.join(transitionPath, path.basename(claim.claimPath)));
    fs.unlinkSync(path.join(transitionPath, "owner.json"));
    fs.rmdirSync(transitionPath);
    fs.rmdirSync(generationPath);
    fs.unlinkSync(path.join(retiredLeasePath, "owner.json"));
    fs.rmdirSync(retiredLeasePath);
    return true;
  } catch {
    return false;
  }
}

function parseTaskLeaseClaim({claimPath, transitionToken}) {
  const match = TASK_EXECUTION_CLAIM_NAME_PATTERN.exec(path.basename(claimPath));
  if (match == null) return null;
  const stat = lstatOrNull(claimPath);
  if (stat == null || stat.isSymbolicLink() || !stat.isDirectory()) return null;
  let entries;
  try {
    entries = fs.readdirSync(claimPath);
  } catch {
    return null;
  }
  if (entries.length !== 1 || entries[0] !== "transition.json") return null;
  const receipt = readJsonFileOrNull(path.join(claimPath, "transition.json"));
  if (receipt?.schema !== TASK_EXECUTION_TRANSITION_CLAIM_SCHEMA_V1 ||
      receipt.transitionToken !== transitionToken) return null;
  return {pid: Number(match[1]), token: match[2], claimPath};
}

function taskLeaseClaimName({pid, token}) {
  return `claim-${Number(pid)}-${token}`;
}

function taskLeaseGenerationPath(leasePath, leaseToken) {
  return path.join(leasePath, `generation-${leaseToken}`);
}

function writeJsonFileExclusive(filePath, value) {
  const fd = fs.openSync(filePath, "wx", 0o600);
  try {
    fs.writeFileSync(fd, `${JSON.stringify(value)}\n`, "utf8");
    fs.fsyncSync(fd);
  } finally {
    fs.closeSync(fd);
  }
}

function isEmptyOrdinaryDirectory(directoryPath) {
  try {
    const stat = fs.lstatSync(directoryPath);
    return !stat.isSymbolicLink() && stat.isDirectory() &&
      fs.readdirSync(directoryPath).length === 0;
  } catch {
    return false;
  }
}

function isOrdinaryDirectory(directoryPath) {
  const stat = lstatOrNull(directoryPath);
  return stat != null && !stat.isSymbolicLink() && stat.isDirectory();
}

function isProcessLive(pid) {
  try {
    process.kill(Number(pid), 0);
    return true;
  } catch (error) {
    if (error?.code === "ESRCH") return false;
    return true;
  }
}

function stableStringify(value) {
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(",")}]`;
  if (value == null || typeof value !== "object") return JSON.stringify(value);
  return `{${Object.keys(value).sort().map((key) =>
    `${JSON.stringify(key)}:${stableStringify(value[key])}`).join(",")}}`;
}

async function runTaskCheckChildEntrypoint(args) {
  const [mode, leasePath, leaseToken, command] = args;
  if (mode !== "task-check-child" || !leasePath || !leaseToken || !command) {
    console.error("Managed task check child requires a lease path, lease token, and command.");
    process.exit(TASK_EXECUTION_DENIED_EXIT_CODE);
  }

  const child = registerTaskExecutionChild({leasePath, leaseToken});
  if (!child.registered) {
    console.error(`Managed task check child denied: ${child.blocker}.`);
    process.exit(TASK_EXECUTION_DENIED_EXIT_CODE);
  }

  const commandChild = spawn(command, {
    cwd: process.cwd(),
    shell: true,
    stdio: "inherit",
  });
  let commandResult = null;
  let requestedSignal = null;
  let cancellationStartedAt = null;
  let ownerLost = false;

  const beginCancellation = (signal) => {
    if (requestedSignal != null) return;
    requestedSignal = signal;
    cancellationStartedAt = Date.now();
  };
  const signalCommandGroup = (signal) => {
    const pid = process.platform === "win32" ? commandChild.pid : -process.pid;
    if (!pid) return;
    try {
      process.kill(pid, signal);
    } catch (error) {
      if (error?.code !== "ESRCH") throw error;
    }
  };
  for (const signal of ["SIGINT", "SIGTERM"]) {
    process.on(signal, () => beginCancellation(signal));
  }
  commandChild.once("error", (error) => {
    commandResult = {status: 1, signal: null, error};
  });
  commandChild.once("close", (status, signal) => {
    commandResult = {status, signal, error: null};
  });

  while (true) {
    if (!isProcessLive(child.ownerPid)) {
      ownerLost = true;
      beginCancellation("SIGTERM");
    }
    if (requestedSignal) {
      const elapsed = Date.now() - cancellationStartedAt;
      signalCommandGroup(elapsed >= 2000 ? "SIGKILL" : requestedSignal);
    }
    if (commandResult != null && !ownerLost) break;
    if (commandResult != null && ownerLost && Date.now() - cancellationStartedAt >= 2000) {
      signalCommandGroup("SIGKILL");
    }
    await new Promise((resolve) => setTimeout(resolve, 50));
  }

  if (commandResult?.error) {
    console.error(commandResult.error.message);
    process.exit(1);
  }
  if (requestedSignal || commandResult?.signal) {
    process.exit(requestedSignal === "SIGINT" ? 130 : 143);
  }
  process.exit(commandResult?.status ?? 1);
}

const directEntrypoint = process.argv[1] == null
  ? null
  : pathToFileURL(path.resolve(process.argv[1])).href;
if (directEntrypoint === import.meta.url) {
  await runTaskCheckChildEntrypoint(process.argv.slice(2));
}
