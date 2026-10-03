import assert from "node:assert/strict";
import {test} from "node:test";
import {applyCatchReadinessReview, catchReadinessRecordDigest} from
  "./whatsappReadinessProvisioning";
import type {ReadinessApproval, ReadinessMutation, ReadinessSnapshot,
  ReadinessTransaction, VerifiedReadinessHistory} from
  "./whatsappReadinessProvisioning";

function fixture() {
  const scope = {projectId: "catchdates-dev", wabaId: "123",
    phoneNumberId: "456", recipientUid: "recipient",
    endpointHash: "a".repeat(64), evidenceSha256: "b".repeat(64)};
  const approval: ReadinessApproval = {approvalId: "review_1", action: "create",
    scope, reviewerUid: "owner", reviewedAtMillis: 2000,
    expiresAtMillis: 10000, atomicIngressStartedAtMillis: 1000,
    expectedRecordSha256: null};
  const current: ReadinessSnapshot = {scope: {...scope}, nowMillis: 3000,
    authority: {uid: "owner", disabled: false, roles: ["adminOwner"],
      sessionCurrent: true}, recipientEnabled: true,
    verifiedRecipientEndpointHash: scope.endpointHash, suppressed: false,
    atomicIngressStartedAtMillis: 1000, existing: null};
  const proof: VerifiedReadinessHistory = {approvalId: "review_1",
    scope: {...scope}, provenanceSha256: "c".repeat(64), historyFromMillis: 0,
    coveredThroughMillis: 1000, atomicIngressStartedAtMillis: 1000};
  const writes: ReadinessMutation[] = [];
  let approvals = 0;
  let verifications = 0;
  const tx: ReadinessTransaction = {
    async loadApprovedReview() {
      approvals++;
      return approval;
    },
    async readCurrent() {
      return current;
    },
    async verifyCompleteStopHistory() {
      verifications++;
      return proof;
    },
    async commit(mutation) {
      writes.push(mutation);
    },
  };
  const deps = {async runFencedTransaction<T>(
    callback: (tx: ReadinessTransaction) => Promise<T>) {
    return callback(tx);
  }};
  return {approval, current, proof, writes, tx, deps,
    counts: () => ({approvals, verifications})};
}

test("creates canonical readiness only with bound trusted evidence and audit",
  async () => {
    const f = fixture();
    const result = await applyCatchReadinessReview("review_1", f.deps);
    assert.deepEqual(Object.keys(result).sort(), ["readinessId", "state"]);
    assert.equal(result.state, "ready");
    const mutation = f.writes[0];
    assert.equal(mutation.record.completeHistory, true);
    assert.equal(mutation.record.historyFromMillis, 0);
    assert.equal(mutation.record.expiresAtMillis, f.approval.expiresAtMillis);
    assert.equal(mutation.record.reviewedAtMillis,
      f.approval.reviewedAtMillis);
    assert.equal(mutation.expectedRecordSha256, null);
    assert.equal(mutation.audit.provenanceSha256, f.proof.provenanceSha256);
    assert.equal(mutation.audit.projectId, "catchdates-dev");
    assert.equal(mutation.audit.actorUid, "owner");
    assert.equal(mutation.audit.recordSha256,
      catchReadinessRecordDigest(mutation.record));
    assert.deepEqual(f.counts(), {approvals: 1, verifications: 1});
  });

test("caller assertions and missing trusted approval cannot grant readiness",
  async () => {
    const f = fixture();
    await assert.rejects(applyCatchReadinessReview({completeHistory: true,
      ...f.approval} as unknown as string, f.deps));
    assert.equal(f.counts().approvals, 0);
    f.tx.loadApprovedReview = async () => null;
    await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
    assert.equal(f.writes.length, 0);
  });

test("rejects wrong reference, purpose action, scope and malformed metadata",
  async () => {
    const edits: Array<(f: ReturnType<typeof fixture>) => void> = [
      (f) => f.approval.approvalId = "other",
      (f) => Object.assign(f.approval, {action: "activate"}),
      (f) => f.approval.scope.projectId = "foreign-project",
      (f) => f.current.scope.wabaId = "999",
      (f) => f.current.scope.phoneNumberId = "999",
      (f) => f.current.scope.recipientUid = "other",
      (f) => f.current.scope.endpointHash = "d".repeat(64),
      (f) => f.current.scope.evidenceSha256 = "d".repeat(64),
      (f) => f.approval.scope.wabaId = "bad/id",
      (f) => f.approval.scope.endpointHash = "bad",
      (f) => f.approval.expectedRecordSha256 = "d".repeat(64),
    ];
    for (const edit of edits) {
      const f = fixture();
      edit(f);
      await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
      assert.equal(f.writes.length, 0);
    }
  });

test("requires current owner session and recipient without suppression",
  async () => {
    const edits: Array<(s: ReadinessSnapshot) => void> = [
      (s) => s.authority.uid = "other",
      (s) => s.authority.disabled = true,
      (s) => s.authority.roles = ["support"],
      (s) => s.authority.sessionCurrent = false,
      (s) => s.recipientEnabled = false,
      (s) => s.suppressed = true,
      (s) => s.verifiedRecipientEndpointHash = "d".repeat(64),
      (s) => s.atomicIngressStartedAtMillis = null,
      (s) => s.atomicIngressStartedAtMillis = 1001,
    ];
    for (const edit of edits) {
      const f = fixture();
      edit(f.current);
      await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
      assert.equal(f.writes.length, 0);
    }
  });

test("partial, unverifiable, gapped or foreign history cannot be clearance",
  async () => {
    const edits: Array<(p: VerifiedReadinessHistory) => void> = [
      (p) => p.approvalId = "other",
      (p) => p.provenanceSha256 = "",
      (p) => Object.assign(p, {historyFromMillis: 1}),
      (p) => p.coveredThroughMillis = 999,
      (p) => p.coveredThroughMillis = 2001,
      (p) => p.coveredThroughMillis = NaN,
      (p) => p.atomicIngressStartedAtMillis = 999,
      (p) => p.scope.evidenceSha256 = "d".repeat(64),
      (p) => p.scope.projectId = "foreign-project",
    ];
    for (const edit of edits) {
      const f = fixture();
      edit(f.proof);
      await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
      assert.equal(f.writes.length, 0);
    }
    for (const verified of [null, {completeHistory: true}]) {
      const f = fixture();
      f.tx.verifyCompleteStopHistory = async () =>
        verified as VerifiedReadinessHistory | null;
      await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
      assert.equal(f.writes.length, 0);
    }
    const f = fixture();
    f.tx.verifyCompleteStopHistory = async () => {
      throw new Error("Archive verifier found a retained-history gap");
    };
    await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
    assert.equal(f.writes.length, 0);
  });

test("review cannot be future, expired, malformed or extend beyond 24 hours",
  async () => {
    const edits: Array<(f: ReturnType<typeof fixture>) => void> = [
      (f) => f.current.nowMillis = NaN,
      (f) => f.approval.reviewedAtMillis = 4000,
      (f) => f.approval.expiresAtMillis = 3000,
      (f) => f.approval.expiresAtMillis = 2000,
      (f) => f.approval.expiresAtMillis = 2000 + 86400001,
      (f) => f.approval.atomicIngressStartedAtMillis = 2001,
      (f) => f.approval.reviewedAtMillis = -1,
    ];
    for (const edit of edits) {
      const f = fixture();
      edit(f);
      await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
      assert.equal(f.writes.length, 0);
    }
  });

test("creation cannot overwrite, renew or reactivate any existing record",
  async () => {
    const seed = fixture();
    await applyCatchReadinessReview("review_1", seed.deps);
    for (const existing of [{}, seed.writes[0].record,
      {...seed.writes[0].record, state: "revoked"}]) {
      const f = fixture();
      f.current.existing = existing;
      await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
      assert.equal(f.writes.length, 0);
    }
  });

test("revocation preserves evidence even with STOP and removed recipient",
  async () => {
    const f = fixture();
    await applyCatchReadinessReview("review_1", f.deps);
    const original = f.writes[0].record;
    f.current.existing = original;
    f.current.suppressed = true;
    f.current.recipientEnabled = false;
    f.current.atomicIngressStartedAtMillis = null;
    f.approval.action = "revoke";
    f.approval.expectedRecordSha256 = catchReadinessRecordDigest(original);
    await applyCatchReadinessReview("review_1", f.deps);
    assert.deepEqual(f.writes[1].record, {...original, state: "revoked"});
    assert.equal(f.writes[1].audit.provenanceSha256, null);
    assert.equal(f.counts().verifications, 1);
    f.approval.expectedRecordSha256 = "d".repeat(64);
    await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
    assert.equal(f.writes.length, 2);
  });

test("transaction replay rechecks changed STOP before any readiness commit",
  async () => {
    const f = fixture();
    // Simulate a transaction conflict: the first commit does not take effect.
    let attempts = 0;
    const conflict = new Error("conflict");
    f.tx.commit = async (mutation) => {
      if (++attempts === 1) throw conflict;
      f.writes.push(mutation);
    };
    f.deps.runFencedTransaction = async (callback) => {
      try {
        return await callback(f.tx);
      } catch (error) {
        if (error !== conflict) throw error;
        f.current.suppressed = true;
        return callback(f.tx);
      }
    };
    await assert.rejects(applyCatchReadinessReview("review_1", f.deps));
    assert.equal(f.counts().approvals, 2);
    assert.equal(f.writes.length, 0);
  });

test("unknown commit outcome propagates without another approval or retry",
  async () => {
    const f = fixture();
    const uncertain = new Error("unknown atomic commit outcome");
    let attempts = 0;
    f.tx.commit = async () => {
      attempts++;
      throw uncertain;
    };
    await assert.rejects(applyCatchReadinessReview("review_1", f.deps),
      (error) => error === uncertain);
    assert.equal(attempts, 1);
    assert.equal(f.counts().approvals, 1);
  });
