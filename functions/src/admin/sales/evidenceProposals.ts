import * as admin from "firebase-admin";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {addSalesEvidence, salesRelationshipId, type EvidenceInput} from
  "./records";
import type {SalesPrincipal} from "./types";

export interface ReviewProposalInput {
  organizerId: string;
  requestId: string;
  proposalId: string;
  expectedRevision: number;
  decision: "accept" | "reject";
  reason: string;
}

/** Suggestions stay outside the employee-reviewed evidence collection. */
export async function proposeSalesEvidence(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: EvidenceInput,
  now: string,
): Promise<Record<string, unknown>> {
  const account = await tx.get(db.collection("organizerSalesAccounts")
    .doc(input.organizerId));
  if (!account.exists || account.data()?.classification !== "sales_private") {
    throw new HttpsError("not-found", "Sales account not found.");
  }
  if (principal.clientId && input.contactId) {
    throw new HttpsError("permission-denied",
      "Assistant proposals cannot contain contact evidence.");
  }
  if (input.contactId) {
    const relationship = await tx.get(db.collection("salesContactRelationships")
      .doc(salesRelationshipId(input.organizerId, input.contactId)));
    if (!relationship.exists) {
      throw new HttpsError("failed-precondition",
        "Contact evidence requires an existing relationship.");
    }
  }
  if (Date.parse(input.observedAt) > Date.parse(now) ||
      (input.validThrough &&
       Date.parse(input.validThrough) < Date.parse(input.observedAt))) {
    throw new HttpsError("invalid-argument",
      "Evidence dates are inconsistent.");
  }
  if (input.claimKey === "operation" && !input.signalId) {
    throw new HttpsError("invalid-argument",
      "Operating evidence needs a signal.");
  }
  const proposalId = "proposal-" + createHash("sha256")
    .update(`${principal.uid}\u0000${input.requestId}`)
    .digest("hex").slice(0, 24);
  const evidence: Partial<EvidenceInput> = {...input};
  delete evidence.requestId;
  const proposal = {
    schemaVersion: 1, classification: "sales_private", proposalId,
    organizerId: input.organizerId, revision: 1, status: "pending",
    evidence, createdAt: now, createdBy: principal.uid,
    clientId: principal.clientId ?? null,
    clientAuthUid: principal.clientAuthUid ?? null,
    delegationId: principal.delegationId ?? null,
    reviewedAt: null, reviewerUid: null, reviewReason: null,
    promotedEvidenceId: null,
  };
  tx.create(db.collection("salesEvidenceProposals").doc(proposalId), proposal);
  return {proposal};
}

export async function reviewSalesEvidenceProposal(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: ReviewProposalInput,
  now: string,
): Promise<Record<string, unknown>> {
  if (principal.clientId) {
    throw new HttpsError("permission-denied",
      "An employee must review evidence.");
  }
  const ref = db.collection("salesEvidenceProposals").doc(input.proposalId);
  const snap = await tx.get(ref);
  const current = snap.data();
  if (!current || current.classification !== "sales_private" ||
      current.organizerId !== input.organizerId) {
    throw new HttpsError("not-found", "Evidence proposal not found.");
  }
  if (current.revision !== input.expectedRevision) {
    throw new HttpsError("aborted", "Evidence proposal changed since review.");
  }
  if (current.status !== "pending") {
    throw new HttpsError("failed-precondition",
      "Proposal was already reviewed.");
  }
  let promoted: Record<string, unknown> | null = null;
  if (input.decision === "accept") {
    const evidence = current.evidence as Omit<EvidenceInput, "requestId">;
    if (evidence.validThrough && Date.parse(evidence.validThrough) <=
        Date.parse(now)) {
      throw new HttpsError("failed-precondition",
        "Evidence expired; request an updated observation.");
    }
    const result = await addSalesEvidence(tx, db, principal,
      {...evidence, requestId: input.requestId}, now);
    promoted = result.evidence as Record<string, unknown>;
  }
  const proposal = {...current, revision: current.revision + 1,
    status: input.decision === "accept" ? "accepted" : "rejected",
    reviewedAt: now, reviewerUid: principal.uid, reviewReason: input.reason,
    promotedEvidenceId: promoted?.evidenceId ?? null};
  tx.set(ref, proposal);
  return {proposal, evidence: promoted};
}

export async function listSalesEvidenceProposals(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  if (principal.clientId) {
    throw new HttpsError("permission-denied",
      "Proposal review is employee only.");
  }
  const organizerId = input.organizerId as string;
  const limit = Number(input.limit ?? 25);
  let query = db.collection("salesEvidenceProposals")
    .where("organizerId", "==", organizerId)
    .orderBy(admin.firestore.FieldPath.documentId());
  if (input.cursor !== undefined) {
    try {
      const cursor = JSON.parse(Buffer.from(input.cursor as string,
        "base64url").toString("utf8"));
      if (cursor.organizerId !== organizerId ||
          typeof cursor.lastId !== "string" || !cursor.lastId ||
          cursor.lastId.includes("/")) throw new Error();
      query = query.startAfter(cursor.lastId);
    } catch {
      throw new HttpsError("invalid-argument",
        "Proposal cursor scope is invalid.");
    }
  }
  const snapshot = await query.limit(limit + 1).get();
  const page = snapshot.docs.slice(0, limit);
  return {rows: page.map((doc) => doc.data()), nextCursor:
    snapshot.size > limit ? Buffer.from(JSON.stringify({organizerId,
      lastId: page[page.length - 1].id})).toString("base64url") : null};
}
