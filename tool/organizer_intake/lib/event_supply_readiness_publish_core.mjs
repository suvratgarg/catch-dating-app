export function buildEventSupplyReadinessPublishPlan({
  executionPlan,
  generatedAt = new Date().toISOString(),
  importPlan,
  importPlanPath,
  executionPlanPath,
  targetPath = "eventSupplyReadiness/current",
} = {}) {
  assertPlainObject(importPlan, "importPlan");
  assertPlainObject(executionPlan, "executionPlan");
  assertPlainObject(importPlan.summary, "importPlan.summary");
  assertPlainObject(executionPlan.summary, "executionPlan.summary");
  assertPlainObject(importPlan.policy, "importPlan.policy");
  assertPlainObject(executionPlan.policy, "executionPlan.policy");

  const document = {
    schemaVersion: 1,
    generatedAt,
    source: "organizer_intake_generated_artifacts",
    sourcePaths: {
      importPlan: importPlanPath ?? null,
      executionPlan: executionPlanPath ?? null,
    },
    summary: {
      candidates: numeric(importPlan.summary.candidates),
      proposedReadOnlyEvents: numeric(
        importPlan.summary.proposedReadOnlyEvents ??
          importPlan.summary.proposedCreates
      ),
      importBlocked: numeric(importPlan.summary.blocked),
      waitingReview: numeric(importPlan.summary.waitingReview),
      executionBlocked: numeric(executionPlan.summary.blocked),
      projectionInvalidCount: numeric(
        executionPlan.summary.projectionInvalidCount ??
          executionPlan.summary.payloadInvalid
      ),
      writeEnabled: importPlan.policy.writeEnabled === true ||
        executionPlan.policy.writeEnabled === true,
    },
    importPlan,
    executionPlan,
  };

  return {
    targetPath,
    document,
    summary: {
      targetPath,
      generatedAt,
      source: document.source,
      sourcePaths: document.sourcePaths,
      ...document.summary,
      importPolicyStatus: String(importPlan.policy.status ?? "unknown"),
      executionPolicyStatus: String(executionPlan.policy.status ?? "unknown"),
      importActions: Array.isArray(importPlan.actions) ?
        importPlan.actions.length :
        0,
      executionActions: Array.isArray(executionPlan.actions) ?
        executionPlan.actions.length :
        0,
    },
  };
}

export async function applyEventSupplyReadinessPublishPlan(
  firestore,
  plan,
  {serverTimestamp = null} = {}
) {
  const [collectionPath, docId] = splitDocumentPath(plan.targetPath);
  const patch = {
    ...plan.document,
    updatedAt: serverTimestamp ?? new Date().toISOString(),
  };
  await firestore.collection(collectionPath).doc(docId).set(patch, {merge: true});
  return {
    targetPath: plan.targetPath,
    written: true,
    generatedAt: plan.document.generatedAt,
  };
}

function assertPlainObject(value, label) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${label} must be an object.`);
  }
}

function numeric(value) {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function splitDocumentPath(targetPath) {
  const parts = String(targetPath ?? "").split("/").filter(Boolean);
  if (parts.length !== 2) {
    throw new Error(`Expected collection/document target path, got ${targetPath}`);
  }
  return parts;
}
