import fs from "node:fs/promises";
import path from "node:path";
import {hashValue} from "./canonical-json.mjs";
import {PRIMARY_STAGES, safeId, uniqueSorted} from "./contracts.mjs";
import {OperationsError} from "./errors.mjs";
import {validateJsonSchema} from "./json-schema.mjs";

export function summarizeRun(run, items, actions = [], checkpoints = []) {
  const activeItems = items.filter((item) => item.lifecycleStatus === "active");
  return {
    schemaVersion: 1,
    run: toCanonicalRunRecord(run, items, actions, checkpoints),
    summary: {
      totalItems: items.length,
      activeItems: activeItems.length,
      terminalItems: items.length - activeItems.length,
      stageCounts: counts(PRIMARY_STAGES, activeItems, (item) => item.primaryStage),
      lifecycleCounts: counts(
        ["active", "published", "rejected", "expired", "cancelled", "taken_down"],
        items,
        (item) => item.lifecycleStatus
      ),
      entityCounts: counts(["event", "organizer", "source_result", "source_profile"], items, (item) => item.entityKind),
      ownerCounts: dynamicCounts(activeItems, (item) => item.owner),
      blockerCounts: dynamicCounts(activeItems.flatMap((item) => item.blockers), (value) => value),
      taskFlagCounts: dynamicCounts(activeItems.flatMap((item) => item.taskFlags), (value) => value),
      actions: actions.length,
      checkpoints: checkpoints.length,
    },
  };
}

export function queueProjection(items, {limit = 100} = {}) {
  return items
    .sort(compareQueueItems)
    .slice(0, limit)
    .map(toCanonicalWorkItemRecord);
}

export function buildAdminProjection(run, items, actions = [], checkpoints = []) {
  const status = summarizeRun(run, items, actions, checkpoints);
  return {
    schemaVersion: 1,
    program: "catch-operations-admin-projection",
    workflowId: run.workflowId,
    workflowVersion: run.workflowVersion,
    generatedAt: run.updatedAt,
    run: status.run,
    summary: status.summary,
    stageOrder: [...PRIMARY_STAGES],
    items: queueProjection(items, {limit: Number.MAX_SAFE_INTEGER}),
    guardrails: [
      "Run and item records conform to contracts/operations/run.schema.json and work_item.schema.json.",
      "This projection is read-only and contains no raw provider payloads.",
      "Primary stages are exclusive; task flags and blocker codes are overlapping concerns.",
      "Shadow decisions and ready items do not authorize publication.",
    ],
  };
}

export function toCanonicalRunRecord(run, items = [], actions = [], checkpoints = []) {
  const latestCheckpoint = checkpoints.find((checkpoint) => checkpoint.stepId === "deterministic-review") ??
    checkpoints.find((checkpoint) => checkpoint.stepId === "project-artifacts") ?? null;
  const consumed = run.budget?.consumed ?? {};
  const limits = run.budget?.limits ?? {};
  return {
    schemaVersion: 1,
    runId: run.runId,
    workflowId: run.workflowId,
    revision: run.revision ?? 0,
    mode: run.mode,
    status: run.status,
    scope: {
      market: run.plan?.market ?? null,
      through: run.plan?.through ?? null,
      planId: run.planId,
    },
    rulesetVersion: `${run.workflowId}-v${run.workflowVersion}`,
    policyVersion: `${run.workflowId}-shadow-policy-v1`,
    inputHash: run.planHash,
    budgets: {
      maxWorkItems: limits.workItems ?? 1,
      maxModelCalls: limits.modelCalls ?? 0,
      maxModelTokens: (limits.modelInputTokens ?? 0) + (limits.modelOutputTokens ?? 0),
      maxCostMicros: limits.modelCostMicros ?? 0,
      deadlineAt: null,
    },
    counters: {
      discovered: items.length,
      processed: items.filter((item) => item.primaryStage !== "incoming" || item.lifecycleStatus !== "active").length,
      modelCalls: consumed.modelCalls ?? 0,
      modelTokens: (consumed.modelInputTokens ?? 0) + (consumed.modelOutputTokens ?? 0),
      costMicros: consumed.modelCostMicros ?? 0,
      escalated: items.filter((item) => item.owner === "human" && item.lifecycleStatus === "active").length,
      published: items.filter((item) => item.lifecycleStatus === "published").length,
      failed: run.status === "failed" ? 1 : 0,
    },
    checkpoint: {
      lastSequence: actions.length,
      cursor: latestCheckpoint?.stepId ?? null,
    },
    createdAt: run.createdAt,
    updatedAt: run.updatedAt,
    startedAt: run.startedAt,
    finishedAt: run.completedAt,
    failure: run.failure ? {
      code: canonicalCode(run.failure.code ?? "run_failed"),
      message: String(run.failure.message ?? "Run failed."),
      retryable: false,
    } : null,
    metadata: {
      planHash: run.planHash,
      localCounters: run.counters,
      capabilities: run.capabilities,
      localBudget: run.budget,
    },
  };
}

export function toCanonicalWorkItemRecord(item) {
  const artifactId = safeId(`artifact-${item.evidence.artifactHash.slice(0, 32)}`);
  const evidenceRef = {
    artifactId,
    contentHash: item.evidence.artifactHash,
    observedAt: item.timestamps.observedAt ?? item.createdAt,
    locator: item.evidence.artifactRef ?? null,
  };
  const terminal = item.lifecycleStatus !== "active";
  const confidence = boundedConfidence(item.confidence.overall);
  return {
    schemaVersion: 1,
    workItemId: item.workItemId,
    workflowId: item.workflowId,
    runId: item.runId,
    entityKind: item.entityKind,
    externalKey: item.sourceEntity.id ?? null,
    revision: item.revision ?? 0,
    candidateHash: hashValue({
      sourceEntity: item.sourceEntity,
      evidenceHash: item.evidence.artifactHash,
      decisionInputHash: item.decisionProvenance.inputHash,
    }),
    primaryStage: item.primaryStage,
    lifecycleStatus: canonicalLifecycleStatus(item),
    outcome: terminal ? item.lifecycleStatus : null,
    taskFlags: uniqueSorted([
      ...item.taskFlags,
      ...(item.owner === "human" ? ["human_review_required"] : []),
    ]).map(canonicalCode),
    blockerCodes: uniqueSorted(item.blockers).map(canonicalCode),
    warningCodes: [],
    priority: priorityFor(item),
    attemptCount: Math.max(1, (item.stageHistory?.length ?? 0) + 1),
    evidenceRefs: [evidenceRef],
    fieldProvenance: [
      fieldProvenance("sourceEntity.title", item, artifactId, confidence),
      fieldProvenance("source.url", item, artifactId, boundedConfidence(item.confidence.fieldConfidence?.source)),
    ],
    normalizedPayload: {
      title: item.sourceEntity.title,
      market: item.market ?? null,
      sourceEntity: {...item.sourceEntity},
      source: {...item.source},
      owner: item.owner,
      confidence: {...item.confidence, overall: confidence},
      decisionProvenance: {...item.decisionProvenance},
      citations: uniqueSorted(item.evidence.citations),
      provenanceStatus: item.evidence.provenanceStatus,
    },
    decisionId: null,
    publicationPlanId: null,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    staleAt: item.timestamps.evidenceStaleAt ?? null,
    expiresAt: item.expiresAt,
  };
}

export async function validateCanonicalProjection({repoRoot, projection, requireContracts = false}) {
  const contractRoot = path.join(repoRoot, "contracts", "operations");
  let common;
  let runSchema;
  let itemSchema;
  try {
    [common, runSchema, itemSchema] = await Promise.all([
      readJson(path.join(contractRoot, "common.schema.json")),
      readJson(path.join(contractRoot, "run.schema.json")),
      readJson(path.join(contractRoot, "work_item.schema.json")),
    ]);
  } catch (error) {
    if (error?.code === "ENOENT" && !requireContracts) {
      return {status: "contracts_missing", valid: null, contractRoot};
    }
    throw new OperationsError("OPERATIONS_CONTRACTS_MISSING", "Canonical operations contracts are required for projection validation.", {
      details: {contractRoot},
      cause: error,
    });
  }
  const registry = {"common.schema.json": common};
  const run = validateJsonSchema(runSchema, projection.run, {registry});
  const items = projection.items.map((item) => validateJsonSchema(itemSchema, item, {registry}));
  const errors = [
    ...run.errors.map((error) => ({record: "run", ...error})),
    ...items.flatMap((result, index) => result.errors.map((error) => ({record: `items[${index}]`, ...error}))),
  ];
  if (errors.length > 0) {
    throw new OperationsError("CANONICAL_PROJECTION_INVALID", "Admin projection does not satisfy canonical operations contracts.", {
      details: {contractRoot, errors: errors.slice(0, 100)},
    });
  }
  return {status: "validated", valid: true, contractRoot, runRecords: 1, workItemRecords: projection.items.length};
}

function fieldProvenance(field, item, artifactId, confidence) {
  return {
    field,
    artifactId,
    contentHash: item.evidence.artifactHash,
    locator: item.evidence.artifactRef ?? null,
    extractedBy: item.decisionProvenance.actorKind === "human" ? "human" : "deterministic",
    extractorVersion: `${item.workflowId}-v0.1.0`,
    confidence,
  };
}

function canonicalLifecycleStatus(item) {
  if (item.lifecycleStatus === "published") return "published";
  if (item.lifecycleStatus !== "active") return "terminal";
  if (item.primaryStage === "incoming") return "queued";
  if (item.primaryStage === "verify") return "in_progress";
  if (item.primaryStage === "resolve") return "waiting";
  return "ready";
}

function priorityFor(item) {
  const stageBase = {incoming: 400_000, verify: 500_000, resolve: 800_000, ready: 100_000}[item.primaryStage];
  const expiration = Date.parse(item.expiresAt);
  if (Number.isNaN(expiration)) return stageBase;
  const days = Math.max(0, Math.min(30, Math.ceil((expiration - Date.parse(item.updatedAt)) / 86_400_000)));
  return Math.max(0, Math.min(1_000_000, stageBase + (30 - days) * 1_000));
}

function boundedConfidence(value) {
  if (typeof value !== "number" || !Number.isFinite(value)) return null;
  return Math.max(0, Math.min(1, Math.round(value * 10_000) / 10_000));
}

function canonicalCode(value) {
  const code = String(value ?? "unknown")
    .toLowerCase()
    .replace(/[^a-z0-9_.:-]+/g, "_")
    .replace(/^[^a-z]+/g, "")
    .slice(0, 120);
  return code || "unknown";
}

function compareQueueItems(left, right) {
  const lifecycle = Number(left.lifecycleStatus !== "active") - Number(right.lifecycleStatus !== "active");
  if (lifecycle !== 0) return lifecycle;
  const priority = priorityFor(right) - priorityFor(left);
  if (priority !== 0) return priority;
  return left.workItemId.localeCompare(right.workItemId);
}

function counts(keys, values, select) {
  const result = Object.fromEntries(keys.map((key) => [key, 0]));
  for (const value of values) {
    const key = select(value);
    if (Object.hasOwn(result, key)) result[key] += 1;
  }
  return result;
}

function dynamicCounts(values, select) {
  return Object.fromEntries([...values.reduce((map, value) => {
    const key = select(value);
    map.set(key, (map.get(key) ?? 0) + 1);
    return map;
  }, new Map()).entries()].sort(([left], [right]) => left.localeCompare(right)));
}

async function readJson(file) {
  return JSON.parse(await fs.readFile(file, "utf8"));
}
