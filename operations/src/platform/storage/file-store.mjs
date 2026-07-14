import fs from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";
import {stableStringify, hashText} from "../canonical-json.mjs";
import {OperationsError, invariant} from "../errors.mjs";
import {assertRun, assertWorkItem, validId} from "../contracts.mjs";

const STORE_VERSION = 1;

export class FileOperationsStore {
  constructor(root) {
    invariant(typeof root === "string" && root.length > 0, "INVALID_STORE", "State directory is required.");
    this.root = path.resolve(root);
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

  async updateRun(runId, mutate, {expectedRevision} = {}) {
    const current = await this.requireRun(runId);
    if (expectedRevision !== undefined && current.revision !== expectedRevision) {
      throw new OperationsError("REVISION_CONFLICT", `Run ${runId} changed concurrently.`, {
        details: {expectedRevision, actualRevision: current.revision},
      });
    }
    const next = await mutate(structuredClone(current));
    assertRun(next);
    invariant(next.runId === runId, "INVALID_RUN", "Run id cannot change.");
    const stored = {...next, revision: current.revision + 1};
    await atomicWriteJson(this.entityPath("runs", runId), stored);
    return stored;
  }

  async listRuns() {
    return this.listEntities("runs");
  }

  async putWorkItem(item, {ifAbsent = false} = {}) {
    assertWorkItem(item);
    const file = this.entityPath("work-items", item.workItemId);
    const current = await readJsonIfExists(file);
    if (current && ifAbsent) return {item: current, created: false};
    const stored = {...item, revision: (current?.revision ?? 0) + 1};
    await atomicWriteJson(file, stored);
    return {item: stored, created: !current};
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

  async updateWorkItem(workItemId, mutate, {expectedRevision} = {}) {
    const current = await this.requireWorkItem(workItemId);
    if (expectedRevision !== undefined && current.revision !== expectedRevision) {
      throw new OperationsError("REVISION_CONFLICT", `Work item ${workItemId} changed concurrently.`, {
        details: {expectedRevision, actualRevision: current.revision},
      });
    }
    const next = await mutate(structuredClone(current));
    assertWorkItem(next);
    invariant(next.workItemId === workItemId, "INVALID_WORK_ITEM", "Work item id cannot change.");
    const stored = {...next, revision: current.revision + 1};
    await atomicWriteJson(this.entityPath("work-items", workItemId), stored);
    return stored;
  }

  async listWorkItems({runId, stage, owner, sourceProfileId} = {}) {
    const items = await this.listEntities("work-items");
    return items.filter((item) =>
      (!runId || item.runId === runId) &&
      (!stage || item.primaryStage === stage) &&
      (!owner || item.owner === owner) &&
      (!sourceProfileId || item.source?.sourceProfileId === sourceProfileId)
    );
  }

  async appendAction(action) {
    invariant(validId(action.runId), "INVALID_ACTION", "Action runId is invalid.");
    invariant(validId(action.actionId), "INVALID_ACTION", "Action actionId is invalid.");
    invariant(typeof action.at === "string", "INVALID_ACTION", "Action timestamp is required.");
    const directory = this.resolve("actions", encoded(action.runId));
    await fs.mkdir(directory, {recursive: true});
    const file = this.resolve("actions", encoded(action.runId), `${encoded(action.actionId)}.json`);
    try {
      await exclusiveWriteJson(file, action);
    } catch (error) {
      if (error?.code === "EEXIST") {
        const existing = await readJsonIfExists(file);
        if (stableStringify(existing) === stableStringify(action)) return existing;
        throw new OperationsError("ACTION_CONFLICT", `Action ${action.actionId} already exists with different content.`);
      }
      throw error;
    }
    return action;
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
    const lockDirectory = this.resolve("leases", `${encoded(resourceId)}.lock`);
    const lease = createLease(resourceId, owner, ttlMs, now);
    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        await fs.mkdir(lockDirectory);
        await exclusiveWriteJson(path.join(lockDirectory, "lease.json"), lease);
        return lease;
      } catch (error) {
        if (error?.code !== "EEXIST") throw error;
        const existing = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
        if (existing && Date.parse(existing.expiresAt) > Date.parse(now)) {
          throw new OperationsError("LEASE_HELD", `Resource ${resourceId} is leased by ${existing.owner}.`, {
            details: {resourceId, owner: existing.owner, expiresAt: existing.expiresAt},
            exitCode: 3,
          });
        }
        const stale = this.resolve("leases", `${encoded(resourceId)}.stale.${crypto.randomUUID()}`);
        try {
          await fs.rename(lockDirectory, stale);
          await fs.rm(stale, {recursive: true, force: true});
        } catch (recoveryError) {
          if (recoveryError?.code !== "ENOENT") throw recoveryError;
        }
      }
    }
    throw new OperationsError("LEASE_RACE", `Could not acquire lease for ${resourceId}.`, {exitCode: 3});
  }

  async renewLease(lease, {ttlMs, now}) {
    const lockDirectory = this.resolve("leases", `${encoded(lease.resourceId)}.lock`);
    const current = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
    assertLeaseToken(current, lease);
    const renewed = {
      ...current,
      renewedAt: now,
      expiresAt: new Date(Date.parse(now) + ttlMs).toISOString(),
    };
    await atomicWriteJson(path.join(lockDirectory, "lease.json"), renewed);
    return renewed;
  }

  async releaseLease(lease) {
    const lockDirectory = this.resolve("leases", `${encoded(lease.resourceId)}.lock`);
    const current = await readJsonIfExists(path.join(lockDirectory, "lease.json"));
    if (!current) return false;
    assertLeaseToken(current, lease);
    await fs.rm(lockDirectory, {recursive: true, force: true});
    return true;
  }

  async putCheckpoint(runId, stepId, checkpoint) {
    assertEntityId(runId, "runId");
    assertEntityId(stepId, "stepId");
    const directory = this.resolve("checkpoints", encoded(runId));
    await fs.mkdir(directory, {recursive: true});
    const stored = {schemaVersion: 1, runId, stepId, ...checkpoint};
    await atomicWriteJson(this.resolve("checkpoints", encoded(runId), `${encoded(stepId)}.json`), stored);
    return stored;
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
    try {
      await exclusiveWriteJson(file, record);
      return {record, created: true};
    } catch (error) {
      if (error?.code !== "EEXIST") throw error;
      return {record: await readJsonIfExists(file), created: false};
    }
  }

  async putPromotion(receipt) {
    await atomicWriteJson(this.entityPath("promotions", receipt.receiptId), receipt);
    return receipt;
  }

  async getPromotion(receiptId) {
    return readJsonIfExists(this.entityPath("promotions", receiptId));
  }

  async putAdminProjection(runId, projection) {
    const file = this.resolve("exports", "admin", `${encoded(runId)}.json`);
    await atomicWriteJson(file, projection);
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
    await atomicWriteJson(this.entityPath("rules/evaluations", evaluation.evaluationId), evaluation);
    return evaluation;
  }

  async listRuleEvaluations() {
    return this.listEntities("rules/evaluations");
  }

  async putRuleCanary(canary) {
    await atomicWriteJson(this.entityPath("rules/canaries", canary.canaryId), canary);
    return canary;
  }

  async listRuleCanaries() {
    return this.listEntities("rules/canaries");
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

function createLease(resourceId, owner, ttlMs, now) {
  const timestamp = new Date(now);
  invariant(!Number.isNaN(timestamp.valueOf()), "INVALID_LEASE", "Lease time must be ISO-8601.");
  return {
    schemaVersion: 1,
    resourceId,
    owner,
    token: crypto.randomUUID(),
    acquiredAt: timestamp.toISOString(),
    renewedAt: timestamp.toISOString(),
    expiresAt: new Date(timestamp.valueOf() + ttlMs).toISOString(),
  };
}

function assertLeaseToken(current, expected) {
  if (!current || current.token !== expected.token || current.owner !== expected.owner) {
    throw new OperationsError("LEASE_LOST", `Lease for ${expected.resourceId} is no longer owned by ${expected.owner}.`, {exitCode: 3});
  }
}

function assertEntityId(value, label) {
  invariant(validId(value), "INVALID_ID", `${label} is invalid.`, {[label]: value});
}

function encoded(value) {
  return encodeURIComponent(value);
}

function entitySortKey(value) {
  return String(value.runId ?? value.workItemId ?? value.proposalId ?? value.evaluationId ?? value.canaryId ?? value.receiptId ?? "");
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
