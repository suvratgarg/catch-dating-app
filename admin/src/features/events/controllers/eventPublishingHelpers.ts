import type {
  AdminEventActivityKind,
  AdminEventDetails,
  AdminEventInteractionModel,
  AdminEventPace,
  AdminExternalEventListRow,
  ExternalEventImportAction,
  ExternalEventImportExecutionAction,
  ExternalEventImportExecutionPlan,
  ExternalEventImportPlan,
  AdminUpdateEventDetailsPayload,
} from "../../../shared/types/adminTypes";

export interface EventPublishingFormState {
  eventId: string;
  description: string;
  photoUrl: string;
  activityKind: AdminEventActivityKind;
  interactionModel: AdminEventInteractionModel;
  customActivityLabel: string;
  distanceKm: string;
  pace: AdminEventPace;
  reviewNote: string;
}

export interface EventValidationIssue {
  id: string;
  label: string;
  detail: string;
  severity: "blocker" | "warning";
}

export interface EventValidationOptions {
  requireReviewNote?: boolean;
}

export interface EventDiffRow {
  field: string;
  before: string;
  after: string;
}

export type ExternalEventImportReviewStatus =
  | "publishedExternal"
  | "preflightReady"
  | "blocked"
  | "waitingReview"
  | "rejected"
  | "mergedDuplicate"
  | "notInCurrentPlan";

export interface ExternalEventImportReview {
  status: ExternalEventImportReviewStatus;
  label: string;
  detail: string;
  targetPath: string;
  importActionId: string | null;
  executionActionId: string | null;
  blockers: string[];
  nextCommand: string | null;
}

export const eventActivityKindOptions: AdminEventActivityKind[] = [
  "socialRun",
  "running",
  "walking",
  "pickleball",
  "padel",
  "tennis",
  "badminton",
  "cycling",
  "spinClass",
  "yoga",
  "strengthTraining",
  "pubQuiz",
  "barCrawl",
  "dinner",
  "singlesMixer",
  "openActivity",
];

export const eventInteractionModelOptions: AdminEventInteractionModel[] = [
  "pacePods",
  "pairedRotations",
  "teamRotations",
  "seatedTable",
  "freeFormMixer",
  "hostLedProgram",
  "openFormat",
];

export const eventPaceOptions: AdminEventPace[] = [
  "easy",
  "moderate",
  "fast",
  "competitive",
];

export function formFromEventProfile(
  event: AdminEventDetails
): EventPublishingFormState {
  return {
    eventId: event.eventId,
    description: event.description,
    photoUrl: event.photoUrl ?? "",
    activityKind: event.eventFormat.activityKind,
    interactionModel: event.eventFormat.interactionModel,
    customActivityLabel: event.eventFormat.customActivityLabel ?? "",
    distanceKm: String(event.distanceKm),
    pace: event.pace,
    reviewNote: "",
  };
}

export function diffEventProfile(
  event: AdminEventDetails | null,
  form: EventPublishingFormState | null
): EventDiffRow[] {
  if (!event || !form) return [];
  const original = formFromEventProfile(event);
  const rows: EventDiffRow[] = [];
  for (const key of Object.keys(original) as Array<keyof EventPublishingFormState>) {
    if (key === "reviewNote") continue;
    const before = normalizeComparable(original[key]);
    const after = normalizeComparable(form[key]);
    if (before !== after) {
      rows.push({
        field: labelFromKey(key),
        before: before || "empty",
        after: after || "empty",
      });
    }
  }
  return rows;
}

export function buildEventSavePayload(
  event: AdminEventDetails,
  form: EventPublishingFormState
): AdminUpdateEventDetailsPayload {
  const original = formFromEventProfile(event);
  const fields: AdminUpdateEventDetailsPayload["fields"] = {};
  addChanged(fields, "description", original.description, form.description.trim());
  addChanged(fields, "photoUrl", original.photoUrl, nullableText(form.photoUrl));
  addChanged(
    fields,
    "distanceKm",
    normalizeDistance(original.distanceKm),
    normalizeDistance(form.distanceKm)
  );
  addChanged(fields, "pace", original.pace, form.pace);

  const eventFormatChanged =
    original.activityKind !== form.activityKind ||
    original.interactionModel !== form.interactionModel ||
    normalizeComparable(original.customActivityLabel) !==
      normalizeComparable(form.customActivityLabel);
  if (eventFormatChanged) {
    const customActivityLabel = nullableText(form.customActivityLabel);
    fields.eventFormat = {
      version: 1,
      activityKind: form.activityKind,
      interactionModel: form.interactionModel,
      ...(customActivityLabel ? {customActivityLabel} : {}),
    };
  }

  return {
    eventId: form.eventId.trim(),
    fields,
    reviewNote: nullableText(form.reviewNote),
  };
}

export function validateEventPublishingForm(
  form: EventPublishingFormState | null,
  options: EventValidationOptions = {}
): EventValidationIssue[] {
  if (!form) {
    return [{
      id: "no-form",
      label: "No event loaded",
      detail: "Load a canonical events/{id} document before saving.",
      severity: "blocker",
    }];
  }
  const issues: EventValidationIssue[] = [];
  requireText(issues, "event-id", "Event id", form.eventId);
  requireText(issues, "description", "Description", form.description);
  const distance = normalizeDistance(form.distanceKm);
  if (!Number.isFinite(distance) || distance <= 0 || distance > 100) {
    issues.push({
      id: "distance",
      label: "Distance",
      detail: "Distance must be a number between 0 and 100 km.",
      severity: "blocker",
    });
  }
  if (options.requireReviewNote && !form.reviewNote.trim()) {
    issues.push({
      id: "review-note",
      label: "Review note",
      detail: "Add a review note so the audited event save has context.",
      severity: "blocker",
    });
  }
  return issues;
}

export function hasBlockingEventIssues(
  issues: EventValidationIssue[]
): boolean {
  return issues.some((issue) => issue.severity === "blocker");
}

export function countBlockingEventIssues(
  issues: EventValidationIssue[]
): number {
  return issues.filter((issue) => issue.severity === "blocker").length;
}

export function countEventDiffRows(rows: EventDiffRow[]): number {
  return rows.length;
}

export function eventNeedsSearchBackfill(row: {
  searchIndexStatus: "missing" | "indexed";
}): boolean {
  return row.searchIndexStatus !== "indexed";
}

export function eventIsFull(row: {
  bookedCount: number;
  capacityLimit: number;
}): boolean {
  return row.bookedCount >= row.capacityLimit;
}

export function externalEventNeedsReview(
  row: Pick<
    AdminExternalEventListRow,
    "importPolicyAcknowledged" | "ownerSafeCopyReviewed" | "publicationStatus"
  >
): boolean {
  return row.publicationStatus !== "public" ||
    !row.importPolicyAcknowledged ||
    !row.ownerSafeCopyReviewed;
}

export function buildExternalEventImportReview(
  row: AdminExternalEventListRow | null,
  importPlan: ExternalEventImportPlan | null,
  executionPlan: ExternalEventImportExecutionPlan | null
): ExternalEventImportReview | null {
  if (!row) return null;
  const importAction = findImportAction(row, importPlan?.actions ?? []);
  const executionAction = findExecutionAction(
    row,
    executionPlan?.actions ?? [],
    importAction?.actionId ?? null
  );
  const blockers = uniqueStrings([
    ...(importAction?.blockers ?? []),
    ...(executionAction?.blockers ?? []),
    ...(executionAction?.projectionValidation?.errors ?? [])
      .map((error) => validationErrorLabel(error.path, error.message)),
    ...(executionAction?.payloadValidation.errors ?? [])
      .map((error) => validationErrorLabel(error.path, error.message)),
  ]);
  const targetPath =
    executionAction?.targetPath ?? importAction?.targetPath ?? row.targetPath;

  if (!importAction && !executionAction) {
    const isPublishedAndReviewed =
      row.publicationStatus === "public" &&
      row.importPolicyAcknowledged &&
      row.ownerSafeCopyReviewed;
    return {
      status: isPublishedAndReviewed ? "publishedExternal" : "notInCurrentPlan",
      label: isPublishedAndReviewed ?
        "Published external supply" :
        "No current import action",
      detail: isPublishedAndReviewed ?
        "This row already exists in externalEvents and is not part of the current readiness snapshot." :
        "Regenerate and publish event supply readiness after review changes to see the deterministic import action.",
      targetPath,
      importActionId: null,
      executionActionId: null,
      blockers: isPublishedAndReviewed ? [] : [
        "not_present_in_current_event_supply_readiness_snapshot",
      ],
      nextCommand: importPlan?.commands.plan ??
        executionPlan?.commands.plan ??
        null,
    };
  }

  const status = externalImportReviewStatus(importAction, executionAction);
  return {
    status,
    label: externalImportReviewLabel(status),
    detail: externalImportReviewDetail(
      status,
      importPlan?.policy.reason ?? null,
      executionPlan?.policy.reason ?? null
    ),
    targetPath,
    importActionId: importAction?.actionId ?? null,
    executionActionId: executionAction?.actionId ?? null,
    blockers,
    nextCommand: externalImportReviewCommand(
      status,
      importPlan,
      executionPlan
    ),
  };
}

export function formatEventLabel(value: string): string {
  return value
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/[_-]+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

function findImportAction(
  row: AdminExternalEventListRow,
  actions: ExternalEventImportAction[]
): ExternalEventImportAction | null {
  return actions.find((action) => importActionMatchesRow(row, action)) ?? null;
}

function importActionMatchesRow(
  row: AdminExternalEventListRow,
  action: ExternalEventImportAction
): boolean {
  const draft = action.proposedReadOnlyEventDraft;
  return action.targetPath === row.targetPath ||
    action.candidateId === row.candidateId ||
    action.sourceEventKey === row.sourceEventKey ||
    action.normalizedEventKey === row.normalizedEventKey ||
    draft.eventId === row.eventId ||
    draft.booking.externalLinks.some((link) =>
      link.candidateId === row.candidateId ||
      link.sourceEventKey === row.sourceEventKey
    );
}

function findExecutionAction(
  row: AdminExternalEventListRow,
  actions: ExternalEventImportExecutionAction[],
  sourceActionId: string | null
): ExternalEventImportExecutionAction | null {
  return actions.find((action) =>
    executionActionMatchesRow(row, action, sourceActionId)
  ) ?? null;
}

function executionActionMatchesRow(
  row: AdminExternalEventListRow,
  action: ExternalEventImportExecutionAction,
  sourceActionId: string | null
): boolean {
  const projection = action.readOnlyEventProjection;
  return action.sourceActionId === sourceActionId ||
    action.targetPath === row.targetPath ||
    action.candidateId === row.candidateId ||
    projection?.eventId === row.eventId ||
    projection?.booking.externalLinks.some((link) =>
      link.candidateId === row.candidateId ||
      link.sourceEventKey === row.sourceEventKey
    ) === true;
}

function externalImportReviewStatus(
  importAction: ExternalEventImportAction | null,
  executionAction: ExternalEventImportExecutionAction | null
): ExternalEventImportReviewStatus {
  if (importAction?.status === "rejected") return "rejected";
  if (importAction?.status === "merged_duplicate") return "mergedDuplicate";
  if (importAction?.status === "waiting_review") return "waitingReview";
  if (
    importAction?.status === "blocked" ||
    executionAction?.status === "blocked" ||
    executionAction?.status === "projection_invalid" ||
    executionAction?.status === "schema_invalid" ||
    executionAction?.payloadValidation.valid === false ||
    executionAction?.projectionValidation?.valid === false
  ) {
    return "blocked";
  }
  if (
    importAction?.status === "write_ready" ||
    executionAction?.status === "would_publish_read_only"
  ) {
    return "preflightReady";
  }
  return "notInCurrentPlan";
}

function externalImportReviewLabel(
  status: ExternalEventImportReviewStatus
): string {
  switch (status) {
    case "publishedExternal":
      return "Published external supply";
    case "preflightReady":
      return "Preflight ready, writes disabled";
    case "blocked":
      return "Blocked by deterministic checks";
    case "waitingReview":
      return "Waiting for human review";
    case "rejected":
      return "Rejected by review";
    case "mergedDuplicate":
      return "Merged as duplicate link";
    case "notInCurrentPlan":
      return "No current import action";
  }
}

function externalImportReviewDetail(
  status: ExternalEventImportReviewStatus,
  importPolicyReason: string | null,
  executionPolicyReason: string | null
): string {
  if (status === "preflightReady") {
    return executionPolicyReason ?? importPolicyReason ??
      "The projection passed preflight; writes still require an explicit importer policy.";
  }
  if (status === "blocked") {
    return "Resolve the listed blockers before this candidate can be published to externalEvents.";
  }
  if (status === "waitingReview") {
    return "Finish event review, import-policy acknowledgement, copy review, and location resolution.";
  }
  if (status === "mergedDuplicate") {
    return "This source should merge into the primary external event as an outbound link.";
  }
  if (status === "rejected") {
    return "This candidate should stay out of externalEvents unless review is reopened.";
  }
  return "Regenerate and publish readiness to connect this row to the latest deterministic action.";
}

function externalImportReviewCommand(
  status: ExternalEventImportReviewStatus,
  importPlan: ExternalEventImportPlan | null,
  executionPlan: ExternalEventImportExecutionPlan | null
): string | null {
  if (status === "preflightReady") {
    return executionPlan?.commands.write ??
      "not available: approve ownership, defaults, and import policy first";
  }
  if (status === "blocked") {
    return executionPlan?.commands.preflight ?? importPlan?.commands.plan ?? null;
  }
  return importPlan?.commands.plan ?? executionPlan?.commands.plan ?? null;
}

function uniqueStrings(values: Array<string | null | undefined>): string[] {
  return Array.from(new Set(values.filter((value): value is string =>
    typeof value === "string" && value.trim().length > 0
  )));
}

function validationErrorLabel(path: string, message: string): string {
  const normalizedPath = path.trim() || "payload";
  return `${normalizedPath}: ${message}`;
}

function requireText(
  issues: EventValidationIssue[],
  id: string,
  label: string,
  value: string
) {
  if (value.trim()) return;
  issues.push({
    id,
    label,
    detail: `${label} is required for a canonical event listing.`,
    severity: "blocker",
  });
}

function addChanged<T extends Record<string, unknown>, K extends keyof T>(
  target: T,
  key: K,
  before: unknown,
  after: T[K]
) {
  if (normalizeComparable(before) !== normalizeComparable(after)) {
    target[key] = after;
  }
}

function normalizeComparable(value: unknown): string {
  if (value === null || value === undefined) return "";
  return String(value).trim();
}

function normalizeDistance(value: string): number {
  return Number(value.trim());
}

function nullableText(value: string): string | null {
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function labelFromKey(key: string): string {
  return key
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}
