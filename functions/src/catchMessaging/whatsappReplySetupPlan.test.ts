import {strict as assert} from "node:assert";
import {createHash} from "node:crypto";
import {test} from "node:test";
import {planCatchReplySetup} from "./whatsappReplySetupPlan";

const scope = {
  projectId: "catch-offline-test", sourceSha: "a".repeat(40),
  wabaId: "123", phoneNumberId: "456", actorUid: "staff",
  recipientUid: "recipient", endpointHash: "b".repeat(64),
};
const fixture = () => ({
  schema: "catch.whatsapp-setup-inventory/v1", scope: {...scope},
  reviewedAtMillis: 3000, expiresAtMillis: 5000,
  atomicIngressStartedAtMillis: 2000,
  coverage: [
    {fromMillis: 0, throughMillis: 1000,
      artifactSha256: "c".repeat(64), provenanceSha256: "d".repeat(64)},
    {fromMillis: 1000, throughMillis: 2000,
      artifactSha256: "e".repeat(64), provenanceSha256: "f".repeat(64)},
  ],
});
function input(evidence: unknown = fixture()) {
  const evidenceJson = JSON.stringify(evidence);
  return {evidenceJson, externallyReviewedEvidenceSha256:
    createHash("sha256").update(evidenceJson).digest("hex"),
  expectedScope: {...scope}, verifiedAtomicIngressStartedAtMillis: 2000,
  nowMillis: 3500};
}

test("valid inventory yields an immutable plan with no authority", () => {
  const result = planCatchReplySetup(input());
  assert.equal(result.kind, "offline-review-plan");
  assert.equal(result.grantsReadinessAuthority, false);
  assert.equal(result.grantsDeploymentAuthority, false);
  assert.equal(result.grantsSendAuthority, false);
  assert.ok(Object.isFrozen(result));
  assert.ok(Object.isFrozen(result.requiredIndependentChecks));
  for (const key of ["state", "completeHistory", "body", "accessToken"]) {
    assert.equal(Object.hasOwn(result, key), false);
  }
});

test("missing pin and exact-byte changes fail without trusting the inventory",
  () => {
    const request = input();
    assert.throws(() => planCatchReplySetup({...request,
      externallyReviewedEvidenceSha256: ""}));
    assert.throws(() => planCatchReplySetup({...request,
      evidenceJson: request.evidenceJson + " "}), /independent review pin/);
    assert.throws(() => planCatchReplySetup(input("not an object")));
    const malformed = input();
    malformed.evidenceJson = "{";
    malformed.externallyReviewedEvidenceSha256 =
      createHash("sha256").update("{").digest("hex");
    assert.throws(() => planCatchReplySetup(malformed), /JSON/);
  });

test("trial identities and source must match the independent scope",
  () => {
    for (const key of Object.keys(scope) as (keyof typeof scope)[]) {
      const evidence = fixture();
      evidence.scope[key] = key === "projectId" ? "other-project" :
        key === "sourceSha" ? "9".repeat(40) :
          key === "endpointHash" ? "9".repeat(64) : "789";
      assert.throws(() => planCatchReplySetup(input(evidence)),
        /scope differs/);
    }
    const request = input();
    request.verifiedAtomicIngressStartedAtMillis = 1999;
    assert.throws(() => planCatchReplySetup(request), /timing/);
  });

test("gaps, overlap, partial and empty history fail", () => {
  for (const change of [
    (e: ReturnType<typeof fixture>) => {
      e.coverage[0].fromMillis = 1;
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage[1].fromMillis = 1001;
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage[1].fromMillis = 999;
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage[1].throughMillis = 1999;
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage = [];
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage.reverse();
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage[0].artifactSha256 = "";
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage[0].provenanceSha256 = "";
    },
  ]) {
    const evidence = fixture();
    change(evidence);
    assert.throws(() => planCatchReplySetup(input(evidence)));
  }
});

test("expiry, future claims and invalid times fail closed", () => {
  for (const change of [
    (e: ReturnType<typeof fixture>) => {
      e.expiresAtMillis = 3500;
    },
    (e: ReturnType<typeof fixture>) => {
      e.reviewedAtMillis = 3501;
    },
    (e: ReturnType<typeof fixture>) => {
      e.expiresAtMillis = 86403001;
    },
    (e: ReturnType<typeof fixture>) => {
      e.reviewedAtMillis = 1999;
    },
    (e: ReturnType<typeof fixture>) => {
      e.coverage[1].throughMillis = 3001;
    },
  ]) {
    const evidence = fixture();
    change(evidence);
    assert.throws(() => planCatchReplySetup(input(evidence)));
  }
  for (const nowMillis of [-1, NaN, Infinity, 0.5]) {
    assert.throws(() => planCatchReplySetup({...input(), nowMillis}));
  }
});

test("metadata rejects secrets, bodies and invented clearance", () => {
  const extraKeys = ["accessToken", "body", "recipientE164", "completeHistory"];
  for (const key of extraKeys) {
    const extraField = {...fixture(), [key]: true};
    assert.throws(() => planCatchReplySetup(input(extraField)));
    const evidence = fixture();
    Object.assign(evidence.coverage[0], {[key]: true});
    assert.throws(() => planCatchReplySetup(input(evidence)));
  }
  assert.throws(() => planCatchReplySetup(input({
    ...fixture(), schema: "catch.whatsapp-sender-token/v1",
  })));
  assert.throws(() => planCatchReplySetup({...input(),
    evidenceJson: " ".repeat(65537)}));
});
