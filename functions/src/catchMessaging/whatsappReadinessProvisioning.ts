import {createHash} from "node:crypto";
import type {CatchWhatsappReplyReadinessDocument as Readiness} from
  "../shared/generated/catchWhatsappReplyReadinessDocument";
import {validateCatchWhatsappReplyReadinessDocument} from
  "../shared/generated/validators/catchWhatsappReplyReadinessDocument";

export interface ReadinessScope {
  projectId: string;
  wabaId: string;
  phoneNumberId: string;
  recipientUid: string;
  endpointHash: string;
  evidenceSha256: string;
}

/** Loaded from an independent authorized store, never request JSON. */
export interface ReadinessApproval {
  approvalId: string;
  action: "create" | "revoke";
  scope: ReadinessScope;
  reviewerUid: string;
  reviewedAtMillis: number;
  expiresAtMillis: number;
  atomicIngressStartedAtMillis: number;
  /** For revocation, digest of the exact reviewed existing record. */
  expectedRecordSha256: string | null;
}

export interface ReadinessAuthority {
  uid: string;
  disabled: boolean;
  roles: readonly string[];
  sessionCurrent: boolean;
}

/**
 * Independent verification of authoritative archives and ingress evidence.
 * This is NOT an inventory format or a signature verified by this module. The
 * Verifier establishes complete history from inception, no retention gaps,
 * STOP absence and authentic evidence bytes; an empty receipt query, a supplied
 * completeHistory flag or the offline setup planner cannot implement it.
 */
export interface VerifiedReadinessHistory {
  approvalId: string;
  scope: ReadinessScope;
  provenanceSha256: string;
  historyFromMillis: 0;
  coveredThroughMillis: number;
  atomicIngressStartedAtMillis: number;
}

export interface ReadinessSnapshot {
  scope: ReadinessScope;
  nowMillis: number;
  authority: ReadinessAuthority;
  recipientEnabled: boolean;
  verifiedRecipientEndpointHash: string;
  /** STOP, sender withdrawal, deleted recipient or invalid preference. */
  suppressed: boolean;
  atomicIngressStartedAtMillis: number | null;
  existing: unknown;
}

export interface ReadinessMutation {
  record: Readiness;
  expectedRecordSha256: string | null;
  audit: {
    approvalId: string;
    action: "create" | "revoke";
    projectId: string;
    actorUid: string;
    atMillis: number;
    provenanceSha256: string | null;
    recordSha256: string;
  };
}

/**
 * Trusted server-only boundary, deliberately without a production adapter.
 * Every callback retry must reload and fence approvals, authority/session,
 * recipient, suppression, ingress and existing readiness. Auth and archive
 * evidence outside Firestore require an independently audited fencing protocol;
 * simply reading Auth before a Firestore write does not satisfy this contract.
 * commit atomically consumes the approval and creates immutable audit alongside
 * a create-only record or compare-and-set revocation. It must not touch STOP,
 * preferences, provider claims, gates or credentials. No default exists.
 */
export interface ReadinessTransaction {
  loadApprovedReview(reference: string): Promise<ReadinessApproval | null>;
  readCurrent(scope: ReadinessScope): Promise<ReadinessSnapshot>;
  verifyCompleteStopHistory(approval: ReadinessApproval):
    Promise<VerifiedReadinessHistory | null>;
  commit(mutation: ReadinessMutation): Promise<void>;
}
export interface ReadinessProvisioningDependencies {
  runFencedTransaction<T>(callback: (tx: ReadinessTransaction) => Promise<T>):
    Promise<T>;
}

const sha = (value: unknown): string =>
  createHash("sha256").update(JSON.stringify(value)).digest("hex");
const hash = (value: unknown): value is string =>
  typeof value === "string" && /^[a-f0-9]{64}$/u.test(value);
const uid = (value: unknown): value is string =>
  typeof value === "string" && /^[A-Za-z0-9_-]{1,128}$/u.test(value);
const millis = (value: unknown): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= 0;
const dayMillis = 24 * 60 * 60 * 1000;
function fail(): never {
  throw new Error("Catch readiness approval or evidence unavailable.");
}

function scopeParts(scope: ReadinessScope): string[] {
  if (!scope || !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(scope.projectId) ||
      !/^[0-9]{1,32}$/u.test(scope.wabaId) ||
      !/^[0-9]{1,32}$/u.test(scope.phoneNumberId) ||
      !uid(scope.recipientUid) || !hash(scope.endpointHash) ||
      !hash(scope.evidenceSha256)) fail();
  return [scope.projectId, scope.wabaId, scope.phoneNumberId,
    scope.recipientUid, scope.endpointHash, scope.evidenceSha256];
}
const sameScope = (a: ReadinessScope, b: ReadinessScope): boolean =>
  sha(scopeParts(a)) === sha(scopeParts(b));
const readinessId = (scope: ReadinessScope): string =>
  "cwready_" + sha([scope.wabaId, scope.phoneNumberId, scope.endpointHash]);

/** Canonical semantic digest: independent of JSON object property order. */
export function catchReadinessRecordDigest(record: Readiness): string {
  if (!validateCatchWhatsappReplyReadinessDocument(record)) fail();
  return sha([record.schemaVersion, record.readinessId, record.wabaId,
    record.phoneNumberId, record.recipientUid, record.endpointHash,
    record.purpose, record.state, record.completeHistory,
    record.historyFromMillis, record.coveredThroughMillis,
    record.atomicIngressStartedAtMillis, record.evidenceSha256,
    record.reviewedByUid, record.reviewedAtMillis, record.expiresAtMillis]);
}

/**
 * Only an opaque review reference is accepted, never caller-supplied proof.
 * No network, Firestore adapter, callable export or activation is provided.
 * Creation cannot renew or reactivate ANY existing readiness. Those operations
 * need separate review. Unknown commit outcomes propagate; never auto-retry.
 */
export async function applyCatchReadinessReview(reference: string,
  deps: ReadinessProvisioningDependencies): Promise<{
    readinessId: string; state: "ready" | "revoked";
  }> {
  if (!uid(reference)) fail();
  return deps.runFencedTransaction(async (tx) => {
    const loaded = await tx.loadApprovedReview(reference);
    if (!loaded) fail();
    // Copy trusted values so an awaiting dependency cannot mutate our approval.
    const approval = {...loaded, scope: {...loaded.scope}};
    if (approval.approvalId !== reference ||
        !["create", "revoke"].includes(approval.action) ||
        !uid(approval.reviewerUid) || !millis(approval.reviewedAtMillis) ||
        !millis(approval.expiresAtMillis) ||
        !millis(approval.atomicIngressStartedAtMillis) ||
        approval.atomicIngressStartedAtMillis > approval.reviewedAtMillis ||
        approval.expiresAtMillis <= approval.reviewedAtMillis ||
        approval.expiresAtMillis - approval.reviewedAtMillis > dayMillis) {
      fail();
    }
    scopeParts(approval.scope);
    const current = await tx.readCurrent({...approval.scope});
    const now = current.nowMillis;
    if (!sameScope(approval.scope, current.scope) || !millis(now) ||
        approval.reviewedAtMillis > now || approval.expiresAtMillis <= now ||
        !current.authority || current.authority.uid !== approval.reviewerUid ||
        current.authority.disabled !== false ||
        current.authority.sessionCurrent !== true ||
        !Array.isArray(current.authority.roles) ||
        !current.authority.roles.includes("adminOwner")) fail();
    let record: Readiness;
    let provenanceSha256: string | null = null;
    if (approval.action === "revoke") {
      // Revocation remains possible after STOP or ingress/recipient removal.
      if (!validateCatchWhatsappReplyReadinessDocument(current.existing)) {
        fail();
      }
      const existing = current.existing;
      if (existing.readinessId !== readinessId(approval.scope) ||
          existing.wabaId !== approval.scope.wabaId ||
          existing.phoneNumberId !== approval.scope.phoneNumberId ||
          existing.recipientUid !== approval.scope.recipientUid ||
          existing.endpointHash !== approval.scope.endpointHash ||
          existing.evidenceSha256 !== approval.scope.evidenceSha256 ||
          existing.atomicIngressStartedAtMillis !==
            approval.atomicIngressStartedAtMillis ||
          !hash(approval.expectedRecordSha256) ||
          catchReadinessRecordDigest(existing) !==
            approval.expectedRecordSha256) fail();
      record = {...existing, state: "revoked"};
    } else {
      if (approval.expectedRecordSha256 !== null ||
          current.existing !== null || current.suppressed !== false ||
          current.recipientEnabled !== true ||
          current.verifiedRecipientEndpointHash !==
            approval.scope.endpointHash ||
          current.atomicIngressStartedAtMillis !==
            approval.atomicIngressStartedAtMillis) fail();
      const proof = await tx.verifyCompleteStopHistory({
        ...approval, scope: {...approval.scope},
      });
      if (!proof || proof.approvalId !== reference ||
          !sameScope(proof.scope, approval.scope) ||
          !hash(proof.provenanceSha256) || proof.historyFromMillis !== 0 ||
          !millis(proof.coveredThroughMillis) ||
          proof.coveredThroughMillis < approval.atomicIngressStartedAtMillis ||
          proof.coveredThroughMillis > approval.reviewedAtMillis ||
          proof.atomicIngressStartedAtMillis !==
            approval.atomicIngressStartedAtMillis) fail();
      provenanceSha256 = proof.provenanceSha256;
      record = {schemaVersion: 1, readinessId: readinessId(approval.scope),
        wabaId: approval.scope.wabaId,
        phoneNumberId: approval.scope.phoneNumberId,
        recipientUid: approval.scope.recipientUid,
        endpointHash: approval.scope.endpointHash, purpose: "serviceSupport",
        state: "ready", completeHistory: true, historyFromMillis: 0,
        coveredThroughMillis: proof.coveredThroughMillis,
        atomicIngressStartedAtMillis: approval.atomicIngressStartedAtMillis,
        evidenceSha256: approval.scope.evidenceSha256,
        reviewedByUid: approval.reviewerUid,
        reviewedAtMillis: approval.reviewedAtMillis,
        expiresAtMillis: approval.expiresAtMillis};
    }
    const recordSha256 = catchReadinessRecordDigest(record);
    await tx.commit({record, expectedRecordSha256:
      approval.expectedRecordSha256, audit: {approvalId: reference,
      action: approval.action, projectId: approval.scope.projectId,
      actorUid: current.authority.uid, atMillis: now,
      provenanceSha256, recordSha256}});
    return {readinessId: record.readinessId, state: record.state};
  });
}
