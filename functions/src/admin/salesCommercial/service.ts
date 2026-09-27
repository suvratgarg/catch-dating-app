import * as admin from "firebase-admin";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesOpportunity, SalesPrincipal} from "../sales/types";
import {validateCommercialAction, validateCommercialRead} from "./schemas";
import type {
  CommercialAction,
  CommercialDecision,
  CommercialPayload,
  CommercialRead,
  EvidenceReference,
  EvidenceSelection,
  OpportunityStageHistory,
  PilotPlan,
  PilotPlanInput,
  QuoteDecisionInput,
  QuoteHead,
  QuoteReviseInput,
  QuoteVersion,
} from "./types";

const accountCollection = "organizerSalesAccounts";
const opportunityCollection = "salesOpportunities";
const pilotCollection = "salesPilotPlans";
const quoteCollection = "salesQuotes";
const versionCollection = "salesQuoteVersions";
const decisionCollection = "salesCommercialDecisions";
const stageCollection = "salesOpportunityStageHistory";

function sha(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function canonical(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => `${JSON.stringify(key)}:${canonical(child)}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}

export function commercialQuoteId(opportunityId: string): string {
  return `quote-${sha(opportunityId).slice(0, 24)}`;
}

function assertPrincipal(
  principal: SalesPrincipal,
  action: string,
  organizerId: string,
): void {
  if (
    !principal.uid ||
    (!principal.roles.includes("admin") &&
      !principal.roles.includes("adminOwner")) ||
    principal.clientId ||
    (principal.organizerIds && !principal.organizerIds.includes(organizerId)) ||
    (principal.allowedActions && !principal.allowedActions.includes(action))
  ) {
    throw new HttpsError(
      "permission-denied",
      "Current employee commercial authority is required.",
    );
  }
}

function expectRevision(actual: number, expected: number): void {
  if (actual !== expected) {
    throw new HttpsError(
      "aborted",
      `Record changed since review; current revision is ${actual}.`,
    );
  }
}

async function resolveEvidence(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  organizerId: string,
  selected: EvidenceSelection,
  now: string,
): Promise<EvidenceReference> {
  const snap = await tx.get(
    db.collection("salesEvidence").doc(selected.evidenceId),
  );
  const value = snap.data();
  if (
    !snap.exists ||
    value?.classification !== "sales_private" ||
    value?.organizerId !== organizerId ||
    !value?.reviewerUid ||
    Date.parse(value.observedAt) > Date.parse(now) ||
    (value.validThrough && Date.parse(value.validThrough) < Date.parse(now))
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Current reviewed same-host evidence is required.",
    );
  }
  return {
    evidenceId: selected.evidenceId,
    sourceRef: value.sourceRef,
    contentHash: sha(canonical(value)),
    observedAt: value.observedAt,
  };
}

async function requiredOpportunity(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  organizerId: string,
  opportunityId: string,
): Promise<SalesOpportunity> {
  const [account, opportunity] = await Promise.all([
    tx.get(db.collection(accountCollection).doc(organizerId)),
    tx.get(db.collection(opportunityCollection).doc(opportunityId)),
  ]);
  if (
    !account.exists ||
    account.data()?.classification !== "sales_private" ||
    !opportunity.exists ||
    opportunity.data()?.organizerId !== organizerId
  ) {
    throw new HttpsError(
      "not-found",
      "Sales opportunity is not linked to this host.",
    );
  }
  return opportunity.data() as SalesOpportunity;
}

function planMaterial(plan: PilotPlanInput["plan"]): string {
  return canonical({workflowId: plan.workflowId, objective: plan.objective,
    successMeasures: plan.successMeasures, startsAt: plan.startsAt,
    endsAt: plan.endsAt});
}

async function upsertPilot(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: PilotPlanInput,
  now: string,
): Promise<Record<string, unknown>> {
  const ref = db.collection(pilotCollection).doc(input.opportunityId);
  const [opportunity, snap] = await Promise.all([
    requiredOpportunity(tx, db, input.organizerId, input.opportunityId),
    tx.get(ref),
  ]);
  if (
    opportunity.stage === "closed_lost" ||
    opportunity.stage === "closed_won"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Closed opportunity cannot change its pilot plan.",
    );
  }
  const current = snap.exists ? (snap.data() as PilotPlan) : null;
  if (current && current.organizerId !== input.organizerId) {
    throw new HttpsError(
      "failed-precondition",
      "Pilot plan belongs to another host.",
    );
  }
  expectRevision(current?.revision ?? 0, input.expectedRevision);
  const next = input.plan;
  if (
    next.startsAt &&
    next.endsAt &&
    Date.parse(next.startsAt) > Date.parse(next.endsAt)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Pilot end must follow its start.",
    );
  }
  const [reviewEvidence, outcomeEvidence] = await Promise.all([
    next.reviewEvidence ?
      resolveEvidence(tx, db, input.organizerId, next.reviewEvidence, now) :
      Promise.resolve(null),
    next.outcomeEvidence ?
      resolveEvidence(tx, db, input.organizerId, next.outcomeEvidence, now) :
      Promise.resolve(null),
  ]);
  if (next.status !== "draft" && !next.reviewEvidence) {
    throw new HttpsError(
      "failed-precondition",
      "Reviewed pilot plan needs source evidence.",
    );
  }
  if (
    current?.status === "completed" ||
    current?.status === "cancelled" ||
    (current?.status === "active" &&
      !["active", "completed", "cancelled"].includes(next.status))
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Finished or active pilot cannot restart.",
    );
  }
  if (
    (next.status === "active" && current?.status !== "reviewed") ||
    (next.status === "completed" && current?.status !== "active")
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Pilot status requires the prior reviewed step.",
    );
  }
  if (
    ["active", "completed"].includes(next.status) &&
    current &&
    (planMaterial(next) !== planMaterial(current) ||
      reviewEvidence?.evidenceId !== current.reviewEvidence?.evidenceId)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Changed pilot terms need a new draft and review.",
    );
  }
  if (next.status === "completed" && !next.outcomeEvidence) {
    throw new HttpsError(
      "failed-precondition",
      "Completed pilot needs outcome evidence.",
    );
  }
  if (next.status !== "completed" && next.outcomeEvidence) {
    throw new HttpsError(
      "invalid-argument",
      "Outcome evidence belongs to a completed pilot.",
    );
  }
  const pilotPlan: PilotPlan = {
    schemaVersion: 1,
    classification: "sales_private",
    organizerId: input.organizerId,
    opportunityId: input.opportunityId,
    revision: (current?.revision ?? 0) + 1,
    ...next,
    reviewEvidence,
    outcomeEvidence,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  if (current) tx.set(ref, pilotPlan);
  else tx.create(ref, pilotPlan);
  return {pilotPlan};
}

async function verifySourceFacts(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  organizerId: string,
  sourceFactRefs: string[],
  now: string,
): Promise<void> {
  const snapshots = await Promise.all(
    sourceFactRefs.map((id) => tx.get(db.collection("salesEvidence").doc(id))),
  );
  if (
    snapshots.some(
      (snap) =>
        !snap.exists ||
        snap.data()?.organizerId !== organizerId ||
        snap.data()?.classification !== "sales_private" ||
        !snap.data()?.reviewerUid ||
        Date.parse(snap.data()?.observedAt as string) > Date.parse(now) ||
        (snap.data()?.validThrough &&
          Date.parse(snap.data()!.validThrough as string) < Date.parse(now)),
    )
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Quote source facts need current same-host evidence.",
    );
  }
}

async function reviseQuote(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: QuoteReviseInput,
  now: string,
): Promise<Record<string, unknown>> {
  const quoteId = commercialQuoteId(input.opportunityId);
  const ref = db.collection(quoteCollection).doc(quoteId);
  const [opportunity, snap] = await Promise.all([
    requiredOpportunity(tx, db, input.organizerId, input.opportunityId),
    tx.get(ref),
  ]);
  if (["closed_won", "closed_lost"].includes(opportunity.stage)) {
    throw new HttpsError(
      "failed-precondition",
      "Closed opportunity cannot revise commercial terms.",
    );
  }
  const current = snap.exists ? (snap.data() as QuoteHead) : null;
  if (current && current.organizerId !== input.organizerId) {
    throw new HttpsError(
      "failed-precondition",
      "Quote belongs to another host.",
    );
  }
  expectRevision(current?.revision ?? 0, input.expectedRevision);
  if (current?.status === "accepted_reviewed") {
    throw new HttpsError(
      "failed-precondition",
      "Accepted terms require a new opportunity.",
    );
  }
  if (Date.parse(input.terms.validUntil) <= Date.parse(now)) {
    throw new HttpsError(
      "failed-precondition",
      "Quote validity must be in the future.",
    );
  }
  await verifySourceFacts(
    tx,
    db,
    input.organizerId,
    input.terms.sourceFactRefs,
    now,
  );
  const termVersion = (current?.termVersion ?? 0) + 1;
  const quoteVersion: QuoteVersion = {
    schemaVersion: 1,
    classification: "sales_private",
    organizerId: input.organizerId,
    opportunityId: input.opportunityId,
    quoteId,
    termVersion,
    terms: input.terms,
    termsHash: sha(canonical(input.terms)),
    createdAt: now,
    createdBy: principal.uid,
  };
  const quote: QuoteHead = {
    schemaVersion: 1,
    classification: "sales_private",
    organizerId: input.organizerId,
    opportunityId: input.opportunityId,
    quoteId,
    revision: (current?.revision ?? 0) + 1,
    termVersion,
    status: "draft",
    approvedDecisionId: null,
    acceptedDecisionId: null,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  tx.create(
    db.collection(versionCollection).doc(`${quoteId}-v${termVersion}`),
    quoteVersion,
  );
  if (current) tx.set(ref, quote);
  else tx.create(ref, quote);
  return {quote, quoteVersion};
}

async function decideQuote(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  action: "commercial.quotes.approve" | "commercial.quotes.accept",
  input: QuoteDecisionInput,
  now: string,
): Promise<Record<string, unknown>> {
  const quoteId = commercialQuoteId(input.opportunityId);
  const ref = db.collection(quoteCollection).doc(quoteId);
  const [opportunity, snap] = await Promise.all([
    requiredOpportunity(tx, db, input.organizerId, input.opportunityId),
    tx.get(ref),
  ]);
  if (["closed_won", "closed_lost"].includes(opportunity.stage)) {
    throw new HttpsError(
      "failed-precondition",
      "Closed opportunity cannot accept commercial terms.",
    );
  }
  if (!snap.exists || snap.data()?.organizerId !== input.organizerId) {
    throw new HttpsError("not-found", "Quote not found for this host.");
  }
  const current = snap.data() as QuoteHead;
  expectRevision(current.revision, input.expectedRevision);
  if (current.termVersion !== input.termVersion) {
    throw new HttpsError("aborted", "Quote terms changed since review.");
  }
  const versionSnap = await tx.get(
    db.collection(versionCollection).doc(`${quoteId}-v${input.termVersion}`),
  );
  if (
    !versionSnap.exists ||
    versionSnap.data()?.organizerId !== input.organizerId ||
    versionSnap.data()?.opportunityId !== input.opportunityId
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Approved quote version is unavailable.",
    );
  }
  const version = versionSnap.data() as QuoteVersion;
  if (Date.parse(version.terms.validUntil) <= Date.parse(now)) {
    throw new HttpsError("failed-precondition", "Quote expired before review.");
  }
  const evidence = await resolveEvidence(
    tx,
    db,
    input.organizerId,
    input.evidence,
    now,
  );
  const approving = action === "commercial.quotes.approve";
  if (
    (approving && current.status !== "draft") ||
    (!approving &&
      (current.status !== "approved" || !current.approvedDecisionId))
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Quote is not in the required review state.",
    );
  }
  await verifySourceFacts(
    tx,
    db,
    input.organizerId,
    version.terms.sourceFactRefs,
    now,
  );
  let priorApproval: CommercialDecision | null = null;
  if (!approving) {
    const priorSnap = await tx.get(
      db.collection(decisionCollection).doc(current.approvedDecisionId!),
    );
    priorApproval = priorSnap.exists ?
      (priorSnap.data() as CommercialDecision) :
      null;
    if (
      !priorApproval ||
      priorApproval.organizerId !== input.organizerId ||
      priorApproval.opportunityId !== input.opportunityId ||
      priorApproval.quoteId !== quoteId ||
      priorApproval.termVersion !== input.termVersion ||
      priorApproval.termsHash !== version.termsHash ||
      priorApproval.kind !== "quote_approved" ||
      priorApproval.evidence.evidenceId === evidence.evidenceId
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Acceptance needs a distinct reviewed source for the approved terms.",
      );
    }
  }
  const decisionKey = `${principal.uid}\u0000${input.requestId}`;
  const decisionId = `commercial-${sha(decisionKey).slice(0, 24)}`;
  const decision: CommercialDecision = {
    schemaVersion: 1,
    classification: "sales_private",
    decisionId,
    organizerId: input.organizerId,
    opportunityId: input.opportunityId,
    quoteId,
    termVersion: input.termVersion,
    termsHash: version.termsHash,
    kind: approving ? "quote_approved" : "terms_acceptance_reviewed",
    evidence,
    approvedDecisionId: approving ? null : priorApproval!.decisionId,
    actorUid: principal.uid,
    decidedAt: now,
    paymentStatus: "unknown",
  };
  const quote: QuoteHead = {
    ...current,
    revision: current.revision + 1,
    status: approving ? "approved" : "accepted_reviewed",
    approvedDecisionId: approving ? decisionId : current.approvedDecisionId,
    acceptedDecisionId: approving ? null : decisionId,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  tx.create(db.collection(decisionCollection).doc(decisionId), decision);
  tx.set(ref, quote);
  return {quote, decision};
}

/** Called after executeSalesAction's fresh auth and receipt replay check. */
export async function executeCommercialActionInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  action: CommercialAction,
  payload: unknown,
  now: string,
): Promise<Record<string, unknown>> {
  validateCommercialAction(action, payload);
  const input = payload as CommercialPayload;
  assertPrincipal(principal, action, input.organizerId);
  if (action === "commercial.pilots.upsert") {
    return upsertPilot(tx, db, principal, input as PilotPlanInput, now);
  }
  if (action === "commercial.quotes.revise") {
    return reviseQuote(tx, db, principal, input as QuoteReviseInput, now);
  }
  return decideQuote(
    tx,
    db,
    principal,
    action,
    input as QuoteDecisionInput,
    now,
  );
}

/** Generic opportunity upsert must call this before any transaction write. */
export function appendOpportunityStageHistory(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  current: SalesOpportunity | null,
  next: SalesOpportunity,
  requestId: string,
  reason: string | null,
): OpportunityStageHistory | null {
  if (current?.stage === next.stage) return null;
  if (next.stage === "closed_won") {
    throw new HttpsError(
      "failed-precondition",
      "Commercial close requires finance-owned review.",
    );
  }
  if (
    (next.stage === "closed_lost" || current?.stage === "closed_lost") &&
    !reason?.trim()
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Loss or reopen needs a recorded reason.",
    );
  }
  const historyKey = `${principal.uid}\u0000${requestId}`;
  const historyId = `stage-${sha(historyKey).slice(0, 24)}`;
  const history: OpportunityStageHistory = {
    schemaVersion: 1,
    classification: "sales_private",
    historyId,
    organizerId: next.organizerId,
    opportunityId: next.opportunityId,
    fromStage: current?.stage ?? null,
    toStage: next.stage,
    reason: reason?.trim() || null,
    actorUid: principal.uid,
    changedAt: next.stageEnteredAt,
  };
  tx.create(db.collection(stageCollection).doc(historyId), history);
  return history;
}

interface ReportInput {
  organizerId: string;
  limit?: number;
  cursor?: string;
}
interface DetailInput {
  organizerId: string;
  opportunityId: string;
}
function decodeCursor(
  cursor: string | undefined,
  organizerId: string,
  uid: string,
): string | null {
  if (!cursor) return null;
  try {
    const value = JSON.parse(Buffer.from(cursor, "base64url").toString("utf8"));
    if (
      value.v !== 1 ||
      value.organizerId !== organizerId ||
      value.uid !== uid ||
      typeof value.lastId !== "string" ||
      !value.lastId
    ) {
      throw new Error();
    }
    return value.lastId;
  } catch {
    throw new HttpsError(
      "invalid-argument",
      "Commercial report cursor does not match this scope.",
    );
  }
}

/** Called after executeSalesRead checks current auth and organizer scope. */
export async function executeCommercialRead(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  action: CommercialRead,
  payload: unknown,
): Promise<Record<string, unknown>> {
  validateCommercialRead(action, payload);
  const input = payload as ReportInput & DetailInput;
  assertPrincipal(principal, action, input.organizerId);
  if (action === "commercial.detail") {
    const [accountSnap, opportunitySnap, pilotSnap, quoteSnap, historySnap] =
      await Promise.all([
        db.collection(accountCollection).doc(input.organizerId).get(),
        db.collection(opportunityCollection).doc(input.opportunityId).get(),
        db.collection(pilotCollection).doc(input.opportunityId).get(),
        db
          .collection(quoteCollection)
          .doc(commercialQuoteId(input.opportunityId))
          .get(),
        db
          .collection(stageCollection)
          .where("opportunityId", "==", input.opportunityId)
          .orderBy(admin.firestore.FieldPath.documentId())
          .limit(26)
          .get(),
      ]);
    if (
      !accountSnap.exists ||
      accountSnap.data()?.classification !== "sales_private" ||
      !opportunitySnap.exists ||
      opportunitySnap.data()?.organizerId !== input.organizerId
    ) {
      throw new HttpsError(
        "not-found",
        "Commercial opportunity not found for this host.",
      );
    }
    const pilotPlan = pilotSnap.exists ? (pilotSnap.data() as PilotPlan) : null;
    const quote = quoteSnap.exists ? (quoteSnap.data() as QuoteHead) : null;
    if (
      (pilotPlan &&
        (pilotPlan.organizerId !== input.organizerId ||
          pilotPlan.opportunityId !== input.opportunityId)) ||
      (quote &&
        (quote.organizerId !== input.organizerId ||
          quote.opportunityId !== input.opportunityId))
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Commercial record host mismatch.",
      );
    }
    const [quoteVersionSnap, approvedSnap, acceptedSnap] = await Promise.all([
      quote ?
        db
          .collection(versionCollection)
          .doc(`${quote.quoteId}-v${quote.termVersion}`)
          .get() :
        Promise.resolve(null),
      quote?.approvedDecisionId ?
        db.collection(decisionCollection).doc(quote.approvedDecisionId).get() :
        Promise.resolve(null),
      quote?.acceptedDecisionId ?
        db.collection(decisionCollection).doc(quote.acceptedDecisionId).get() :
        Promise.resolve(null),
    ]);
    const scope = (record: FirebaseFirestore.DocumentSnapshot | null) => {
      if (!record?.exists) return null;
      const value = record.data();
      if (
        value?.organizerId !== input.organizerId ||
        value?.opportunityId !== input.opportunityId
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Commercial record host mismatch.",
        );
      }
      return value;
    };
    const history = historySnap.docs.slice(0, 25).map((doc) => scope(doc));
    return {
      opportunity: opportunitySnap.data(),
      pilotPlan,
      quote,
      quoteVersion: scope(quoteVersionSnap),
      approvedDecision: scope(approvedSnap),
      acceptedDecision: scope(acceptedSnap),
      history,
      historyTruncated: historySnap.docs.length > 25,
      paymentStatus: "unknown",
      bookedHostRevenueMinor: null,
    };
  }
  const limit = input.limit ?? 25;
  const lastId = decodeCursor(input.cursor, input.organizerId, principal.uid);
  let query: FirebaseFirestore.Query = db
    .collection(opportunityCollection)
    .where("organizerId", "==", input.organizerId)
    .orderBy(admin.firestore.FieldPath.documentId());
  if (lastId) query = query.startAfter(lastId);
  const snap = await query.limit(limit + 1).get();
  const page = snap.docs.slice(0, limit);
  const rows = await Promise.all(
    page.map(async (doc) => {
      const opportunity = doc.data() as SalesOpportunity;
      const [pilotSnap, quoteSnap] = await Promise.all([
        db.collection(pilotCollection).doc(opportunity.opportunityId).get(),
        db
          .collection(quoteCollection)
          .doc(commercialQuoteId(opportunity.opportunityId))
          .get(),
      ]);
      const pilotPlan = pilotSnap.exists ?
        (pilotSnap.data() as PilotPlan) :
        null;
      const quote = quoteSnap.exists ? (quoteSnap.data() as QuoteHead) : null;
      if (
        (pilotPlan &&
          (pilotPlan.organizerId !== input.organizerId ||
            pilotPlan.opportunityId !== opportunity.opportunityId)) ||
        (quote &&
          (quote.organizerId !== input.organizerId ||
            quote.opportunityId !== opportunity.opportunityId))
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Commercial record host mismatch.",
        );
      }
      return {
        opportunityId: opportunity.opportunityId,
        stage: opportunity.stage,
        ownerUid: opportunity.ownerUid,
        pilotStatus: pilotPlan?.status ?? null,
        pilotRevision: pilotPlan?.revision ?? null,
        quoteStatus: quote?.status ?? null,
        quoteRevision: quote?.revision ?? null,
        termVersion: quote?.termVersion ?? null,
        paymentStatus: "unknown",
        bookedHostRevenueMinor: null,
      };
    }),
  );
  const hasMore = snap.docs.length > limit;
  const nextCursor =
    hasMore && page.length ?
      Buffer.from(
        JSON.stringify({
          v: 1,
          organizerId: input.organizerId,
          uid: principal.uid,
          lastId: page.at(-1)!.id,
        }),
      ).toString("base64url") :
      null;
  return {rows, nextCursor, pageScope: true};
}
