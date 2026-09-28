/* eslint-disable max-len */
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesAccount, SalesPrincipal} from "../sales/types";
import {qualificationPolicyHash} from "../sales/qualificationPolicy";
import {evaluateScore, hash, parsePolicy, type Assessment,
  type IntelligencePolicy} from "../salesIntelligence/model";
import {boundedLimit, decodeCursor, encodeCursor, entryVisible, exactFields,
  failed, identifier, invalid, projectScore, receiptId, stableRequestId,
  viewOf, type FitQueueEntry, type FitQueueView} from "./model";

export interface FitQueueDeps {
  db: FirebaseFirestore.Firestore;
  now: () => Date;
  authorize: (principal: SalesPrincipal) => Promise<void>;
}
const policyPath = "salesIntelligencePolicies/current";
const qualificationPath = "salesSettings/qualificationPolicy";
const metaPath = "salesFitQueueMeta/current";
const maxEvidence = 50;
const pageScan = 100;

function employee(principal: SalesPrincipal): void {
  if (!principal.uid || principal.clientId ||
      !principal.roles.some((role) => role === "admin" || role === "adminOwner")) {
    throw new HttpsError("permission-denied", "A current employee Sales role is required.");
  }
}
function currentPolicy(raw: FirebaseFirestore.DocumentData | undefined): IntelligencePolicy {
  if (raw?.classification !== "sales_private" ||
      raw.policyRecordId !== "current" ||
      !Number.isSafeInteger(raw.revision) || raw.revision < 1) {
    failed("Current reviewed fit policy is unavailable.");
  }
  const parsed = parsePolicy({policyId: raw!.policyId, version: raw!.version,
    status: raw!.status, factors: raw!.factors,
    priorityBands: raw!.priorityBands, promptVersion: raw!.promptVersion,
    playbookVersion: raw!.playbookVersion});
  if (parsed.status !== "active") failed("Reviewed fit policy is paused.");
  return {schemaVersion: 1, classification: "sales_private",
    policyRecordId: "current", revision: raw!.revision,
    updatedAt: raw!.updatedAt, updatedBy: raw!.updatedBy, ...parsed};
}
function currentQualificationHash(raw: FirebaseFirestore.DocumentData | undefined): string | null {
  if (raw?.schemaVersion !== 1 || raw.classification !== "sales_private" ||
      raw.status !== "active" || typeof raw.policyHash !== "string" ||
      !/^[a-f0-9]{64}$/u.test(raw.policyHash) ||
      typeof raw.policyId !== "string" || typeof raw.version !== "string" ||
      !Array.isArray(raw.rules) || raw.rules.length < 1 ||
      raw.rules.length > 8) return null;
  try {
    return qualificationPolicyHash({policyId: raw.policyId,
      version: raw.version, rules: raw.rules}) === raw.policyHash ?
      raw.policyHash : null;
  } catch {
    return null;
  }
}
function generation(raw: FirebaseFirestore.DocumentData | undefined): number {
  const value = raw?.generation ?? 0;
  if (!Number.isSafeInteger(value) || value < 0) {
    failed("Fit queue generation is invalid.");
  }
  return value as number;
}

/** Parent-owned source mutations call this in their existing transaction. */
export function invalidateFitQueueInTransaction(tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore, organizerId: string, now: string): void {
  tx.delete(db.collection("salesFitQueueEntries").doc(organizerId));
  tx.set(db.doc(metaPath), {schemaVersion: 1,
    classification: "sales_private", metaId: "current",
    generation: admin.firestore.FieldValue.increment(1), updatedAt: now},
  {merge: true});
}

function assessmentIdFor(organizerId: string, factorId: string): string {
  return `assess-${hash([organizerId, factorId]).slice(0, 32)}`;
}

export async function refreshFitQueue(deps: FitQueueDeps,
  principal: SalesPrincipal, payload: unknown) {
  employee(principal);
  const input = exactFields(payload,
    ["organizerId", "requestId", "expectedAccountRevision"]);
  const organizerId = identifier(input.organizerId);
  const requestId = stableRequestId(input.requestId);
  const expected = input.expectedAccountRevision;
  if (expected !== undefined && (!Number.isSafeInteger(expected) ||
      (expected as number) < 1)) invalid("Expected account revision is invalid.");
  await deps.authorize(principal);
  const materialHash = hash({organizerId, expected: expected ?? null});
  const receiptRef = deps.db.collection("salesFitQueueReceipts")
    .doc(receiptId(principal.uid, requestId));
  return deps.db.runTransaction(async (tx) => {
    await deps.authorize(principal);
    const prior = (await tx.get(receiptRef)).data();
    if (prior) {
      if (prior.actorUid !== principal.uid || prior.requestId !== requestId ||
          prior.materialHash !== materialHash) {
        throw new HttpsError("already-exists", "Fit refresh request ID has different material.");
      }
      return prior.result as {entry: FitQueueEntry; receipt: {requestId: string; sourceHash: string}};
    }
    const accountRef = deps.db.collection("organizerSalesAccounts").doc(organizerId);
    const [accountSnap, policySnap, qualificationSnap, metaSnap, evidenceSnap] =
      await Promise.all([
        tx.get(accountRef), tx.get(deps.db.doc(policyPath)),
        tx.get(deps.db.doc(qualificationPath)), tx.get(deps.db.doc(metaPath)),
        tx.get(deps.db.collection("salesEvidence")
          .where("organizerId", "==", organizerId).limit(maxEvidence + 1)),
      ]);
    const account = accountSnap.data() as SalesAccount | undefined;
    if (!accountSnap.exists || account?.classification !== "sales_private" ||
        account.organizerId !== organizerId ||
        !Number.isSafeInteger(account.revision)) {
      throw new HttpsError("not-found", "Private Sales account not found.");
    }
    if (expected !== undefined && expected !== account.revision) {
      throw new HttpsError("aborted", "Sales account changed since fit review.");
    }
    if (evidenceSnap.size > maxEvidence) {
      throw new HttpsError("resource-exhausted", "Evidence needs curation before fit refresh.");
    }
    const policy = currentPolicy(policySnap.data());
    const assessmentSnaps = await Promise.all(policy.factors.map((factor) =>
      tx.get(deps.db.collection("salesIntelligenceAssessments")
        .doc(assessmentIdFor(organizerId, factor.id)))));
    const assessments = assessmentSnaps.filter((doc) => doc.exists)
      .map((doc) => doc.data() as Assessment);
    const evidence = evidenceSnap.docs.map((doc) => doc.data());
    const now = deps.now().toISOString();
    const snapshot = evaluateScore(policy, organizerId, account.revision,
      assessments, evidence, now);
    const entry = projectScore(account, policy, snapshot,
      assessments, evidence, currentQualificationHash(qualificationSnap.data()));
    const nextGeneration = generation(metaSnap.data()) + 1;
    tx.set(deps.db.collection("salesFitQueueEntries").doc(organizerId), entry);
    tx.set(deps.db.doc(metaPath), {schemaVersion: 1,
      classification: "sales_private", metaId: "current",
      generation: nextGeneration, updatedAt: now});
    const result = {entry, receipt: {requestId, sourceHash: snapshot.sourceHash}};
    tx.create(receiptRef, {schemaVersion: 1, classification: "sales_private",
      receiptId: receiptRef.id, actorUid: principal.uid, requestId,
      materialHash, result, createdAt: now});
    return result;
  });
}

function queryForView(db: FirebaseFirestore.Firestore, view: FitQueueView,
  policyRevision: number, qualificationHash: string | null): FirebaseFirestore.Query {
  let query: FirebaseFirestore.Query = db.collection("salesFitQueueEntries")
    .where("policyRevision", "==", policyRevision);
  if (view === "needs_research") {
    return query.where("score", "==", null)
      .orderBy(admin.firestore.FieldPath.documentId());
  }
  query = query.where("status", "==", "complete");
  if (view === "outreach_review_candidate") {
    if (qualificationHash === null) failed("Current qualification policy is unavailable.");
    query = query.where("eligibleForOutreachReview", "==", true)
      .where("qualificationPolicyHash", "==", qualificationHash);
  }
  return query.orderBy("score", "desc")
    .orderBy(admin.firestore.FieldPath.documentId());
}

export async function listFitQueue(deps: FitQueueDeps,
  principal: SalesPrincipal, payload: unknown) {
  employee(principal);
  const input = exactFields(payload, ["view", "limit", "cursor"]);
  const view = viewOf(input.view);
  const limit = boundedLimit(input.limit, 25, 25);
  await deps.authorize(principal);
  const [policyBefore, qualificationBefore, metaBefore] = await Promise.all([
    deps.db.doc(policyPath).get(), deps.db.doc(qualificationPath).get(),
    deps.db.doc(metaPath).get()]);
  const policy = currentPolicy(policyBefore.data());
  const qualificationHash = currentQualificationHash(qualificationBefore.data());
  const firstGeneration = generation(metaBefore.data());
  const bound = {view, policyRevision: policy.revision,
    qualificationPolicyHash: qualificationHash, generation: firstGeneration};
  const cursor = decodeCursor(input.cursor, bound);
  let query = queryForView(deps.db, view, policy.revision, qualificationHash);
  if (cursor) {
    query = view === "needs_research" ?
      query.startAfter(cursor.lastId) :
      query.startAfter(cursor.lastScore, cursor.lastId);
  }
  const snapshot = await query.limit(pageScan).get();
  const rows: FitQueueEntry[] = [];
  let last: FirebaseFirestore.QueryDocumentSnapshot | null = null;
  let omittedExpired = 0;
  const now = deps.now().toISOString();
  for (const doc of snapshot.docs) {
    last = doc;
    const entry = doc.data() as FitQueueEntry;
    if (entry.expiresAt !== null && entry.expiresAt <= now) {
      omittedExpired++;
    } else if (entryVisible(entry, view, policy.revision,
      qualificationHash, now)) {
      rows.push(entry);
    }
    if (rows.length === limit) break;
  }
  const [policyAfter, qualificationAfter, metaAfter] = await Promise.all([
    deps.db.doc(policyPath).get(), deps.db.doc(qualificationPath).get(),
    deps.db.doc(metaPath).get()]);
  await deps.authorize(principal);
  const after = currentPolicy(policyAfter.data());
  if (after.revision !== policy.revision ||
      currentQualificationHash(qualificationAfter.data()) !== qualificationHash ||
      generation(metaAfter.data()) !== firstGeneration) {
    throw new HttpsError("aborted", "Fit queue changed; restart at the first page.");
  }
  const mayHaveMore = last !== null &&
    (rows.length === limit || snapshot.size === pageScan);
  return {rows, nextCursor: mayHaveMore ? encodeCursor({...bound,
    lastId: last!.id,
    lastScore: view === "needs_research" ? null : Number(last!.get("score"))}) : null,
  generation: firstGeneration, policyRevision: policy.revision,
  qualificationPolicyHash: qualificationHash,
  omittedExpiredInPage: omittedExpired};
}

export async function refreshFitQueueBatch(deps: FitQueueDeps,
  principal: SalesPrincipal, payload: unknown) {
  employee(principal);
  const input = exactFields(payload, ["requestId", "limit", "cursor"]);
  const requestId = stableRequestId(input.requestId);
  const limit = boundedLimit(input.limit, 10, 10);
  let after: string | null = null;
  if (input.cursor !== undefined) {
    try {
      const parsed = JSON.parse(Buffer.from(String(input.cursor), "base64url")
        .toString("utf8")) as Record<string, unknown>;
      if (Object.keys(parsed).length !== 3 ||
          parsed.requestId !== requestId || parsed.limit !== limit) {
        invalid("Batch cursor does not match its request.");
      }
      after = identifier(parsed.lastId);
    } catch {
      invalid("Batch cursor is invalid.");
    }
  }
  await deps.authorize(principal);
  let query = deps.db.collection("organizerSalesAccounts")
    .orderBy(admin.firestore.FieldPath.documentId());
  if (after) query = query.startAfter(after);
  const page = await query.limit(limit + 1).get();
  const docs = page.docs.slice(0, limit);
  const rows: Array<{organizerId: string; result: "refreshed" | "needs_review";
    sourceHash: string | null; reason: string | null}> = [];
  for (const doc of docs) {
    const hostRequestId = `fitbatch-${hash([requestId, doc.id]).slice(0, 32)}`;
    try {
      const result = await refreshFitQueue(deps, principal,
        {organizerId: doc.id, requestId: hostRequestId});
      rows.push({organizerId: doc.id, result: "refreshed",
        sourceHash: result.entry.sourceHash, reason: null});
    } catch (error) {
      if (!(error instanceof HttpsError) ||
          !["not-found", "failed-precondition", "resource-exhausted"]
            .includes(error.code)) throw error;
      rows.push({organizerId: doc.id, result: "needs_review",
        sourceHash: null, reason: error.message});
    }
  }
  await deps.authorize(principal);
  return {rows, nextCursor: page.size > limit && docs.length ?
    Buffer.from(JSON.stringify({requestId, limit,
      lastId: docs[docs.length - 1].id})).toString("base64url") : null};
}
