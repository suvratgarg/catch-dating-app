import {invalidateFitQueueInTransaction} from "../salesFitQueue/service";
import * as admin from "firebase-admin";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesPrincipal} from "./types";

export interface ContactInput {
  organizerId: string;
  requestId: string;
  contactId?: string;
  expectedRevision: number;
  linkExisting?: boolean;
  contact: { displayName: string };
  relationship: {
    role: string;
    decisionInfluence: "unknown" | "decision_maker" | "influencer" | "operator";
    primary: boolean;
    endpoints?: Array<{
      kind: "email" | "phone";
      value: string;
      verificationStatus: "unverified" | "verified";
      evidenceId?: string | null;
    }>;
  };
}

export interface EvidenceInput {
  organizerId: string;
  contactId?: string | null;
  requestId: string;
  claimKey: "identity" | "recurrence" | "operation" | "stack" | "other";
  signalId?: string;
  sourceType: "first_party" | "public_web" | "human_note" | "import_artifact";
  sourceRef: string;
  observedAt: string;
  validThrough?: string | null;
  confidence: "high" | "medium" | "low";
  normalizedValue?: string | null;
  excerpt?: string | null;
}

function digest(value: string): string {
  return createHash("sha256").update(value).digest("hex").slice(0, 24);
}

export function salesRelationshipId(
  organizerId: string,
  contactId: string,
): string {
  return `relationship-${digest(`${organizerId}\u0000${contactId}`)}`;
}

export async function upsertSalesContact(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: ContactInput,
  now: string,
): Promise<Record<string, unknown>> {
  const contactId =
    input.contactId ??
    `contact-${digest(`${principal.uid}\u0000${input.requestId}`)}`;
  const relationshipId = salesRelationshipId(input.organizerId, contactId);
  const accountRef = db
    .collection("organizerSalesAccounts")
    .doc(input.organizerId);
  const contactRef = db.collection("salesContacts").doc(contactId);
  const relationshipRef = db
    .collection("salesContactRelationships")
    .doc(relationshipId);
  const [accountSnap, contactSnap, relationshipSnap] = await Promise.all([
    tx.get(accountRef),
    tx.get(contactRef),
    tx.get(relationshipRef),
  ]);
  if (
    !accountSnap.exists ||
    accountSnap.data()?.classification !== "sales_private"
  ) {
    throw new HttpsError("not-found", "Sales account not found.");
  }
  const current = relationshipSnap.exists ?
    (relationshipSnap.data() ?? {}) :
    null;
  if (Number(current?.revision ?? 0) !== input.expectedRevision) {
    throw new HttpsError(
      "aborted",
      "Contact relationship changed since review.",
    );
  }
  if (
    contactSnap.exists &&
    !relationshipSnap.exists &&
    (!input.linkExisting || principal.clientId)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "An existing shared contact requires explicit employee linking.",
    );
  }
  if (
    contactSnap.exists &&
    contactSnap.data()?.displayName !== input.contact.displayName
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Shared contact identity differs; review the existing person first.",
    );
  }
  if (
    principal.readEndpoints === false &&
    input.relationship.endpoints !== undefined
  ) {
    throw new HttpsError(
      "permission-denied",
      "Endpoint changes are outside delegated Sales scope.",
    );
  }
  if (!contactSnap.exists) {
    tx.create(contactRef, {
      schemaVersion: 1,
      classification: "sales_private",
      contactId,
      displayName: input.contact.displayName,
      revision: 1,
      createdAt: now,
      updatedAt: now,
      createdBy: principal.uid,
    });
  }
  const relationship = {
    schemaVersion: 1,
    classification: "sales_private",
    relationshipId,
    contactId,
    organizerId: input.organizerId,
    revision: input.expectedRevision + 1,
    role: input.relationship.role,
    decisionInfluence: input.relationship.decisionInfluence,
    primary: input.relationship.primary,
    contactabilityStatus:
      input.relationship.endpoints !== undefined ?
        "unknown" :
        (current?.contactabilityStatus ?? "unknown"),
    contactabilityReason:
      input.relationship.endpoints !== undefined ?
        "endpoints_changed" :
        (current?.contactabilityReason ?? null),
    contactabilityAt:
      input.relationship.endpoints !== undefined ?
        now :
        (current?.contactabilityAt ?? null),
    contactabilityBy:
      input.relationship.endpoints !== undefined ?
        principal.uid :
        (current?.contactabilityBy ?? null),
    draftReviewEvidenceId:
      input.relationship.endpoints !== undefined ?
        null :
        (current?.draftReviewEvidenceId ?? null),
    sendAuthority: false,
    endpoints: input.relationship.endpoints ?? current?.endpoints ?? [],
    createdAt: current?.createdAt ?? now,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  tx.set(relationshipRef, relationship);
  return {
    contact: {contactId, displayName: input.contact.displayName},
    relationship: projectRelationship(relationship, principal),
  };
}

export async function addSalesEvidence(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: EvidenceInput,
  now: string,
): Promise<Record<string, unknown>> {
  const accountSnap = await tx.get(
    db.collection("organizerSalesAccounts").doc(input.organizerId),
  );
  if (
    !accountSnap.exists ||
    accountSnap.data()?.classification !== "sales_private"
  ) {
    throw new HttpsError("not-found", "Sales account not found.");
  }
  if (input.contactId) {
    const relationshipRef = db
      .collection("salesContactRelationships")
      .doc(salesRelationshipId(input.organizerId, input.contactId));
    const relationshipSnap = await tx.get(relationshipRef);
    if (
      !relationshipSnap.exists ||
      relationshipSnap.data()?.contactId !== input.contactId
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Contact evidence requires an existing organizer relationship.",
      );
    }
  }
  if (input.claimKey === "operation" && !input.signalId) {
    throw new HttpsError(
      "invalid-argument",
      "Operating evidence needs a distinct signal id.",
    );
  }
  if (
    input.validThrough &&
    Date.parse(input.validThrough) < Date.parse(input.observedAt)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Evidence validity cannot end before observation.",
    );
  }
  const evidenceKey = `${principal.uid}\u0000${input.requestId}`;
  const evidenceId = `evidence-${digest(evidenceKey)}`;
  const evidence = {
    schemaVersion: 1,
    classification: "sales_private",
    evidenceId,
    organizerId: input.organizerId,
    contactId: input.contactId ?? null,
    claimKey: input.claimKey,
    signalId: input.signalId ?? null,
    sourceType: input.sourceType,
    sourceRef: input.sourceRef,
    observedAt: input.observedAt,
    validThrough: input.validThrough ?? null,
    confidence: input.confidence,
    normalizedValue: input.normalizedValue ?? null,
    excerpt: input.excerpt ?? null,
    reviewedAt: now,
    reviewerUid: principal.uid,
    createdAt: now,
    createdBy: principal.uid,
  };
  tx.create(db.collection("salesEvidence").doc(evidenceId), evidence);
  invalidateFitQueueInTransaction(tx, db, input.organizerId, now);
  return {evidence};
}

export async function listSalesContacts(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const organizerId = input.organizerId as string;
  const limit = Number(input.limit ?? 25);
  let query: FirebaseFirestore.Query = db
    .collection("salesContactRelationships")
    .where("organizerId", "==", organizerId)
    .orderBy(admin.firestore.FieldPath.documentId());
  const cursor = decodeCursor(input.cursor, organizerId);
  if (cursor) query = query.startAfter(cursor);
  const snap = await query.limit(limit + 1).get();
  const page = snap.docs.slice(0, limit);
  const contacts = await Promise.all(
    page.map(async (doc) => {
      const relationship = doc.data();
      const contactSnap = await db
        .collection("salesContacts")
        .doc(relationship.contactId)
        .get();
      if (
        !contactSnap.exists ||
        contactSnap.data()?.classification !== "sales_private"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Shared contact is missing.",
        );
      }
      return {
        contactId: relationship.contactId,
        displayName: contactSnap.data()?.displayName,
        relationship: projectRelationship(relationship, principal),
      };
    }),
  );
  return {
    rows: contacts,
    nextCursor:
      snap.size > limit ?
        encodeCursor(page[page.length - 1].id, organizerId) :
        null,
  };
}

export async function listSalesEvidence(
  db: FirebaseFirestore.Firestore,
  input: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const organizerId = input.organizerId as string;
  const limit = Number(input.limit ?? 25);
  let query: FirebaseFirestore.Query = db
    .collection("salesEvidence")
    .where("organizerId", "==", organizerId)
    .orderBy(admin.firestore.FieldPath.documentId());
  const cursor = decodeCursor(input.cursor, organizerId);
  if (cursor) query = query.startAfter(cursor);
  const snap = await query.limit(limit + 1).get();
  const page = snap.docs.slice(0, limit);
  return {
    rows: page.map((doc) => doc.data()),
    nextCursor:
      snap.size > limit ?
        encodeCursor(page[page.length - 1].id, organizerId) :
        null,
  };
}

function projectRelationship(
  value: Record<string, unknown>,
  principal: SalesPrincipal,
): Record<string, unknown> {
  if (principal.readEndpoints !== false) return value;
  const safe = {...value};
  delete safe.endpoints;
  return safe;
}

function encodeCursor(lastId: string, organizerId: string): string {
  return Buffer.from(JSON.stringify({lastId, organizerId})).toString(
    "base64url",
  );
}

function decodeCursor(cursor: unknown, organizerId: string): string | null {
  if (cursor === undefined) return null;
  try {
    const parsed = JSON.parse(
      Buffer.from(cursor as string, "base64url").toString("utf8"),
    ) as { lastId: unknown; organizerId: unknown };
    if (
      parsed.organizerId !== organizerId ||
      typeof parsed.lastId !== "string"
    ) {
      throw new Error();
    }
    return parsed.lastId;
  } catch {
    throw new HttpsError("invalid-argument", "Sales cursor scope is invalid.");
  }
}
