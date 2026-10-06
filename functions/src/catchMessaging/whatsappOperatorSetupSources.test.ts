import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {test} from "node:test";
import type {Auth} from "firebase-admin/auth";
import type {Firestore} from "firebase-admin/firestore";
import {createPinnedOperatorHistoryLoader, createProtectedOperatorSetupSources,
  operatorEmailHash} from "./whatsappOperatorSetupSources";
import {desiredOperatorClaims, planOperatorSetup, setupHash} from
  "./whatsappOperatorSetup";
import type {OperatorSetupPlan} from "./whatsappOperatorSetup";
import {OPERATOR_SETUP_OPERATIONS, OPERATOR_SETUP_AUDITS} from
  "./whatsappOperatorSetupFirestore";
import type {ReadinessApproval} from "./whatsappReadinessProvisioning";
import {catchEndpointHash} from "./whatsappReply";

function fixture() {
  let now = 1800000000000;
  let reads = 0;
  let setterCalls = 0;
  let setterOutcome = "normal";
  let loseReceiptResponse = false;
  let onReceipt: (() => void) | undefined;
  let claims: Record<string, unknown> = {syntheticFeature: true};
  const scope = {projectId: "demo-catch-setup", actorUid: "operator",
    actorEmailSha256: operatorEmailHash("operator@example.invalid"),
    recipientUid: "recipient", endpointHash: "b".repeat(64), appId: "10001",
    wabaId: "10002", phoneNumberId: "10003",
    credentialVersionSha256: "c".repeat(64)};
  const actor = {uid: "operator", disabled: false,
    email: "operator@example.invalid", emailVerified: true,
    providerData: [{providerId: "google.com",
      uid: "synthetic-google-subject"}]};
  const decoded = {uid: "operator", sub: "operator", aud: scope.projectId,
    iss: "https://securetoken.google.com/" + scope.projectId,
    email: actor.email, email_verified: true, auth_time: now / 1000 - 1,
    iat: now / 1000, exp: now / 1000 + 1800,
    firebase: {sign_in_provider: "google.com", identities:
      {"google.com": ["synthetic-google-subject"]}}};
  const metadata = {resourceSha256: scope.credentialVersionSha256,
    enabled: true, runtimeAccessor: true};
  const auth = {app: {options: {projectId: scope.projectId}},
    getUser: async (uid: string) => {
      reads++;
      return uid === "operator" ? {...actor, customClaims: {...claims}} :
        {uid, disabled: false, customClaims: {}};
    },
    verifyIdToken: async (token: string, revoked: boolean) => {
      reads++;
      assert.equal(token, "synthetic-token");
      assert.equal(revoked, true);
      return structuredClone(decoded);
    },
    listUsers: async () => ({users: [{...actor, customClaims: {...claims}}]}),
    setCustomUserClaims: async (uid: string, value: Record<string,
      unknown>) => {
      assert.equal(uid, "operator");
      setterCalls++;
      if (setterOutcome === "before") throw new Error("lost before Auth");
      claims = structuredClone(value);
      if (setterOutcome === "after") throw new Error("lost after Auth");
    }} as unknown as Auth;
  const query = {where: () => query, limit: () => query,
    get: async () => ({docs: [], empty: true})};
  const records = new Map<string, Record<string, unknown>>();
  const ref = (path: string) => ({path, get: async () => ({
    exists: records.has(path), data: () => records.get(path),
  })});
  let tail: Promise<unknown> = Promise.resolve();
  const db = {projectId: scope.projectId, databaseId: "(default)",
    collection: (name: string) => ({...query,
      doc: (id: string) => ref(name + "/" + id)}),
    runTransaction: (callback: (tx: {
      get: (value: ReturnType<typeof ref>) => Promise<unknown>;
      create: (value: ReturnType<typeof ref>, data: Record<string, unknown>) =>
        void;
    }) => Promise<unknown>, options: {maxAttempts: number}) => {
      assert.equal(options.maxAttempts, 1);
      const pending = tail.then(async () => {
        const writes = new Map<string, Record<string, unknown>>();
        const value = await callback({get: async (value) => {
          assert.equal(writes.size, 0);
          return value.get();
        }, create: (value, data) => {
          assert.ok(!records.has(value.path) && !writes.has(value.path));
          writes.set(value.path, structuredClone(data));
        }});
        for (const [path, data] of writes) records.set(path, data);
        onReceipt?.();
        if (loseReceiptResponse) throw new Error("lost receipt response");
        return value;
      });
      tail = pending.catch(() => undefined);
      return pending;
    }} as unknown as Firestore;
  const plans = new Map<string, OperatorSetupPlan>();
  const options = {scope, sourceSha: "e".repeat(40), db, auth,
    reviewedPlans: plans,
    actorIdToken: async () => "synthetic-token", now: () => now,
    credentialMetadata: async () => {
      reads++; return metadata;
    },
    transport: {getProjectId: async () => scope.projectId,
      lookup: async (request: {body: {localId: string[]}}) => {
        reads++;
        const uid = request.body.localId[0];
        return {users: [{localId: uid, createdAt: "1001", validSince: "0",
          disabled: uid === "operator" && actor.disabled,
          customAttributes: JSON.stringify(uid === "operator" ? claims : {}),
          ...(uid === "recipient" ? {phoneNumber: "+15555550123"} : {})}]};
      }}};
  // Endpoint fixture uses the exact existing phone hash, not a plaintext plan.
  scope.endpointHash = catchEndpointHash("+15555550123");
  return {options, actor, decoded, metadata, plans, reads: () => reads,
    claims: () => claims, records, setters: () => setterCalls,
    changeClaims: (value: Record<string, unknown>) => {
      claims = value;
    }, tick: (millis: number) => {
      now += millis;
    },
    duringReceipt: (callback: () => void) => {
      onReceipt = callback;
    },
    failClaims: (outcome: string) => {
      setterOutcome = outcome;
    }, loseReceipt: () => {
      loseReceiptResponse = true;
    }};
}
function setupRequest(plan: OperatorSetupPlan) {
  return {planId: plan.planId, planSha256: setupHash(plan),
    replayKey: "1".repeat(64)};
}
function reserveAuthIntent(f: ReturnType<typeof fixture>,
  plan: OperatorSetupPlan) {
  f.records.set(OPERATOR_SETUP_OPERATIONS + "/" + plan.scope.projectId,
    {schemaVersion: 1, operationId: plan.scope.projectId,
      projectId: plan.scope.projectId, planId: plan.planId,
      planSha256: setupHash(plan), replaySha256: setupHash("1".repeat(64)),
      scopeSha256: setupHash(plan.scope), actorUid: plan.scope.actorUid,
      recipientUid: plan.scope.recipientUid, phase: "auth-intent", revision: 2,
      updatedAtMillis: f.options.now()});
}
test("protected Google source is lazy, precise and metadata-only", async () => {
  const f = fixture();
  const sources = createProtectedOperatorSetupSources(f.options);
  assert.equal(f.reads(), 0);
  const snapshot = await sources.snapshot();
  assert.equal(snapshot.actor.auth.creationTimeMillis, 1001);
  assert.equal(snapshot.actor.emailSha256, f.options.scope.actorEmailSha256);
  assert.equal(snapshot.recipient.auth.endpointHash,
    f.options.scope.endpointHash);
  assert.equal(sources.authorizeApply, undefined);
  await assert.rejects(sources.setActorClaims({adminOwner: true},
    {planId: "absent", planSha256: "0".repeat(64),
      replayKey: "1".repeat(64)}));
  assert.deepEqual(f.claims(), {syntheticFeature: true});
  assert.ok(!JSON.stringify(snapshot).includes("synthetic-token"));
});
test("Google source rejects mismatched provider/email, " +
  "disabled and revoked session",
async () => {
  for (const mutate of [(f: ReturnType<typeof fixture>) => {
    f.actor.emailVerified = false;
  }, (f: ReturnType<typeof fixture>) => {
    f.actor.email = "other@example.invalid";
  },
  (f: ReturnType<typeof fixture>) => {
    f.actor.disabled = true;
  },
  (f: ReturnType<typeof fixture>) => {
    f.decoded.firebase.sign_in_provider = "password";
  }, (f: ReturnType<typeof fixture>) => {
    f.decoded.firebase.identities["google.com"] = ["other-google-subject"];
  }, (f: ReturnType<typeof fixture>) => {
    f.decoded.aud = "other-project";
  },
  (f: ReturnType<typeof fixture>) => {
    f.decoded.exp = 1;
  },
  (f: ReturnType<typeof fixture>) => {
    f.metadata.runtimeAccessor = false;
  }]) {
    const f = fixture();
    mutate(f);
    await assert.rejects(createProtectedOperatorSetupSources(
      f.options).snapshot(),
    /Protected Catch operator setup unavailable/u);
  }
});
test("source gate requires protected immutable plan " +
  "and exact owner-only claim delta",
async () => {
  const f = fixture();
  const initial = createProtectedOperatorSetupSources(f.options);
  const plan = planOperatorSetup(f.options.scope, await initial.snapshot(),
    {planId: "reviewed-plan", sourceSha: f.options.sourceSha,
      grantNonce: "f".repeat(64), createReviewRef: "review-create",
      revokeReviewRef: "review-revoke", now: f.options.now()});
  f.plans.set(plan.planId, plan);
  let authorized = 0;
  const sources = createProtectedOperatorSetupSources({...f.options,
    authorizeApply: async (digest) => {
      assert.equal(digest, setupHash(plan)); authorized++;
    }});
  f.plans.clear(); // Trusted source froze the approved exact bytes.
  await sources.authorizeApply?.(setupHash(plan));
  const request = setupRequest(plan);
  await assert.rejects(sources.setActorClaims(desiredOperatorClaims(f.claims()),
    request)); // Independent policy alone cannot dispatch without the journal.
  assert.equal(f.setters(), 0);
  reserveAuthIntent(f, plan);
  await assert.rejects(sources.setActorClaims({adminOwner: true,
    finance: true}, request));
  const desired = desiredOperatorClaims(f.claims());
  f.duringReceipt(() => {
    desired.adminFinance = true;
    desired.syntheticFeature = false;
  });
  await sources.setActorClaims(desired, request);
  assert.deepEqual(f.claims(), {syntheticFeature: true, adminOwner: true});
  assert.equal(authorized, 1);
  await assert.rejects(async () => {
    await sources.authorizeApply?.("0".repeat(64));
  });
});
test("pinned archive loader uses exact generation and " +
  "rejects missing/false history",
async () => {
  const f = fixture();
  const scope = f.options.scope;
  const identity = {projectId: scope.projectId, wabaId: scope.wabaId,
    phoneNumberId: scope.phoneNumberId, recipientUid: scope.recipientUid,
    endpointHash: scope.endpointHash};
  const root = {schema: "catch.whatsapp-history-archive/v1", identity,
    atomicIngressStartedAtMillis: 2000, segments: [{fromMillis: 0,
      throughMillis: 2000, records: [{messageId: "synthetic-message",
        receivedAtMillis: 1000, endpointHash: scope.endpointHash,
        messageType: "text", text: "hello", textTruncated: false}]}]};
  const bytes = Buffer.from(JSON.stringify(root));
  const archiveSha256 = createHash("sha256").update(bytes).digest("hex");
  const approval: ReadinessApproval = {approvalId: "review-create",
    action: "create", scope: {...identity, evidenceSha256: archiveSha256},
    reviewerUid: scope.actorUid, reviewedAtMillis: f.options.now(),
    expiresAtMillis: f.options.now() + 60000,
    atomicIngressStartedAtMillis: 2000,
    expectedRecordSha256: null};
  const pin = {objectPath: "catch-whatsapp-history/synthetic/archive.json",
    generation: "12345", archiveSha256, trustedPin: {
      schema: "catch.whatsapp-history-audit-pin/v1" as const,
      approvalId: approval.approvalId, scope: {...approval.scope},
      sourceAuditSha256: "a".repeat(64), atomicIngressStartedAtMillis: 2000,
      coveredThroughMillis: 2000}};
  let downloads = 0;
  let currentPin: typeof pin | null = pin;
  let currentBytes: Uint8Array = bytes;
  let onPin: (() => void) | undefined;
  const loader = createPinnedOperatorHistoryLoader({scope, now: f.options.now,
    loadAuthenticatedPin: async () => {
      onPin?.();
      return currentPin;
    },
    bucket: {file: (name, options) => {
      assert.equal(name, pin.objectPath);
      assert.deepEqual(options, {generation: "12345"});
      return {download: async (downloadOptions) => {
        downloads++;
        assert.deepEqual(downloadOptions, {validation: "crc32c"});
        return [currentBytes];
      }};
    }}});
  assert.equal(downloads, 0);
  const loaded = await loader(approval);
  assert.deepEqual(Buffer.from(loaded.archiveBytes), bytes);
  const mutableApproval = structuredClone(approval);
  onPin = () => {
    mutableApproval.scope.phoneNumberId = "99999";
  };
  const detached = await loader(mutableApproval);
  assert.deepEqual(Buffer.from(detached.archiveBytes), bytes);
  onPin = undefined;
  currentPin = null;
  await assert.rejects(loader(approval));
  assert.equal(downloads, 2);
  currentPin = pin;
  for (const mutate of [() => {
    currentBytes = new Uint8Array();
  }, () => {
    root.segments[0].fromMillis = 1;
    currentBytes = Buffer.from(JSON.stringify(root));
  }, () => {
    root.segments[0].records[0].textTruncated = true;
    currentBytes = Buffer.from(JSON.stringify(root));
  }]) {
    mutate();
    await assert.rejects(loader(approval));
  }
  await assert.rejects(loader({...approval, scope: {...approval.scope,
    phoneNumberId: "99999"}}));
});

for (const outcome of ["before", "after", "receipt"]) {
  test(`direct Auth writer ${outcome} unknown cannot consume another permit`,
    async () => {
      const f = fixture();
      const initial = createProtectedOperatorSetupSources(f.options);
      const plan = planOperatorSetup(f.options.scope, await initial.snapshot(),
        {planId: "reviewed-plan", sourceSha: f.options.sourceSha,
          grantNonce: "f".repeat(64), createReviewRef: "review-create",
          revokeReviewRef: "review-revoke", now: f.options.now()});
      f.plans.set(plan.planId, plan);
      const sources = createProtectedOperatorSetupSources({...f.options,
        authorizeApply: async (digest) => {
          assert.equal(digest, setupHash(plan));
        }});
      await sources.authorizeApply?.(setupHash(plan));
      reserveAuthIntent(f, plan);
      const desired = desiredOperatorClaims(f.claims());
      if (outcome === "receipt") f.loseReceipt();
      else f.failClaims(outcome);
      await assert.rejects(sources.setActorClaims(desired, setupRequest(plan)));
      await assert.rejects(sources.setActorClaims(desired, setupRequest(plan)));
      assert.equal(f.setters(), outcome === "receipt" ? 0 : 1);
      const receipt = f.records.get(OPERATOR_SETUP_AUDITS + "/" +
        plan.scope.projectId + "_auth_dispatch");
      assert.equal(receipt?.receiptKind, "auth-dispatch-intent");
      assert.equal(receipt?.effectSha256, plan.desiredClaimsSha256);
      assert.equal(f.records.size, 2);
    });
}

test("observed drift or expiry after dispatch receipt prevents the Auth call",
  async () => {
    for (const mode of ["drift", "expired"]) {
      const f = fixture();
      const initial = createProtectedOperatorSetupSources(f.options);
      const plan = planOperatorSetup(f.options.scope, await initial.snapshot(),
        {planId: "reviewed-plan", sourceSha: f.options.sourceSha,
          grantNonce: "f".repeat(64), createReviewRef: "review-create",
          revokeReviewRef: "review-revoke", now: f.options.now()});
      f.plans.set(plan.planId, plan);
      const sources = createProtectedOperatorSetupSources({...f.options,
        authorizeApply: async (digest) => {
          assert.equal(digest, setupHash(plan));
        }});
      await sources.authorizeApply?.(setupHash(plan));
      reserveAuthIntent(f, plan);
      const desired = desiredOperatorClaims(f.claims());
      f.duringReceipt(() => {
        if (mode === "drift") {
          f.changeClaims({...f.claims(), syntheticConcurrentChange: true});
        } else f.tick(15 * 60 * 1000);
      });
      await assert.rejects(sources.setActorClaims(desired, setupRequest(plan)));
      assert.equal(f.setters(), 0);
      assert.equal(f.records.size, 2); // Dispatch intent remains consumed.
    }
  });
