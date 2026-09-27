import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {organizerDraftOperationId} from "../organizerDraftIdentity";
import type {SalesPrincipal} from "../sales/types";
import {linkOrganizerIntakeToSales, type LinkIntakeToSalesInput} from
  "./service";

type Doc = Record<string, unknown>;
class Ref {
  constructor(readonly path: string) {}
}
class Db {
  readonly docs = new Map<string, Doc>();
  private nextId = 0;
  collection(name: string) {
    return {doc: (id?: string) => new Ref(`${name}/${id ??
      `audit-${++this.nextId}`}`)};
  }
  async runTransaction<T>(run: (tx: Tx) => Promise<T>): Promise<T> {
    const tx = new Tx(this);
    const result = await run(tx);
    tx.commit();
    return result;
  }
}
class Tx {
  private writes: Array<{ref: Ref; value: Doc}> = [];
  constructor(readonly db: Db) {}
  async get(ref: Ref) {
    if (this.writes.length) throw new Error("Firestore read after write");
    const data = this.db.docs.get(ref.path);
    return {exists: data !== undefined, data: () =>
      data === undefined ? undefined : structuredClone(data)};
  }
  create(ref: Ref, value: Doc) {
    this.writes.push({ref, value});
  }
  commit() {
    for (const {ref} of this.writes) {
      if (this.db.docs.has(ref.path)) throw new Error("duplicate create");
    }
    for (const {ref, value} of this.writes) {
      this.db.docs.set(ref.path, structuredClone(value));
    }
  }
}
const actor: SalesPrincipal = {uid: "employee-1", roles: ["admin"]};
const hash = "b".repeat(64);
const now = "2026-09-28T00:00:00.000Z";
const normalizedKey = "domain:courtside.example";
const draftId = organizerDraftOperationId(normalizedKey);

function workItem(matches: Array<{entityId: string}> = []) {
  return {schemaVersion: 1, workItemId: "work-1", workflowId: "supply-intake",
    runId: "run-1", entityKind: "organizer", externalKey: "candidate-1",
    revision: 0, candidateHash: hash, primaryStage: "ready",
    lifecycleStatus: "queued", outcome: null, taskFlags: [],
    blockerCodes: [], warningCodes: [], priority: 10, attemptCount: 1,
    evidenceRefs: [], fieldProvenance: [],
    normalizedPayload: {intake: {recordType: "organizer_search_candidate",
      candidate: {candidateId: "candidate-1", normalizedKey,
        canonicalUrl: "https://courtside.example/",
        existingEntityMatches: matches,
        suggestedSurface: {surfaceId: "surface-1",
          normalizedKey: "domain:courtside.example"},
        reviewContext: {verifiedAt: "2026-09-27T00:00:00.000Z"}}}},
    decisionId: null, publicationPlanId: null,
    createdAt: now, updatedAt: now, staleAt: null, expiresAt: null};
}

function fixture(mode: "draft" | "attach" = "draft") {
  const db = new Db();
  db.docs.set("operationWorkItems/work-1", workItem(mode === "attach" ?
    [{entityId: "org-1"}, {entityId: "org-2"}] : []));
  db.docs.set("organizers/org-1", {name: "Courtside", cityName: "Mumbai",
    appVisibility: "hidden", ownership: {state: "programmatic"}});
  const curationId = mode === "draft" ? draftId : "attach-review-1";
  db.docs.set(`organizerIntakeCurationDecisions/${curationId}`, {
    operationId: curationId,
    operationType: mode === "draft" ? "create_entity_draft" :
      "attach_surface",
    operationStatus: "active", sourceCandidateId: "candidate-1",
    sourceWorkItemId: mode === "draft" ? "work-1" : undefined,
    sourceNormalizedKey: mode === "draft" ? normalizedKey : undefined,
    entityId: "org-1", surfaceId: mode === "attach" ? "surface-1" :
      undefined,
    surface: mode === "attach" ? {normalizedKey} : undefined,
    reviewedByUid: "reviewer-1",
    reviewedAt: "2026-09-27T12:00:00.000Z",
  });
  const input: LinkIntakeToSalesInput = {workItemId: "work-1",
    candidateId: "candidate-1", expectedWorkItemRevision: 0,
    expectedCandidateHash: hash, organizerId: "org-1",
    curationPath: `organizerIntakeCurationDecisions/${curationId}`,
    requestId: "intake-link-1"};
  const link = (next = input, principal = actor) =>
    linkOrganizerIntakeToSales(db as unknown as FirebaseFirestore.Firestore,
      principal, next, now);
  return {db, input, link};
}

test("reviewed draft creates private Sales companion and link", async () => {
  const {db, link} = fixture();
  const original = structuredClone(db.docs.get("organizers/org-1"));
  const first = await link();
  assert.equal(first.accountCreated, true);
  assert.equal(first.account.organizerId, "org-1");
  assert.equal(first.link.curationOperationType, "create_entity_draft");
  assert.equal(first.link.sourceCandidateHash, hash);
  assert.deepEqual(db.docs.get("organizers/org-1"), original);
  assert.equal([...db.docs.keys()].some((path) => path.startsWith("clubs/")),
    false);
  const replay = await link();
  assert.equal(replay.accountCreated, false);
  assert.equal(replay.link.linkId, first.link.linkId);
  assert.equal([...db.docs.keys()].filter((path) =>
    path.startsWith("organizerSalesAccounts/")).length, 1);
});

test("existing reviewed match joins existing Sales account", async () => {
  const {db, link} = fixture("attach");
  db.docs.set("organizerSalesAccounts/org-1", {
    classification: "sales_private", organizerId: "org-1",
    researchStatus: "qualified", revision: 4});
  const result = await link();
  assert.equal(result.accountCreated, false);
  assert.equal(result.account.researchStatus, "qualified");
  assert.equal(result.link.curationOperationType, "attach_surface");
  assert.equal(db.docs.get("organizerSalesAccounts/org-1")?.revision, 4);
});

test("stale, wrong-organizer and unreviewed choices fail", async () => {
  const {db, input, link} = fixture("attach");
  await assert.rejects(link({...input, expectedCandidateHash: "c".repeat(64)}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "aborted");
  await assert.rejects(link({...input, organizerId: "org-2"}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
  db.docs.set("organizerIntakeCurationDecisions/attach-review-1", {
    ...db.docs.get("organizerIntakeCurationDecisions/attach-review-1"),
    reviewedByUid: null});
  await assert.rejects(link(),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
  await assert.rejects(link(input, {uid: "support", roles: ["support"]}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "permission-denied");
  assert.equal([...db.docs.keys()].some((path) =>
    path.startsWith("salesIntakeLinks/")), false);
});

test("post-intake partial success resumes without new identity", async () => {
  const {db, link} = fixture();
  db.docs.set("organizerSalesAccounts/org-1", {
    classification: "sales_private", organizerId: "org-1",
    researchStatus: "needs_research", revision: 2});
  const result = await link();
  assert.equal(result.accountCreated, false);
  assert.equal(result.account.researchStatus, "needs_research");
  assert.equal(result.link.curationPath,
    `organizerIntakeCurationDecisions/${draftId}`);
});
