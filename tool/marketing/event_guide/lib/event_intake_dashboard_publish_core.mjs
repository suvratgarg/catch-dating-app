export function buildEventIntakeDashboardPublishPlan({
  bridge,
  bridgePath,
  generatedAt = null,
  targetPath = "eventIntakeDashboards/current",
} = {}) {
  assertPlainObject(bridge, "bridge");
  const eventBridge = normalizeEventIntakeBridge(bridge);
  const document = {
    schemaVersion: 1,
    generatedAt: generatedAt ?? eventBridge.generatedAt ?? new Date().toISOString(),
    source: "event_guide_generated_event_intake_bridge",
    sourcePaths: {
      bridge: bridgePath ?? null,
    },
    summary: {
      eventCandidates: arrayLength(eventBridge.eventCandidates),
      sourceResults: arrayLength(eventBridge.sourceResults),
      dedupeGroups: arrayLength(eventBridge.dedupeGroups),
      sourceProfiles: arrayLength(eventBridge.sourceProfiles),
      queryTemplates: arrayLength(eventBridge.queryTemplates),
    },
    bridge: eventBridge,
  };

  return {
    targetPath,
    document,
    summary: {
      targetPath,
      generatedAt: document.generatedAt,
      source: document.source,
      sourcePaths: document.sourcePaths,
      ...document.summary,
      city: eventBridge.city?.label ?? eventBridge.city?.id ?? "unknown",
      weekStart: eventBridge.weekStart ?? null,
      bridgeSource: eventBridge.bridgeSource,
    },
  };
}

export async function applyEventIntakeDashboardPublishPlan(
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

function normalizeEventIntakeBridge(bridge) {
  return {
    schemaVersion: bridge.schemaVersion ?? 1,
    program: "catch-event-intake",
    generatedAt: bridge.generatedAt ?? null,
    bridgeSource: "native_generated",
    city: bridge.city ?? {id: "unknown", label: "Unknown"},
    weekStart: bridge.weekStart ?? null,
    summary: plainObjectOrEmpty(bridge.summary),
    sourceProfiles: arrayOrEmpty(bridge.sourceProfiles),
    queryTemplates: arrayOrEmpty(bridge.queryTemplates),
    runPlan: plainObjectOrEmpty(bridge.runPlan),
    sourceResults: arrayOrEmpty(bridge.sourceResults),
    eventCandidates: arrayOrEmpty(bridge.eventCandidates),
    dedupeGroups: arrayOrEmpty(bridge.dedupeGroups),
    auditTrail: arrayOrEmpty(bridge.auditTrail),
  };
}

function assertPlainObject(value, label) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${label} must be an object.`);
  }
}

function plainObjectOrEmpty(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  return value;
}

function arrayOrEmpty(value) {
  return Array.isArray(value) ? value : [];
}

function arrayLength(value) {
  return Array.isArray(value) ? value.length : 0;
}

function splitDocumentPath(targetPath) {
  const parts = String(targetPath ?? "").split("/").filter(Boolean);
  if (parts.length !== 2) {
    throw new Error(`Expected collection/document target path, got ${targetPath}`);
  }
  return parts;
}
