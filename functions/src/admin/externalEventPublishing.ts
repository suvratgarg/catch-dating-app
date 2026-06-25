import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {AdminPublishExternalEventCallablePayload} from
  "../shared/generated/adminPublishExternalEventCallablePayload";
import {ExternalEventDocument} from
  "../shared/generated/externalEventDocument";
import {
  validateAdminPublishExternalEventCallablePayload,
  validateExternalEventDocument,
} from "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAdminRole} from "./adminAuth";
import {setAdminAuditLogInTransaction} from "./adminAudit";

const externalEventPublishRoles = ["admin", "adminOwner", "support"] as const;

interface ExternalEventPublishingDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  now?: () => Date;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ExternalEventPublishingDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  now: () => new Date(),
  checkRateLimit: defaultCheckRateLimit,
};

export interface AdminPublishExternalEventResponse {
  eventId: string;
  targetPath: string;
  sourceActionId: string;
  publicationStatus: "public";
  externalLinkCount: number;
  publishedAt: string;
}

/**
 * Publishes one preflight-approved read-only external event projection.
 * This never creates canonical events/{id}, bookings, payments, waitlists,
 * reservations, notifications, attendance, or schedule locks.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ExternalEventPublishingDeps} deps Injectable dependencies.
 * @return {Promise<AdminPublishExternalEventResponse>} Published event.
 */
export async function adminPublishExternalEventHandler(
  request: CallableRequest<unknown>,
  deps: ExternalEventPublishingDeps = defaultDeps
): Promise<AdminPublishExternalEventResponse> {
  const adminContext = requireAdminRole(request, externalEventPublishRoles);
  const data =
    validateCallableWithAjv<AdminPublishExternalEventCallablePayload>(
      request,
      validateAdminPublishExternalEventCallablePayload,
      normalizeAdminPublishExternalEventPayload
    );
  assertPublishChecklist(data.checklist);

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    adminContext.uid,
    "adminPublishExternalEvent"
  );

  const eventId = eventIdFromTargetPath(data.targetPath);
  const readinessRef = db.collection("eventSupplyReadiness").doc("current");
  const externalEventRef = db.collection("externalEvents").doc(eventId);
  const publishedAt = (deps.now?.() ?? new Date()).toISOString();
  let externalLinkCount = 0;

  await db.runTransaction(async (tx) => {
    const [readinessSnap, beforeSnap] = await Promise.all([
      tx.get(readinessRef),
      tx.get(externalEventRef),
    ]);
    if (!readinessSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "No event supply readiness snapshot has been published."
      );
    }
    if (beforeSnap.exists) {
      throw new HttpsError(
        "already-exists",
        "External event already exists; update/takedown is a separate flow."
      );
    }
    const readiness = readinessSnap.data() ?? {};
    const importPlan = requireRecord(readiness.importPlan, "importPlan");
    const executionPlan = requireRecord(
      readiness.executionPlan,
      "executionPlan"
    );
    assertImportPolicyEnabled(importPlan, executionPlan);
    const action = findExecutionAction(executionPlan, data);
    const externalEventDocument = externalEventDocumentFromAction(
      action,
      eventId,
      data.targetPath
    );
    externalLinkCount = externalEventDocument.booking.externalLinks.length;
    const firestoreDocument =
      externalEventDocumentForFirestore(externalEventDocument);

    tx.create(externalEventRef, firestoreDocument);
    setAdminAuditLogInTransaction(tx, db, adminContext, {
      action: "adminPublishExternalEvent",
      targetPath: externalEventRef.path,
      request,
      before: {},
      after: {
        eventId,
        sourceActionId: data.sourceActionId,
        readinessGeneratedAt: nullableString(readiness.generatedAt),
        externalLinkCount,
        effect: "publish_read_only_external_event",
      },
      note: data.reviewNote,
      serverTimestamp: deps.serverTimestamp,
    });
  });

  return {
    eventId,
    targetPath: data.targetPath,
    sourceActionId: data.sourceActionId,
    publicationStatus: "public",
    externalLinkCount,
    publishedAt,
  };
}

/**
 * Normalizes publish payload strings before JSON Schema validation.
 * @param {unknown} value Raw payload.
 * @return {unknown} Normalized payload.
 */
function normalizeAdminPublishExternalEventPayload(value: unknown): unknown {
  if (!value || typeof value !== "object") return value;
  const data = value as Record<string, unknown>;
  return {
    ...data,
    sourceActionId: normalizeString(data.sourceActionId),
    targetPath: normalizeString(data.targetPath),
    reviewNote: normalizeString(data.reviewNote),
  };
}

/**
 * Requires every admin publish checklist gate.
 * @param {AdminPublishExternalEventCallablePayload["checklist"]} checklist
 * Checklist.
 */
function assertPublishChecklist(
  checklist: AdminPublishExternalEventCallablePayload["checklist"]
) {
  if (
    checklist.preflightActionReviewed &&
    checklist.outboundLinksReviewed &&
    checklist.noCatchBookingPaymentsWaitlist &&
    checklist.ownerSafeCopyReviewed
  ) {
    return;
  }
  throw new HttpsError(
    "failed-precondition",
    "Preflight, outbound links, no-Catch-booking/payment/waitlist, and " +
      "owner-safe copy gates must be confirmed before publishing."
  );
}

/**
 * Enforces the explicit import authority switch.
 * @param {Record<string, unknown>} importPlan Import plan.
 * @param {Record<string, unknown>} executionPlan Execution plan.
 */
function assertImportPolicyEnabled(
  importPlan: Record<string, unknown>,
  executionPlan: Record<string, unknown>
) {
  const importPolicy = requireRecord(importPlan.policy, "importPlan.policy");
  const executionPolicy = requireRecord(
    executionPlan.policy,
    "executionPlan.policy"
  );
  if (
    importPolicy.writeEnabled === true &&
    executionPolicy.writeEnabled === true &&
    executionPolicy.authorityModel === "admin_import_service"
  ) {
    return;
  }
  throw new HttpsError(
    "failed-precondition",
    "External event publishing is disabled until the readiness policy has " +
      "writeEnabled=true and authorityModel=admin_import_service."
  );
}

/**
 * Finds the selected execution action in the published readiness snapshot.
 * @param {Record<string, unknown>} executionPlan Execution plan.
 * @param {AdminPublishExternalEventCallablePayload} data Request data.
 * @return {Record<string, unknown>} Execution action.
 */
function findExecutionAction(
  executionPlan: Record<string, unknown>,
  data: AdminPublishExternalEventCallablePayload
): Record<string, unknown> {
  const actions = Array.isArray(executionPlan.actions) ?
    executionPlan.actions :
    [];
  const action = actions
    .filter((item): item is Record<string, unknown> =>
      Boolean(item && typeof item === "object" && !Array.isArray(item)))
    .find((item) =>
      item.sourceActionId === data.sourceActionId &&
      item.targetPath === data.targetPath
    );
  if (!action) {
    throw new HttpsError(
      "not-found",
      "Selected preflight action is not in eventSupplyReadiness/current."
    );
  }
  assertExecutionActionPublishable(action);
  return action;
}

/**
 * Requires a clean preflight action.
 * @param {Record<string, unknown>} action Execution action.
 */
function assertExecutionActionPublishable(action: Record<string, unknown>) {
  const blockers = stringArray(action.blockers);
  const projectionValidation = requireRecord(
    action.projectionValidation,
    "projectionValidation"
  );
  const payloadValidation = requireRecord(
    action.payloadValidation,
    "payloadValidation"
  );
  if (
    action.sourceAction === "publish_read_only_external_event" &&
    action.status === "would_publish_read_only" &&
    blockers.length === 0 &&
    projectionValidation.valid === true &&
    payloadValidation.valid === true
  ) {
    return;
  }
  throw new HttpsError(
    "failed-precondition",
    "Selected preflight action is not publishable. Resolve blockers and " +
      "regenerate readiness before publishing."
  );
}

/**
 * Reads and validates the ExternalEventDocument embedded in the preflight.
 * @param {Record<string, unknown>} action Execution action.
 * @param {string} eventId Expected event id.
 * @param {string} targetPath Expected target path.
 * @return {ExternalEventDocument} Serialized external event document.
 */
function externalEventDocumentFromAction(
  action: Record<string, unknown>,
  eventId: string,
  targetPath: string
): ExternalEventDocument {
  const document = requireRecord(
    action.externalEventDocument,
    "externalEventDocument"
  );
  if (document.eventId !== eventId) {
    throw new HttpsError(
      "failed-precondition",
      "Preflight document eventId does not match the target path."
    );
  }
  if (document.publicationStatus !== "public") {
    throw new HttpsError(
      "failed-precondition",
      "External event document must be public before publishing."
    );
  }
  if (!validateExternalEventDocument(document)) {
    throw new HttpsError(
      "failed-precondition",
      `External event document failed schema validation for ${targetPath}.`
    );
  }
  return document as unknown as ExternalEventDocument;
}

/**
 * Converts serialized timestamp fixture fields into live Firestore timestamps.
 * @param {ExternalEventDocument} document Serialized document.
 * @return {Record<string, unknown>} Firestore document.
 */
function externalEventDocumentForFirestore(
  document: ExternalEventDocument
): Record<string, unknown> {
  return {
    ...document,
    startTime: timestampFromSerialized(document.startTime),
    endTime: document.endTime ?
      timestampFromSerialized(document.endTime) :
      null,
    createdAt: timestampFromSerialized(document.createdAt),
    updatedAt: timestampFromSerialized(document.updatedAt),
  };
}

/**
 * Converts a serialized timestamp shape to a Firestore Timestamp.
 * @param {{_seconds: number, _nanoseconds: number}} value Serialized timestamp.
 * @return {FirebaseFirestore.Timestamp} Firestore timestamp.
 */
function timestampFromSerialized(value: {
  _seconds: number;
  _nanoseconds: number;
}): FirebaseFirestore.Timestamp {
  return new admin.firestore.Timestamp(value._seconds, value._nanoseconds);
}

/**
 * Extracts the target event id from externalEvents/{eventId}.
 * @param {string} targetPath Target path.
 * @return {string} Event id.
 */
function eventIdFromTargetPath(targetPath: string): string {
  const [collection, eventId] = targetPath.split("/");
  if (collection !== "externalEvents" || !eventId) {
    throw new HttpsError("invalid-argument", "Invalid external event path.");
  }
  return eventId;
}

/**
 * Narrows a plain object.
 * @param {unknown} value Raw value.
 * @param {string} label Error label.
 * @return {Record<string, unknown>} Record.
 */
function requireRecord(
  value: unknown,
  label: string
): Record<string, unknown> {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new HttpsError("failed-precondition", `${label} is missing.`);
}

/**
 * Narrows string arrays.
 * @param {unknown} value Raw value.
 * @return {string[]} String values.
 */
function stringArray(value: unknown): string[] {
  return Array.isArray(value) ?
    value.filter((item): item is string => typeof item === "string") :
    [];
}

/**
 * Trims string values.
 * @param {unknown} value Raw value.
 * @return {unknown} Trimmed value.
 */
function normalizeString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

/**
 * Narrows nullable strings.
 * @param {unknown} value Raw value.
 * @return {string | null} String or null.
 */
function nullableString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value : null;
}

export const adminPublishExternalEvent = onCall(
  appCheckCallableOptions,
  (request) => adminPublishExternalEventHandler(request)
);
