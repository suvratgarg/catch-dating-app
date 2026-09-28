import {invalidateFitQueueInTransaction} from "../salesFitQueue/service";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesAccount, SalesPrincipal} from "./types";
import {salesRelationshipId} from "./records";

export interface AccountSuppressionInput {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  status: "clear" | "held" | "suppressed";
  reason: string;
}

export interface ContactabilityInput {
  organizerId: string;
  contactId: string;
  requestId: string;
  expectedRevision: number;
  status: "unknown" | "draft_reviewed" | "held" | "suppressed";
  reason: string;
  evidenceId?: string | null;
}

function currentContactEvidence(
  evidence: FirebaseFirestore.DocumentData | undefined,
  organizerId: string,
  contactId: string,
  now: string,
): boolean {
  const observed = Date.parse(String(evidence?.observedAt ?? ""));
  const validThrough = evidence?.validThrough ?
    Date.parse(String(evidence.validThrough)) : Infinity;
  const at = Date.parse(now);
  return evidence?.classification === "sales_private" &&
    evidence.organizerId === organizerId && evidence.contactId === contactId &&
    Number.isFinite(observed) && observed <= at && validThrough > at;
}

/** Contact review is reconsidered at use time, not just when it was saved. */
export async function hasCurrentDraftContact(
  db: FirebaseFirestore.Firestore,
  organizerId: string,
  contactId: string,
  now: string,
  tx?: FirebaseFirestore.Transaction,
): Promise<boolean> {
  const relationshipRef = db.collection("salesContactRelationships")
    .doc(salesRelationshipId(organizerId, contactId));
  const read = (ref: FirebaseFirestore.DocumentReference) =>
    tx ? tx.get(ref) : ref.get();
  const relationship = (await read(relationshipRef)).data();
  if (relationship?.classification !== "sales_private" ||
      relationship.organizerId !== organizerId ||
      relationship.contactId !== contactId ||
      relationship.contactabilityStatus !== "draft_reviewed" ||
      typeof relationship.draftReviewEvidenceId !== "string") return false;
  const evidence = await read(db.collection("salesEvidence")
    .doc(relationship.draftReviewEvidenceId));
  return currentContactEvidence(evidence.data(), organizerId, contactId, now);
}

function decisionId(principal: SalesPrincipal, requestId: string): string {
  const hash = createHash("sha256")
    .update(`${principal.uid}\u0000${requestId}`)
    .digest("hex")
    .slice(0, 24);
  return `suppression-${hash}`;
}

export async function setAccountSuppression(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: AccountSuppressionInput,
  now: string,
): Promise<Record<string, unknown>> {
  const ref = db.collection("organizerSalesAccounts").doc(input.organizerId);
  const snap = await tx.get(ref);
  if (!snap.exists || snap.data()?.classification !== "sales_private") {
    throw new HttpsError("not-found", "Sales account not found.");
  }
  const current = snap.data() as SalesAccount;
  if (current.revision !== input.expectedRevision) {
    throw new HttpsError("aborted", "Sales account changed since review.");
  }
  const next: SalesAccount = {
    ...current,
    suppressionStatus: input.status,
    suppressionReason: input.reason,
    suppressionAt: now,
    suppressionBy: principal.uid,
    revision: current.revision + 1,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  const decision = {
    schemaVersion: 1,
    classification: "sales_private",
    decisionId: decisionId(principal, input.requestId),
    targetType: "account",
    organizerId: input.organizerId,
    contactId: null,
    previousStatus: current.suppressionStatus,
    status: input.status,
    reason: input.reason,
    actorUid: principal.uid,
    recordedAt: now,
    accountRevision: next.revision,
  };
  tx.set(ref, next);
  invalidateFitQueueInTransaction(tx, db, input.organizerId, now);
  tx.create(
    db.collection("salesSuppressionDecisions").doc(decision.decisionId),
    decision,
  );
  return {account: next, decision};
}

export async function setContactability(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: ContactabilityInput,
  now: string,
): Promise<Record<string, unknown>> {
  const id = salesRelationshipId(input.organizerId, input.contactId);
  const ref = db.collection("salesContactRelationships").doc(id);
  const snap = await tx.get(ref);
  if (
    !snap.exists ||
    snap.data()?.classification !== "sales_private" ||
    snap.data()?.organizerId !== input.organizerId ||
    snap.data()?.contactId !== input.contactId
  ) {
    throw new HttpsError("not-found", "Contact relationship not found.");
  }
  const current = snap.data() ?? {};
  if (current.revision !== input.expectedRevision) {
    throw new HttpsError(
      "aborted",
      "Contact relationship changed since review.",
    );
  }
  if (input.status === "draft_reviewed") {
    if (!input.evidenceId) {
      throw new HttpsError(
        "failed-precondition",
        "Draft review requires linked organizer evidence.",
      );
    }
    const evidenceSnap = await tx.get(
      db.collection("salesEvidence").doc(input.evidenceId),
    );
    if (!currentContactEvidence(evidenceSnap.data(), input.organizerId,
      input.contactId, now)) {
      throw new HttpsError(
        "failed-precondition",
        "Draft review evidence is not current.",
      );
    }
  }
  const next = {
    ...current,
    contactabilityStatus: input.status,
    contactabilityReason: input.reason,
    contactabilityAt: now,
    contactabilityBy: principal.uid,
    revision: input.expectedRevision + 1,
    draftReviewEvidenceId:
      input.status === "draft_reviewed" ? input.evidenceId : null,
    sendAuthority: false,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  const decision = {
    schemaVersion: 1,
    classification: "sales_private",
    decisionId: decisionId(principal, input.requestId),
    targetType: "contact_relationship",
    organizerId: input.organizerId,
    contactId: input.contactId,
    previousStatus: current.contactabilityStatus ?? "unknown",
    status: input.status,
    reason: input.reason,
    actorUid: principal.uid,
    evidenceId: input.evidenceId ?? null,
    sendAuthority: false,
    recordedAt: now,
    relationshipRevision: next.revision,
  };
  tx.set(ref, next);
  tx.create(
    db.collection("salesSuppressionDecisions").doc(decision.decisionId),
    decision,
  );
  const safe: Record<string, unknown> = {...next};
  delete safe.endpoints;
  return {
    relationship: principal.readEndpoints === false ? safe : next,
    decision,
  };
}
