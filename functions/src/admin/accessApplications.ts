import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAdminRole} from "./adminAuth";
import {setAdminAuditLogInTransaction} from "./adminAudit";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";

const accessReviewRoles = ["admin", "adminOwner", "support"] as const;
const editableStatuses = ["pending", "waitlisted", "notSelectedYet"];

export type AccessApplicationDecision = "approve" | "deny";

export interface AdminDecideAccessApplicationPayload {
  applicationUid: string;
  decision: AccessApplicationDecision;
  note?: string | null;
  cohortId?: string | null;
}

export interface AdminDecideAccessApplicationResponse {
  applicationUid: string;
  decision: AccessApplicationDecision;
  status: "approvedForProfile" | "notSelectedYet";
}

interface AccessApplicationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: AccessApplicationDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Reviews a launch access application from the admin dashboard.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {AccessApplicationDeps} deps Injectable dependencies.
 * @return {Promise<AdminDecideAccessApplicationResponse>} Decision result.
 */
export async function adminDecideAccessApplicationHandler(
  request: CallableRequest<unknown>,
  deps: AccessApplicationDeps = defaultDeps
): Promise<AdminDecideAccessApplicationResponse> {
  const adminContext = requireAdminRole(request, accessReviewRoles);
  const payload = normalizeDecisionPayload(request.data);
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    adminContext.uid,
    "adminDecideAccessApplication"
  );
  const applicationPath = `accessApplications/${payload.applicationUid}`;
  const applicationRef = db
    .collection("accessApplications")
    .doc(payload.applicationUid);
  const nextStatus = payload.decision === "approve" ?
    "approvedForProfile" :
    "notSelectedYet";

  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(applicationRef);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Access application not found.");
    }

    const data = snapshot.data() ?? {};
    const currentStatus = stringValue(data.status) ?? "pending";
    if (!editableStatuses.includes(currentStatus)) {
      throw new HttpsError(
        "failed-precondition",
        "This access application has already been reviewed."
      );
    }

    const reviewPatch: Record<string, unknown> = {
      status: nextStatus,
      reviewerUid: adminContext.uid,
      reviewNote: payload.note ?? null,
      reviewedAt: deps.serverTimestamp(),
      updatedAt: deps.serverTimestamp(),
    };
    if (payload.cohortId) {
      reviewPatch.cohortId = payload.cohortId;
    }

    tx.set(applicationRef, reviewPatch, {merge: true});
    setAdminAuditLogInTransaction(tx, db, adminContext, {
      action: "adminDecideAccessApplication",
      targetPath: applicationPath,
      request,
      before: {status: currentStatus},
      after: {
        status: nextStatus,
        decision: payload.decision,
        ...(payload.cohortId ? {cohortId: payload.cohortId} : {}),
      },
      note: payload.note,
      serverTimestamp: deps.serverTimestamp,
    });
  });

  return {
    applicationUid: payload.applicationUid,
    decision: payload.decision,
    status: nextStatus,
  };
}

export const adminDecideAccessApplication = onCall(
  appCheckCallableOptions,
  (request) => adminDecideAccessApplicationHandler(request)
);

/**
 * Parses and validates the admin decision payload.
 * @param {unknown} data Raw callable payload.
 * @return {AdminDecideAccessApplicationPayload} Valid payload.
 */
export function normalizeDecisionPayload(
  data: unknown
): AdminDecideAccessApplicationPayload {
  if (!isRecord(data)) {
    throw new HttpsError("invalid-argument", "Expected an object payload.");
  }

  const applicationUid = stringValue(data.applicationUid);
  if (!applicationUid || applicationUid.includes("/")) {
    throw new HttpsError(
      "invalid-argument",
      "A valid applicationUid is required."
    );
  }

  const decision = stringValue(data.decision);
  if (decision !== "approve" && decision !== "deny") {
    throw new HttpsError(
      "invalid-argument",
      "Decision must be approve or deny."
    );
  }

  const note = nullableStringValue(data.note);
  if (note && note.length > 1000) {
    throw new HttpsError(
      "invalid-argument",
      "Review note must be 1000 characters or fewer."
    );
  }

  const cohortId = nullableStringValue(data.cohortId);
  if (cohortId && cohortId.length > 120) {
    throw new HttpsError(
      "invalid-argument",
      "Cohort id must be 120 characters or fewer."
    );
  }

  return {applicationUid, decision, note, cohortId};
}

/**
 * Checks whether a value is a plain object record.
 * @param {unknown} value Candidate value.
 * @return {boolean} Whether the value is a record.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null &&
    !Array.isArray(value);
}

/**
 * Returns a trimmed string when non-empty.
 * @param {unknown} value Candidate value.
 * @return {string | null} String value.
 */
function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

/**
 * Returns a trimmed nullable string.
 * @param {unknown} value Candidate value.
 * @return {string | null} Nullable string.
 */
function nullableStringValue(value: unknown): string | null {
  if (value == null) return null;
  return stringValue(value);
}
