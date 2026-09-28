import {invalidateFitQueueInTransaction} from "../salesFitQueue/service";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {validateOperationWorkItem} from "../../operations/validation";
import type {SalesAccount, SalesPrincipal} from "../sales/types";
import {newSalesAccount} from "../sales/account";
import {organizerDraftOperationId} from "../organizerDraftIdentity";

export interface LinkIntakeToSalesInput {
  workItemId: string;
  candidateId: string;
  expectedWorkItemRevision: number;
  expectedCandidateHash: string;
  organizerId: string;
  curationPath: string;
  requestId: string;
}

export interface SalesIntakeLink {
  schemaVersion: 1;
  classification: "sales_private";
  linkId: string;
  workItemId: string;
  candidateId: string;
  sourceRunId: string;
  sourceWorkItemRevision: number;
  sourceCandidateHash: string;
  organizerId: string;
  curationPath: string;
  curationOperationType: "create_entity_draft" | "attach_surface";
  curationReviewedByUid: string;
  curationReviewedAt: string;
  linkedByUid: string;
  linkedAt: string;
}

type Result = {link: SalesIntakeLink; account: SalesAccount;
  accountCreated: boolean};
type RecordValue = Record<string, unknown>;

function sha(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export function salesIntakeLinkId(workItemId: string,
  candidateId: string): string {
  const digest = sha(`${workItemId}\u0000${candidateId}`);
  return `intake-sales-${digest.slice(0, 32)}`;
}

function record(value: unknown): RecordValue | null {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as RecordValue : null;
}

function iso(value: unknown): string | null {
  if (typeof value === "string" && Number.isFinite(Date.parse(value))) {
    return new Date(value).toISOString();
  }
  if (value && typeof value === "object" && "toDate" in value &&
    typeof value.toDate === "function") {
    const date = value.toDate() as Date;
    return Number.isFinite(date.getTime()) ? date.toISOString() : null;
  }
  return null;
}

function assertEmployee(principal: SalesPrincipal): void {
  if (!principal.uid || principal.clientId ||
    !principal.roles.some((role) => role === "admin" ||
      role === "adminOwner")) {
    throw new HttpsError("permission-denied",
      "Current employee Sales review is required.");
  }
}

/** Reuses Intake's identity decision; writes no canonical/public data. */
export async function linkOrganizerIntakeToSales(
  db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
  input: LinkIntakeToSalesInput, now: string,
  recheckEmployee?: () => Promise<void>,
): Promise<Result> {
  assertEmployee(principal);
  const linkId = salesIntakeLinkId(input.workItemId, input.candidateId);
  const workItemRef = db.collection("operationWorkItems")
    .doc(input.workItemId);
  const curationId = input.curationPath.split("/")[1];
  if (input.curationPath !==
    `organizerIntakeCurationDecisions/${curationId}` || !curationId) {
    throw new HttpsError("invalid-argument",
      "Choose an exact Intake curation decision.");
  }
  const curationRef = db.collection("organizerIntakeCurationDecisions")
    .doc(curationId);
  const organizerRef = db.collection("organizers").doc(input.organizerId);
  const accountRef = db.collection("organizerSalesAccounts")
    .doc(input.organizerId);
  const linkRef = db.collection("salesIntakeLinks").doc(linkId);
  return db.runTransaction(async (tx) => {
    await recheckEmployee?.();
    const [itemSnap, curationSnap, organizerSnap, accountSnap, linkSnap] =
      await Promise.all([tx.get(workItemRef), tx.get(curationRef),
        tx.get(organizerRef), tx.get(accountRef), tx.get(linkRef)]);
    if (accountSnap.data()?.researchStatus === "archived") {
      throw new HttpsError("failed-precondition",
        "Reopen the archived Sales account before linking Intake.");
    }
    if (linkSnap.exists) {
      const prior = linkSnap.data() as SalesIntakeLink;
      if (prior.organizerId !== input.organizerId ||
        prior.curationPath !== input.curationPath ||
        prior.sourceCandidateHash !== input.expectedCandidateHash ||
        prior.sourceWorkItemRevision !== input.expectedWorkItemRevision ||
        !accountSnap.exists ||
        accountSnap.data()?.organizerId !== input.organizerId) {
        throw new HttpsError("already-exists",
          "Intake candidate has a different Sales identity link.");
      }
      return {link: prior, account: accountSnap.data() as SalesAccount,
        accountCreated: false};
    }
    const checked = validateOperationWorkItem(itemSnap.data());
    if (!itemSnap.exists || !checked.ok ||
      checked.value.workItemId !== input.workItemId ||
      checked.value.workflowId !== "supply-intake" ||
      checked.value.entityKind !== "organizer") {
      throw new HttpsError("failed-precondition",
        "Current Supply Intake organizer work item is required.");
    }
    const workItem = checked.value;
    if (workItem.revision !== input.expectedWorkItemRevision ||
      workItem.candidateHash !== input.expectedCandidateHash) {
      throw new HttpsError("aborted",
        "Intake candidate changed; refresh the review before linking.");
    }
    const intake = record(workItem.normalizedPayload.intake);
    const candidate = record(intake?.candidate);
    if (intake?.recordType !== "organizer_search_candidate" ||
      !candidate || candidate.candidateId !== input.candidateId ||
      workItem.externalKey !== input.candidateId ||
      !Array.isArray(candidate.existingEntityMatches)) {
      throw new HttpsError("failed-precondition",
        "Intake candidate identity does not match the selected work item.");
    }
    const curation = curationSnap.data();
    const reviewedAt = iso(curation?.reviewedAt);
    if (!curationSnap.exists || curation?.operationStatus !== "active" ||
      curation.sourceCandidateId !== input.candidateId ||
      typeof curation.reviewedByUid !== "string" || !reviewedAt ||
      !organizerSnap.exists) {
      throw new HttpsError("failed-precondition",
        "An employee-reviewed canonical Intake identity is required.");
    }
    const normalizedKey = typeof candidate.normalizedKey === "string" &&
      candidate.normalizedKey.trim() ? candidate.normalizedKey.trim() :
      typeof candidate.canonicalUrl === "string" ?
        candidate.canonicalUrl.trim().toLowerCase() : "";
    if (curation.operationType === "create_entity_draft") {
      if (curationId !== organizerDraftOperationId(normalizedKey) ||
        curation.sourceWorkItemId !== input.workItemId ||
        curation.sourceNormalizedKey !== normalizedKey ||
        curation.entityId !== input.organizerId ||
        candidate.existingEntityMatches.length !== 0 ||
        !iso(record(candidate.reviewContext)?.verifiedAt)) {
        throw new HttpsError("failed-precondition",
          "Reviewed new-organizer draft does not match this candidate.");
      }
    } else if (curation.operationType === "attach_surface") {
      const matches = candidate.existingEntityMatches
        .map((value) => record(value)?.entityId);
      const suggestedSurface = record(candidate.suggestedSurface);
      if (!matches.includes(input.organizerId) ||
        curation.entityId !== input.organizerId ||
        curation.surfaceId !== suggestedSurface?.surfaceId ||
        record(curation.surface)?.normalizedKey !==
          suggestedSurface?.normalizedKey) {
        throw new HttpsError("failed-precondition",
          "Reviewed existing-organizer match is no longer current.");
      }
    } else {
      throw new HttpsError("failed-precondition",
        "Intake curation did not establish a canonical organizer identity.");
    }
    const organizer = organizerSnap.data() ?? {};
    if (accountSnap.exists &&
      (accountSnap.data()?.classification !== "sales_private" ||
        accountSnap.data()?.organizerId !== input.organizerId)) {
      throw new HttpsError("failed-precondition",
        "Existing Sales account has a different canonical identity.");
    }
    const account = accountSnap.exists ?
      accountSnap.data() as SalesAccount :
      newSalesAccount(input.organizerId, organizer, principal.uid, now);
    const link: SalesIntakeLink = {
      schemaVersion: 1, classification: "sales_private", linkId,
      workItemId: input.workItemId, candidateId: input.candidateId,
      sourceRunId: workItem.runId,
      sourceWorkItemRevision: workItem.revision,
      sourceCandidateHash: workItem.candidateHash,
      organizerId: input.organizerId, curationPath: input.curationPath,
      curationOperationType: curation.operationType,
      curationReviewedByUid: curation.reviewedByUid,
      curationReviewedAt: reviewedAt, linkedByUid: principal.uid,
      linkedAt: now,
    };
    if (!accountSnap.exists) {
      tx.create(accountRef, account);
      invalidateFitQueueInTransaction(tx, db, input.organizerId, now);
    }
    tx.create(linkRef, link);
    tx.create(db.collection("adminAuditLogs").doc(), {
      actorUid: principal.uid, roles: [...principal.roles],
      action: "adminLinkOrganizerIntakeToSales",
      targetPath: accountRef.path, createdAt: now,
      requestId: input.requestId,
    });
    return {link, account, accountCreated: !accountSnap.exists};
  });
}
