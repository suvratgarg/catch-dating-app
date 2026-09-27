/* eslint-disable max-len */
import {strict as assert} from "node:assert";
import {readFileSync} from "node:fs";
import path from "node:path";
import {test} from "node:test";
import Ajv from "ajv";
import addFormats from "ajv-formats";
import {evaluateScore, parsePolicy, type Assessment,
  type IntelligencePolicy} from "./model";
import {saveIntelligencePolicy, saveFactorAssessment,
  type IntelligenceDeps} from "./service";
import type {SalesPrincipal} from "../sales/types";

const at = "2026-09-28T10:00:00.000Z";
const factorIds = ["one", "two", "three", "four", "five", "six", "seven"];
const policy = parsePolicy({policyId: "synthetic", version: "test-v1",
  status: "active", promptVersion: "test-prompt", playbookVersion: "test-playbook",
  priorityBands: {high: 80, medium: 50},
  factors: factorIds.map((id, index) => ({id,
    weight: index === 6 ? 16 : 14,
    claimKeys: ["operation"], maxAgeDays: 30}))});
const storedPolicy: IntelligencePolicy = {schemaVersion: 1,
  classification: "sales_private", policyRecordId: "current", ...policy, revision: 2,
  updatedAt: at, updatedBy: "reviewer"};
const assessments: Assessment[] = factorIds.map((factorId, index) => ({
  schemaVersion: 1, classification: "sales_private",
  assessmentId: `assessment-${factorId}`, organizerId: "org-one", factorId,
  revision: 1, state: "known", value: index % 2 === 0 ? 5 : 4,
  evidenceIds: [`evidence-${factorId}`], reason: null,
  reviewedAt: at, reviewerUid: "reviewer",
}));
const evidence = factorIds.map((factorId) => ({classification: "sales_private",
  evidenceId: `evidence-${factorId}`, organizerId: "org-one",
  claimKey: "operation", observedAt: "2026-09-27T10:00:00.000Z",
  validThrough: null, reviewedAt: at, reviewerUid: "reviewer"}));

test("versioned policy is supplied privately and rejects partial or inflated weights", () => {
  assert.equal(policy.factors.length, 7);
  assert.throws(() => parsePolicy({...policy, factors: policy.factors.slice(1)}));
  assert.throws(() => parsePolicy({...policy, factors: policy.factors.map(
    (factor) => ({...factor, weight: 20}))}));
  assert.throws(() => parsePolicy({...policy, secretPrompt: "ignored"}));
});

test("score is deterministic, complete only with seven current reviewed factors", () => {
  const first = evaluateScore(storedPolicy, "org-one", 3,
    assessments, evidence, at);
  const replay = evaluateScore(storedPolicy, "org-one", 3,
    assessments, evidence, at);
  assert.deepEqual(replay, first);
  assert.equal(first.status, "complete");
  assert.equal(first.priority, "high");
  assert.equal(first.score, 91.6);
  assert.equal(first.factors.length, 7);
  assert(first.factors.every((factor) => factor.evidenceIds.length === 1));
});

test("missing, stale, foreign or disputed evidence cannot become a numeric score", () => {
  for (const altered of [evidence.slice(1),
    evidence.map((row, index) => index === 0 ?
      {...row, observedAt: "2026-01-01T00:00:00.000Z"} : row),
    evidence.map((row, index) => index === 0 ?
      {...row, organizerId: "other"} : row),
    evidence.map((row, index) => index === 0 ?
      {...row, reviewedAt: ""} : row)]) {
    const result = evaluateScore(storedPolicy, "org-one", 3,
      assessments, altered, at);
    assert.equal(result.score, null);
    assert.equal(result.priority, "unranked");
    assert.equal(result.status, "needs_research");
  }
  const disputed = assessments.map((row, index) => index === 0 ?
    {...row, state: "disputed" as const, value: null,
      reason: "Conflicting reports"} : row);
  assert.equal(evaluateScore(storedPolicy, "org-one", 3,
    disputed, evidence, at).status, "review_required");
});

class MemoryDb {
  docs = new Map<string, Record<string, unknown>>();
  doc(path: string) {
    return new MemoryRef(this, path);
  }
  collection(path: string) {
    return new MemoryCollection(this, path);
  }
  async runTransaction<T>(action: (tx: MemoryTransaction) => Promise<T>): Promise<T> {
    const tx = new MemoryTransaction(this);
    const result = await action(tx);
    tx.commit();
    return result;
  }
}
class MemoryRef {
  constructor(private db: MemoryDb, public path: string) {}
  get id() {
    return this.path.split("/").at(-1)!;
  }
  async get() {
    return snapshot(this.id, this.db.docs.get(this.path));
  }
}
class MemoryCollection {
  private filters: Array<[string, unknown]> = [];
  private max = 100;
  constructor(private db: MemoryDb, private path: string) {}
  doc(id: string) {
    return new MemoryRef(this.db, `${this.path}/${id}`);
  }
  where(key: string, _operator: string, value: unknown) {
    this.filters.push([key, value]); return this;
  }
  limit(max: number) {
    this.max = max; return this;
  }
  async get() {
    const docs = [...this.db.docs.entries()].filter(([path, value]) =>
      path.startsWith(`${this.path}/`) &&
      this.filters.every(([key, expected]) => value[key] === expected))
      .slice(0, this.max).map(([path, value]) =>
        snapshot(path.split("/").at(-1)!, value));
    return {docs, size: docs.length};
  }
}
function snapshot(id: string, value: Record<string, unknown> | undefined) {
  return {id, exists: value !== undefined, data: () => value};
}
class MemoryTransaction {
  writes: Array<() => void> = [];
  constructor(private db: MemoryDb) {}
  get(target: MemoryRef | MemoryCollection) {
    return target.get();
  }
  create(ref: MemoryRef, value: Record<string, unknown>) {
    if (this.db.docs.has(ref.path)) throw new Error("already exists");
    this.writes.push(() => this.db.docs.set(ref.path, value));
  }
  set(ref: MemoryRef, value: Record<string, unknown>) {
    this.writes.push(() => this.db.docs.set(ref.path, value));
  }
  update(ref: MemoryRef, patch: Record<string, unknown>) {
    this.writes.push(() => this.db.docs.set(ref.path,
      {...this.db.docs.get(ref.path), ...patch}));
  }
  commit() {
    this.writes.forEach((write) => write());
  }
}

test("policy receipts return exact retry, reject changed material and recheck owner", async () => {
  const memory = new MemoryDb();
  let active = true;
  const deps: IntelligenceDeps = {db: memory as unknown as FirebaseFirestore.Firestore,
    now: () => new Date(at), authorize: async (_principal, ownerOnly) => {
      assert.equal(ownerOnly, true);
      if (!active) throw new Error("owner revoked");
    }};
  const principal: SalesPrincipal = {uid: "owner-1", roles: ["adminOwner"]};
  const payload = {requestId: "policy-request-1", expectedRevision: 0,
    policy};
  const first = await saveIntelligencePolicy(deps, principal, payload);
  const retry = await saveIntelligencePolicy(deps, principal, payload);
  assert.deepEqual(retry, first);
  assert.equal(memory.docs.get("salesIntelligencePolicies/current")?.revision, 1);
  assert.equal([...memory.docs.keys()].filter((key) =>
    key.startsWith("salesIntelligenceReceipts/")).length, 1);
  assert.equal([...memory.docs.keys()].filter((key) =>
    key.startsWith("adminAuditLogs/sales_intelligence_")).length, 1);
  await assert.rejects(saveIntelligencePolicy(deps, principal,
    {...payload, policy: {...policy, version: "test-v2"}}),
  /different material/u);
  active = false;
  await assert.rejects(saveIntelligencePolicy(deps, principal, payload),
    /owner revoked/u);
});

test("factor assessment rejects unreviewed source without writing a receipt", async () => {
  const memory = new MemoryDb();
  memory.docs.set("salesIntelligencePolicies/current", {...storedPolicy});
  memory.docs.set("organizerSalesAccounts/org-one", {schemaVersion: 1,
    classification: "sales_private", organizerId: "org-one", revision: 1});
  memory.docs.set("salesEvidence/evidence-one", {
    ...evidence[0], reviewedAt: null});
  const deps: IntelligenceDeps = {db: memory as unknown as FirebaseFirestore.Firestore,
    now: () => new Date(at), authorize: async () => undefined};
  const principal: SalesPrincipal = {uid: "employee-1", roles: ["admin"]};
  await assert.rejects(saveFactorAssessment(deps, principal,
    {requestId: "factor-request-1", organizerId: "org-one", factorId: "one",
      expectedRevision: 0, state: "known", value: 4,
      evidenceIds: ["evidence-one"], reason: null}),
  /not reviewed Sales evidence/u);
  assert.equal([...memory.docs.keys()].filter((key) =>
    key.startsWith("salesIntelligenceReceipts/")).length, 0);
});

test("persisted policy, assessment and score satisfy their strict source contracts", () => {
  const root = path.resolve(__dirname, "../../../../contracts/firestore");
  const ajv = new Ajv({strict: false, allErrors: true});
  addFormats(ajv);
  const valid = (name: string, value: unknown) => {
    const schema = JSON.parse(readFileSync(path.join(root, name), "utf8"));
    const check = ajv.compile(schema);
    assert.equal(check(value), true, JSON.stringify(check.errors));
  };
  valid("sales_intelligence_policies.schema.json", storedPolicy);
  valid("sales_intelligence_assessments.schema.json", assessments[0]);
  valid("sales_intelligence_score_snapshots.schema.json",
    evaluateScore(storedPolicy, "org-one", 3, assessments, evidence, at));
});
