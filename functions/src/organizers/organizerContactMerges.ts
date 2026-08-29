import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {
  OrganizerContactDocument,
  OrganizerContactIdentityClaimDocument,
  OrganizerContactMergeReceiptDocument,
} from "../shared/generated/firestoreAdminTypes";
import {MergeOrganizerContactsCallablePayload} from
  "../shared/generated/mergeOrganizerContactsCallablePayload";
import {MutateOrganizerContactMergeCallableResponse} from
  "../shared/generated/mutateOrganizerContactMergeCallableResponse";
import {UnmergeOrganizerContactsCallablePayload} from
  "../shared/generated/unmergeOrganizerContactsCallablePayload";
import {
  validateMergeOrganizerContactsCallablePayload,
  validateUnmergeOrganizerContactsCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {AudienceProjectionDeps, rebuildOrganizerContact} from
  "./organizerAudienceProjection";

const maxAtomicMergeDocuments = 400;

interface OrganizerContactMergeDeps extends AudienceProjectionDeps {
  checkRateLimit: typeof checkRateLimit;
}

const defaultDeps: OrganizerContactMergeDeps = {
  firestore: () => admin.firestore(),
  timestamp: () => admin.firestore.Timestamp.now(),
  identitySecret: () => "unused-by-contact-merge".padEnd(32, "_"),
  checkRateLimit,
};

/** Merges a source contact into a survivor with immutable move evidence. */
export async function mergeOrganizerContactsHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactMergeDeps = defaultDeps
): Promise<MutateOrganizerContactMergeCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<MergeOrganizerContactsCallablePayload>(
    request,
    validateMergeOrganizerContactsCallablePayload,
    normalizeMergePayload
  );
  if (data.survivorContactId === data.sourceContactId) {
    throw new HttpsError("invalid-argument", "A contact cannot merge itself.");
  }
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "mergeOrganizerContacts");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const receiptId = mergeReceiptId(
    data.organizerId,
    "merge",
    data.idempotencyKey
  );
  const receiptRef = db.collection("organizerContactMergeReceipts")
    .doc(receiptId);
  const existingReceipt = await receiptRef.get();
  if (existingReceipt.exists) {
    const receipt = receiptDocument(existingReceipt);
    assertReceiptReplay(receipt, data, "merge");
    await rebuildMergedContacts(receipt, receiptId, deps);
    return receiptResponse(receiptId, receipt, true);
  }

  const survivorRef = db.collection("organizerContacts")
    .doc(data.survivorContactId);
  const sourceRef = db.collection("organizerContacts")
    .doc(data.sourceContactId);
  const [
    survivorSnap,
    sourceSnap,
    edgeSnap,
    evidenceSnap,
    claimSnap,
    originSnap,
  ] = await Promise.all([
    survivorRef.get(),
    sourceRef.get(),
    db.collection("organizerContactEventEdges")
      .where("contactId", "==", data.sourceContactId)
      .limit(maxAtomicMergeDocuments + 1).get(),
    db.collection("organizerContactIdentityLinks")
      .where("contactId", "==", data.sourceContactId)
      .limit(maxAtomicMergeDocuments + 1).get(),
    db.collection("organizerContactIdentityClaims")
      .where("verifiedContactId", "==", data.sourceContactId)
      .limit(maxAtomicMergeDocuments + 1).get(),
    db.collection("organizerContactOrigins")
      .where("currentContactId", "==", data.sourceContactId)
      .limit(maxAtomicMergeDocuments + 1).get(),
  ]);
  const survivor = activeContact(survivorSnap, data.organizerId);
  const source = activeContact(sourceSnap, data.organizerId);
  if (survivor.revision !== data.survivorRevision ||
      source.revision !== data.sourceRevision) {
    throw new HttpsError(
      "aborted",
      "Contact data changed. Refresh before merging."
    );
  }
  const totalMoved = edgeSnap.size + evidenceSnap.size + claimSnap.size +
    originSnap.size;
  if (totalMoved > maxAtomicMergeDocuments) {
    throw new HttpsError(
      "resource-exhausted",
      "This contact is too large for an in-app merge. Contact support."
    );
  }
  const conflicts = mergeConflicts(survivor, source);
  if (conflicts.length > 0 && !data.confirmConflicts) {
    throw new HttpsError(
      "failed-precondition",
      `Confirm these identity conflicts: ${conflicts.join(", ")}.`
    );
  }
  const evidence = mergeEvidence(survivor, source);
  const now = deps.timestamp();
  const receipt: OrganizerContactMergeReceiptDocument = {
    organizerId: data.organizerId,
    operation: "merge",
    survivorContactId: data.survivorContactId,
    sourceContactId: data.sourceContactId,
    evidence,
    conflicts,
    actorUid,
    survivorRevision: survivor.revision,
    sourceRevision: source.revision,
    movedEdgeIds: edgeSnap.docs.map((doc) => doc.id),
    movedIdentityEvidenceIds: evidenceSnap.docs.map((doc) => doc.id),
    movedClaimIds: claimSnap.docs.map((doc) => doc.id),
    movedOriginIds: originSnap.docs.map((doc) => doc.id),
    movedEdgeCount: edgeSnap.size,
    movedIdentityEvidenceCount: evidenceSnap.size,
    movedClaimCount: claimSnap.size,
    movedOriginCount: originSnap.size,
    idempotencyKey: data.idempotencyKey,
    reversalOfReceiptId: null,
    createdAt: now,
  };
  const moveDocuments = [
    ...edgeSnap.docs.map((doc) => ({kind: "edge" as const, doc})),
    ...evidenceSnap.docs.map((doc) => ({kind: "evidence" as const, doc})),
    ...claimSnap.docs.map((doc) => ({kind: "claim" as const, doc})),
    ...originSnap.docs.map((doc) => ({kind: "origin" as const, doc})),
  ];
  await db.runTransaction(async (tx) => {
    const [liveReceipt, liveSurvivor, liveSource, ...liveMoves] =
      await Promise.all([
        tx.get(receiptRef),
        tx.get(survivorRef),
        tx.get(sourceRef),
        ...moveDocuments.map((item) => tx.get(item.doc.ref)),
      ]);
    if (liveReceipt.exists) {
      assertReceiptReplay(receiptDocument(liveReceipt), data, "merge");
      return;
    }
    const currentSurvivor = activeContact(liveSurvivor, data.organizerId);
    const currentSource = activeContact(liveSource, data.organizerId);
    if (currentSurvivor.revision !== data.survivorRevision ||
        currentSource.revision !== data.sourceRevision) {
      throw new HttpsError(
        "aborted",
        "Contact data changed. Refresh before merging."
      );
    }
    for (let index = 0; index < moveDocuments.length; index += 1) {
      assertMergeMoveUnchanged(
        moveDocuments[index].kind,
        moveDocuments[index].doc,
        liveMoves[index],
        data.sourceContactId
      );
    }
    for (const document of edgeSnap.docs) {
      tx.update(document.ref, {
        contactId: data.survivorContactId,
        updatedAt: now,
      });
    }
    for (const document of evidenceSnap.docs) {
      tx.update(document.ref, {
        contactId: data.survivorContactId,
        updatedAt: now,
      });
    }
    for (const document of claimSnap.docs) {
      const claim = document.data() as OrganizerContactIdentityClaimDocument;
      tx.update(document.ref, {
        verifiedContactId: data.survivorContactId,
        revision: Math.max(claim.revision + 1, now.toMillis()),
        updatedAt: now,
      });
    }
    for (const document of originSnap.docs) {
      tx.update(document.ref, {currentContactId: data.survivorContactId});
    }
    tx.update(survivorRef, {
      ambiguousCandidateContactIds: [],
      revision: Math.max(currentSurvivor.revision + 1, now.toMillis()),
      updatedAt: now,
    });
    tx.update(sourceRef, {
      identityState: "merged",
      mergedIntoContactId: data.survivorContactId,
      revision: Math.max(currentSource.revision + 1, now.toMillis()),
      updatedAt: now,
      deletedAt: now,
    });
    tx.create(receiptRef, receipt);
  });
  await rebuildMergedContacts(receipt, receiptId, deps);
  return receiptResponse(receiptId, receipt, false);
}

function assertMergeMoveUnchanged(
  kind: "edge" | "evidence" | "claim" | "origin",
  planned: FirebaseFirestore.QueryDocumentSnapshot,
  live: FirebaseFirestore.DocumentSnapshot,
  sourceContactId: string
): void {
  if (!live.exists) {
    throw new HttpsError("aborted", "A contact fact changed. Refresh first.");
  }
  const liveData = live.data() as Record<string, unknown>;
  const contactField = kind === "claim" ? "verifiedContactId" :
    kind === "origin" ? "currentContactId" : "contactId";
  const plannedVersion = planned.updateTime?.toMillis();
  const liveVersion = live.updateTime?.toMillis();
  if (liveData[contactField] !== sourceContactId ||
      plannedVersion === undefined || liveVersion !== plannedVersion) {
    throw new HttpsError("aborted", "A contact fact changed. Refresh first.");
  }
}

/** Reverses exactly the source-origin rows named by a prior merge receipt. */
export async function unmergeOrganizerContactsHandler(
  request: CallableRequest<unknown>,
  deps: OrganizerContactMergeDeps = defaultDeps
): Promise<MutateOrganizerContactMergeCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<UnmergeOrganizerContactsCallablePayload>(
    request,
    validateUnmergeOrganizerContactsCallablePayload,
    normalizeUnmergePayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "unmergeOrganizerContacts");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const mergeReceiptRef = db.collection("organizerContactMergeReceipts")
    .doc(data.mergeReceiptId);
  const reversalId = mergeReversalReceiptId(
    data.organizerId,
    data.mergeReceiptId
  );
  const reversalRef = db.collection("organizerContactMergeReceipts")
    .doc(reversalId);
  const [mergeReceiptSnap, existingReversal] = await Promise.all([
    mergeReceiptRef.get(),
    reversalRef.get(),
  ]);
  const mergeReceipt = receiptDocument(mergeReceiptSnap);
  if (mergeReceipt.organizerId !== data.organizerId ||
      mergeReceipt.operation !== "merge") {
    throw new HttpsError("not-found", "Merge receipt not found.");
  }
  if (existingReversal.exists) {
    const receipt = receiptDocument(existingReversal);
    assertUnmergeReplay(receipt, data, mergeReceipt);
    await rebuildMergedContacts(receipt, reversalId, deps);
    return receiptResponse(reversalId, receipt, true);
  }
  const now = deps.timestamp();
  const reversal: OrganizerContactMergeReceiptDocument = {
    ...mergeReceipt,
    movedOriginIds: mergeReceipt.movedOriginIds ?? [],
    movedOriginCount: mergeReceipt.movedOriginCount ?? 0,
    operation: "unmerge",
    actorUid,
    idempotencyKey: data.idempotencyKey,
    reversalOfReceiptId: data.mergeReceiptId,
    createdAt: now,
  };
  const refs = mergeMoveReferences(db, mergeReceipt);
  await db.runTransaction(async (tx) => {
    const [liveReversal, sourceSnap, ...moveSnaps] = await Promise.all([
      tx.get(reversalRef),
      tx.get(db.collection("organizerContacts")
        .doc(mergeReceipt.sourceContactId)),
      ...refs.map((item) => tx.get(item.ref)),
    ]);
    if (liveReversal.exists) {
      assertUnmergeReplay(
        receiptDocument(liveReversal),
        data,
        mergeReceipt
      );
      return;
    }
    const source = sourceSnap.data() as OrganizerContactDocument | undefined;
    if (!source || source.identityState !== "merged" ||
        source.mergedIntoContactId !== mergeReceipt.survivorContactId) {
      throw new HttpsError(
        "failed-precondition",
        "The source contact changed after this merge."
      );
    }
    for (let index = 0; index < refs.length; index += 1) {
      const item = refs[index];
      const snap = moveSnaps[index];
      assertReversibleMove(item.kind, snap, mergeReceipt);
      tx.update(item.ref, restoredMovePatch(item.kind, snap, now));
    }
    tx.update(db.collection("organizerContacts")
      .doc(mergeReceipt.sourceContactId), {
      identityState: "unlinked",
      mergedIntoContactId: null,
      deletedAt: null,
      revision: Math.max(source.revision + 1, now.toMillis()),
      updatedAt: now,
    });
    tx.create(reversalRef, reversal);
  });
  await rebuildMergedContacts(reversal, reversalId, deps);
  return receiptResponse(reversalId, reversal, false);
}

function mergeMoveReferences(
  db: FirebaseFirestore.Firestore,
  receipt: OrganizerContactMergeReceiptDocument
): Array<{kind: "edge" | "evidence" | "claim" | "origin";
  ref: FirebaseFirestore.DocumentReference}> {
  return [
    ...receipt.movedEdgeIds.map((id) => ({
      kind: "edge" as const,
      ref: db.collection("organizerContactEventEdges").doc(id),
    })),
    ...receipt.movedIdentityEvidenceIds.map((id) => ({
      kind: "evidence" as const,
      ref: db.collection("organizerContactIdentityLinks").doc(id),
    })),
    ...receipt.movedClaimIds.map((id) => ({
      kind: "claim" as const,
      ref: db.collection("organizerContactIdentityClaims").doc(id),
    })),
    ...(receipt.movedOriginIds ?? []).map((id) => ({
      kind: "origin" as const,
      ref: db.collection("organizerContactOrigins").doc(id),
    })),
  ];
}

function assertReversibleMove(
  kind: "edge" | "evidence" | "claim" | "origin",
  snap: FirebaseFirestore.DocumentSnapshot,
  receipt: OrganizerContactMergeReceiptDocument
): void {
  if (!snap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "A merged source fact is missing."
    );
  }
  const data = snap.data() as Record<string, unknown>;
  const current = kind === "claim" ? data.verifiedContactId :
    kind === "origin" ? data.currentContactId : data.contactId;
  const origin = kind === "claim" ? data.originVerifiedContactId :
    data.originContactId;
  if (current !== receipt.survivorContactId ||
      origin !== receipt.sourceContactId) {
    throw new HttpsError(
      "failed-precondition",
      "A merged source fact changed and cannot be safely restored."
    );
  }
}

function restoredMovePatch(
  kind: "edge" | "evidence" | "claim" | "origin",
  snap: FirebaseFirestore.DocumentSnapshot,
  now: FirebaseFirestore.Timestamp
): Record<string, unknown> {
  const data = snap.data() as Record<string, unknown>;
  if (kind === "claim") {
    return {
      verifiedContactId: data.originVerifiedContactId,
      revision: Math.max(Number(data.revision ?? 0) + 1, now.toMillis()),
      updatedAt: now,
    };
  }
  if (kind === "origin") {
    return {currentContactId: data.originContactId};
  }
  return {contactId: data.originContactId, updatedAt: now};
}

function activeContact(
  snap: FirebaseFirestore.DocumentSnapshot,
  organizerId: string
): OrganizerContactDocument {
  const contact = snap.data() as OrganizerContactDocument | undefined;
  if (!contact || contact.organizerId !== organizerId ||
      contact.deletedAt !== null || contact.identityState === "merged") {
    throw new HttpsError("not-found", "Audience contact not found.");
  }
  return contact;
}

export function mergeConflicts(
  survivor: OrganizerContactDocument,
  source: OrganizerContactDocument
): string[] {
  const conflicts = [];
  if (survivor.linkedUid && source.linkedUid &&
      survivor.linkedUid !== source.linkedUid) conflicts.push("linkedUid");
  if (survivor.phoneE164 && source.phoneE164 &&
      survivor.phoneE164 !== source.phoneE164) conflicts.push("phoneE164");
  if (survivor.email && source.email &&
      survivor.email !== source.email) conflicts.push("email");
  return conflicts;
}

export function mergeEvidence(
  survivor: OrganizerContactDocument,
  source: OrganizerContactDocument
): OrganizerContactMergeReceiptDocument["evidence"] {
  const evidence: OrganizerContactMergeReceiptDocument["evidence"] = [
    "managerConfirmed",
  ];
  if (survivor.linkedUid && survivor.linkedUid === source.linkedUid) {
    evidence.push("sameVerifiedUid");
  }
  if (survivor.phoneE164 && survivor.phoneE164 === source.phoneE164) {
    evidence.push(survivor.linkedUid || source.linkedUid ?
      "sameVerifiedPhone" : "sameImportedPhone");
  }
  if (survivor.email && survivor.email === source.email) {
    evidence.push("sameEmail");
  }
  return evidence;
}

async function rebuildMergedContacts(
  receipt: OrganizerContactMergeReceiptDocument,
  receiptId: string,
  deps: OrganizerContactMergeDeps
): Promise<void> {
  await rebuildOrganizerContact(
    receipt.survivorContactId,
    `${receiptId}|survivor`,
    deps
  );
  await rebuildOrganizerContact(
    receipt.sourceContactId,
    `${receiptId}|source`,
    deps
  );
}

function receiptDocument(
  snap: FirebaseFirestore.DocumentSnapshot
): OrganizerContactMergeReceiptDocument {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Merge receipt not found.");
  }
  return snap.data() as OrganizerContactMergeReceiptDocument;
}

function assertReceiptReplay(
  receipt: OrganizerContactMergeReceiptDocument,
  data: MergeOrganizerContactsCallablePayload,
  operation: "merge"
): void {
  if (receipt.operation !== operation ||
      receipt.organizerId !== data.organizerId ||
      receipt.survivorContactId !== data.survivorContactId ||
      receipt.sourceContactId !== data.sourceContactId ||
      receipt.idempotencyKey !== data.idempotencyKey) {
    throw new HttpsError(
      "already-exists",
      "Idempotency key already belongs to another contact merge."
    );
  }
}

function assertUnmergeReplay(
  receipt: OrganizerContactMergeReceiptDocument,
  data: UnmergeOrganizerContactsCallablePayload,
  mergeReceipt: OrganizerContactMergeReceiptDocument
): void {
  if (receipt.operation !== "unmerge" ||
      receipt.organizerId !== data.organizerId ||
      receipt.reversalOfReceiptId !== data.mergeReceiptId ||
      receipt.survivorContactId !== mergeReceipt.survivorContactId ||
      receipt.sourceContactId !== mergeReceipt.sourceContactId) {
    throw new HttpsError(
      "already-exists",
      "Idempotency key already belongs to another unmerge."
    );
  }
}

function receiptResponse(
  receiptId: string,
  receipt: OrganizerContactMergeReceiptDocument,
  replayed: boolean
): MutateOrganizerContactMergeCallableResponse {
  return {
    receiptId,
    operation: receipt.operation,
    survivorContactId: receipt.survivorContactId,
    sourceContactId: receipt.sourceContactId,
    movedEdgeCount: receipt.movedEdgeCount,
    movedIdentityEvidenceCount: receipt.movedIdentityEvidenceCount,
    movedClaimCount: receipt.movedClaimCount,
    movedOriginCount: receipt.movedOriginCount ?? 0,
    replayed,
  };
}

function mergeReceiptId(
  organizerId: string,
  operation: "merge" | "unmerge",
  idempotencyKey: string
): string {
  return `ocmr_${createHash("sha256")
    .update(`${organizerId}|${operation}|${idempotencyKey}`)
    .digest("hex").slice(0, 48)}`;
}

function mergeReversalReceiptId(
  organizerId: string,
  mergeReceiptIdValue: string
): string {
  return `ocmr_${createHash("sha256")
    .update(`${organizerId}|unmerge|${mergeReceiptIdValue}`)
    .digest("hex").slice(0, 48)}`;
}

function normalizeMergePayload(value: unknown): unknown {
  return normalizePayloadStrings(value, [
    "organizerId",
    "survivorContactId",
    "sourceContactId",
    "idempotencyKey",
  ]);
}

function normalizeUnmergePayload(value: unknown): unknown {
  return normalizePayloadStrings(value, [
    "organizerId",
    "mergeReceiptId",
    "idempotencyKey",
  ]);
}

function normalizePayloadStrings(
  value: unknown,
  fields: string[]
): unknown {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const input = {...value} as Record<string, unknown>;
  for (const field of fields) {
    if (typeof input[field] === "string") input[field] = input[field].trim();
  }
  return input;
}

export const mergeOrganizerContacts = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 10}),
  (request) => mergeOrganizerContactsHandler(request)
);

export const unmergeOrganizerContacts = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 10}),
  (request) => unmergeOrganizerContactsHandler(request)
);
