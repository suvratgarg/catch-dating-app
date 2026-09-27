import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesPrincipal} from "../sales/types";
import {attestHostSettlementInTransaction, hostSettlementAttestationId,
  validateHostFinanceCloseInTransaction} from "./finance";
import {commercialQuoteId} from "./ids";
import {appendOpportunityStageHistory} from "./service";

type Doc = Record<string, unknown>;
class Ref {
  constructor(readonly db: Db, readonly path: string) {}
}
class Db {
  readonly docs = new Map<string, Doc>();
  collection(name: string) {
    return {doc: (id: string) => new Ref(this, `${name}/${id}`)};
  }
  async transact<T>(run: (tx: Tx) => Promise<T>): Promise<T> {
    const tx = new Tx(this);
    const result = await run(tx);
    tx.commit();
    return result;
  }
}
class Tx {
  private writes: Array<() => void> = [];
  constructor(readonly db: Db) {}
  async get(ref: Ref) {
    if (this.writes.length) throw new Error("Firestore read after write");
    const data = this.db.docs.get(ref.path);
    return {exists: data !== undefined, data: () => structuredClone(data)};
  }
  create(ref: Ref, value: Doc) {
    this.writes.push(() => {
      if (this.db.docs.has(ref.path)) throw new Error("duplicate create");
      this.db.docs.set(ref.path, structuredClone(value));
    });
  }
  commit() {
    for (const write of this.writes) write();
  }
}
const now = "2026-09-28T00:00:00.000Z";
const owner: SalesPrincipal = {uid: "owner-1", roles: ["adminOwner"]};
const input = {organizerId: "org-1", opportunityId: "opp-1",
  requestId: "settlement-1", expectedQuoteRevision: 3, termVersion: 1,
  amountMinor: 120000, currency: "INR", purpose: "host_subscription" as const,
  receivedAt: "2026-09-27T12:00:00.000Z",
  settlementMethod: "bank_transfer" as const,
  servicePeriod: {startsAt: "2026-09-27T00:00:00.000Z",
    endsAt: "2026-10-27T00:00:00.000Z"},
  evidence: {evidenceId: "bank-proof-1"}};
function fixture() {
  const db = new Db();
  const quoteId = commercialQuoteId("opp-1");
  db.docs.set("organizerSalesAccounts/org-1", {
    classification: "sales_private"});
  db.docs.set("salesOpportunities/opp-1", {organizerId: "org-1",
    opportunityId: "opp-1", stage: "commercial_discussion"});
  db.docs.set(`salesQuotes/${quoteId}`, {classification: "sales_private",
    organizerId: "org-1", opportunityId: "opp-1", quoteId, revision: 3,
    termVersion: 1, status: "accepted_reviewed",
    acceptedDecisionId: "acceptance-1"});
  db.docs.set(`salesQuoteVersions/${quoteId}-v1`, {
    classification: "sales_private", organizerId: "org-1",
    opportunityId: "opp-1", quoteId, termVersion: 1,
    termsHash: "a".repeat(64), terms: {amountMinor: 120000,
      currency: "INR", billingCadence: "monthly"}});
  db.docs.set("salesCommercialDecisions/acceptance-1", {
    classification: "sales_private", kind: "terms_acceptance_reviewed",
    organizerId: "org-1", opportunityId: "opp-1", quoteId,
    termVersion: 1, termsHash: "a".repeat(64)});
  db.docs.set("salesEvidence/bank-proof-1", {
    classification: "sales_private", evidenceId: "bank-proof-1",
    organizerId: "org-1", reviewerUid: "reviewer-1",
    sourceType: "first_party", sourceRef: "private-bank-confirmation-1",
    observedAt: "2026-09-27T12:00:00.000Z", validThrough: null});
  db.docs.set("payments/guest-payment-1", {
    kind: "guest_checkout", status: "paid"});
  const attest = (data: typeof input, principal = owner) => db.transact(
    (tx) => attestHostSettlementInTransaction(
      tx as unknown as FirebaseFirestore.Transaction,
      db as unknown as FirebaseFirestore.Firestore, principal, data, now));
  const close = (attestationId: string | null,
    principal = owner) => db.transact(
    (tx) => validateHostFinanceCloseInTransaction(
      tx as unknown as FirebaseFirestore.Transaction,
      db as unknown as FirebaseFirestore.Firestore, principal,
      "org-1", "opp-1", attestationId, now));
  return {db, quoteId, attest, close};
}

test("owner attests host terms without guest payment writes", async () => {
  const {db, quoteId, attest, close} = fixture();
  const result = await attest(input);
  const attestation = result.attestation as Doc;
  const id = hostSettlementAttestationId(quoteId, 1);
  assert.equal(attestation.attestationId, id);
  assert.equal(attestation.providerConfirmed, false);
  assert.equal(attestation.status, "manual_attested_collected");
  const saved = db.docs.get(`salesHostSettlementAttestations/${id}`);
  assert.equal(saved?.amountMinor,
    120000);
  const use = db.docs.get("salesHostSettlementEvidenceUses/bank-proof-1");
  assert.equal(use?.attestationId,
    id);
  assert.equal(db.docs.get("payments/guest-payment-1")?.status, "paid");
  const proof = await close(id);
  assert.equal(proof.attestationId, id);
  await db.transact(async (tx) => {
    const checked = await validateHostFinanceCloseInTransaction(
      tx as unknown as FirebaseFirestore.Transaction,
      db as unknown as FirebaseFirestore.Firestore, owner,
      "org-1", "opp-1", id, now);
    appendOpportunityStageHistory(
      tx as unknown as FirebaseFirestore.Transaction,
      db as unknown as FirebaseFirestore.Firestore, owner,
      {organizerId: "org-1", opportunityId: "opp-1",
        stage: "commercial_discussion"} as never,
      {organizerId: "org-1", opportunityId: "opp-1",
        stage: "closed_won", stageEnteredAt: now} as never,
      "close-won-1", null, checked);
  });
  const history = [...db.docs.entries()].find(([key]) =>
    key.startsWith("salesOpportunityStageHistory/"))?.[1];
  assert.equal(history?.reason, `manual_host_settlement:${id}`);
});

test("finance proof rejects wrong authority, scope or terms", async () => {
  const {db, attest} = fixture();
  await assert.rejects(attest(input, {uid: "staff", roles: ["admin"]}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "permission-denied");
  await assert.rejects(attest({...input, organizerId: "org-2"}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
  await assert.rejects(attest({...input, expectedQuoteRevision: 2}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "aborted");
  await assert.rejects(attest({...input, amountMinor: 100000}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
  db.docs.set("salesEvidence/bank-proof-1", {...db.docs.get(
    "salesEvidence/bank-proof-1"), sourceType: "human_note"});
  await assert.rejects(attest(input),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
});

test("one source cannot be reused and close rechecks proof", async () => {
  const {db, quoteId, attest, close} = fixture();
  await attest(input);
  const id = hostSettlementAttestationId(quoteId, 1);
  await assert.rejects(attest({...input, requestId: "settlement-2"}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "already-exists");
  await assert.rejects(close("guest-payment-1"),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
  await assert.rejects(close(id, {uid: "staff", roles: ["admin"]}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "permission-denied");
  db.docs.set("salesEvidence/bank-proof-1", {...db.docs.get(
    "salesEvidence/bank-proof-1"), sourceRef: "changed-source"});
  await assert.rejects(close(id),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition");
});
