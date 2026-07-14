import {createHash} from "node:crypto";
import {Firestore} from "firebase-admin/firestore";
import {operationCollections} from "./collections";
import {OperationConflictError, OperationDomainError} from "./errors";
import {
  OperationRun,
  OperationWorkItem,
  WorkItemPrimaryStage,
} from "./models";
import {
  validateOperationRun,
  validateOperationWorkItem,
  ValidationResult,
} from "./validation";

const workflowId = "supply-intake";
const program = "catch-operations-admin-projection";
const stages: WorkItemPrimaryStage[] = [
  "incoming",
  "verify",
  "resolve",
  "ready",
];
const batchSize = 400;

interface ProjectionSummary {
  totalItems: number;
  activeItems: number;
  terminalItems: number;
  stageCounts: Record<WorkItemPrimaryStage, number>;
}

export interface PreparedShadowProjection {
  artifactHash: string;
  run: OperationRun;
  workItems: OperationWorkItem[];
  summary: ProjectionSummary & {humanReviewCount: number};
}

export interface ProjectionImportWriter {
  getRun(runId: string): Promise<OperationRun | null>;
  getWorkItems(workItemIds: string[]):
    Promise<Map<string, OperationWorkItem>>;
  createWorkItems(workItems: OperationWorkItem[]): Promise<void>;
  createRun(run: OperationRun): Promise<void>;
}

export interface ShadowProjectionImportResult {
  schemaVersion: 1;
  mode: "dry_run" | "apply";
  runId: string;
  artifactHash: string;
  workItemCount: number;
  humanReviewCount: number;
  stageCounts: Record<WorkItemPrimaryStage, number>;
  createdWorkItems: number;
  reusedWorkItems: number;
  idempotent: boolean;
}

export function prepareShadowProjection(
  input: unknown
): PreparedShadowProjection {
  const projection = record(input, "projection");
  if (projection.schemaVersion !== 1 || projection.program !== program ||
      projection.workflowId !== workflowId) {
    throw new OperationDomainError(
      "invalid_projection_identity",
      "Projection must be a version-1 Supply Intake admin export"
    );
  }
  if (!Array.isArray(projection.items)) {
    throw new OperationDomainError(
      "invalid_projection_items",
      "Projection items must be an array"
    );
  }
  if (!Array.isArray(projection.stageOrder) ||
      projection.stageOrder.join(",") !== stages.join(",")) {
    throw new OperationDomainError(
      "invalid_stage_order",
      "Projection must preserve incoming, verify, resolve, ready"
    );
  }
  const sourceRun = validated(
    validateOperationRun(projection.run),
    "projection run"
  );
  const sourceItems = projection.items.map((item, index) =>
    validated(validateOperationWorkItem(item), `projection item ${index}`));
  assertShadowAuthority(sourceRun);
  assertProjectionJoin(sourceRun, sourceItems);
  const sourceSummary = validateSummary(projection.summary, sourceItems);
  const artifactHash = hash(input);
  const humanReviewCount = sourceItems.filter(needsHumanReview).length;
  const run: OperationRun = {
    ...sourceRun,
    revision: 0,
    metadata: {
      ...sourceRun.metadata,
      projection: {
        artifactHash,
        sourceRunRevision: sourceRun.revision,
        workItemCount: sourceSummary.totalItems,
        activeItems: sourceSummary.activeItems,
        terminalItems: sourceSummary.terminalItems,
        humanReviewCount,
        stageCounts: sourceSummary.stageCounts,
      },
    },
  };
  const workItems = sourceItems.map((item) => {
    if ("__projection" in item.normalizedPayload) {
      throw new OperationDomainError(
        "reserved_projection_metadata",
        `Work item ${item.workItemId} uses reserved __projection metadata`
      );
    }
    return {
      ...item,
      revision: 0,
      normalizedPayload: {
        ...item.normalizedPayload,
        __projection: {
          artifactHash,
          sourceRevision: item.revision,
          sourceItemHash: hash(item),
        },
      },
    };
  });
  validated(validateOperationRun(run), "prepared run");
  workItems.forEach((item, index) =>
    validated(validateOperationWorkItem(item), `prepared item ${index}`));
  return {
    artifactHash,
    run,
    workItems,
    summary: {...sourceSummary, humanReviewCount},
  };
}

export async function importShadowProjection({
  input,
  apply = false,
  writer,
}: {
  input: unknown;
  apply?: boolean;
  writer?: ProjectionImportWriter;
}): Promise<ShadowProjectionImportResult> {
  const prepared = prepareShadowProjection(input);
  const base = {
    schemaVersion: 1 as const,
    runId: prepared.run.runId,
    artifactHash: prepared.artifactHash,
    workItemCount: prepared.summary.totalItems,
    humanReviewCount: prepared.summary.humanReviewCount,
    stageCounts: prepared.summary.stageCounts,
  };
  if (!apply) {
    return {
      ...base,
      mode: "dry_run",
      createdWorkItems: 0,
      reusedWorkItems: 0,
      idempotent: false,
    };
  }
  if (!writer) {
    throw new OperationDomainError(
      "projection_writer_required",
      "Apply mode requires a trusted projection writer"
    );
  }
  const existingRun = await writer.getRun(prepared.run.runId);
  if (existingRun) {
    assertMatchingArtifact(existingRun.metadata, prepared.artifactHash);
    assertMatchingPreparedRecord(existingRun, prepared.run, "run");
  }
  const existingItems = await writer.getWorkItems(
    prepared.workItems.map((item) => item.workItemId)
  );
  for (const expected of prepared.workItems) {
    const existing = existingItems.get(expected.workItemId);
    if (!existing) continue;
    assertMatchingArtifact(existing.normalizedPayload, prepared.artifactHash);
    assertMatchingPreparedRecord(existing, expected, "work item");
  }
  const pendingItems = prepared.workItems.filter((item) =>
    !existingItems.has(item.workItemId));
  if (pendingItems.length > 0) await writer.createWorkItems(pendingItems);
  if (!existingRun) await writer.createRun(prepared.run);
  return {
    ...base,
    mode: "apply",
    createdWorkItems: pendingItems.length,
    reusedWorkItems: existingItems.size,
    idempotent: Boolean(existingRun) && pendingItems.length === 0,
  };
}

export class FirestoreShadowProjectionWriter implements
  ProjectionImportWriter {
  constructor(private readonly db: Firestore) {}

  async getRun(runId: string): Promise<OperationRun | null> {
    const snapshot = await this.db.collection(operationCollections.runs)
      .doc(runId).get();
    if (!snapshot.exists) return null;
    return validated(validateOperationRun(snapshot.data()), "stored run");
  }

  async getWorkItems(
    workItemIds: string[]
  ): Promise<Map<string, OperationWorkItem>> {
    const output = new Map<string, OperationWorkItem>();
    for (let offset = 0; offset < workItemIds.length; offset += batchSize) {
      const ids = workItemIds.slice(offset, offset + batchSize);
      const refs = ids.map((id) =>
        this.db.collection(operationCollections.workItems).doc(id));
      const snapshots = await this.db.getAll(...refs);
      snapshots.forEach((snapshot) => {
        if (!snapshot.exists) return;
        output.set(snapshot.id, validated(
          validateOperationWorkItem(snapshot.data()),
          `stored work item ${snapshot.id}`
        ));
      });
    }
    return output;
  }

  async createWorkItems(workItems: OperationWorkItem[]): Promise<void> {
    for (let offset = 0; offset < workItems.length; offset += batchSize) {
      const batch = this.db.batch();
      for (const item of workItems.slice(offset, offset + batchSize)) {
        batch.create(
          this.db.collection(operationCollections.workItems)
            .doc(item.workItemId),
          item
        );
      }
      await batch.commit();
    }
  }

  async createRun(run: OperationRun): Promise<void> {
    const batch = this.db.batch();
    batch.create(
      this.db.collection(operationCollections.runs).doc(run.runId),
      run
    );
    await batch.commit();
  }
}

function assertShadowAuthority(run: OperationRun): void {
  if (run.workflowId !== workflowId || run.mode !== "shadow" ||
      run.status !== "completed") {
    throw new OperationDomainError(
      "unsafe_projection_mode",
      "Only completed Supply Intake shadow runs can be imported"
    );
  }
  const metadata = record(run.metadata, "run metadata");
  const capabilities = record(metadata.capabilities, "run capabilities");
  for (const capability of [
    "network",
    "modelCalls",
    "publicWrites",
    "ruleDeployment",
  ]) {
    if (capabilities[capability] !== false) {
      throw new OperationDomainError(
        "unsafe_projection_capability",
        `Shadow projection capability ${capability} must be false`
      );
    }
  }
}

function assertProjectionJoin(
  run: OperationRun,
  items: OperationWorkItem[]
): void {
  const ids = new Set<string>();
  for (const item of items) {
    if (item.runId !== run.runId || item.workflowId !== run.workflowId) {
      throw new OperationDomainError(
        "projection_join_mismatch",
        `Work item ${item.workItemId} does not belong to the projection run`
      );
    }
    if (ids.has(item.workItemId)) {
      throw new OperationDomainError(
        "duplicate_projection_item",
        `Projection repeats work item ${item.workItemId}`
      );
    }
    ids.add(item.workItemId);
  }
  if (run.counters.discovered !== items.length) {
    throw new OperationDomainError(
      "projection_counter_mismatch",
      "Run discovered counter must equal exported work-item inventory"
    );
  }
  if (items.length > run.budgets.maxWorkItems) {
    throw new OperationDomainError(
      "projection_work_item_budget_exceeded",
      "Exported work-item inventory exceeds the run's frozen budget"
    );
  }
}

function validateSummary(
  value: unknown,
  items: OperationWorkItem[]
): ProjectionSummary {
  const summary = record(value, "projection summary");
  const activeItems = items.filter((item) =>
    !["published", "terminal"].includes(item.lifecycleStatus));
  const calculated: ProjectionSummary = {
    totalItems: items.length,
    activeItems: activeItems.length,
    terminalItems: items.length - activeItems.length,
    stageCounts: countStages(activeItems),
  };
  const suppliedStages = record(summary.stageCounts, "summary stage counts");
  const matches = summary.totalItems === calculated.totalItems &&
    summary.activeItems === calculated.activeItems &&
    summary.terminalItems === calculated.terminalItems &&
    stages.every((stage) =>
      suppliedStages[stage] === calculated.stageCounts[stage]);
  if (!matches) {
    throw new OperationDomainError(
      "projection_summary_mismatch",
      "Projection summary does not match its work-item inventory"
    );
  }
  return calculated;
}

function countStages(
  items: OperationWorkItem[]
): Record<WorkItemPrimaryStage, number> {
  const counts: Record<WorkItemPrimaryStage, number> = {
    incoming: 0,
    verify: 0,
    resolve: 0,
    ready: 0,
  };
  for (const item of items) counts[item.primaryStage] += 1;
  return counts;
}

function needsHumanReview(item: OperationWorkItem): boolean {
  return item.taskFlags.includes("human_review_required") ||
    item.blockerCodes.includes("human_review_required") ||
    item.normalizedPayload.owner === "human";
}

function assertMatchingArtifact(
  container: Record<string, unknown>,
  artifactHash: string
): void {
  const projection = record(
    container.projection ?? container.__projection,
    "stored projection metadata"
  );
  if (projection.artifactHash !== artifactHash) {
    throw new OperationConflictError(
      "projection_artifact_conflict",
      "Run-scoped projection records are immutable; use a new run id"
    );
  }
}

function assertMatchingPreparedRecord(
  existing: OperationRun | OperationWorkItem,
  expected: OperationRun | OperationWorkItem,
  label: string
): void {
  if (hash(existing) !== hash(expected)) {
    throw new OperationConflictError(
      `projection_${label.replace(" ", "_")}_conflict`,
      `Stored ${label} differs from the immutable prepared projection`
    );
  }
}

function validated<T>(result: ValidationResult<T>, label: string): T {
  if (!result.ok) {
    throw new OperationDomainError(
      "invalid_projection_record",
      `${label} is invalid: ${result.issues.map((issue) =>
        `${issue.path}:${issue.code}`).join(", ")}`
    );
  }
  return result.value;
}

function record(value: unknown, label: string): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new OperationDomainError(
      "invalid_projection_record",
      `${label} must be an object`
    );
  }
  return value as Record<string, unknown>;
}

function hash(value: unknown): string {
  return createHash("sha256").update(canonicalJson(value)).digest("hex");
}

function canonicalJson(value: unknown): string {
  if (value === null || typeof value !== "object") {
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    return `[${value.map(canonicalJson).join(",")}]`;
  }
  const object = value as Record<string, unknown>;
  return `{${Object.keys(object).sort().map((key) =>
    `${JSON.stringify(key)}:${canonicalJson(object[key])}`).join(",")}}`;
}
