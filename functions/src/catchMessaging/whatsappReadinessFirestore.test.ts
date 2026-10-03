import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {test} from "node:test";
import {createRequire} from "node:module";
import {readFileSync} from "node:fs";
import path from "node:path";
import {initializeApp, deleteApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import type {Firestore} from "firebase-admin/firestore";
import {applyCatchReadinessReviewInFirestore as apply,
  catchReadinessIngressId} from "./whatsappReadinessFirestore";
import type {CatchReadinessFirestoreDependencies} from
  "./whatsappReadinessFirestore";
import {catchReadinessRecordDigest} from "./whatsappReadinessProvisioning";
import type {ReadinessApproval} from "./whatsappReadinessProvisioning";
import type {CatchWhatsappReplyReadinessDocument} from
  "../shared/generated/catchWhatsappReplyReadinessDocument";

type Data = Record<string, unknown>;
type Ref = {path: string; id: string};
const hash = (value: unknown): string => createHash("sha256")
  .update(JSON.stringify(value)).digest("hex");

/** Synthetic atomic backend with injected commit outcomes. */
class TestFirestore {
  projectId = "catchdates-dev";
  databaseId = "(default)";
  records = new Map<string, Data>();
  attempts = 0;
  beforeCommit: (() => void) | null = null;
  afterCommit: (() => void) | null = null;
  collection(name: string) {
    return {doc: (id: string): Ref => ({path: name + "/" + id, id})};
  }
  async runTransaction<T>(callback: (tx: {
    get: (ref: Ref) => Promise<{exists: boolean; data: () => Data | undefined}>;
    create: (ref: Ref, value: Data) => void;
    update: (ref: Ref, value: Data) => void;
  }) => Promise<T>, options: {maxAttempts: number}): Promise<T> {
    assert.equal(options.maxAttempts, 1, "SDK must not retry unknown outcomes");
    this.attempts++;
    const writes = new Map<string, Data>();
    const result = await callback({
      get: async (ref) => {
        assert.equal(writes.size, 0, "Every read precedes every write");
        const data = structuredClone(this.records.get(ref.path));
        return {exists: data !== undefined, data: () => data};
      },
      create: (ref, data) => {
        assert.equal(this.records.has(ref.path), false);
        assert.equal(writes.has(ref.path), false);
        writes.set(ref.path, structuredClone(data));
      },
      update: (ref, data) => {
        assert.equal(this.records.has(ref.path), true);
        writes.set(ref.path, {...this.records.get(ref.path),
          ...structuredClone(data)});
      },
    });
    this.beforeCommit?.();
    for (const [path, data] of writes) this.records.set(path, data);
    this.afterCommit?.();
    return result;
  }
}

function fixture(projectId = "catchdates-dev") {
  const db = new TestFirestore();
  db.projectId = projectId;
  const approval: ReadinessApproval = {approvalId: "review_1", action: "create",
    scope: {projectId: db.projectId, wabaId: "123", phoneNumberId: "456",
      recipientUid: "recipient", endpointHash: "a".repeat(64),
      evidenceSha256: "b".repeat(64)}, reviewerUid: "owner",
    reviewedAtMillis: 2000, expiresAtMillis: 10000,
    atomicIngressStartedAtMillis: 1000, expectedRecordSha256: null};
  const archive = {schema: "catch.whatsapp-history-archive/v1",
    identity: {projectId, wabaId: "123", phoneNumberId: "456",
      recipientUid: "recipient", endpointHash: "a".repeat(64)},
    atomicIngressStartedAtMillis: 1000,
    segments: [{fromMillis: 0, throughMillis: 1000, records: [{
      messageId: "wamid.synthetic", receivedAtMillis: 500,
      endpointHash: "a".repeat(64), messageType: "text",
      text: "Please help with my account", textTruncated: false,
    }]}]};
  let archiveBytes: Uint8Array = Buffer.from(JSON.stringify(archive));
  approval.scope.evidenceSha256 = createHash("sha256")
    .update(archiveBytes).digest("hex");
  const trustedPin = {schema: "catch.whatsapp-history-audit-pin/v1" as const,
    approvalId: approval.approvalId, scope: {...approval.scope},
    sourceAuditSha256: "c".repeat(64), atomicIngressStartedAtMillis: 1000,
    coveredThroughMillis: 1000};
  const approvalPath = "catchWhatsappReadinessApprovals/review_1";
  const auditPath = "catchWhatsappReadinessAudits/review_1";
  const endpoint = hash(["123", "456", "a".repeat(64)]);
  const readinessPath = "catchWhatsappReplyReadiness/cwready_" + endpoint;
  const stopPath = "catchWhatsappEndpointStops/cwstop_" + endpoint;
  const ingressPath = "catchWhatsappReadinessIngress/" +
    catchReadinessIngressId(approval.scope);
  const saveApproval = (review = approval) => db.records.set(
    "catchWhatsappReadinessApprovals/" + review.approvalId,
    {schemaVersion: 1, approvalId: review.approvalId, state: "approved",
      approval: structuredClone(review),
      ingressEvidenceSha256: "d".repeat(64),
      consumedAtMillis: null, recordSha256: null});
  saveApproval();
  db.records.set(ingressPath, {schemaVersion: 1,
    ingressId: catchReadinessIngressId(approval.scope), projectId: db.projectId,
    wabaId: "123", phoneNumberId: "456", state: "active",
    atomicIngressStartedAtMillis: 1000, evidenceSha256: "d".repeat(64),
    verifiedAtMillis: 1500});
  let now = 3000;
  let fenced = false;
  let verifications = 0;
  const identity = {authority: {uid: "owner", disabled: false,
    roles: ["adminOwner"], sessionCurrent: true}, recipientEnabled: true,
  verifiedRecipientEndpointHash: approval.scope.endpointHash};
  const deps: CatchReadinessFirestoreDependencies = {
    projectId: db.projectId, now: () => now,
    async withAuditedAuthorityFence(binding, callback) {
      assert.equal(fenced, false);
      fenced = true;
      try {
        return await callback({...binding, provenanceSha256: "e".repeat(64),
          readCurrent: async () => structuredClone(identity)});
      } finally {
        fenced = false;
      }
    },
    async loadTrustedHistoryArchive() {
      assert.equal(fenced, true);
      verifications++;
      return {archiveBytes, trustedPin};
    },
  };
  db.beforeCommit = () => assert.equal(fenced, true,
    "External authority fence must span actual commit");
  const run = (reference = "review_1") => apply(reference,
    db as unknown as Firestore, deps);
  return {db, approval, approvalPath, auditPath, readinessPath, stopPath,
    ingressPath, saveApproval, identity, deps, run, archive, trustedPin,
    replaceBytes: (bytes: Buffer) => {
      archiveBytes = bytes;
    },
    verifications: () => verifications,
    setNow: (value: number) => {
      now = value;
    }};
}

test("creates readiness, consumes review and immutable audit atomically",
  async () => {
    const f = fixture();
    const before = new Set(f.db.records.keys());
    const result = await f.run();
    assert.equal(result.state, "ready");
    assert.equal(f.db.records.get(f.approvalPath)?.state, "consumed");
    const audit = f.db.records.get(f.auditPath)!;
    assert.equal(audit.readinessId, result.readinessId);
    assert.equal(audit.authorityFenceSha256, "e".repeat(64));
    assert.match(String(audit.provenanceSha256), /^[a-f0-9]{64}$/u);
    assert.deepEqual([...f.db.records.keys()]
      .filter((key) => !before.has(key))
      .sort(), [f.auditPath, f.readinessPath].sort());
    const saved = structuredClone([...f.db.records]);
    await assert.rejects(f.run());
    assert.deepEqual([...f.db.records], saved);
  });

test("requires audited fence and actual project/database",
  async () => {
    for (const edit of [
      (f: ReturnType<typeof fixture>) => Object.assign(f.deps,
        {withAuditedAuthorityFence: undefined}),
      (f: ReturnType<typeof fixture>) => f.db.projectId = "other-project",
      (f: ReturnType<typeof fixture>) => f.db.databaseId = "another",
    ]) {
      const f = fixture(); edit(f);
      await assert.rejects(f.run());
      assert.equal(f.db.attempts, 0);
    }
  });

test("approval and ingress require valid schema, identity and evidence",
  async () => {
    for (const edit of [
      (f: ReturnType<typeof fixture>) => f.db.records.delete(f.approvalPath),
      (f: ReturnType<typeof fixture>) =>
        f.db.records.get(f.approvalPath)!.state = "consumed",
      (f: ReturnType<typeof fixture>) =>
        f.db.records.get(f.approvalPath)!.extra = true,
      (f: ReturnType<typeof fixture>) => {
        f.approval.scope.projectId = "other-project"; f.saveApproval();
      },
      (f: ReturnType<typeof fixture>) => f.db.records.delete(f.ingressPath),
      (f: ReturnType<typeof fixture>) =>
        f.db.records.get(f.ingressPath)!.state = "revoked",
      (f: ReturnType<typeof fixture>) =>
        f.db.records.get(f.ingressPath)!.evidenceSha256 = "f".repeat(64),
      (f: ReturnType<typeof fixture>) =>
        f.db.records.get(f.ingressPath)!.verifiedAtMillis = 2001,
      (f: ReturnType<typeof fixture>) => f.db.records.set(f.auditPath, {}),
      (f: ReturnType<typeof fixture>) =>
        f.db.records.set(f.readinessPath, {}),
    ]) {
      const f = fixture(); edit(f);
      const before = structuredClone([...f.db.records]);
      await assert.rejects(f.run());
      assert.deepEqual([...f.db.records], before);
    }
  });

test("STOP, deletion, invalid preference and identity fail closed",
  async () => {
    for (const edit of [
      (f: ReturnType<typeof fixture>) => f.db.records.set(f.stopPath, {}),
      (f: ReturnType<typeof fixture>) =>
        f.db.records.set("deletedUsers/recipient", {}),
      (f: ReturnType<typeof fixture>) =>
        f.db.records.set("catchCommunicationPreferences/recipient", {}),
      (f: ReturnType<typeof fixture>) => f.identity.authority.disabled = true,
      (f: ReturnType<typeof fixture>) =>
        f.identity.authority.roles = ["support"],
      (f: ReturnType<typeof fixture>) =>
        f.identity.authority.sessionCurrent = false,
      (f: ReturnType<typeof fixture>) => f.identity.recipientEnabled = false,
      (f: ReturnType<typeof fixture>) =>
        f.identity.verifiedRecipientEndpointHash = "f".repeat(64),
    ]) {
      const f = fixture(); edit(f);
      await assert.rejects(f.run());
      assert.equal(f.db.records.has(f.readinessPath), false);
      assert.equal(f.db.records.has(f.auditPath), false);
      assert.equal(f.db.records.get(f.approvalPath)?.state, "approved");
    }
  });

test("expiry during verification prevents mutations", async () => {
  const f = fixture();
  const verify = f.deps.loadTrustedHistoryArchive;
  f.deps.loadTrustedHistoryArchive = async (approval) => {
    const proof = await verify(approval);
    f.setNow(approval.expiresAtMillis);
    return proof;
  };
  await assert.rejects(f.run());
  assert.equal(f.db.records.has(f.readinessPath), false);
  assert.equal(f.db.records.get(f.approvalPath)?.state, "approved");
});

test("conflict reload sees newly committed STOP",
  async () => {
    const f = fixture();
    f.db.beforeCommit = () => {
      f.db.records.set(f.stopPath, {});
      f.db.beforeCommit = null;
      throw Object.assign(new Error("conflict"), {code: 10});
    };
    await assert.rejects(f.run());
    assert.equal(f.db.attempts, 2);
    assert.equal(f.db.records.has(f.readinessPath), false);
    assert.equal(f.db.records.has(f.auditPath), false);
    assert.equal(f.db.records.get(f.approvalPath)?.state, "approved");
  });

test("conflict retries are bounded and reverify history", async () => {
  const f = fixture();
  f.db.beforeCommit = () => {
    throw Object.assign(new Error("conflict"), {code: 10});
  };
  await assert.rejects(f.run());
  assert.equal(f.db.attempts, 3);
  assert.equal(f.verifications(), 3);
  assert.equal(f.db.records.has(f.readinessPath), false);
});

test("ambiguous commits never retry, even a saved commit with lost response",
  async () => {
    for (const code of [2, 4, 13, 14, 409]) {
      for (const committed of [false, true]) {
        const f = fixture();
        const failure = Object.assign(new Error("uncertain"), {code});
        if (committed) {
          f.db.afterCommit = () => {
            throw failure;
          };
        } else {
          f.db.beforeCommit = () => {
            throw failure;
          };
        }
        await assert.rejects(f.run(), (error) => error === failure);
        assert.equal(f.db.attempts, 1);
        assert.equal(f.db.records.has(f.readinessPath), committed);
        assert.equal(f.db.records.has(f.auditPath), committed);
        assert.equal(f.db.records.get(f.approvalPath)?.state,
          committed ? "consumed" : "approved");
      }
    }
  });

test("revocation works after STOP and ingress revocation",
  async () => {
    const f = fixture();
    await f.run();
    const before = structuredClone(f.db.records.get(f.readinessPath)!) as
      unknown as CatchWhatsappReplyReadinessDocument;
    const approval: ReadinessApproval = {...f.approval,
      approvalId: "revoke_1",
      action: "revoke",
      expectedRecordSha256: catchReadinessRecordDigest(before)};
    f.saveApproval(approval);
    f.db.records.set(f.stopPath, {});
    f.db.records.delete(f.ingressPath);
    f.identity.recipientEnabled = false;
    await f.run("revoke_1");
    assert.deepEqual(f.db.records.get(f.readinessPath), {...before,
      state: "revoked"});
    assert.equal(f.verifications(), 1, "Revocation needs no archive");
    assert.equal(f.db.records.get("catchWhatsappReadinessAudits/revoke_1")?.
      provenanceSha256, null);
  });

// The canonical rules lane supplies this host; ordinary unit tests may skip.
// Reject non-loopback hosts before any SDK initialization or data access.
const emulatorHost = process.env.FIRESTORE_EMULATOR_HOST ?? "";
const emulatorEnabled = emulatorHost.length > 0;
if (emulatorEnabled &&
    !/^(127\.0\.0\.1|localhost):[0-9]+$/u.test(emulatorHost)) {
  throw new Error("Readiness tests require a loopback Firestore emulator");
}

test("readiness control documents deny every SDK client including staff",
  {skip: !emulatorEnabled}, async () => {
    const requireTest = createRequire(__filename);
    const {initializeTestEnvironment, assertFails} =
      requireTest("@firebase/rules-unit-testing");
    const {doc, getDoc, setDoc} = requireTest("firebase/firestore");
    const [host, port] = emulatorHost.split(":");
    const env = await initializeTestEnvironment({
      projectId: "demo-catch-readiness-rules", firestore: {host,
        port: Number(port), rules: readFileSync(path.resolve(__dirname,
          "../../../firestore.rules"), "utf8")},
    });
    try {
      for (const db of [env.unauthenticatedContext().firestore(),
        env.authenticatedContext("recipient").firestore(),
        env.authenticatedContext("owner", {admin: true, adminOwner: true,
          support: true}).firestore()]) {
        for (const collection of ["catchWhatsappReadinessApprovals",
          "catchWhatsappReadinessIngress", "catchWhatsappReadinessAudits"]) {
          const ref = doc(db, collection, "review_1");
          await assertFails(getDoc(ref));
          await assertFails(setDoc(ref, {approved: true}));
        }
      }
    } finally {
      await env.cleanup();
    }
  });

test("real emulator consumes review once with readiness and audit",
  {skip: !emulatorEnabled}, async () => {
    const projectId = "demo-catch-readiness";
    const app = initializeApp({projectId}, "readiness-adapter-test");
    const db = getFirestore(app);
    const f = fixture(projectId);
    try {
      for (const [ref, data] of f.db.records) await db.doc(ref).set(data);
      const first = await apply("review_1", db, f.deps);
      assert.equal(first.state, "ready");
      const [approval, readiness, audit] = await Promise.all([
        db.doc(f.approvalPath).get(), db.doc(f.readinessPath).get(),
        db.doc(f.auditPath).get(),
      ]);
      assert.equal(approval.data()?.state, "consumed");
      assert.equal(readiness.data()?.state, "ready");
      assert.equal(audit.data()?.recordSha256, approval.data()?.recordSha256);
      await assert.rejects(apply("review_1", db, f.deps));
      assert.deepEqual((await db.doc(f.auditPath).get()).data(),
        audit.data());
    } finally {
      await db.terminate();
      await deleteApp(app);
    }
  });

test("archive verifier blocks forged bytes and pinned STOP atomically",
  async () => {
    for (const repin of [false, true]) {
      const f = fixture();
      f.archive.segments[0].records[0].text = "STOP";
      const bytes = Buffer.from(JSON.stringify(f.archive));
      f.replaceBytes(bytes);
      if (repin) {
        const digest = createHash("sha256").update(bytes).digest("hex");
        f.approval.scope.evidenceSha256 = digest;
        f.trustedPin.scope.evidenceSha256 = digest;
        f.saveApproval();
      }
      await assert.rejects(f.run());
      assert.equal(f.db.records.has(f.readinessPath), false);
      assert.equal(f.db.records.has(f.auditPath), false);
      assert.equal(f.db.records.get(f.approvalPath)?.state, "approved");
    }
  });

test("dependency failure cannot masquerade as commit abort", async () => {
  const f = fixture();
  f.deps.loadTrustedHistoryArchive = async () => {
    throw Object.assign(new Error("source unavailable"), {code: 10});
  };
  await assert.rejects(f.run());
  assert.equal(f.db.attempts, 1);
  assert.equal(f.db.records.has(f.readinessPath), false);
});
