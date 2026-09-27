/* eslint-disable max-len */
import * as admin from "firebase-admin";
import {hasCurrentDraftContact} from "../sales/suppression";
import {salesRelationshipId} from "../sales/records";
import {assertQualifiedByRuntimePolicy} from "../sales/qualificationPolicy";
import type {SalesPrincipal} from "../sales/types";
import {Assessment, Clause, IntelligencePolicy, ScoreSnapshot,
  evaluateScore, fail, hash, id, iso, object, parsePolicy, requestId,
  revision, text, uniqueIds} from "./model";

export interface IntelligenceDeps {
  db: FirebaseFirestore.Firestore;
  now: () => Date;
  authorize: (principal: SalesPrincipal, owner: boolean) => Promise<void>;
}
const POLICY_REF = "salesIntelligencePolicies/current";
const MAX_EVIDENCE = 50;

function employee(principal: SalesPrincipal): void {
  if (principal.clientId || !principal.roles.some((role) =>
    role === "admin" || role === "adminOwner")) {
    fail("permission-denied", "An employee Sales role is required.");
  }
}
function owner(principal: SalesPrincipal): void {
  employee(principal);
  if (!principal.roles.includes("adminOwner")) {
    fail("permission-denied", "Admin Owner review is required.");
  }
}
function receiptId(principal: SalesPrincipal, action: string,
  request: string): string {
  return `intel-${hash([principal.uid, action, request]).slice(0, 32)}`;
}
function assessmentIdFor(organizerId: string, factorId: string): string {
  return `assess-${hash([organizerId, factorId]).slice(0, 32)}`;
}
async function mutate<T extends Record<string, unknown>>(
  deps: IntelligenceDeps, principal: SalesPrincipal, action: string,
  request: string, material: unknown, ownerOnly: boolean,
  apply: (tx: FirebaseFirestore.Transaction, now: string) => Promise<T>,
  replayGuard?: (tx: FirebaseFirestore.Transaction) => Promise<void>,
): Promise<T> {
  (ownerOnly ? owner : employee)(principal);
  await deps.authorize(principal, ownerOnly);
  const db = deps.db;
  const ref = db.collection("salesIntelligenceReceipts")
    .doc(receiptId(principal, action, request));
  const materialHash = hash([principal.uid, action, material]);
  return db.runTransaction(async (tx) => {
    await deps.authorize(principal, ownerOnly);
    if (replayGuard) await replayGuard(tx);
    const existing = await tx.get(ref);
    if (existing.exists) {
      const data = existing.data();
      if (data?.materialHash !== materialHash || data?.actorUid !== principal.uid ||
          data?.action !== action) {
        return fail("already-exists", "Request ID belongs to different material.");
      }
      return data.result as T;
    }
    const now = deps.now().toISOString();
    const result = await apply(tx, now);
    tx.create(ref, {schemaVersion: 1, classification: "sales_private",
      receiptId: ref.id, actorUid: principal.uid, action, requestId: request,
      materialHash, result, createdAt: now});
    tx.create(db.collection("adminAuditLogs").doc(`sales_intelligence_${ref.id}`),
      {action: `salesIntelligence.${action}`, actorUid: principal.uid,
        roles: [...principal.roles],
        targetPath: "salesIntelligenceReceipts/" + ref.id,
        createdAt: admin.firestore.Timestamp.fromDate(new Date(now)),
        after: {receiptId: ref.id, materialHash}});
    return result;
  });
}
function accountOk(row: FirebaseFirestore.DocumentData | undefined,
  organizerId: string): boolean {
  return row?.classification === "sales_private" &&
    row.organizerId === organizerId && Number.isInteger(row.revision);
}
function currentReviewedEvidence(row: FirebaseFirestore.DocumentData | undefined,
  organizerId: string, now: string): boolean {
  const at = Date.parse(now);
  const observed = Date.parse(String(row?.observedAt ?? ""));
  const reviewed = Date.parse(String(row?.reviewedAt ?? ""));
  return row?.classification === "sales_private" &&
    row.organizerId === organizerId &&
    typeof row.reviewerUid === "string" && row.reviewerUid.length > 0 &&
    Number.isFinite(observed) && observed <= at &&
    Number.isFinite(reviewed) && reviewed <= at &&
    (!row.validThrough ||
      (Number.isFinite(Date.parse(row.validThrough)) &&
        Date.parse(row.validThrough) > at));
}
async function requireAccount(tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore, organizerId: string) {
  const snap = await tx.get(db.collection("organizerSalesAccounts").doc(organizerId));
  if (!snap.exists || !accountOk(snap.data(), organizerId)) {
    return fail("not-found", "Private Sales account not found.");
  }
  return snap.data()!;
}
function requireCurrentPolicy(raw: FirebaseFirestore.DocumentData | undefined): IntelligencePolicy {
  if (!raw || raw.classification !== "sales_private" ||
      raw.policyRecordId !== "current" || !Number.isInteger(raw.revision)) {
    return fail("failed-precondition", "Versioned intelligence policy is unavailable.");
  }
  const policyRevision = raw.revision as number;
  const updatedAt = raw.updatedAt as string;
  const updatedBy = raw.updatedBy as string;
  const material = {policyId: raw.policyId, version: raw.version,
    status: raw.status, factors: raw.factors,
    priorityBands: raw.priorityBands,
    promptVersion: raw.promptVersion,
    playbookVersion: raw.playbookVersion};
  const parsed = parsePolicy(material);
  return {schemaVersion: 1, classification: "sales_private",
    policyRecordId: "current",
    revision: policyRevision, updatedAt, updatedBy, ...parsed};
}

export async function saveIntelligencePolicy(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "expectedRevision", "policy"]);
  const request = requestId(input.requestId);
  const expectedRevision = revision(input.expectedRevision);
  const policy = parsePolicy(input.policy);
  return mutate(deps, principal, "policy.save", request,
    {expectedRevision, policy}, true, async (tx, now) => {
      const ref = deps.db.doc(POLICY_REF);
      const snap = await tx.get(ref);
      if (Number(snap.data()?.revision ?? 0) !== expectedRevision) {
        return fail("aborted", "Intelligence policy changed since review.");
      }
      const next: IntelligencePolicy = {schemaVersion: 1,
        classification: "sales_private", policyRecordId: "current", ...policy,
        revision: expectedRevision + 1, updatedAt: now,
        updatedBy: principal.uid};
      tx.set(ref, next);
      return {policy: next};
    });
}

export async function saveFactorAssessment(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "organizerId", "factorId",
    "expectedRevision", "state", "value", "evidenceIds", "reason"]);
  const request = requestId(input.requestId);
  const organizerId = id(input.organizerId);
  const factorId = id(input.factorId);
  const expectedRevision = revision(input.expectedRevision);
  const state = input.state;
  const evidenceIds = uniqueIds(input.evidenceIds, 8);
  const value = input.value;
  const reason = input.reason === null ? null : text(input.reason, 240);
  if (!["known", "unknown", "disputed"].includes(String(state)) ||
      (state === "known" && (!Number.isInteger(value) || (value as number) < 0 ||
        (value as number) > 5 || evidenceIds.length === 0 || reason !== null)) ||
      (state !== "known" && (value !== null || !reason))) {
    return fail("invalid-argument", "Assessment needs reviewed evidence or an explicit gap.");
  }
  return mutate(deps, principal, "assessment.save", request,
    {organizerId, factorId, expectedRevision, state, value, evidenceIds, reason},
    false, async (tx, now) => {
      await requireAccount(tx, deps.db, organizerId);
      const policy = requireCurrentPolicy((await tx.get(deps.db.doc(POLICY_REF))).data());
      const factor = policy.factors.find((row) => row.id === factorId);
      if (!factor || policy.status !== "active") {
        return fail("failed-precondition", "Factor is not in the current policy.");
      }
      for (const evidenceId of evidenceIds) {
        const evidence = (await tx.get(deps.db.collection("salesEvidence").doc(evidenceId))).data();
        if (!currentReviewedEvidence(evidence, organizerId, now) ||
            !factor.claimKeys.includes(evidence?.claimKey) ||
            Date.parse(evidence?.observedAt) < Date.parse(now) -
              factor.maxAgeDays * 86_400_000) {
          return fail("failed-precondition", "Assessment source is not reviewed Sales evidence.");
        }
      }
      const assessmentId = assessmentIdFor(organizerId, factorId);
      const ref = deps.db.collection("salesIntelligenceAssessments").doc(assessmentId);
      if (Number((await tx.get(ref)).data()?.revision ?? 0) !== expectedRevision) {
        return fail("aborted", "Assessment changed since review.");
      }
      const assessment: Assessment = {schemaVersion: 1,
        classification: "sales_private", assessmentId, organizerId, factorId,
        revision: expectedRevision + 1, state: state as Assessment["state"],
        value: value as number | null, evidenceIds, reason,
        reviewedAt: now, reviewerUid: principal.uid};
      tx.set(ref, assessment);
      return {assessment};
    });
}

export async function getIntelligenceScore(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<{snapshot: ScoreSnapshot}> {
  employee(principal);
  const input = object(payload, ["organizerId"]);
  const organizerId = id(input.organizerId);
  await deps.authorize(principal, false);
  const db = deps.db;
  const [accountSnap, policySnap, evidenceSnap] = await Promise.all([
    db.collection("organizerSalesAccounts").doc(organizerId).get(),
    db.doc(POLICY_REF).get(),
    db.collection("salesEvidence").where("organizerId", "==", organizerId).limit(MAX_EVIDENCE + 1).get(),
  ]);
  await deps.authorize(principal, false);
  if (!accountSnap.exists || !accountOk(accountSnap.data(), organizerId)) {
    return fail("not-found", "Private Sales account not found.");
  }
  if (evidenceSnap.size > MAX_EVIDENCE) {
    return fail("resource-exhausted", "Evidence must be curated before scoring.");
  }
  const policy = requireCurrentPolicy(policySnap.data());
  const assessments = await Promise.all(policy.factors.map((factor) =>
    db.collection("salesIntelligenceAssessments")
      .doc(assessmentIdFor(organizerId, factor.id)).get()));
  await deps.authorize(principal, false);
  const snapshot = evaluateScore(policy, organizerId,
    accountSnap.data()!.revision as number,
    assessments.filter((doc) => doc.exists).map((doc) => doc.data() as Assessment),
    evidenceSnap.docs.map((doc) => doc.data()), deps.now().toISOString());
  return {snapshot};
}

/** Bounded, private current catalog for selecting reviewed evidence and prose. */
export async function getIntelligenceCatalog(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<Record<string, unknown>> {
  employee(principal);
  const input = object(payload, ["organizerId"]);
  const organizerId = id(input.organizerId);
  await deps.authorize(principal, false);
  const db = deps.db;
  const [account, policySnap, clauseSnap] = await Promise.all([
    db.collection("organizerSalesAccounts").doc(organizerId).get(),
    db.doc(POLICY_REF).get(),
    db.collection("salesIntelligenceClauses")
      .where("organizerId", "==", organizerId).limit(51).get(),
  ]);
  await deps.authorize(principal, false);
  if (!accountOk(account.data(), organizerId)) {
    return fail("not-found", "Private Sales account not found.");
  }
  if (clauseSnap.size > 50) {
    return fail("resource-exhausted", "Private catalog needs curation before review.");
  }
  const policy = policySnap.exists ? requireCurrentPolicy(policySnap.data()) : null;
  const assessmentSnaps = policy ? await Promise.all(policy.factors.map((factor) =>
    db.collection("salesIntelligenceAssessments")
      .doc(assessmentIdFor(organizerId, factor.id)).get())) : [];
  await deps.authorize(principal, false);
  const assessments = assessmentSnaps.filter((doc) => doc.exists)
    .map((doc) => doc.data() as Assessment);
  const clauses = clauseSnap.docs.map((doc) => doc.data() as Clause);
  if (assessments.some((row) => row.classification !== "sales_private" ||
      row.organizerId !== organizerId ||
      (policy && !policy.factors.some((factor) => factor.id === row.factorId))) ||
      clauses.some((row) => row.classification !== "sales_private" ||
        row.organizerId !== organizerId)) {
    return fail("failed-precondition", "Private catalog contains invalid records.");
  }
  await deps.authorize(principal, false);
  return {policy, assessments: assessments.map((row) => ({
    schemaVersion: 1, classification: "sales_private", assessmentId: row.assessmentId,
    organizerId: row.organizerId, factorId: row.factorId, revision: row.revision,
    state: row.state, value: row.value, evidenceIds: row.evidenceIds,
    reason: row.reason, reviewedAt: row.reviewedAt, reviewerUid: row.reviewerUid,
  })).sort((a, b) => a.factorId.localeCompare(b.factorId)),
  clauses: clauses.map((row) => ({schemaVersion: 1,
    classification: "sales_private", clauseId: row.clauseId,
    organizerId: row.organizerId, revision: row.revision, kind: row.kind,
    text: row.text, state: row.state, evidenceIds: row.evidenceIds,
    validUntil: row.validUntil, permission: row.permission,
    reviewedAt: row.reviewedAt, reviewedBy: row.reviewedBy,
    updatedAt: row.updatedAt, updatedBy: row.updatedBy,
  })).sort((a, b) => a.clauseId.localeCompare(b.clauseId)),
  evaluatedAt: deps.now().toISOString()};
}

/** An intentionally capped organizer list; full drafts require current-source get. */
export async function listOutreachDrafts(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<Record<string, unknown>> {
  employee(principal);
  const input = object(payload, ["organizerId"]);
  const organizerId = id(input.organizerId);
  await deps.authorize(principal, false);
  const [account, draftsSnap] = await Promise.all([
    deps.db.collection("organizerSalesAccounts").doc(organizerId).get(),
    deps.db.collection("salesOutreachDrafts")
      .where("organizerId", "==", organizerId).limit(51).get(),
  ]);
  await deps.authorize(principal, false);
  if (!accountOk(account.data(), organizerId)) {
    return fail("not-found", "Private Sales account not found.");
  }
  if (draftsSnap.size > 50) {
    return fail("resource-exhausted", "Draft list needs curation before review.");
  }
  const rows = draftsSnap.docs.map((doc) => doc.data());
  if (rows.some((row) => row.classification !== "sales_private" ||
      row.organizerId !== organizerId || typeof row.draftId !== "string" ||
      typeof row.draft?.contentHash !== "string" ||
      typeof row.createdAt !== "string")) {
    return fail("failed-precondition", "Private draft list contains invalid records.");
  }
  await deps.authorize(principal, false);
  return {rows: rows.map((row) => ({draftId: row.draftId,
    contactId: row.contactId, opportunityId: row.opportunityId,
    subject: row.draft.subject, status: row.status,
    contentHash: row.draft.contentHash, createdAt: row.createdAt,
    reviewedAt: row.reviewedAt})).sort((a, b) =>
    b.createdAt.localeCompare(a.createdAt) || a.draftId.localeCompare(b.draftId))};
}

export async function saveScoreSnapshot(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "organizerId",
    "expectedAccountRevision", "expectedPolicyRevision"]);
  const request = requestId(input.requestId);
  const organizerId = id(input.organizerId);
  const expectedAccountRevision = revision(input.expectedAccountRevision);
  const expectedPolicyRevision = revision(input.expectedPolicyRevision);
  return mutate(deps, principal, "score.snapshot", request,
    {organizerId, expectedAccountRevision, expectedPolicyRevision},
    false, async (tx, now) => {
      const db = deps.db;
      const account = await requireAccount(tx, db, organizerId);
      const policy = requireCurrentPolicy((await tx.get(db.doc(POLICY_REF))).data());
      if (account.revision !== expectedAccountRevision ||
          policy.revision !== expectedPolicyRevision) {
        return fail("aborted", "Reviewed score sources changed.");
      }
      const [assessmentSnaps, evidence] = await Promise.all([
        Promise.all(policy.factors.map((factor) =>
          tx.get(db.collection("salesIntelligenceAssessments")
            .doc(assessmentIdFor(organizerId, factor.id))))),
        tx.get(db.collection("salesEvidence")
          .where("organizerId", "==", organizerId).limit(MAX_EVIDENCE + 1)),
      ]);
      if (evidence.size > MAX_EVIDENCE) {
        return fail("resource-exhausted", "Evidence must be curated before scoring.");
      }
      const snapshot = evaluateScore(policy, organizerId, account.revision,
        assessmentSnaps.filter((doc) => doc.exists)
          .map((doc) => doc.data() as Assessment),
        evidence.docs.map((doc) => doc.data()), now);
      tx.create(db.collection("salesIntelligenceScoreSnapshots")
        .doc(snapshot.snapshotId), snapshot);
      return {snapshot};
    });
}

export async function saveIntelligenceClause(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "clauseId", "organizerId",
    "expectedRevision", "kind", "text", "evidenceIds", "validUntil",
    "permission"]);
  const request = requestId(input.requestId);
  const clauseId = id(input.clauseId);
  const organizerId = id(input.organizerId);
  const expectedRevision = revision(input.expectedRevision);
  const kind = input.kind;
  const sentence = text(input.text);
  const evidenceIds = uniqueIds(input.evidenceIds, 8);
  const validUntil = iso(input.validUntil);
  const permission = input.permission;
  if (!["observation", "capability", "reference", "cta"].includes(String(kind)) ||
      !["not_required", "private_mention", "withdrawn"].includes(String(permission)) ||
      (kind === "reference" && permission !== "private_mention") ||
      (kind !== "cta" && evidenceIds.length === 0)) {
    return fail("invalid-argument", "Invalid bounded clause source or permission.");
  }
  return mutate(deps, principal, "clause.save", request,
    {clauseId, organizerId, expectedRevision, kind, sentence,
      evidenceIds, validUntil, permission}, false, async (tx, now) => {
      await requireAccount(tx, deps.db, organizerId);
      if (Date.parse(validUntil) <= Date.parse(now)) {
        return fail("failed-precondition", "Clause expiry must be in the future.");
      }
      for (const evidenceId of evidenceIds) {
        const evidence = (await tx.get(deps.db.collection("salesEvidence").doc(evidenceId))).data();
        if (!currentReviewedEvidence(evidence, organizerId, now)) {
          return fail("failed-precondition", "Clause source is not current reviewed evidence.");
        }
      }
      const ref = deps.db.collection("salesIntelligenceClauses").doc(clauseId);
      const prior = (await tx.get(ref)).data();
      if (Number(prior?.revision ?? 0) !== expectedRevision ||
          (prior && prior.organizerId !== organizerId)) {
        return fail("aborted", "Clause changed since review.");
      }
      const clause: Clause = {schemaVersion: 1, classification: "sales_private",
        clauseId, organizerId, revision: expectedRevision + 1,
        kind: kind as Clause["kind"], text: sentence, state: "draft",
        evidenceIds, validUntil, permission: permission as Clause["permission"],
        reviewedAt: null, reviewedBy: null, updatedAt: now,
        updatedBy: principal.uid};
      tx.set(ref, clause);
      return {clause};
    });
}

export async function reviewIntelligenceClause(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "clauseId", "expectedRevision",
    "decision"]);
  const request = requestId(input.requestId);
  const clauseId = id(input.clauseId);
  const expectedRevision = revision(input.expectedRevision);
  const decision = input.decision;
  if (decision !== "approve" && decision !== "withdraw") {
    return fail("invalid-argument", "Explicit clause decision required.");
  }
  return mutate(deps, principal, "clause.review", request,
    {clauseId, expectedRevision, decision}, true, async (tx, now) => {
      const ref = deps.db.collection("salesIntelligenceClauses").doc(clauseId);
      const prior = (await tx.get(ref)).data() as Clause | undefined;
      if (!prior || prior.classification !== "sales_private") {
        return fail("not-found", "Clause not found.");
      }
      if (prior.revision !== expectedRevision) {
        return fail("aborted", "Clause changed since review.");
      }
      if (decision === "approve" && (prior.state !== "draft" ||
          prior.permission === "withdrawn" || Date.parse(prior.validUntil) <= Date.parse(now))) {
        return fail("failed-precondition", "Clause is not eligible for approval.");
      }
      await requireAccount(tx, deps.db, prior.organizerId);
      for (const evidenceId of prior.evidenceIds) {
        const evidence = (await tx.get(deps.db.collection("salesEvidence").doc(evidenceId))).data();
        if (!currentReviewedEvidence(evidence, prior.organizerId, now)) {
          return fail("failed-precondition", "Reviewed clause source changed.");
        }
      }
      const clause: Clause = {...prior, revision: prior.revision + 1,
        state: decision === "approve" ? "approved" : "withdrawn",
        reviewedAt: now, reviewedBy: principal.uid,
        updatedAt: now, updatedBy: principal.uid};
      tx.set(ref, clause);
      return {clause};
    });
}

export async function buildOutreachInput(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown,
  tx?: FirebaseFirestore.Transaction): Promise<Record<string, unknown>> {
  if (!tx) {
    return deps.db.runTransaction((readTx) =>
      buildOutreachInput(deps, principal, payload, readTx));
  }
  employee(principal);
  const input = object(payload, ["organizerId", "contactId", "opportunityId",
    "observationIds", "capabilityIds", "referenceIds", "ctaIds",
    "channel", "purpose", "priorActivityId"]);
  const organizerId = id(input.organizerId);
  const contactId = id(input.contactId);
  const opportunityId = id(input.opportunityId);
  const observationIds = uniqueIds(input.observationIds, 12);
  const capabilityIds = uniqueIds(input.capabilityIds, 12);
  const referenceIds = uniqueIds(input.referenceIds, 8);
  const ctaIds = uniqueIds(input.ctaIds, 8);
  if (observationIds.length < 1 || capabilityIds.length < 1 || ctaIds.length < 1 ||
      !["email", "message"].includes(String(input.channel)) ||
      !["first_message", "follow_up"].includes(String(input.purpose)) ||
      (input.purpose === "follow_up" && !input.priorActivityId) ||
      (input.purpose === "first_message" && input.priorActivityId)) {
    return fail("invalid-argument", "A grounded outreach purpose and clauses are required.");
  }
  await deps.authorize(principal, false);
  const db = deps.db;
  const read = (ref: FirebaseFirestore.DocumentReference) =>
    tx ? tx.get(ref) : ref.get();
  const now = deps.now().toISOString();
  const clauseIds = [...observationIds, ...capabilityIds, ...referenceIds, ...ctaIds];
  if (new Set(clauseIds).size !== clauseIds.length) {
    return fail("invalid-argument", "Clause IDs must be unique across kinds.");
  }
  const [accountSnap, contactSnap, relationshipSnap, opportunitySnap,
    policySnap, ...clauseSnaps] = await Promise.all([
    read(db.collection("organizerSalesAccounts").doc(organizerId)),
    read(db.collection("salesContacts").doc(contactId)),
    read(db.collection("salesContactRelationships")
      .doc(salesRelationshipId(organizerId, contactId))),
    read(db.collection("salesOpportunities").doc(opportunityId)),
    read(db.doc(POLICY_REF)),
    ...clauseIds.map((clauseId) => read(db.collection("salesIntelligenceClauses").doc(clauseId))),
  ]);
  const account = accountSnap.data();
  const contact = contactSnap.data();
  const relationship = relationshipSnap.data();
  const opportunity = opportunitySnap.data();
  const policy = requireCurrentPolicy(policySnap.data());
  const draftContact = await hasCurrentDraftContact(db, organizerId, contactId, now, tx);
  await deps.authorize(principal, false);
  if (!accountOk(account, organizerId) || account?.suppressionStatus !== "clear" ||
      account.duplicateReviewRequired || account.researchStatus !== "qualified" ||
      !account.qualificationPolicy || !contact ||
      contact.classification !== "sales_private" ||
      relationship?.classification !== "sales_private" ||
      opportunity?.classification !== "sales_private" ||
      opportunity.organizerId !== organizerId || !draftContact ||
      policy.status !== "active") {
    return fail("failed-precondition", "Current Sales identity or contact review blocks drafting.");
  }
  const qualification = await assertQualifiedByRuntimePolicy(
    tx, db, organizerId, now);
  if (hash(qualification) !== hash(account.qualificationPolicy)) {
    return fail("failed-precondition", "Sales qualification policy changed since review.");
  }
  // Qualification and contactability can remain eligible after an evidence
  // edit. Bind the draft to the complete bounded current evidence set too.
  const allEvidence = await tx.get(db.collection("salesEvidence")
    .where("organizerId", "==", organizerId).limit(MAX_EVIDENCE + 1));
  if (allEvidence.size > MAX_EVIDENCE) {
    return fail("resource-exhausted", "Evidence must be curated before drafting.");
  }
  const clauses = clauseSnaps.map((snap) => snap.data() as Clause | undefined);
  const sourceEvidence: Array<Record<string, unknown>> = [];
  const expectedKinds = [
    ...observationIds.map(() => "observation"),
    ...capabilityIds.map(() => "capability"),
    ...referenceIds.map(() => "reference"),
    ...ctaIds.map(() => "cta"),
  ];
  for (let index = 0; index < clauses.length; index++) {
    const clause = clauses[index];
    if (!clause || clause.organizerId !== organizerId ||
        clause.kind !== expectedKinds[index] || clause.state !== "approved" ||
        clause.permission === "withdrawn" ||
        (clause.kind === "reference" && clause.permission !== "private_mention") ||
        Date.parse(clause.validUntil) <= Date.parse(now)) {
      return fail("failed-precondition", "Approved clause is no longer eligible.");
    }
    for (const evidenceId of clause.evidenceIds) {
      const evidence = (await read(db.collection("salesEvidence").doc(evidenceId))).data();
      if (!currentReviewedEvidence(evidence, organizerId, now)) {
        return fail("failed-precondition", "Clause evidence is not current.");
      }
      sourceEvidence.push({evidenceId, claimKey: evidence?.claimKey,
        sourceRef: evidence?.sourceRef, observedAt: evidence?.observedAt,
        validThrough: evidence?.validThrough, reviewedAt: evidence?.reviewedAt,
        reviewerUid: evidence?.reviewerUid,
        normalizedValue: evidence?.normalizedValue, excerpt: evidence?.excerpt});
    }
  }
  const prior = input.priorActivityId ?
    (await read(db.collection("salesActivities").doc(id(input.priorActivityId)))).data() : null;
  if (input.priorActivityId && (prior?.organizerId !== organizerId ||
      prior?.opportunityId !== opportunityId)) {
    return fail("failed-precondition", "Prior interaction does not match this opportunity.");
  }
  const make = (ids: string[]) => ids.map((clauseId) => {
    const clause = clauses[clauseIds.indexOf(clauseId)]!;
    return {id: clause.clauseId, text: clause.text, revision: clause.revision,
      organizerId, approved: true, validUntil: clause.validUntil};
  });
  const bundle = {schemaVersion: 1,
    organizer: {organizerId, name: account.name, revision: account.revision,
      identityStatus: "verified"},
    contact: {contactId, revision: relationship.revision,
      role: relationship.role, eligibility: "eligible",
      suppressionStatus: "clear", claimStatus: "not_required"},
    opportunity: {opportunityId, revision: opportunity.revision,
      stage: opportunity.stage, motion: opportunity.motion},
    language: "en", channel: input.channel, purpose: input.purpose,
    evaluatedAt: now, evidenceConflictStatus: "clear",
    policy: {promptVersion: policy.promptVersion,
      playbookVersion: policy.playbookVersion, modelId: "disabled"},
    observations: make(observationIds), capabilities: make(capabilityIds),
    references: make(referenceIds),
    ctas: ctaIds.map((clauseId) => {
      const clause = clauses[clauseIds.indexOf(clauseId)]!;
      return {id: clause.clauseId, text: clause.text, revision: clause.revision};
    }),
    priorInteraction: prior ? {activityId: id(input.priorActivityId),
      summary: prior.note, revision: 0} : null};
  await deps.authorize(principal, false);
  return {bundle, sourceHash: hash({material: materialBundle(bundle),
    intelligencePolicy: policy,
    contactRecordRevision: contact.revision,
    allEvidence: allEvidence.docs.map((doc) => ({id: doc.id,
      data: doc.data()})).sort((a, b) => a.id.localeCompare(b.id)),
    sourceEvidence: sourceEvidence.sort((a, b) =>
      String(a.evidenceId).localeCompare(String(b.evidenceId)))}),
  sendAuthority: false};
}

export interface DraftRequest {
  organizerId: string; contactId: string; opportunityId: string;
  observationIds: string[]; capabilityIds: string[]; referenceIds: string[];
  ctaIds: string[]; channel: "email" | "message";
  purpose: "first_message" | "follow_up"; priorActivityId?: string;
}
interface RenderedDraft {
  draftId: string; organizerId: string; contactId: string;
  opportunityId: string; inputHash: string; contentHash: string;
  subject: string | null; text: string; sentences: Array<{
    text: string; kind: string; sourceIds: string[]}>;
  sourceRevisions: Record<string, number>; sendAuthority: false;
  reviewStatus: "pending_review";
}
function materialBundle(bundle: Record<string, unknown>): string {
  const rest = {...bundle};
  delete rest.evaluatedAt;
  return hash(rest);
}
function checkedDraft(value: unknown, bundle: Record<string, unknown>): RenderedDraft {
  const row = object(value, ["schemaVersion", "draftId", "organizerId",
    "contactId", "opportunityId", "language", "channel", "subject",
    "text", "sentences", "selection", "inputHash", "contentHash",
    "sourceRevisions", "model", "reviewStatus", "sendAuthority"]);
  const organizer = bundle.organizer as Record<string, unknown>;
  const contact = bundle.contact as Record<string, unknown>;
  const opportunity = bundle.opportunity as Record<string, unknown>;
  const expected = [
    ...(bundle.purpose === "follow_up" ? [{kind: "prior_interaction",
      id: (bundle.priorInteraction as Record<string, unknown>).activityId,
      text: (bundle.priorInteraction as Record<string, unknown>).summary}] : []),
    ...["observations", "capabilities", "references", "ctas"].flatMap((key) =>
      (bundle[key] as Array<Record<string, unknown>>).map((item) => ({
        kind: key === "observations" ? "observation" :
          key === "capabilities" ? "capability" :
            key === "references" ? "reference" : "cta",
        id: item.id, text: item.text,
      }))),
  ];
  const sentences = row.sentences;
  const model = object(row.model, ["modelId", "promptVersion",
    "playbookVersion", "cacheHit", "usage"]);
  const usage = object(model.usage, ["inputTokens", "outputTokens",
    "costMicros"]);
  if (row.schemaVersion !== 1 || row.organizerId !== organizer.organizerId ||
      row.contactId !== contact.contactId ||
      row.opportunityId !== opportunity.opportunityId ||
      row.language !== "en" || row.channel !== bundle.channel ||
      row.reviewStatus !== "pending_review" || row.sendAuthority !== false ||
      row.inputHash !== hash(bundle) ||
      model.modelId !== "deterministic" || model.cacheHit !== false ||
      Object.values(usage).some((value) => value !== 0) ||
      !Array.isArray(sentences) || sentences.length < 3 || sentences.length > 5) {
    return fail("failed-precondition", "Rendered outreach artifact differs from frozen Sales input.");
  }
  const used = new Set<string>();
  for (const sentence of sentences) {
    const part = object(sentence, ["text", "kind", "sourceIds"]);
    const sourceIds = part.sourceIds;
    if (!Array.isArray(sourceIds) || sourceIds.length !== 1 ||
        typeof sourceIds[0] !== "string" || used.has(sourceIds[0]) ||
        !expected.some((item) => item.id === sourceIds[0] &&
          item.kind === part.kind && item.text === part.text)) {
      return fail("failed-precondition", "Draft contains a sentence outside approved clauses.");
    }
    used.add(sourceIds[0]);
  }
  const parts = sentences as RenderedDraft["sentences"];
  const kinds = parts.map((part) => part.kind);
  if (hash(kinds) !== hash([...(bundle.purpose === "follow_up" ?
    ["prior_interaction"] : []), "observation", "capability",
  ...(kinds.includes("reference") ? ["reference"] : []), "cta"])) {
    return fail("failed-precondition", "Draft sentence sequence is not approved.");
  }
  const body = parts.map((part) => part.text).join("\n\n");
  if (body !== row.text || body.length > 2500 ||
      row.contentHash !== hash({subject: row.subject, text: body}) ||
      typeof row.draftId !== "string" ||
      !row.draftId.startsWith("draft-")) {
    return fail("failed-precondition", "Rendered text or hash is invalid.");
  }
  const revisions = row.sourceRevisions;
  if (!revisions || typeof revisions !== "object" || Array.isArray(revisions)) {
    return fail("failed-precondition", "Draft source revisions are missing.");
  }
  const expectedRevisions = Object.fromEntries([
    [organizer.organizerId, organizer.revision],
    [contact.contactId, contact.revision],
    [opportunity.opportunityId, opportunity.revision],
    ...["observations", "capabilities", "references", "ctas"].flatMap((key) =>
      (bundle[key] as Array<Record<string, unknown>>).map((item) => [item.id, item.revision])),
    ...(bundle.priorInteraction ? [[
      (bundle.priorInteraction as Record<string, unknown>).activityId,
      (bundle.priorInteraction as Record<string, unknown>).revision]] : []),
  ]);
  if (hash(revisions) !== hash(expectedRevisions)) {
    return fail("failed-precondition", "Draft source revisions differ from current input.");
  }
  return row as unknown as RenderedDraft;
}

/** Trusted Operations worker persistence hook; never exported as a browser callable. */
export async function recordOperationsDraft(deps: IntelligenceDeps,
  principal: SalesPrincipal, request: string, sourceRequest: DraftRequest,
  frozenBundle: Record<string, unknown>, frozenSourceHash: string,
  rendered: unknown) {
  requestId(request);
  const draft = checkedDraft(rendered, frozenBundle);
  const material = {sourceRequest, frozenBundle, frozenSourceHash, draft};
  return mutate(deps, principal, "draft.record", request, material, false,
    async (tx, now) => {
      const current = await buildOutreachInput(deps, principal, sourceRequest, tx);
      if (current.sourceHash !== frozenSourceHash ||
          materialBundle(current.bundle as Record<string, unknown>) !==
            materialBundle(frozenBundle)) {
        return fail("aborted", "Outreach sources changed during drafting.");
      }
      const ref = deps.db.collection("salesOutreachDrafts").doc(draft.draftId);
      const prior = await tx.get(ref);
      if (prior.exists) {
        return fail("already-exists", "Draft identity already exists.");
      }
      const stored = {schemaVersion: 1, classification: "sales_private",
        draftId: draft.draftId, organizerId: sourceRequest.organizerId,
        contactId: sourceRequest.contactId,
        opportunityId: sourceRequest.opportunityId,
        sourceRequest, sourceMaterialHash: materialBundle(frozenBundle),
        sourceHash: frozenSourceHash,
        inputHash: draft.inputHash, draft, status: "pending_review",
        createdAt: now, createdBy: principal.uid,
        reviewedAt: null, reviewedBy: null};
      tx.create(ref, stored);
      return {draftId: draft.draftId, draft, status: stored.status};
    });
}

async function requireCurrentDraft(deps: IntelligenceDeps,
  principal: SalesPrincipal, tx: FirebaseFirestore.Transaction, draftId: string) {
  const ref = deps.db.collection("salesOutreachDrafts").doc(draftId);
  const stored = (await tx.get(ref)).data();
  if (!stored || stored.classification !== "sales_private") {
    return fail("not-found", "Private outreach draft not found.");
  }
  const current = await buildOutreachInput(deps, principal,
    stored.sourceRequest, tx);
  if (current.sourceHash !== stored.sourceHash ||
      materialBundle(current.bundle as Record<string, unknown>) !==
        stored.sourceMaterialHash) {
    return fail("aborted", "Outreach sources changed; prepare a new draft.");
  }
  return {ref, stored};
}

export async function reviewOutreachDraft(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "draftId", "expectedContentHash",
    "factualValidity", "tone", "channelReadiness"]);
  const request = requestId(input.requestId);
  const draftId = id(input.draftId);
  const expectedContentHash = text(input.expectedContentHash, 64);
  if (input.factualValidity !== "verified" || input.tone !== "approved" ||
      input.channelReadiness !== "manual_copy_only") {
    return fail("invalid-argument", "Explicit factual, tone and manual-channel review required.");
  }
  return mutate(deps, principal, "draft.review", request,
    {draftId, expectedContentHash, factualValidity: input.factualValidity,
      tone: input.tone, channelReadiness: input.channelReadiness}, false,
    async (tx, now) => {
      const {ref, stored} = await requireCurrentDraft(deps, principal, tx, draftId);
      if (stored.status !== "pending_review" ||
          stored.draft.contentHash !== expectedContentHash) {
        return fail("aborted", "Exact draft has changed since review.");
      }
      tx.update(ref, {status: "approved", reviewedAt: now,
        reviewedBy: principal.uid});
      return {draftId, exactContentHash: expectedContentHash,
        factualValidity: "verified", tone: "approved",
        channelReadiness: "manual_copy_only", sendAuthority: false,
        providerConfirmed: false, reviewedAt: now};
    }, async (tx) => {
      await requireCurrentDraft(deps, principal, tx, draftId);
    });
}

export async function copyOutreachDraft(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown) {
  const input = object(payload, ["requestId", "draftId", "expectedContentHash"]);
  const request = requestId(input.requestId);
  const draftId = id(input.draftId);
  const expectedContentHash = text(input.expectedContentHash, 64);
  return mutate(deps, principal, "draft.copy", request,
    {draftId, expectedContentHash}, false, async (tx, now) => {
      const {stored} = await requireCurrentDraft(deps, principal, tx, draftId);
      if (stored.status !== "approved" ||
          stored.draft.contentHash !== expectedContentHash) {
        return fail("failed-precondition", "Current reviewed draft is required for copying.");
      }
      return {draftId, subject: stored.draft.subject as string | null,
        text: stored.draft.text as string, exactContentHash: expectedContentHash,
        copiedAt: now, sendAuthority: false, providerConfirmed: false};
    }, async (tx) => {
      await requireCurrentDraft(deps, principal, tx, draftId);
    });
}

export async function getOutreachDraft(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<Record<string, unknown>> {
  employee(principal);
  const input = object(payload, ["draftId"]);
  const draftId = id(input.draftId);
  await deps.authorize(principal, false);
  const result = await deps.db.runTransaction(async (tx) => {
    const {stored} = await requireCurrentDraft(deps, principal, tx, draftId);
    return {draftId, draft: stored.draft, status: stored.status,
      reviewedAt: stored.reviewedAt, reviewedBy: stored.reviewedBy,
      sendAuthority: false};
  });
  await deps.authorize(principal, false);
  return result;
}
