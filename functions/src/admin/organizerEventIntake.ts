import crypto from "node:crypto";
import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {AdminDecideOrganizerEventCandidateCallablePayload} from
  "../shared/generated/adminDecideOrganizerEventCandidateCallablePayload";
import {OrganizerEventCandidateReviewDecisionDocument} from
  "../shared/generated/organizerEventCandidateReviewDecisionDocument";
import {validateAdminDecideOrganizerEventCandidateCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAdminRole} from "./adminAuth";
import {setAdminAuditLogInTransaction} from "./adminAudit";

const organizerIntakeRoles = ["admin", "adminOwner", "support"] as const;
const decisionCollection = "organizerEventCandidateReviewDecisions";

interface OrganizerEventIntakeDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: OrganizerEventIntakeDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

type OrganizerEventCandidateDecision =
  AdminDecideOrganizerEventCandidateCallablePayload["decision"];
type OrganizerEventCandidateChecklist =
  AdminDecideOrganizerEventCandidateCallablePayload["checklist"];

export interface AdminDecideOrganizerEventCandidateResponse {
  candidateId: string;
  decisionId: string;
  decision: OrganizerEventCandidateDecision;
  decisionStatus:
    OrganizerEventCandidateReviewDecisionDocument["decisionStatus"];
  decisionPath: string;
  importState: OrganizerEventCandidateReviewDecisionDocument["importState"];
}

/**
 * Records the latest manual admin review decision for an external event
 * candidate. This does not create or update events; approved candidates remain
 * blocked by product import policy until a later importer explicitly opts in.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {OrganizerEventIntakeDeps} deps Injectable dependencies.
 * @return {Promise<AdminDecideOrganizerEventCandidateResponse>} Decision.
 */
export async function adminDecideOrganizerEventCandidateHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerEventIntakeDeps = defaultDeps
): Promise<AdminDecideOrganizerEventCandidateResponse> {
  const adminContext = requireAdminRole(request, organizerIntakeRoles);
  const data =
    validateCallableWithAjv<AdminDecideOrganizerEventCandidateCallablePayload>(
      request,
      validateAdminDecideOrganizerEventCandidateCallablePayload,
      normalizeAdminDecideOrganizerEventCandidatePayload
    );
  assertDecisionAllowed(data);

  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    adminContext.uid,
    "adminDecideOrganizerEventCandidate"
  );
  const decisionId = decisionIdForCandidate(data.candidateId);
  const decisionRef = db.collection(decisionCollection).doc(decisionId);
  const timestamp = deps.serverTimestamp();
  const decisionStatus = decisionStatusFor(data.decision);
  const importState = importStateFor(data.decision);
  const decisionDoc: OrganizerEventCandidateReviewDecisionDocument = {
    schemaVersion: 1,
    decisionId,
    candidateId: data.candidateId,
    decision: data.decision,
    decisionStatus,
    checklist: data.checklist,
    note: data.note,
    reviewedByUid: adminContext.uid,
    reviewedAt: timestamp as unknown as
      OrganizerEventCandidateReviewDecisionDocument["reviewedAt"],
    updatedAt: timestamp as unknown as
      OrganizerEventCandidateReviewDecisionDocument["updatedAt"],
    importState,
  };

  await db.runTransaction(async (tx) => {
    const beforeSnap = await tx.get(decisionRef);
    tx.set(decisionRef, decisionDoc, {merge: true});
    setAdminAuditLogInTransaction(tx, db, adminContext, {
      action: "adminDecideOrganizerEventCandidate",
      targetPath: decisionRef.path,
      request,
      before: beforeSnap.exists ? beforeSnap.data() ?? {} : {},
      after: {
        candidateId: data.candidateId,
        decisionId,
        decision: data.decision,
        decisionStatus,
        importState,
      },
      note: data.note,
      serverTimestamp: deps.serverTimestamp,
    });
  });

  return {
    candidateId: data.candidateId,
    decisionId,
    decision: data.decision,
    decisionStatus,
    decisionPath: decisionRef.path,
    importState,
  };
}

/**
 * Applies string trimming before schema validation.
 * @param {unknown} value Raw payload.
 * @return {unknown} Normalized payload.
 */
function normalizeAdminDecideOrganizerEventCandidatePayload(
  value: unknown
): unknown {
  if (!value || typeof value !== "object") return value;
  const data = value as Record<string, unknown>;
  return {
    ...data,
    candidateId: normalizeString(data.candidateId),
    decision: normalizeString(data.decision),
    note: normalizeString(data.note),
  };
}

/**
 * Enforces manual review guardrails that JSON Schema cannot express.
 * @param {AdminDecideOrganizerEventCandidateCallablePayload} data Payload.
 */
function assertDecisionAllowed(
  data: AdminDecideOrganizerEventCandidateCallablePayload
) {
  if (data.decision === "approve_for_import" &&
    !reviewChecklistComplete(data.checklist)) {
    throw new HttpsError(
      "failed-precondition",
      "Identity, source event, time, location, dedupe, owner-safe copy, " +
        "and import-policy checks must be complete before import approval."
    );
  }
}

/**
 * Maps admin decisions to stable decision states.
 * @param {OrganizerEventCandidateDecision} decision Admin decision.
 * @return {OrganizerEventCandidateReviewDecisionDocument["decisionStatus"]}
 * State.
 */
function decisionStatusFor(
  decision: OrganizerEventCandidateDecision
): OrganizerEventCandidateReviewDecisionDocument["decisionStatus"] {
  if (decision === "approve_for_import") return "approved_for_import";
  if (decision === "hold") return "held";
  return "rejected";
}

/**
 * Maps review decisions to event-import state. Import remains disabled even
 * when a candidate is manually approved for future import.
 * @param {OrganizerEventCandidateDecision} decision Admin decision.
 * @return {OrganizerEventCandidateReviewDecisionDocument["importState"]}
 * Import state.
 */
function importStateFor(
  decision: OrganizerEventCandidateDecision
): OrganizerEventCandidateReviewDecisionDocument["importState"] {
  if (decision === "approve_for_import") return "blocked_by_policy";
  return "not_importable";
}

/**
 * Returns whether every import-safety checklist field was reviewed.
 * @param {OrganizerEventCandidateChecklist} checklist Admin checklist.
 * @return {boolean} True when complete.
 */
function reviewChecklistComplete(
  checklist: OrganizerEventCandidateChecklist
): boolean {
  return checklist.identityReviewed &&
    checklist.sourceEventReviewed &&
    checklist.timeReviewed &&
    checklist.locationReviewed &&
    checklist.dedupeReviewed &&
    checklist.ownerSafeCopyReviewed &&
    checklist.importPolicyAcknowledged;
}

/**
 * Builds a Firestore-safe document id while preserving candidateId in the doc.
 * @param {string} candidateId External event candidate id.
 * @return {string} Decision document id.
 */
export function decisionIdForCandidate(candidateId: string): string {
  const slug = candidateId
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "candidate";
  const base = `event-${slug}`;
  if (base.length <= 150) return base;
  const hash = crypto
    .createHash("sha256")
    .update(candidateId)
    .digest("hex")
    .slice(0, 12);
  return `${base.slice(0, 137).replace(/-+$/g, "")}-${hash}`;
}

/**
 * Trims string payload fields.
 * @param {unknown} value Raw value.
 * @return {unknown} Trimmed value.
 */
function normalizeString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

export const adminDecideOrganizerEventCandidate = onCall(
  appCheckCallableOptions,
  (request) => adminDecideOrganizerEventCandidateHandler(request)
);
