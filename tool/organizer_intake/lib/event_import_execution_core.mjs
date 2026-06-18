import {validateExternalEventDocument} from
  "../../contracts/generated/schema_contract_validators.mjs";

const defaultPolicy = {
  status: "disabled",
  writeEnabled: false,
  authorityModel: "undecided",
  reason:
    "External event import execution is preflight-only for read-only external " +
    "event projections. No createEvent callable invocation, Catch booking, " +
    "payment, reservation, waitlist, notification, or schedule lock is enabled.",
};

export function buildExternalEventImportExecutionPlan(
  importPlan,
  options = {}
) {
  const policy = {
    ...defaultPolicy,
    ...(options.policy ?? {}),
    writeEnabled: options.writeEnabled === true,
  };
  const actions = [...(importPlan.actions ?? [])]
    .sort(compareImportActions)
    .map((action) => executionActionForImportAction(action, policy));
  const actionsByStatus = countBy(actions, "status");

  return {
    schemaVersion: 1,
    generatedFrom: {
      externalEventImportPlan:
        "tool/organizer_intake/generated/external_event_import_plan.json",
      importPlanGeneratedFrom: importPlan.generatedFrom ?? {},
    },
    policy,
    summary: {
      importActions: actions.length,
      createActions: actions.filter((action) =>
        action.sourceAction === "create_event").length,
      readOnlyActions: actions.filter((action) =>
        action.sourceAction === "publish_read_only_external_event").length,
      skipped: actions.filter((action) => action.status === "skipped").length,
      blocked: actions.filter((action) => action.status === "blocked").length,
      projectionInvalid: actions.filter((action) =>
        action.status === "projection_invalid").length,
      schemaInvalid: 0,
      wouldPublishReadOnly: actions.filter((action) =>
        action.status === "would_publish_read_only").length,
      wouldCreate: 0,
      projectionValid: actions.filter((action) =>
        action.projectionValidation.valid).length,
      projectionInvalidCount: actions.filter((action) =>
        !action.projectionValidation.valid).length,
      payloadValid: 0,
      payloadInvalid: 0,
      actionsByStatus,
    },
    guardrails: [
      "execution_preflight_never_writes_firestore",
      "create_event_callable_is_not_used_for_external_read_only_imports",
      "read_only_projection_requires_outbound_external_link",
      "catch_booking_payments_reservations_and_waitlists_must_be_false",
      "write_enabled_requires_explicit_authority_policy",
    ],
    actions,
    commands: {
      plan:
        "node tool/organizer_intake/plan_external_event_imports.mjs",
      preflight:
        "node tool/organizer_intake/preflight_external_event_imports.mjs",
      write:
        "not available: approve ownership, defaults, and import policy first",
    },
  };
}

function executionActionForImportAction(action, policy) {
  const readOnlyEventProjection = readOnlyEventProjectionForAction(action);
  const projectionValidation = validateReadOnlyEventProjection(
    externalEventDocumentForAction(action)
  );
  const blockers = blockersForExecution(action, policy, projectionValidation);
  const status = statusForExecution(action, blockers, projectionValidation);

  return {
    actionId: `preflight-${action.actionId}`,
    sourceActionId: action.actionId,
    sourceAction: action.action,
    status,
    candidateId: action.candidateId,
    entityId: action.entityId,
    targetWriter: "externalEventReadOnlyProjection",
    targetCallable: null,
    targetPath: action.targetPath,
    sourceStatus: action.status,
    sourceReviewStatus: action.reviewStatus,
    blockers,
    projectionValidation,
    payloadValidation: {valid: true, errors: []},
    readOnlyEventProjection,
    externalEventDocument: externalEventDocumentForAction(action),
  };
}

function blockersForExecution(action, policy, projectionValidation) {
  const blockers = new Set();
  if (action.action !== "publish_read_only_external_event") {
    blockers.add("not_a_read_only_external_event_action");
  }
  for (const blocker of action.blockers ?? []) blockers.add(blocker);
  if (action.status !== "write_ready") {
    blockers.add("source_import_action_not_write_ready");
  }
  if (policy.writeEnabled !== true) {
    blockers.add("external_event_import_execution_disabled");
  }
  if (policy.authorityModel !== "admin_import_service") {
    blockers.add("requires_import_authority_policy");
  }
  if (!projectionValidation.valid) {
    blockers.add("read_only_external_event_projection_invalid");
  }
  return [...blockers].sort();
}

function statusForExecution(action, blockers, projectionValidation) {
  if (action.action !== "publish_read_only_external_event") return "skipped";
  if (!projectionValidation.valid) return "projection_invalid";
  if (blockers.length > 0) return "blocked";
  return "would_publish_read_only";
}

function readOnlyEventProjectionForAction(action) {
  return pruneUndefined(action.proposedReadOnlyEventDraft ?? {});
}

function externalEventDocumentForAction(action) {
  return pruneUndefined(action.proposedExternalEventDocument ?? {});
}

function validateReadOnlyEventProjection(document) {
  const valid = Boolean(validateExternalEventDocument(document));
  const errors = valid ? [] : (validateExternalEventDocument.errors ?? [])
    .map((error) => ({
      path: error.instancePath || "/",
      message: error.message ?? "invalid",
      keyword: error.keyword,
    }))
    .sort((left, right) =>
      left.path.localeCompare(right.path) ||
      left.keyword.localeCompare(right.keyword) ||
      left.message.localeCompare(right.message)
    );
  return {valid, errors};
}

function compareImportActions(left, right) {
  const leftStart = left.proposedReadOnlyEventDraft?.startTime ?? "";
  const rightStart = right.proposedReadOnlyEventDraft?.startTime ?? "";
  return String(leftStart).localeCompare(String(rightStart)) ||
    String(left.actionId ?? "").localeCompare(String(right.actionId ?? ""));
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function pruneUndefined(value) {
  if (Array.isArray(value)) return value.map(pruneUndefined);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .filter(([, nested]) => nested !== undefined)
      .map(([key, nested]) => [key, pruneUndefined(nested)])
  );
}
