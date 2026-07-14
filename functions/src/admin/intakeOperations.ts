import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {AdminListIntakeOperationsCallablePayload} from
  "../shared/generated/adminListIntakeOperationsCallablePayload";
import {validateAdminListIntakeOperationsCallablePayload} from
  "../shared/generated/schemaValidators";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {FirestoreOperationsRepository} from
  "../operations/firestoreRepository";
import {
  MAX_OPERATION_WORK_ITEMS_PER_RUN,
  OperationRun,
  OperationWorkItem,
  WorkItemPrimaryStage,
} from "../operations/models";
import {
  OperationRunRepository,
  OperationWorkItemRepository,
} from "../operations/repositories";
import {requireAdminRole} from "./adminAuth";

const intakeOperationsRoles = ["admin", "adminOwner", "support"] as const;
const supplyIntakeWorkflowId = "supply-intake";
const supplyIntakeStages = new Set([
  "incoming",
  "verify",
  "resolve",
  "ready",
]);

type IntakeOperationsReadRepository =
  OperationRunRepository & OperationWorkItemRepository;

interface IntakeOperationsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  repository?: IntakeOperationsReadRepository;
  now?: () => Date;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: IntakeOperationsDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  checkRateLimit: defaultCheckRateLimit,
};

export interface AdminListIntakeOperationsResponse {
  schemaVersion: 1;
  generatedAt: string;
  workflowId: typeof supplyIntakeWorkflowId;
  executionMode: "shadow";
  source: "firestore";
  capabilities: {
    requestRuns: false;
    networkFetches: false;
    modelCalls: false;
    publicWrites: false;
    ruleDeployment: false;
  };
  summary: {
    loadedRunCount: number;
    workItemCount: number;
    humanReviewCount: number;
    stages: Record<WorkItemPrimaryStage, number>;
  };
  runs: OperationRun[];
  workItems: OperationWorkItem[];
  nextRunCursor: string | null;
  nextWorkItemCursor: string | null;
}

/**
 * Lists the durable, read-only Supply Intake operations projection.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {IntakeOperationsDeps} deps Injectable dependencies.
 * @return {Promise<AdminListIntakeOperationsResponse>} Persisted operations.
 */
export async function adminListIntakeOperationsHandler(
  request: CallableRequest<unknown>,
  deps: IntakeOperationsDeps = defaultDeps
): Promise<AdminListIntakeOperationsResponse> {
  const adminContext = requireAdminRole(request, intakeOperationsRoles);
  const data =
    validateCallableWithAjv<AdminListIntakeOperationsCallablePayload>(
      request,
      validateAdminListIntakeOperationsCallablePayload,
      normalizePayload
    );
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    adminContext.uid,
    "adminListIntakeOperations"
  );

  const repository = deps.repository ??
    new FirestoreOperationsRepository(db);
  const workflowId = data.workflowId ?? supplyIntakeWorkflowId;
  const runsPage = data.runId ?
    await exactRunPage(repository, data.runId, workflowId, data.runStatus) :
    await repository.listRuns({
      workflowId,
      status: data.runStatus ?? undefined,
      limit: data.runLimit ?? 10,
      cursor: data.runCursor ?? undefined,
    });
  const shadowRuns = runsPage.items.filter((run) => run.mode === "shadow");
  const selectedRunId = shadowRuns[0]?.runId ?? null;
  const workItemsPage = selectedRunId ?
    await repository.listWorkItems({
      workflowId,
      runId: selectedRunId,
      primaryStage: data.primaryStage ?? undefined,
      entityKind: data.entityKind ?? undefined,
      lifecycleStatus: data.lifecycleStatus ?? undefined,
      humanReviewRequired: data.humanReviewRequired ?? undefined,
      limit: data.workItemLimit ?? 200,
      cursor: data.workItemCursor ?? undefined,
    }) :
    {items: [], nextCursor: null};
  const workItems = workItemsPage.items;
  if (workItems.some((item) =>
    item.workflowId !== supplyIntakeWorkflowId ||
    item.runId !== selectedRunId ||
    !supplyIntakeStages.has(item.primaryStage))) {
    throw new HttpsError(
      "failed-precondition",
      "Supply Intake work-item projection contains an invalid workflow " +
        "join or stage."
    );
  }
  const persistedSummary = shadowRuns[0] ?
    projectionSummary(shadowRuns[0]) : null;
  if (shadowRuns[0] && !persistedSummary) {
    throw new HttpsError(
      "failed-precondition",
      `Operations run ${shadowRuns[0].runId} is missing authoritative ` +
        "projection aggregates."
    );
  }

  return {
    schemaVersion: 1,
    generatedAt: (deps.now?.() ?? new Date()).toISOString(),
    workflowId: supplyIntakeWorkflowId,
    executionMode: "shadow",
    source: "firestore",
    capabilities: {
      requestRuns: false,
      networkFetches: false,
      modelCalls: false,
      publicWrites: false,
      ruleDeployment: false,
    },
    summary: {
      loadedRunCount: shadowRuns.length,
      workItemCount: persistedSummary?.workItemCount ?? 0,
      humanReviewCount: persistedSummary?.humanReviewCount ?? 0,
      stages: persistedSummary?.stages ?? {
        incoming: 0,
        verify: 0,
        resolve: 0,
        ready: 0,
      },
    },
    runs: shadowRuns,
    workItems,
    nextRunCursor: runsPage.nextCursor,
    nextWorkItemCursor: workItemsPage.nextCursor,
  };
}

async function exactRunPage(
  repository: IntakeOperationsReadRepository,
  runId: string,
  workflowId: string,
  runStatus: OperationRun["status"] | null | undefined
) {
  const run = await repository.getRun(runId);
  const matches = run?.workflowId === workflowId &&
    (!runStatus || run.status === runStatus);
  return {items: matches && run ? [run] : [], nextCursor: null};
}

function projectionSummary(run: OperationRun): {
  workItemCount: number;
  humanReviewCount: number;
  stages: Record<WorkItemPrimaryStage, number>;
} | null {
  const value = run.metadata.projection;
  if (!value || typeof value !== "object" || Array.isArray(value)) return null;
  const projection = value as Record<string, unknown>;
  const stagesValue = projection.stageCounts;
  if (!stagesValue || typeof stagesValue !== "object" ||
      Array.isArray(stagesValue)) return null;
  const counts = stagesValue as Record<string, unknown>;
  const workItemCount = nonNegativeInteger(projection.workItemCount);
  const activeItems = nonNegativeInteger(projection.activeItems);
  const terminalItems = nonNegativeInteger(projection.terminalItems);
  const humanReviewCount = nonNegativeInteger(projection.humanReviewCount);
  const incoming = nonNegativeInteger(counts.incoming);
  const verify = nonNegativeInteger(counts.verify);
  const resolve = nonNegativeInteger(counts.resolve);
  const ready = nonNegativeInteger(counts.ready);
  if ([
    workItemCount,
    activeItems,
    terminalItems,
    humanReviewCount,
    incoming,
    verify,
    resolve,
    ready,
  ].some((entry) => entry === null)) return null;
  if ((activeItems as number) + (terminalItems as number) !==
        workItemCount ||
      (incoming as number) + (verify as number) + (resolve as number) +
        (ready as number) !== activeItems ||
      (humanReviewCount as number) > (activeItems as number) ||
      !Number.isSafeInteger(run.budgets.maxWorkItems) ||
      run.budgets.maxWorkItems < 1 ||
      run.budgets.maxWorkItems > MAX_OPERATION_WORK_ITEMS_PER_RUN ||
      (workItemCount as number) > run.budgets.maxWorkItems) {
    return null;
  }
  return {
    workItemCount: workItemCount as number,
    humanReviewCount: humanReviewCount as number,
    stages: {
      incoming: incoming as number,
      verify: verify as number,
      resolve: resolve as number,
      ready: ready as number,
    },
  };
}

function nonNegativeInteger(value: unknown): number | null {
  return Number.isInteger(value) && (value as number) >= 0 ?
    value as number : null;
}

function normalizePayload(value: unknown): unknown {
  if (value === undefined || value === null) return {};
  if (typeof value !== "object" || Array.isArray(value)) return value;
  const data = value as Record<string, unknown>;
  return {
    ...data,
    workflowId: normalizeOptionalString(data.workflowId),
    runId: normalizeNullableString(data.runId),
    primaryStage: normalizeNullableString(data.primaryStage),
    entityKind: normalizeNullableString(data.entityKind),
    lifecycleStatus: normalizeNullableString(data.lifecycleStatus),
    runStatus: normalizeNullableString(data.runStatus),
    runCursor: normalizeNullableString(data.runCursor),
    workItemCursor: normalizeNullableString(data.workItemCursor),
  };
}

function normalizeOptionalString(value: unknown): unknown {
  if (value === undefined) return undefined;
  return normalizeNullableString(value);
}

function normalizeNullableString(value: unknown): unknown {
  if (value === undefined || value === null) return null;
  if (typeof value !== "string") return value;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

export const adminListIntakeOperations = onCall(
  appCheckCallableOptions,
  (request) => adminListIntakeOperationsHandler(request)
);
