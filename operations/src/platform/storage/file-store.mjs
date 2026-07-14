import fs from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";
import {stableStringify, hashText} from "../canonical-json.mjs";
import {OperationsError, invariant} from "../errors.mjs";
import {assertRun, assertWorkItem, validId} from "../contracts.mjs";

const STORE_VERSION = 1;
const LEASE_GUARD_STALE_MS = 30_000;
const LEASE_GUARD_HEARTBEAT_MS = 5_000;

export class FileOperationsStore {
  constructor(root, {
    leaseGuardStaleMs = LEASE_GUARD_STALE_MS,
    leaseGuardHooks = {},
  } = {}) {
    invariant(typeof root === "string" && root.length > 0, "INVALID_STORE", "State directory is required.");
    invariant(Number.isSafeInteger(leaseGuardStaleMs) && leaseGuardStaleMs >= 0,
      "INVALID_STORE", "Lease guard stale duration must be a non-negative integer.");
    this.root = path.resolve(root);
    this.leaseGuardStaleMs = leaseGuardStaleMs;
    this.leaseGuardHooks = leaseGuardHooks;
  }

  async initialize() {
    await Promise.all([
      "runs",
      "work-items",
      "actions",
      "leases",
      "checkpoints",
      "idempotency",
      "promotions",
      "exports/admin",
      "rules/proposals",
      "rules/evaluations",
      "rules/canaries",
      "rules/actions",
      "model-cache",
    ].map((directory) => fs.mkdir(this.resolve(directory), {recursive: true})));
    const metadataPath = this.resolve("store.json");
    const current = await readJsonIfExists(metadataPath);
    if (!current) {
      await atomicWriteJson(metadataPath, {schemaVersion: STORE_VERSION, kind: "catch-operations-file-store"});
    } else {
      invariant(current.schemaVersion === STORE_VERSION, "STORE_VERSION_MISMATCH", "Unsupported operations store version.", {
        expected: STORE_VERSION,
        actual: current.schemaVersion,
      });
    }
    return this;
  }

  async createRun(run) {
    assertRun(run);
    const file = this.entityPath("runs", run.runId);
    try {
      await exclusiveWriteJson(file, {...run, revision: 1});
      return {...run, revision: 1};
    } catch (error) {
      if (error?.code !== "EEXIST") throw error;
      throw new OperationsError("RUN_EXISTS", `Run ${run.runId} already exists.`, {details: {runId: run.runId}});
    }
  }

  async getRun(runId) {
    assertEntityId(runId, "runId");
    return readJsonIfExists(this.entityPath("runs", runId));
  }

  async requireRun(runId) {
    const run = await this.getRun(runId);
    if (!run) throw new OperationsError("RUN_NOT_FOUND", `Run ${runId} was not found.`, {details: {runId}, exitCode: 2});
    return run;
  }

  async updateRun(runId, mutate, {expectedRevision, lease, now} = {}) {
    const write = async (activeLease) => {
      const current = await this.requireRun(runId);
      if (expectedRevision !== undefined && current.revision !== expectedRevision) {
        throw new OperationsError("REVISION_CONFLICT", `Run ${runId} changed concurrently.`, {
          details: {expectedRevision, actualRevision: current.revision},
        });
      }
      const next = await mutate(structuredClone(current));
      assertRun(next);
      invariant(next.runId === runId, "INVALID_RUN", "Run id cannot change.");
      const stored = {
        ...next,
        revision: current.revision + 1,
        ...(activeLease ? {leaseFencingToken: activeLease.fencingToken} : {}),
      };
      await atomicWriteJson(this.entityPath("runs", runId), stored);
      return stored;
    };
    return lease ? this.withFencedWrite(lease, now, write) : write(null);
  }

  async listRuns() {
    return this.listEntities("runs");
  }

  async putWorkItem(item, {ifAbsent = false, lease, now} = {}) {
    const write = async (activeLease) => {
      assertWorkItem(item);
      const file = this.entityPath("work-items", item.workItemId);
      const current = await readJsonIfExists(file);
      if (current && ifAbsent) {
        invariant(
          stableStringify(withoutStoreMetadata(current)) ===
            stableStringify(withoutStoreMetadata(item)),
          "WORK_ITEM_IDEMPOTENCY_CONFLICT",
          `Work item ${item.workItemId} already exists with different content.`,
          {workItemId: item.workItemId}
        );
        return {item: current, created: false};
      }
      const stored = {
        ...item,
        revision: (current?.revision ?? 0) + 1,
        ...(activeLease ? {leaseFencingToken: activeLease.fencingToken} : {}),
      };
      await atomicWriteJson(file, stored);
      return {item: stored, created: !current};
    };
    return lease ? this.withFencedWrite(lease, now, write) : write(null);
  }

  async getWorkItem(workItemId) {
    assertEntityId(workItemId, "workItemId");
    return readJsonIfExists(this.entityPath("work-items", workItemId));
  }

  async requireWorkItem(workItemId) {
    const item = await this.getWorkItem(workItemId);
    if (!item) throw new OperationsError("WORK_ITEM_NOT_FOUND", `Work item ${workItemId} was not found.`, {exitCode: 2});
    return item;
  }

  async updateWorkItem(workItemId, mutate, {expectedRevision, lease, now} = {}) {
    const write = async (activeLease) => {
      const current = await this.requireWorkItem(workItemId);
      if (expectedRevision !== undefined && current.revision !== expectedRevision) {
        throw new OperationsError("REVISION_CONFLICT", `Work item ${workItemId} changed concurrently.`, {
          details: {expectedRevision, actualRevision: current.revision},
        });
      }
      const next = await mutate(structuredClone(current));
      assertWorkItem(next);
      invariant(next.workItemId === workItemId, "INVALID_WORK_ITEM", "Work item id cannot change.");
      const stored = {
        ...next,
        revision: current.revision + 1,
        ...(activeLease ? {leaseFencingToken: activeLease.fencingToken} : {}),
      };
      await atomicWriteJson(this.entityPath("work-items", workItemId), stored);
      return stored;
    };
    return lease ? this.withFencedWrite(lease, now, write) : write(null);
  }

  async listWorkItems({runId, stage, owner, sourceProfileId, lifecycleStatus} = {}) {
    const items = await this.listEntities("work-items");
    return items.filter((item) =>
      (!runId || item.runId === runId) &&
      (!stage || item.primaryStage === stage) &&
      (!owner || item.owner === owner) &&
      (!sourceProfileId || item.source?.sourceProfileId === sourceProfileId) &&
      (!lifecycleStatus || item.lifecycleStatus === lifecycleStatus)
    );
  }

  async appendAction(action, {lease, now} = {}) {
    const write = async (activeLease) => {
      invariant(validId(action.runId), "INVALID_ACTION", "Action runId is invalid.");
      invariant(validId(action.actionId), "INVALID_ACTION", "Action actionId is invalid.");
      invariant(typeof action.at === "string", "INVALID_ACTION", "Action timestamp is required.");
      const stored = activeLease ? {...action, leaseFencingToken: activeLease.fencingToken} : action;
      const directory = this.resolve("actions", encoded(action.runId));
      await fs.mkdir(directory, {recursive: true});
      const file = this.resolve("actions", encoded(action.runId), `${encoded(action.actionId)}.json`);
      try {
        await exclusiveWriteJson(file, stored);
      } catch (error) {
        if (error?.code === "EEXIST") {
          const existing = await readJsonIfExists(file);
          if (stableStringify(existing) === stableStringify(stored)) return existing;
          throw new OperationsError("ACTION_CONFLICT", `Action ${action.actionId} already exists with different content.`);
        }
        throw error;
      }
      return stored;
    };
    return lease ? this.withFencedWrite(lease, now, write) : write(null);
  }

  async listActions(runId) {
    assertEntityId(runId, "runId");
    const directory = this.resolve("actions", encoded(runId));
    const actions = await listJsonFiles(directory);
    return actions.sort((left, right) => left.at.localeCompare(right.at) || left.actionId.localeCompare(right.actionId));
  }

  async acquireLease(resourceId, {owner, ttlMs, now}) {
    assertEntityId(resourceId, "resourceId");
    invariant(validId(owner), "INVALID_LEASE", "Lease owner is invalid.", {owner});
    invariant(Number.isInteger(ttlMs) && ttlMs >= 1_000, "INVALID_LEASE", "Lease ttlMs must be at least 1000.");
    assertIsoTime(now, "INVALID_LEASE");
    return this.withLeaseGuard(resourceId, async () => {
      const lockDirectory = this.resolve("leases", `${encoded(resourceId)}.lock`);
      const existing = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
      if (existing && Date.parse(existing.expiresAt) > Date.parse(now)) {
        throw new OperationsError("LEASE_HELD", `Resource ${resourceId} is leased by ${existing.owner}.`, {
          details: {resourceId, owner: existing.owner, expiresAt: existing.expiresAt},
          exitCode: 3,
        });
      }
      await fs.rm(lockDirectory, {recursive: true, force: true});
      const fencePath = this.resolve("leases", `${encoded(resourceId)}.fence.json`);
      const priorFence = await readJsonIfExists(fencePath);
      const fencingToken = (priorFence?.fencingToken ?? 0) + 1;
      await atomicWriteJson(fencePath, {schemaVersion: 1, resourceId, fencingToken});
      const lease = createLease(resourceId, owner, ttlMs, now, fencingToken);
      await fs.mkdir(lockDirectory);
      await exclusiveWriteJson(path.join(lockDirectory, "lease.json"), lease);
      return lease;
    });
  }

  async renewLease(lease, {ttlMs, now}) {
    invariant(Number.isInteger(ttlMs) && ttlMs >= 1_000, "INVALID_LEASE", "Lease ttlMs must be at least 1000.");
    assertIsoTime(now, "INVALID_LEASE");
    return this.withLeaseGuard(lease.resourceId, async () => {
      const lockDirectory = this.resolve("leases", `${encoded(lease.resourceId)}.lock`);
      const current = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
      assertActiveLease(current, lease, now);
      const renewed = {
        ...current,
        renewedAt: now,
        heartbeatAt: now,
        expiresAt: new Date(Date.parse(now) + ttlMs).toISOString(),
      };
      await atomicWriteJson(path.join(lockDirectory, "lease.json"), renewed);
      return renewed;
    });
  }

  async releaseLease(lease) {
    return this.withLeaseGuard(lease.resourceId, async () => {
      const lockDirectory = this.resolve("leases", `${encoded(lease.resourceId)}.lock`);
      const current = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
      if (!current) return false;
      assertLeaseToken(current, lease);
      await fs.rm(lockDirectory, {recursive: true, force: true});
      return true;
    });
  }

  async putCheckpoint(runId, stepId, checkpoint, {lease, now} = {}) {
    const write = async (activeLease) => {
      assertEntityId(runId, "runId");
      assertEntityId(stepId, "stepId");
      const directory = this.resolve("checkpoints", encoded(runId));
      await fs.mkdir(directory, {recursive: true});
      const stored = {
        schemaVersion: 1,
        runId,
        stepId,
        ...checkpoint,
        ...(activeLease ? {leaseFencingToken: activeLease.fencingToken} : {}),
      };
      await atomicWriteJson(this.resolve("checkpoints", encoded(runId), `${encoded(stepId)}.json`), stored);
      return stored;
    };
    return lease ? this.withFencedWrite(lease, now, write) : write(null);
  }

  async getCheckpoint(runId, stepId) {
    return readJsonIfExists(this.resolve("checkpoints", encoded(runId), `${encoded(stepId)}.json`));
  }

  async listCheckpoints(runId) {
    return listJsonFiles(this.resolve("checkpoints", encoded(runId)));
  }

  async getIdempotency(key) {
    return readJsonIfExists(this.entityPath("idempotency", hashText(key)));
  }

  async recordIdempotency(key, value) {
    const file = this.entityPath("idempotency", hashText(key));
    const record = {schemaVersion: 1, keyHash: hashText(key), ...value};
    return this.withLeaseGuard(`idempotency:${hashText(key)}`, async () => {
      try {
        await exclusiveWriteJson(file, record);
        return {record, created: true};
      } catch (error) {
        if (error?.code !== "EEXIST") throw error;
        return {record: await readJsonIfExists(file), created: false};
      }
    });
  }

  async deleteIdempotency(key, expectedRecord) {
    const file = this.entityPath("idempotency", hashText(key));
    return this.withLeaseGuard(`idempotency:${hashText(key)}`, async () => {
      const current = await readJsonIfExists(file);
      if (!current || stableStringify(current) !== stableStringify(expectedRecord)) {
        return false;
      }
      try {
        await fs.unlink(file);
        return true;
      } catch (error) {
        if (error?.code === "ENOENT") return false;
        throw error;
      }
    });
  }

  async putPromotion(receipt, {lease, now} = {}) {
    const write = async (activeLease) => {
      const stored = activeLease ? {...receipt, leaseFencingToken: activeLease.fencingToken} : receipt;
      await immutableWriteJson(
        this.entityPath("promotions", receipt.receiptId),
        stored,
        "PROMOTION_CONFLICT"
      );
      return stored;
    };
    return lease ? this.withFencedWrite(lease, now, write) : write(null);
  }

  async getPromotion(receiptId) {
    return readJsonIfExists(this.entityPath("promotions", receiptId));
  }

  async putAdminProjection(runId, projection) {
    const file = this.resolve("exports", "admin", `${encoded(runId)}.json`);
    await immutableWriteJson(file, projection, "ADMIN_PROJECTION_CONFLICT");
    return {projection, path: file};
  }

  adminProjectionPath(runId) {
    return this.resolve("exports", "admin", `${encoded(runId)}.json`);
  }

  async putRuleProposal(proposal) {
    await atomicWriteJson(this.entityPath("rules/proposals", proposal.proposalId), proposal);
    return proposal;
  }

  async getRuleProposal(proposalId) {
    return readJsonIfExists(this.entityPath("rules/proposals", proposalId));
  }

  async listRuleProposals() {
    return this.listEntities("rules/proposals");
  }

  async putRuleEvaluation(evaluation) {
    await immutableWriteJson(
      this.entityPath("rules/evaluations", evaluation.evaluationId),
      evaluation,
      "RULE_EVALUATION_CONFLICT"
    );
    return evaluation;
  }

  async listRuleEvaluations() {
    return this.listEntities("rules/evaluations");
  }

  async putRuleCanary(canary) {
    await immutableWriteJson(
      this.entityPath("rules/canaries", canary.canaryId),
      canary,
      "RULE_CANARY_CONFLICT"
    );
    return canary;
  }

  async listRuleCanaries() {
    return this.listEntities("rules/canaries");
  }

  async appendLearningAction(action) {
    await immutableWriteJson(
      this.entityPath("rules/actions", action.actionId),
      action,
      "LEARNING_ACTION_CONFLICT"
    );
    return action;
  }

  async listLearningActions() {
    return this.listEntities("rules/actions");
  }

  async getModelCache(key) {
    return readJsonIfExists(this.entityPath("model-cache", key));
  }

  async putModelCache(key, value) {
    try {
      await exclusiveWriteJson(this.entityPath("model-cache", key), value);
    } catch (error) {
      if (error?.code !== "EEXIST") throw error;
      const current = await this.getModelCache(key);
      if (stableStringify(current) !== stableStringify(value)) {
        throw new OperationsError("MODEL_CACHE_CONFLICT", "Model cache entry is immutable and content differs.", {details: {key}});
      }
    }
    return value;
  }

  async withFencedWrite(lease, now, write) {
    assertIsoTime(now, "INVALID_LEASE");
    return this.withLeaseGuard(lease.resourceId, async () => {
      const lockDirectory = this.resolve("leases", `${encoded(lease.resourceId)}.lock`);
      const current = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
      assertActiveLease(current, lease, now);
      return write(current);
    });
  }

  async withLeaseGuard(resourceId, work) {
    assertEntityId(resourceId, "resourceId");
    const guardDirectory = this.resolve("leases", `${encoded(resourceId)}.guard`);
    for (let attempt = 0; attempt < 50; attempt += 1) {
      const token = crypto.randomUUID();
      const ownerFile = path.join(guardDirectory, `owner-${token}.json`);
      let identity;
      try {
        await fs.mkdir(guardDirectory);
        identity = await directoryIdentity(guardDirectory);
      } catch (error) {
        if (error?.code !== "EEXIST") throw error;
        if (await recoverStaleLeaseGuard(
          guardDirectory,
          this.leaseGuardStaleMs,
          this.leaseGuardHooks
        )) continue;
        await delay(5);
        continue;
      }
      try {
        await this.leaseGuardHooks.afterMkdir?.({guardDirectory, token});
        await fs.writeFile(ownerFile, `${stableStringify({
          schemaVersion: 1,
          token,
          pid: process.pid,
          acquiredAt: new Date().toISOString(),
        }, {space: 2})}\n`, {flag: "wx", mode: 0o600});
      } catch (error) {
        await removeGuardOwner(ownerFile, guardDirectory, identity);
        if (error?.code === "ENOENT") continue;
        throw error;
      }
      if (!await ownsLeaseGuard(guardDirectory, ownerFile, identity)) {
        await removeGuardOwner(ownerFile, guardDirectory, identity);
        await delay(5);
        continue;
      }
      const heartbeat = setInterval(() => {
        const now = new Date();
        fs.utimes(ownerFile, now, now).catch(() => undefined);
      }, LEASE_GUARD_HEARTBEAT_MS);
      heartbeat.unref?.();
      try {
        await this.leaseGuardHooks.afterOwnerVerified?.({
          guardDirectory,
          ownerFile,
          token,
        });
        return await work();
      } finally {
        clearInterval(heartbeat);
        // The token-specific owner file makes cleanup safe if a stale guard was
        // quarantined and another worker acquired the original directory.
        await removeGuardOwner(ownerFile, guardDirectory, identity);
      }
    }
    throw new OperationsError("LEASE_RACE", `Could not lock lease state for ${resourceId}.`, {exitCode: 3});
  }

  resolve(...parts) {
    const resolved = path.resolve(this.root, ...parts);
    const relative = path.relative(this.root, resolved);
    invariant(relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative)), "PATH_ESCAPE", "State path escapes its root.");
    return resolved;
  }

  entityPath(directory, id) {
    assertEntityId(id, "id");
    return this.resolve(directory, `${encoded(id)}.json`);
  }

  async listEntities(directory) {
    const records = await listJsonFiles(this.resolve(directory));
    return records.sort((left, right) => entitySortKey(left).localeCompare(entitySortKey(right)));
  }
}

function withoutStoreMetadata(value) {
  const comparable = structuredClone(value);
  delete comparable.revision;
  delete comparable.leaseFencingToken;
  return comparable;
}

function createLease(resourceId, owner, ttlMs, now, fencingToken) {
  const timestamp = new Date(now);
  invariant(!Number.isNaN(timestamp.valueOf()), "INVALID_LEASE", "Lease time must be ISO-8601.");
  return {
    schemaVersion: 1,
    resourceId,
    owner,
    token: crypto.randomUUID(),
    fencingToken,
    acquiredAt: timestamp.toISOString(),
    renewedAt: timestamp.toISOString(),
    heartbeatAt: timestamp.toISOString(),
    expiresAt: new Date(timestamp.valueOf() + ttlMs).toISOString(),
  };
}

function assertLeaseToken(current, expected) {
  if (!current || current.token !== expected.token || current.owner !== expected.owner ||
      current.fencingToken !== expected.fencingToken) {
    throw new OperationsError("LEASE_LOST", `Lease for ${expected.resourceId} is no longer owned by ${expected.owner}.`, {exitCode: 3});
  }
}

function assertActiveLease(current, expected, now) {
  assertLeaseToken(current, expected);
  if (Date.parse(current.expiresAt) <= Date.parse(now)) {
    throw new OperationsError("LEASE_EXPIRED", `Lease for ${expected.resourceId} expired before the write.`, {
      details: {resourceId: expected.resourceId, expiresAt: current.expiresAt, now},
      exitCode: 3,
    });
  }
}

function assertIsoTime(value, code) {
  invariant(typeof value === "string" && !Number.isNaN(Date.parse(value)), code, "Lease time must be ISO-8601.");
}

function assertEntityId(value, label) {
  invariant(validId(value), "INVALID_ID", `${label} is invalid.`, {[label]: value});
}

function encoded(value) {
  return encodeURIComponent(value);
}

function entitySortKey(value) {
  return String(value.runId ?? value.workItemId ?? value.proposalId ?? value.evaluationId ??
    value.canaryId ?? value.actionId ?? value.receiptId ?? "");
}

async function immutableWriteJson(file, value, conflictCode) {
  try {
    await exclusiveWriteJson(file, value);
  } catch (error) {
    if (error?.code !== "EEXIST") throw error;
    const current = await readJsonIfExists(file);
    if (stableStringify(current) !== stableStringify(value)) {
      throw new OperationsError(conflictCode, "Immutable operations evidence already exists with different content.");
    }
  }
}

function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function recoverStaleLeaseGuard(guardDirectory, staleMs, hooks = {}) {
  const state = await inspectLeaseGuard(guardDirectory);
  if (!state.exists) return true;
  if (!state.stable) return false;
  const now = Date.now();
  const recoverable = state.owners.length === 0 ?
    now - state.mtimeMs >= staleMs :
    state.owners.every((ownerState) => guardOwnerIsRecoverable(ownerState, staleMs, now));
  if (!recoverable) return false;

  await hooks.beforeRecoveryMarker?.({guardDirectory, state});
  const recoveryToken = crypto.randomUUID();
  const recoveryFile = path.join(guardDirectory, `recovery-${recoveryToken}.json`);
  try {
    await fs.writeFile(recoveryFile, `${stableStringify({
      schemaVersion: 1,
      token: recoveryToken,
      pid: process.pid,
      startedAt: new Date(now).toISOString(),
    }, {space: 2})}\n`, {flag: "wx", mode: 0o600});
  } catch (error) {
    if (error?.code === "ENOENT") return true;
    throw error;
  }
  let moved = false;
  const quarantined = `${guardDirectory}.stale-${process.pid}-${crypto.randomUUID()}`;
  try {
    await hooks.afterRecoveryMarker?.({guardDirectory, recoveryFile});
    const confirmed = await inspectLeaseGuard(guardDirectory);
    const marker = await readJsonIfExists(recoveryFile);
    const ownersStillRecoverable = confirmed.owners.every((ownerState) =>
      guardOwnerIsRecoverable(ownerState, staleMs, Date.now()));
    if (!confirmed.exists ||
        !confirmed.stable ||
        !sameDirectoryIdentity(state.identity, confirmed.identity) ||
        marker?.token !== recoveryToken ||
        !ownersStillRecoverable) {
      return !confirmed.exists;
    }
    await fs.rename(guardDirectory, quarantined);
    moved = true;
  } catch (error) {
    if (error?.code === "ENOENT") return true;
    if (error?.code === "EEXIST") return false;
    throw error;
  } finally {
    if (!moved) {
      await fs.unlink(recoveryFile).catch((error) => {
        if (error?.code !== "ENOENT") throw error;
      });
    }
  }
  await fs.rm(quarantined, {recursive: true, force: true});
  return true;
}

function guardOwnerIsRecoverable({owner, mtimeMs}, staleMs, now) {
  if (Number.isSafeInteger(owner?.pid)) return !isProcessAlive(owner.pid);
  return now - mtimeMs >= staleMs;
}

async function inspectLeaseGuard(guardDirectory) {
  const initialIdentity = await directoryIdentity(guardDirectory);
  if (!initialIdentity) {
    return {exists: false, stable: true, identity: null, owners: [], mtimeMs: 0};
  }
  let entries;
  try {
    entries = await fs.readdir(guardDirectory, {withFileTypes: true});
  } catch (error) {
    if (error?.code === "ENOENT") {
      return {exists: false, stable: true, identity: null, owners: [], mtimeMs: 0};
    }
    throw error;
  }
  const owners = [];
  for (const entry of entries.filter(isGuardOwnerEntry)) {
    const ownerPath = path.join(guardDirectory, entry.name);
    const stat = await fs.stat(ownerPath).catch((error) => {
      if (error?.code === "ENOENT") return null;
      throw error;
    });
    if (!stat) continue;
    let owner = null;
    try {
      owner = JSON.parse(await fs.readFile(ownerPath, "utf8"));
    } catch (error) {
      if (error?.code === "ENOENT") continue;
      if (!(error instanceof SyntaxError)) throw error;
    }
    owners.push({name: entry.name, owner, mtimeMs: stat.mtimeMs});
  }
  const finalIdentity = await directoryIdentity(guardDirectory);
  return {
    exists: finalIdentity !== null,
    stable: sameDirectoryIdentity(initialIdentity, finalIdentity),
    identity: finalIdentity,
    owners,
    mtimeMs: initialIdentity.mtimeMs,
  };
}

async function ownsLeaseGuard(guardDirectory, ownerFile, expectedIdentity) {
  if (!sameDirectoryIdentity(expectedIdentity, await directoryIdentity(guardDirectory))) {
    return false;
  }
  let entries;
  try {
    entries = await fs.readdir(guardDirectory, {withFileTypes: true});
  } catch (error) {
    if (error?.code === "ENOENT") return false;
    throw error;
  }
  const owners = entries.filter(isGuardOwnerEntry).map((entry) => entry.name);
  const recoveryInProgress = entries.some(isGuardRecoveryEntry);
  return !recoveryInProgress &&
    owners.length === 1 && owners[0] === path.basename(ownerFile);
}

async function removeGuardOwner(ownerFile, guardDirectory, expectedIdentity) {
  // The UUID token is unique to this acquisition attempt, so removing it is
  // safe even if the original directory was quarantined and replaced.
  await fs.unlink(ownerFile).catch((error) => {
    if (error?.code !== "ENOENT") throw error;
  });
  if (!sameDirectoryIdentity(expectedIdentity, await directoryIdentity(guardDirectory))) {
    return;
  }
  await fs.rmdir(guardDirectory).catch((error) => {
    if (!["ENOENT", "ENOTEMPTY", "EEXIST"].includes(error?.code)) throw error;
  });
}

async function directoryIdentity(directory) {
  try {
    const stat = await fs.stat(directory);
    return {dev: stat.dev, ino: stat.ino, mtimeMs: stat.mtimeMs};
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

function sameDirectoryIdentity(left, right) {
  return Boolean(left && right && left.dev === right.dev && left.ino === right.ino);
}

function isGuardOwnerEntry(entry) {
  return entry.isFile() && entry.name.startsWith("owner-") && entry.name.endsWith(".json");
}

function isGuardRecoveryEntry(entry) {
  return entry.isFile() && entry.name.startsWith("recovery-") && entry.name.endsWith(".json");
}

function isProcessAlive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch (error) {
    return error?.code !== "ESRCH";
  }
}

async function listJsonFiles(directory) {
  let entries;
  try {
    entries = await fs.readdir(directory, {withFileTypes: true});
  } catch (error) {
    if (error?.code === "ENOENT") return [];
    throw error;
  }
  const files = entries.filter((entry) => entry.isFile() && entry.name.endsWith(".json")).map((entry) => entry.name).sort();
  return Promise.all(files.map((file) => readJsonIfExists(path.join(directory, file))));
}

async function readJsonIfExists(file) {
  try {
    return JSON.parse(await fs.readFile(file, "utf8"));
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    if (error instanceof SyntaxError) {
      throw new OperationsError("CORRUPT_STATE", `Invalid JSON in ${file}.`, {cause: error});
    }
    throw error;
  }
}

async function atomicWriteJson(file, value) {
  await fs.mkdir(path.dirname(file), {recursive: true});
  const temporary = `${file}.${process.pid}.${crypto.randomUUID()}.tmp`;
  await fs.writeFile(temporary, `${stableStringify(value, {space: 2})}\n`, {flag: "wx", mode: 0o600});
  try {
    await fs.rename(temporary, file);
  } catch (error) {
    await fs.rm(temporary, {force: true});
    throw error;
  }
}

async function exclusiveWriteJson(file, value) {
  await fs.mkdir(path.dirname(file), {recursive: true});
  await fs.writeFile(file, `${stableStringify(value, {space: 2})}\n`, {flag: "wx", mode: 0o600});
}
