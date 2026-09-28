import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesPrincipal} from "../sales/types";
import {
  appendOpportunityStageHistory,
  commercialQuoteId,
  executeCommercialActionInTransaction,
} from "./service";

type Doc = Record<string, unknown>;
class Ref {
  constructor(
    readonly db: Db,
    readonly path: string,
  ) {}
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
  create(ref: Ref, data: Doc) {
    this.writes.push(() => {
      if (this.db.docs.has(ref.path)) throw new Error("duplicate create");
      this.db.docs.set(ref.path, structuredClone(data));
    });
  }
  set(ref: Ref, data: Doc) {
    this.writes.push(() => this.db.docs.set(ref.path, structuredClone(data)));
  }
  commit() {
    for (const write of this.writes) write();
  }
}
const now = "2026-09-28T00:00:00.000Z";
const employee: SalesPrincipal = {uid: "employee-1", roles: ["admin"]};
function fixture() {
  const db = new Db();
  db.docs.set("organizerSalesAccounts/org-1", {
    classification: "sales_private",
  });
  db.docs.set("organizerSalesAccounts/org-2", {
    classification: "sales_private",
  });
  db.docs.set("salesOpportunities/opp-1", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    stage: "pilot_agreed",
    revision: 1,
  });
  for (const id of [
    "scope",
    "pilot-review",
    "pilot-outcome",
    "approval",
    "acceptance",
  ]) {
    db.docs.set(`salesEvidence/${id}`, {
      classification: "sales_private",
      evidenceId: id,
      organizerId: "org-1",
      reviewerUid: employee.uid,
      sourceRef: `private-source-${id}`,
      observedAt: "2026-09-27T00:00:00.000Z",
      validThrough: null,
    });
  }
  const act = (
    action: Parameters<typeof executeCommercialActionInTransaction>[3],
    payload: unknown,
    principal = employee,
  ) =>
    db.transact((tx) =>
      executeCommercialActionInTransaction(
        tx as unknown as FirebaseFirestore.Transaction,
        db as unknown as FirebaseFirestore.Firestore,
        principal,
        action,
        payload,
        now,
      ),
    );
  return {db, act};
}
const pilot = {
  workflowId: "sample-pilot",
  objective: "Review a sample workflow",
  successMeasures: ["Reviewed outcome"],
  startsAt: now,
  endsAt: "2026-10-01T00:00:00.000Z",
};
const quoteTerms = {
  currency: "INR",
  amountMinor: 120000,
  billingCadence: "one_time",
  scope: "Reviewed sample pilot scope",
  validUntil: "2026-10-01T00:00:00.000Z",
  sourceFactRefs: ["scope"],
};

test("persists pilot, immutable quote and separate acceptance", async () => {
  const {db, act} = fixture();
  await act("commercial.pilots.upsert", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "pilot-draft",
    expectedRevision: 0,
    plan: {
      ...pilot,
      status: "draft",
      reviewEvidence: null,
      outcomeEvidence: null,
    },
  });
  await act("commercial.pilots.upsert", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "pilot-review",
    expectedRevision: 1,
    plan: {
      ...pilot,
      status: "reviewed",
      reviewEvidence: {evidenceId: "pilot-review"},
      outcomeEvidence: null,
    },
  });
  assert.equal(db.docs.get("salesPilotPlans/opp-1")?.revision, 2);
  await act("commercial.quotes.revise", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "quote-v1",
    expectedRevision: 0,
    terms: quoteTerms,
  });
  const quoteId = commercialQuoteId("opp-1");
  assert.equal(db.docs.get(`salesQuoteVersions/${quoteId}-v1`)?.termVersion, 1);
  await act("commercial.quotes.approve", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "approve-v1",
    expectedRevision: 1,
    termVersion: 1,
    evidence: {evidenceId: "approval"},
  });
  await act("commercial.quotes.accept", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "accept-v1",
    expectedRevision: 2,
    termVersion: 1,
    evidence: {evidenceId: "acceptance"},
  });
  const head = db.docs.get(`salesQuotes/${quoteId}`);
  assert.equal(head?.status, "accepted_reviewed");
  assert.equal(head?.revision, 3);
  assert.equal(db.docs.get(`salesQuoteVersions/${quoteId}-v1`)?.termVersion, 1);
  assert.equal(db.docs.get("salesOpportunities/opp-1")?.stage, "pilot_agreed");
  assert.equal(
    db.docs.get(`salesCommercialDecisions/${head?.acceptedDecisionId}`)
      ?.paymentStatus,
    "unknown",
  );
  assert.equal(
    [...db.docs.keys()].filter((key) =>
      key.startsWith("salesCommercialDecisions/"),
    ).length,
    2,
  );
});

test("rejects invalid scope, revision and evidence", async () => {
  const {db, act} = fixture();
  const input = {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "quote-v1",
    expectedRevision: 0,
    terms: quoteTerms,
  };
  await assert.rejects(
    act("commercial.quotes.revise", {...input, organizerId: "org-2"}),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "not-found",
  );
  await assert.rejects(
    act("commercial.quotes.revise", input, {
      uid: "support",
      roles: ["support"],
    }),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  await assert.rejects(
    act("commercial.quotes.revise", input, {
      ...employee,
      clientId: "assistant-client",
    }),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  db.docs.set("salesEvidence/scope", {
    ...db.docs.get("salesEvidence/scope"),
    organizerId: "org-2",
  });
  await assert.rejects(
    act("commercial.quotes.revise", input),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  db.docs.set("salesEvidence/scope", {
    ...db.docs.get("salesEvidence/scope"),
    organizerId: "org-1",
  });
  await act("commercial.quotes.revise", input);
  await assert.rejects(
    act("commercial.quotes.revise", {...input, requestId: "quote-stale"}),
    (error: unknown) => error instanceof HttpsError && error.code === "aborted",
  );
});

test("acceptance needs distinct and current evidence", async () => {
  const {db, act} = fixture();
  await act("commercial.quotes.revise", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "quote-v1",
    expectedRevision: 0,
    terms: quoteTerms,
  });
  await act("commercial.quotes.approve", {
    organizerId: "org-1",
    opportunityId: "opp-1",
    requestId: "approve-v1",
    expectedRevision: 1,
    termVersion: 1,
    evidence: {evidenceId: "approval"},
  });
  await assert.rejects(
    act("commercial.quotes.accept", {
      organizerId: "org-1",
      opportunityId: "opp-1",
      requestId: "bad-accept",
      expectedRevision: 2,
      termVersion: 1,
      evidence: {evidenceId: "approval"},
    }),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  db.docs.set("salesEvidence/scope", {
    ...db.docs.get("salesEvidence/scope"),
    validThrough: "2026-09-27T00:00:00.000Z",
  });
  await assert.rejects(
    act("commercial.quotes.accept", {
      organizerId: "org-1",
      opportunityId: "opp-1",
      requestId: "expired-accept",
      expectedRevision: 2,
      termVersion: 1,
      evidence: {evidenceId: "acceptance"},
    }),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
});

test("stage history requires a reason for loss and reopen", () => {
  const db = new Db();
  const current = {
    organizerId: "org-1",
    opportunityId: "opp-1",
    stage: "commercial_discussion",
  };
  const next = {...current, stage: "closed_lost", stageEnteredAt: now};
  const tx = new Tx(db);
  assert.throws(
    () =>
      appendOpportunityStageHistory(
        tx as unknown as FirebaseFirestore.Transaction,
        db as unknown as FirebaseFirestore.Firestore,
        employee,
        current as never,
        next as never,
        "loss-1",
        null,
      ),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition",
  );
  appendOpportunityStageHistory(
    tx as unknown as FirebaseFirestore.Transaction,
    db as unknown as FirebaseFirestore.Firestore,
    employee,
    current as never,
    next as never,
    "loss-1",
    "No agreed next step",
  );
  tx.commit();
  const histories = [...db.docs.entries()].filter(([key]) =>
    key.startsWith("salesOpportunityStageHistory/"),
  );
  assert.equal(histories.length, 1);
  assert.equal(histories[0][1].reason, "No agreed next step");
});
