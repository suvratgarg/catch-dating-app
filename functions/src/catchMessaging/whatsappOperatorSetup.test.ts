import assert from "node:assert/strict";
import {test} from "node:test";
import {desiredOperatorClaims, planOperatorSetup, setupHash,
  validateSetupRequest, validateSetupPlan} from "./whatsappOperatorSetup";
import type {OperatorSetupScope, OperatorSetupSnapshot} from
  "./whatsappOperatorSetup";

function fixture() {
  const now = 1800000000000;
  const scope: OperatorSetupScope = {projectId: "demo-catch-setup",
    actorUid: "operator", actorEmailSha256: "a".repeat(64),
    recipientUid: "recipient", endpointHash: "b".repeat(64), appId: "10001",
    wabaId: "10002", phoneNumberId: "10003",
    credentialVersionSha256: "c".repeat(64)};
  const auth = (uid: string) => ({projectId: scope.projectId, uid,
    creationTimeMillis: 1001, observedAtMillis: now, disabled: false,
    relevantRoles: [], tokensValidAfterMillis: 0,
    endpointHash: uid === "recipient" ? scope.endpointHash : null});
  const snapshot: OperatorSetupSnapshot = {actor: {auth: auth("operator"),
    session: {projectId: scope.projectId, uid: "operator",
      authTimeSeconds: now / 1000 - 1, expiresAtSeconds: now / 1000 + 1800},
    emailSha256: scope.actorEmailSha256, googleSubjectSha256: "d".repeat(64),
    claims: {tenantLabel: "synthetic", nested: {flag: true}}},
  recipient: {auth: auth("recipient"), claims: {}}, existingOwnerUids: [],
  authorityExists: false, bootstrapExists: false, actorAssignmentExists: false};
  const options = {planId: "reviewed-plan", sourceSha: "e".repeat(40),
    grantNonce: "f".repeat(64), createReviewRef: "review-create",
    revokeReviewRef: "review-revoke", now};
  return {scope, snapshot, options};
}
test("read-only plan is exact, detached and contains only hashed account facts",
  () => {
    const f = fixture();
    const before = structuredClone(f);
    const plan = planOperatorSetup(f.scope, f.snapshot, f.options);
    assert.deepEqual(f, before);
    assert.equal(plan.expectedActorRevision, 0);
    assert.equal(plan.desiredClaimsSha256,
      setupHash({...f.snapshot.actor.claims, adminOwner: true}));
    f.scope.appId = "99999";
    f.snapshot.actor.claims.tenantLabel = "changed";
    assert.equal(plan.scope.appId, "10001");
    assert.ok(!JSON.stringify(plan).includes("tenantLabel"));
    validateSetupPlan(plan);
  });
test("planning rejects current identity, role, " +
  "freshness and existing-state drift",
() => {
  const changes: Array<(f: ReturnType<typeof fixture>) => void> = [
    (f) => {
      f.snapshot.actor.auth.projectId = "other-project";
    },
    (f) => {
      f.snapshot.actor.auth.uid = "other";
    },
    (f) => {
      f.snapshot.actor.emailSha256 = "1".repeat(64);
    },
    (f) => {
      f.snapshot.actor.auth.disabled = true;
    },
    (f) => {
      f.snapshot.recipient.auth.endpointHash = "1".repeat(64);
    },
    (f) => {
      f.snapshot.recipient.auth.disabled = true;
    },
    (f) => {
      f.snapshot.recipient.auth.relevantRoles = ["support"];
    },
    (f) => {
      f.snapshot.recipient.claims.adminOwner = true;
    },
    (f) => {
      f.snapshot.actor.session.authTimeSeconds -= 301;
    },
    (f) => {
      f.snapshot.actor.auth.tokensValidAfterMillis = f.options.now;
    },
    (f) => {
      f.snapshot.actor.auth.observedAtMillis -= 30000;
    },
    (f) => {
      f.snapshot.existingOwnerUids = ["owner-one", "owner-two"];
    },
    (f) => {
      f.snapshot.authorityExists = true;
    },
    (f) => {
      f.snapshot.bootstrapExists = true;
    },
    (f) => {
      f.snapshot.actorAssignmentExists = true;
    },
    (f) => {
      f.snapshot.recipient.claims.finance = true;
    },
    (f) => {
      f.scope.actorUid = f.scope.recipientUid;
    },
  ];
  for (const change of changes) {
    const f = fixture();
    change(f);
    assert.throws(() => planOperatorSetup(f.scope, f.snapshot, f.options),
      /Protected Catch operator setup unavailable/u);
  }
});
test("claim projection adds only owner and preserves unrelated values exactly",
  () => {
    const claims = {analyticsViewer: false, feature: ["a", "b"],
      settings: {allow: true}, counter: 7};
    assert.deepEqual(desiredOperatorClaims(claims),
      {...claims, adminOwner: true});
    assert.ok(!Object.hasOwn(claims, "adminOwner"));
    assert.throws(() => desiredOperatorClaims({huge: "x".repeat(1000)}));
    assert.throws(() => desiredOperatorClaims({unsupported: undefined}));
  });
test("apply accepts only reviewed identifier, digest and replay key", () => {
  const request = {planId: "reviewed-plan", planSha256: "a".repeat(64),
    replayKey: "b".repeat(64)};
  assert.deepEqual(validateSetupRequest(request), request);
  for (const field of ["roles", "scope", "archiveBytes", "credential",
    "evidence", "actorUid", "projectId", "nonce", "capabilities"]) {
    assert.throws(() => validateSetupRequest({...request,
      [field]: "invented"}));
  }
  assert.throws(() => validateSetupRequest({...request, replayKey: "short"}));
});
