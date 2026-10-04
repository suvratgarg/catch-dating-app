/* eslint-disable max-len */
import {strict as assert} from "node:assert";
import {execFileSync} from "node:child_process";
import path from "node:path";
import {test} from "node:test";
import {qualificationPolicyHash} from "../sales/qualificationPolicy";
import {salesRelationshipId} from "../sales/records";
import type {SalesPrincipal} from "../sales/types";
import {parsePolicy} from "./model";
import {claimDraftJob, getDraftJob, jobIdFor} from "./job";
import {generateSalesOutreachDraft} from "./runtime";
import {buildOutreachInput, buildPartnerOutreachInput, recordPartnerOperationsDraft,
  getPartnerOutreachDraft, reviewPartnerOutreachDraft, copyPartnerOutreachDraft,
  type DraftRequest, type IntelligenceDeps} from "./service";
import {PARTNER_TERMS_VERSION, type PartnerDeps} from "../../partners/model";

const started = "2026-09-28T10:00:00.000Z";
const sampleRequest = {requestId: "draft-request-123",
  sourceRequest: {organizerId: "org-one", contactId: "contact-one",
    opportunityId: "opportunity-one", observationIds: ["observation-one"],
    capabilityIds: ["capability-one"], referenceIds: [], ctaIds: ["cta-one"],
    channel: "email", purpose: "first_message"}};
const actor: SalesPrincipal = {uid: "employee-one", roles: ["admin"]};

class MemoryDb {
  docs = new Map<string, Record<string, unknown>>();
  doc(name: string) {
    return new MemoryRef(this, name);
  }
  collection(name: string) {
    return new MemoryQuery(this, name);
  }
  async runTransaction<T>(callback: (tx: MemoryTx) => Promise<T>): Promise<T> {
    const tx = new MemoryTx(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }
}
class MemoryRef {
  constructor(private db: MemoryDb, readonly path: string) {}
  get id() {
    return this.path.split("/").at(-1)!;
  }
  async get() {
    return snap(this.id, this.db.docs.get(this.path));
  }
}
class MemoryQuery {
  private filters: Array<[string, unknown]> = [];
  private cap = 100;
  constructor(private db: MemoryDb, private base: string) {}
  doc(name: string) {
    return new MemoryRef(this.db, `${this.base}/${name}`);
  }
  where(key: string, _op: string, value: unknown) {
    this.filters.push([key, value]); return this;
  }
  limit(value: number) {
    this.cap = value; return this;
  }
  async get() {
    const docs = [...this.db.docs.entries()].filter(([key, value]) =>
      key.startsWith(`${this.base}/`) &&
      key.slice(this.base.length + 1).indexOf("/") === -1 &&
      this.filters.every(([field, expected]) => value[field] === expected))
      .slice(0, this.cap).map(([key, value]) =>
        snap(key.split("/").at(-1)!, value));
    return {docs, size: docs.length};
  }
}
function snap(id: string, value?: Record<string, unknown>) {
  return {id, exists: value !== undefined, data: () => value};
}
class MemoryTx {
  private changes: Array<() => void> = [];
  constructor(private db: MemoryDb) {}
  get(target: MemoryRef | MemoryQuery) {
    return target.get();
  }
  create(ref: MemoryRef, value: Record<string, unknown>) {
    if (this.db.docs.has(ref.path)) throw new Error("already exists");
    this.changes.push(() => this.db.docs.set(ref.path, value));
  }
  set(ref: MemoryRef, value: Record<string, unknown>) {
    this.changes.push(() => this.db.docs.set(ref.path, value));
  }
  update(ref: MemoryRef, patch: Record<string, unknown>) {
    this.changes.push(() => this.db.docs.set(ref.path,
      {...this.db.docs.get(ref.path), ...patch}));
  }
  commit() {
    this.changes.forEach((change) => change());
  }
}

function fixture() {
  const db = new MemoryDb();
  let currentTime = new Date(started);
  let authorized = true;
  const qualification = {policyId: "qual-synthetic", version: "v1",
    rules: [{ruleId: "identity-rule", claimKey: "identity",
      sourceTypes: ["first_party"], confidence: ["high"], minimumCount: 1,
      distinctSignalIds: false, distinctSourceRoots: false, maxAgeDays: 30}]};
  const qualified = {...qualification, policyHash: qualificationPolicyHash(qualification)};
  const policy = parsePolicy({policyId: "intel-synthetic", version: "v1",
    status: "active", promptVersion: "prompt-v1", playbookVersion: "playbook-v1",
    priorityBands: {high: 80, medium: 50}, factors: [
      "a", "b", "c", "d", "e", "f", "g"].map((id, i) => ({id,
      weight: i === 6 ? 16 : 14, claimKeys: ["identity"], maxAgeDays: 30}))});
  db.docs.set("salesSettings/qualificationPolicy", {schemaVersion: 1,
    classification: "sales_private", status: "active", ...qualified});
  db.docs.set("organizerSalesAccounts/org-one", {classification: "sales_private",
    organizerId: "org-one", revision: 2, name: "Example Collective",
    suppressionStatus: "clear", duplicateReviewRequired: false,
    researchStatus: "qualified", qualificationPolicy: {
      policyId: qualified.policyId, version: qualified.version,
      policyHash: qualified.policyHash}});
  db.docs.set("salesContacts/contact-one", {classification: "sales_private",
    contactId: "contact-one", revision: 1});
  db.docs.set(`salesContactRelationships/${salesRelationshipId("org-one", "contact-one")}`,
    {classification: "sales_private", organizerId: "org-one",
      contactId: "contact-one", revision: 3, role: "organizer",
      contactabilityStatus: "draft_reviewed", draftReviewEvidenceId: "contact-evidence"});
  db.docs.set("salesOpportunities/opportunity-one", {classification: "sales_private",
    organizerId: "org-one", opportunityId: "opportunity-one", revision: 4,
    stage: "ready_to_contact", motion: "first_pilot"});
  db.docs.set("salesIntelligencePolicies/current", {schemaVersion: 1,
    classification: "sales_private", policyRecordId: "current",
    ...policy, revision: 1, updatedAt: started, updatedBy: "owner-one"});
  for (const [evidenceId, claimKey, contactId] of [
    ["identity-evidence", "identity", undefined],
    ["observation-evidence", "operation", undefined],
    ["capability-evidence", "operation", undefined],
    ["contact-evidence", "identity", "contact-one"],
  ]) {
    db.docs.set(`salesEvidence/${evidenceId}`, {classification: "sales_private",
      evidenceId, organizerId: "org-one", contactId, claimKey,
      sourceType: "first_party", confidence: "high", sourceRef: "synthetic",
      observedAt: "2026-09-27T10:00:00.000Z", validThrough: null,
      reviewedAt: started, reviewerUid: "owner-one"});
  }
  for (const [clauseId, kind, value, evidenceIds] of [
    ["observation-one", "observation", "Your event uses applications.", ["observation-evidence"]],
    ["capability-one", "capability", "Catch can collect applications for review.", ["capability-evidence"]],
    ["cta-one", "cta", "Would a walkthrough be useful?", []],
  ] as const) {
    db.docs.set(`salesIntelligenceClauses/${clauseId}`, {schemaVersion: 1,
      classification: "sales_private", clauseId, organizerId: "org-one",
      revision: 1, kind, text: value, state: "approved", evidenceIds,
      validUntil: "2026-11-01T00:00:00.000Z", permission: "not_required",
      reviewedAt: started, reviewedBy: "owner-one", updatedAt: started,
      updatedBy: "owner-one"});
  }
  const deps: IntelligenceDeps = {db: db as unknown as FirebaseFirestore.Firestore,
    now: () => currentTime, authorize: async () => {
      if (!authorized) throw new Error("employee revoked");
    }};
  return {db, deps, clock: (iso: string) => {
    currentTime = new Date(iso);
  },
  revoke: () => {
    authorized = false;
  }};
}

// The build post-step copies these exact existing Operations modules to lib.
execFileSync(process.execPath, [path.join(__dirname,
  "../../../src/admin/salesIntelligence/copy-operations.cjs")]);

test("real zero-model Operations runner creates one reviewed draft and exact retry", async () => {
  const f = fixture();
  const first = await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  assert.equal(first.status, "completed");
  assert.equal(first.idempotentReplay, false);
  const again = await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  assert.deepEqual(again.result, first.result);
  assert.equal(again.idempotentReplay, true);
  assert.equal([...f.db.docs.keys()].filter((key) =>
    key.startsWith("salesOutreachJobs/")).length, 1);
  assert.equal([...f.db.docs.keys()].filter((key) =>
    key.startsWith("salesOutreachDrafts/")).length, 1);
  assert.equal([...f.db.docs.keys()].filter((key) =>
    key.startsWith("salesIntelligenceReceipts/")).length, 1);
  const other: SalesPrincipal = {uid: "employee-two", roles: ["admin"]};
  await assert.rejects(getDraftJob(f.deps, other,
    {requestId: sampleRequest.requestId}), /not found/u);
});

test("expired lease resumes same frozen request; another active claim does not run", async () => {
  const f = fixture();
  const claimed = await claimDraftJob(f.deps, actor, sampleRequest);
  assert.equal(claimed.claimed, true);
  const busy = await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  assert.equal(busy.status, "running");
  assert.equal(f.db.docs.has(`salesOutreachJobs/${jobIdFor(actor.uid, sampleRequest.requestId)}`), true);
  f.clock("2026-09-28T10:01:01.000Z");
  const resumed = await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  assert.equal(resumed.status, "completed");
  const job = f.db.docs.get(`salesOutreachJobs/${jobIdFor(actor.uid, sampleRequest.requestId)}`);
  assert.equal(job?.attemptCount, 2);
});

test("crash after draft receipt but before job completion recovers exact artifact", async () => {
  const f = fixture();
  const first = await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  const key = `salesOutreachJobs/${jobIdFor(actor.uid, sampleRequest.requestId)}`;
  const committed = f.db.docs.get(key)!;
  f.db.docs.set(key, {...committed, status: "running", result: null,
    leaseOwner: "interrupted-worker", leaseUntil: "2026-09-28T10:01:00.000Z"});
  f.clock("2026-09-28T10:01:01.000Z");
  const recovered = await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  assert.equal(recovered.status, "completed");
  assert.deepEqual(recovered.result, first.result);
  assert.equal([...f.db.docs.keys()].filter((key) =>
    key.startsWith("salesOutreachDrafts/")).length, 1);
  assert.equal([...f.db.docs.keys()].filter((key) =>
    key.startsWith("salesIntelligenceReceipts/")).length, 1);
});

test("current-source drift and revoked employee block freeze, replay and completion", async () => {
  const changed = fixture();
  await claimDraftJob(changed.deps, actor, sampleRequest);
  changed.db.docs.set("salesIntelligenceClauses/capability-one", {
    ...changed.db.docs.get("salesIntelligenceClauses/capability-one"), revision: 2});
  changed.clock("2026-09-28T10:01:01.000Z");
  await assert.rejects(generateSalesOutreachDraft(changed.deps, actor,
    sampleRequest), /sources changed/u);
  assert.equal([...changed.db.docs.keys()].some((key) =>
    key.startsWith("salesOutreachDrafts/")), false);
  const evidenceDrift = fixture();
  await claimDraftJob(evidenceDrift.deps, actor, sampleRequest);
  evidenceDrift.db.docs.set("salesEvidence/identity-evidence", {
    ...evidenceDrift.db.docs.get("salesEvidence/identity-evidence"),
    sourceRef: "synthetic-corrected"});
  evidenceDrift.clock("2026-09-28T10:01:01.000Z");
  await assert.rejects(generateSalesOutreachDraft(evidenceDrift.deps, actor,
    sampleRequest), /sources changed/u);
  const revoked = fixture();
  await claimDraftJob(revoked.deps, actor, sampleRequest);
  revoked.revoke();
  await assert.rejects(generateSalesOutreachDraft(revoked.deps, actor,
    sampleRequest), /employee revoked/u);
  assert.equal([...revoked.db.docs.keys()].some((key) =>
    key.startsWith("salesOutreachDrafts/")), false);
});

function partnerFixture() {
  const f = fixture();
  f.db.docs.set("organizers/org-one", {name: "Synthetic", appVisibility: "hidden",
    claim: {state: "unclaimed"}, publicPage: {publicationStatus: "draft"}});
  f.db.docs.set("salesPartnerMemberships/partner-one", {schemaVersion: 1,
    classification: "sales_private", uid: "partner-one", status: "active",
    termsVersion: PARTNER_TERMS_VERSION, expiresAt: "2026-11-01T00:00:00.000Z"});
  f.db.docs.set("salesPartnerAssignments/org-one", {schemaVersion: 1,
    classification: "sales_private", organizerId: "org-one", partnerUid: "partner-one",
    revision: 2, status: "accepted", expiresAt: "2026-11-01T00:00:00.000Z"});
  const principal = {uid: "partner-one", roles: []};
  const deps: PartnerDeps = {db: f.deps.db, now: f.deps.now,
    checkAuth: async (current, employee) => {
      assert.equal(employee, false); assert.deepEqual(current.roles, []);
    }};
  return {...f, principal, partnerDeps: deps};
}

test("partner source composition shares qualification gates without borrowing employee roles", async () => {
  const f = partnerFixture();
  const result = await buildPartnerOutreachInput(f.partnerDeps, f.principal, sampleRequest.sourceRequest, 2);
  assert.equal(result.sendAuthority, false);
  assert.equal((result.bundle as {priorInteraction: unknown}).priorInteraction, null);
  await assert.rejects(buildOutreachInput(f.deps, f.principal, sampleRequest.sourceRequest),
    {code: "permission-denied"});
  await assert.rejects(buildPartnerOutreachInput(f.partnerDeps,
    {uid: "other-partner", roles: []}, sampleRequest.sourceRequest, 2), {code: "permission-denied"});
  f.db.docs.set("organizerSalesAccounts/org-one", {...f.db.docs.get("organizerSalesAccounts/org-one"),
    researchStatus: "new"});
  await assert.rejects(buildPartnerOutreachInput(f.partnerDeps, f.principal, sampleRequest.sourceRequest, 2),
    {code: "failed-precondition"});
});

test("partner source hashes bind current assignment generation and reject stale access during reads", async () => {
  const f = partnerFixture();
  const before = await buildPartnerOutreachInput(f.partnerDeps, f.principal, sampleRequest.sourceRequest, 2);
  f.db.docs.set("salesPartnerAssignments/org-one", {...f.db.docs.get("salesPartnerAssignments/org-one"), revision: 3});
  await assert.rejects(buildPartnerOutreachInput(f.partnerDeps, f.principal, sampleRequest.sourceRequest, 2),
    {code: "aborted"});
  const after = await buildPartnerOutreachInput(f.partnerDeps, f.principal, sampleRequest.sourceRequest, 3);
  assert.notEqual(before.sourceHash, after.sourceHash);
  let checks = 0;
  f.partnerDeps.checkAuth = async () => {
    if (++checks === 2) f.db.docs.set("salesPartnerMemberships/partner-one",
      {...f.db.docs.get("salesPartnerMemberships/partner-one"), status: "revoked"});
  };
  await assert.rejects(buildPartnerOutreachInput(f.partnerDeps, f.principal, sampleRequest.sourceRequest, 3),
    {code: "permission-denied"});
});

test("partner follow-up rejects staff notes and consumes only own manual interaction", async () => {
  const f = partnerFixture();
  const row = {classification: "sales_private", organizerId: "org-one",
    opportunityId: "opportunity-one", actorUid: "employee-one", note: "Private staff note",
    type: "outreach_sent_manual", outcome: "actor_attested_sent", providerConfirmed: false};
  f.db.docs.set("salesActivities/prior-one", row);
  const source = {...sampleRequest.sourceRequest, purpose: "follow_up", priorActivityId: "prior-one"};
  await assert.rejects(buildPartnerOutreachInput(f.partnerDeps, f.principal, source, 2),
    {code: "permission-denied"});
  f.db.docs.set("salesActivities/prior-one", {...row, actorUid: f.principal.uid, note: "Own manually recorded context"});
  const result = await buildPartnerOutreachInput(f.partnerDeps, f.principal, source, 2);
  assert.equal((result.bundle as {priorInteraction: {summary: string}}).priorInteraction.summary,
    "Own manually recorded context");
  assert.ok(!JSON.stringify(result).includes("Private staff note"));
});

test("identical employee and replacement-partner renderings retain separate scoped identities", async () => {
  const f = partnerFixture();
  await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  const employeeDraft = [...f.db.docs.entries()].find(([key]) => key.startsWith("salesOutreachDrafts/"))![1];
  const rendered = employeeDraft.draft;
  const request = sampleRequest.sourceRequest as DraftRequest;
  const source = await buildPartnerOutreachInput(f.partnerDeps, f.principal, request, 2);
  const first = await recordPartnerOperationsDraft(f.partnerDeps, f.principal, "partner-first",
    request, 2, source.bundle as Record<string, unknown>, source.sourceHash as string, rendered);
  assert.notEqual(first.draftId, employeeDraft.draftId);
  assert.deepEqual(await recordPartnerOperationsDraft(f.partnerDeps, f.principal, "partner-first",
    request, 2, source.bundle as Record<string, unknown>, source.sourceHash as string, rendered), first);
  f.db.docs.set("salesPartnerAssignments/org-one", {...f.db.docs.get("salesPartnerAssignments/org-one"), revision: 3});
  const newer = await buildPartnerOutreachInput(f.partnerDeps, f.principal, request, 3);
  const second = await recordPartnerOperationsDraft(f.partnerDeps, f.principal, "partner-next",
    request, 3, newer.bundle as Record<string, unknown>, newer.sourceHash as string, rendered);
  assert.notEqual(second.draftId, first.draftId);
  const replacement = {uid: "partner-two", roles: []};
  f.db.docs.set("salesPartnerMemberships/partner-two", {...f.db.docs.get("salesPartnerMemberships/partner-one"), uid: replacement.uid});
  f.db.docs.set("salesPartnerAssignments/org-one", {...f.db.docs.get("salesPartnerAssignments/org-one"), partnerUid: replacement.uid});
  const changed = await buildPartnerOutreachInput(f.partnerDeps, replacement, request, 3);
  const third = await recordPartnerOperationsDraft(f.partnerDeps, replacement, "partner-replaced",
    request, 3, changed.bundle as Record<string, unknown>, changed.sourceHash as string, rendered);
  assert.notEqual(third.draftId, second.draftId);
  assert.equal([...f.db.docs.keys()].filter((key) => key.startsWith("salesOutreachDrafts/")).length, 4);
});

test("participant review and copy require own current artifact on fresh calls and exact replay", async () => {
  const f = partnerFixture();
  await generateSalesOutreachDraft(f.deps, actor, sampleRequest);
  const employeeDraft = [...f.db.docs.entries()].find(([key]) => key.startsWith("salesOutreachDrafts/"))![1];
  const request = sampleRequest.sourceRequest as DraftRequest;
  const source = await buildPartnerOutreachInput(f.partnerDeps, f.principal, request, 2);
  const saved = await recordPartnerOperationsDraft(f.partnerDeps, f.principal, "partner-draft",
    request, 2, source.bundle as Record<string, unknown>, source.sourceHash as string, employeeDraft.draft);
  const target = {organizerId: "org-one", draftId: saved.draftId, expectedAssignmentRevision: 2};
  const expectedContentHash = saved.draft.contentHash;
  const copy = {...target, requestId: "copy-own", expectedContentHash};
  await assert.rejects(copyPartnerOutreachDraft(f.partnerDeps, f.principal, copy), {code: "failed-precondition"});
  const review = {...target, requestId: "review-own", expectedContentHash,
    factualValidity: "verified", tone: "approved", channelReadiness: "manual_copy_only"};
  const reviewed = await reviewPartnerOutreachDraft(f.partnerDeps, f.principal, review);
  assert.equal(reviewed.capabilityApprovalAuthority, false);
  assert.deepEqual(await reviewPartnerOutreachDraft(f.partnerDeps, f.principal, review), reviewed);
  const copied = await copyPartnerOutreachDraft(f.partnerDeps, f.principal, copy);
  assert.equal(copied.sendAuthority, false); assert.equal(copied.providerConfirmed, false);
  assert.deepEqual(await copyPartnerOutreachDraft(f.partnerDeps, f.principal, copy), copied);
  const own = await getPartnerOutreachDraft(f.partnerDeps, f.principal, target);
  assert.ok(!("reviewedBy" in own));
  await assert.rejects(getPartnerOutreachDraft(f.partnerDeps, f.principal,
    {...target, draftId: employeeDraft.draftId}), {code: "permission-denied"});
  f.db.docs.set(`salesOutreachDrafts/${saved.draftId}`, {...f.db.docs.get(`salesOutreachDrafts/${saved.draftId}`), status: "pending_review"});
  await assert.rejects(copyPartnerOutreachDraft(f.partnerDeps, f.principal, copy), {code: "failed-precondition"});
  await assert.rejects(reviewPartnerOutreachDraft(f.partnerDeps, f.principal, review), {code: "failed-precondition"});
});
