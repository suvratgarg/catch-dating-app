import {createHash} from "node:crypto";
import {Timestamp, type Firestore} from "firebase-admin/firestore";
import {applyCatchReadinessReview} from "./whatsappReadinessProvisioning";
import type {ReadinessApproval, ReadinessScope, ReadinessSnapshot,
} from "./whatsappReadinessProvisioning";
import {verifyCatchWhatsappHistoryArchive} from
  "./whatsappHistoryArchiveVerifier";
import type {TrustedCatchHistoryArchivePin} from
  "./whatsappHistoryArchiveVerifier";
import {validateCatchWhatsappReadinessApprovalDocument} from
  "../shared/generated/validators/catchWhatsappReadinessApprovalDocument";
import {validateCatchWhatsappReadinessIngressDocument} from
  "../shared/generated/validators/catchWhatsappReadinessIngressDocument";
import {validateCatchWhatsappReadinessAuditDocument} from
  "../shared/generated/validators/catchWhatsappReadinessAuditDocument";
import {validateCatchCommunicationPreferenceDocument} from
  "../shared/generated/validators/catchCommunicationPreferenceDocument";

/**
 * Mandatory external protocol, NOT implemented by an Auth lookup or a stored
 * approved boolean. The implementation must prevent changes to reviewer role,
 * disabled/session state and recipient identity for the ENTIRE callback AND
 * Firestore commit. All Auth mutators must participate, including out-of-band
 * administration. Existing adminUserRoles does not implement this protocol.
 * No default capability or live caller exists. An unaudited implementation
 * must not be supplied merely to make provisioning pass.
 */
export interface CatchReadinessAuthorityFence {
  projectId: string;
  approvalId: string;
  provenanceSha256: string;
  readCurrent(approval: ReadinessApproval): Promise<Pick<ReadinessSnapshot,
    "authority" | "recipientEnabled" | "verifiedRecipientEndpointHash">>;
}

export interface CatchReadinessFirestoreDependencies {
  projectId: string;
  now: () => number;
  withAuditedAuthorityFence<T>(identity: {
    projectId: string; approvalId: string;
  }, callback: (fence: CatchReadinessAuthorityFence) => Promise<T>): Promise<T>;
  /**
   * Read-only loader from audited immutable sources. Never request
   * JSON, self-attested archive metadata, or an empty retained-receipt query.
   */
  loadTrustedHistoryArchive(approval: ReadinessApproval): Promise<{
    archiveBytes: Uint8Array; trustedPin: TrustedCatchHistoryArchivePin;
  } | null>;
}

const digest = (value: unknown): string =>
  createHash("sha256").update(JSON.stringify(value)).digest("hex");
const isHash = (value: unknown): value is string =>
  typeof value === "string" && /^[a-f0-9]{64}$/u.test(value);
const validMillis = (value: number): boolean =>
  Number.isSafeInteger(value) && value >= 0;
function fail(): never {
  throw new Error("Catch readiness transaction unavailable.");
}
const scopeKey = (scope: ReadinessScope): string => digest([
  scope.projectId, scope.wabaId, scope.phoneNumberId, scope.recipientUid,
  scope.endpointHash, scope.evidenceSha256,
]);
export const catchReadinessIngressId = (scope: Pick<ReadinessScope,
  "projectId" | "wabaId" | "phoneNumberId">): string =>
  "cwingress_" + digest([scope.projectId, scope.wabaId, scope.phoneNumberId]);

function serialized(value: unknown): unknown {
  if (value instanceof Timestamp) {
    return {_seconds: value.seconds,
      _nanoseconds: value.nanoseconds};
  }
  if (Array.isArray(value)) return value.map(serialized);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, entry]) => [key, serialized(entry)]));
  }
  return value;
}

/**
 * Concrete Firestore writes, deliberately disconnected from handlers/exports.
 * Only an opaque review reference is input; protected records own scope.
 * An audited Auth fence and independent history source remain prerequisites.
 * No approval/ingress writer, credential access, provider I/O or gate change.
 *
 * SDK automatic retries include UNKNOWN and deadline errors, so maxAttempts is
 * explicitly one. Only a commit-level gRPC ABORTED conflict gets a bounded
 * fresh retry.
 * Other outcomes propagate; reconcile privately, never blind retry.
 */
export async function applyCatchReadinessReviewInFirestore(reference: string,
  db: Firestore, deps: CatchReadinessFirestoreDependencies): Promise<{
    readinessId: string; state: "ready" | "revoked";
  }> {
  // The installed Firestore SDK exposes this initialized-client getter at
  // runtime but omits it from public typings. Missing/uninitialized identity
  // rejects rather than falling back to an environment or approval assertion.
  const actualProjectId: unknown = Reflect.get(db, "projectId");
  if (typeof actualProjectId !== "string" ||
      typeof reference !== "string" ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(reference) ||
      typeof deps?.withAuditedAuthorityFence !== "function" ||
      typeof deps.loadTrustedHistoryArchive !== "function" ||
      actualProjectId !== deps.projectId ||
      db.databaseId !== "(default)") fail();
  return deps.withAuditedAuthorityFence({projectId: actualProjectId,
    approvalId: reference}, async (fence) => {
    if (!fence || fence.projectId !== actualProjectId ||
        fence.approvalId !== reference || !isHash(fence.provenanceSha256) ||
        typeof fence.readCurrent !== "function") fail();
    // Retry only conflicts with a definite non-commit outcome. Every callback
    // reloads approval, audit absence and all current Firestore facts.
    for (let attempt = 0; ; attempt++) {
      let callbackFailed = false;
      try {
        return await db.runTransaction(async (tx) => {
          try {
            const approvalRef = db.collection("catchWhatsappReadinessApprovals")
              .doc(reference);
            const auditRef = db.collection("catchWhatsappReadinessAudits")
              .doc(reference);
            const [approvalSnap, auditSnap] = await Promise.all([
              tx.get(approvalRef), tx.get(auditRef),
            ]);
            const stored = approvalSnap.data();
            if (auditSnap.exists ||
              !validateCatchWhatsappReadinessApprovalDocument(stored) ||
              stored.approvalId !== reference || stored.state !== "approved" ||
              stored.consumedAtMillis !== null ||
                stored.recordSha256 !== null ||
              stored.approval.approvalId !== reference ||
              stored.approval.scope.projectId !== actualProjectId) fail();
            const approval: ReadinessApproval =
              structuredClone(stored.approval);
            const scope = approval.scope;
            const endpointKey = digest([scope.wabaId, scope.phoneNumberId,
              scope.endpointHash]);
            const readinessRef = db.collection("catchWhatsappReplyReadiness")
              .doc("cwready_" + endpointKey);
            let currentRead = false;
            return await applyCatchReadinessReview(reference, {
              runFencedTransaction: async (callback) => callback({
                loadApprovedReview: async (requested) =>
                  requested === reference ?
                    structuredClone(approval) : null,
                readCurrent: async (requestedScope) => {
                  if (scopeKey(requestedScope) !== scopeKey(scope)) fail();
                  const ingressId = catchReadinessIngressId(scope);
                  const [stop, preference, deleted, ingressSnap, readiness] =
                  await Promise.all([
                    tx.get(db.collection("catchWhatsappEndpointStops")
                      .doc("cwstop_" + endpointKey)),
                    tx.get(db.collection("catchCommunicationPreferences")
                      .doc(scope.recipientUid)),
                    tx.get(db.collection("deletedUsers")
                      .doc(scope.recipientUid)),
                    tx.get(db.collection("catchWhatsappReadinessIngress")
                      .doc(ingressId)),
                    tx.get(readinessRef),
                  ]);
                  const nowMillis = deps.now();
                  if (!validMillis(nowMillis)) fail();
                  const ingress = ingressSnap.data();
                  const ingressValid =
                  validateCatchWhatsappReadinessIngressDocument(ingress) &&
                  ingress.ingressId === ingressId &&
                  ingress.projectId === actualProjectId &&
                  ingress.wabaId === scope.wabaId &&
                  ingress.phoneNumberId === scope.phoneNumberId &&
                  ingress.state === "active" &&
                  ingress.evidenceSha256 === stored.ingressEvidenceSha256 &&
                  ingress.atomicIngressStartedAtMillis <=
                    ingress.verifiedAtMillis &&
                  ingress.verifiedAtMillis <= approval.reviewedAtMillis;
                  const pref = serialized(preference.data());
                  const invalidPreference = preference.exists &&
                  (!validateCatchCommunicationPreferenceDocument(pref) ||
                    pref.uid !== scope.recipientUid ||
                    pref.whatsapp.status === "optedOut");
                  const identity = await fence.readCurrent(
                    structuredClone(approval));
                  currentRead = true;
                  return {...structuredClone(identity), scope: {...scope},
                    nowMillis, suppressed: stop.exists || deleted.exists ||
                    invalidPreference,
                    atomicIngressStartedAtMillis: ingressValid ?
                      ingress.atomicIngressStartedAtMillis : null,
                    existing: readiness.exists ? readiness.data() : null};
                },
                verifyCompleteStopHistory: async (review) => {
                  const source = await deps.loadTrustedHistoryArchive(
                    structuredClone(review));
                  if (!source) return null;
                  return verifyCatchWhatsappHistoryArchive({...source,
                    approval: review, nowMillis: deps.now()});
                },
                commit: async (mutation) => {
                  const now = deps.now();
                  if (!currentRead || !validMillis(now) ||
                    now < mutation.audit.atMillis ||
                    now >= approval.expiresAtMillis ||
                    mutation.record.readinessId !== readinessRef.id ||
                    mutation.audit.approvalId !== reference) fail();
                  const audit = {schemaVersion: 1, auditId: reference,
                    ...mutation.audit, atMillis: now,
                    readinessId: readinessRef.id,
                    authorityFenceSha256: fence.provenanceSha256};
                  const consumed = {...stored, state: "consumed",
                    consumedAtMillis: now,
                    recordSha256: mutation.audit.recordSha256};
                  if (!validateCatchWhatsappReadinessAuditDocument(audit) ||
                    !validateCatchWhatsappReadinessApprovalDocument(consumed)) {
                    fail();
                  }
                  // Read-set preconditions fence concurrent STOP, withdrawal,
                  // deletion, ingress, readiness and approval changes.
                  if (approval.action === "create") {
                    tx.create(readinessRef, mutation.record);
                  } else {
                    tx.update(readinessRef, {state: "revoked"});
                  }
                  tx.update(approvalRef, consumed);
                  tx.create(auditRef, audit);
                },
              }),
            });
          } catch (error) {
            callbackFailed = true;
            throw error;
          }
        }, {maxAttempts: 1});
      } catch (error) {
        const code = error && typeof error === "object" && "code" in error ?
          error.code : null;
        if (callbackFailed || attempt >= 2 || code !== 10) throw error;
      }
    }
  });
}
