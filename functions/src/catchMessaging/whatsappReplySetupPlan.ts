import {createHash} from "node:crypto";

/**
 * Offline inventory format, not a Firestore record or readiness attestation.
 * Artifact hashes identify evidence for a separate authorized human audit;
 * this module cannot establish that the artifacts are truthful or complete.
 */
export interface CatchReplySetupScope {
  projectId: string;
  sourceSha: string;
  wabaId: string;
  phoneNumberId: string;
  actorUid: string;
  recipientUid: string;
  endpointHash: string;
}

const SCOPE_KEYS = ["projectId", "sourceSha", "wabaId", "phoneNumberId",
  "actorUid", "recipientUid", "endpointHash"] as const;
const hash = (value: string): boolean => /^[a-f0-9]{64}$/u.test(value);
const millis = (value: unknown): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= 0;

function object(value: unknown, keys: readonly string[]):
    Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      Object.keys(value).length !== keys.length ||
      keys.some((key) => !Object.hasOwn(value, key))) {
    throw new Error("Invalid offline evidence shape.");
  }
  return value as Record<string, unknown>;
}

function scope(value: unknown): CatchReplySetupScope {
  const record = object(value, SCOPE_KEYS);
  if (SCOPE_KEYS.some((key) => typeof record[key] !== "string")) {
    throw new Error("Invalid offline scope.");
  }
  const result = record as unknown as CatchReplySetupScope;
  if (!/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(result.projectId) ||
      !/^[a-f0-9]{40}$/u.test(result.sourceSha) ||
      !/^[0-9]{1,32}$/u.test(result.wabaId) ||
      !/^[0-9]{1,32}$/u.test(result.phoneNumberId) ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(result.actorUid) ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(result.recipientUid) ||
      !hash(result.endpointHash)) {
    throw new Error("Invalid offline scope.");
  }
  return result;
}

/**
 * Validate exact UTF-8 evidence bytes against an independently reviewed pin.
 * The caller must obtain that pin outside the supplied inventory. A matching
 * digest proves byte identity only. No credentials, private receipts, provider,
 * Firebase, environment variables or clock are accessed here.
 *
 * The inventory contains metadata only. Coverage intervals are contiguous
 * half-open ranges [fromMillis, throughMillis); the final boundary must reach
 * the independently verified atomic-ingress cutover. Both assertions still
 * require external audit. Missing source history cannot be filled by this API.
 */
export function planCatchReplySetup(input: {
  evidenceJson: string;
  externallyReviewedEvidenceSha256: string;
  expectedScope: CatchReplySetupScope;
  verifiedAtomicIngressStartedAtMillis: number;
  nowMillis: number;
}) {
  if (typeof input.evidenceJson !== "string" ||
      Buffer.byteLength(input.evidenceJson, "utf8") > 64 * 1024 ||
      !hash(input.externallyReviewedEvidenceSha256) ||
      !millis(input.nowMillis) ||
      !millis(input.verifiedAtomicIngressStartedAtMillis) ||
      input.verifiedAtomicIngressStartedAtMillis === 0 ||
      input.verifiedAtomicIngressStartedAtMillis > input.nowMillis) {
    throw new Error("Invalid offline review inputs.");
  }
  const evidenceSha256 = createHash("sha256")
    .update(input.evidenceJson, "utf8").digest("hex");
  if (evidenceSha256 !== input.externallyReviewedEvidenceSha256) {
    throw new Error("Evidence does not match the independent review pin.");
  }
  const expected = scope(input.expectedScope);
  let parsed: unknown;
  try {
    parsed = JSON.parse(input.evidenceJson);
  } catch {
    throw new Error("Invalid offline evidence JSON.");
  }
  const evidence = object(parsed, ["schema", "scope", "reviewedAtMillis",
    "expiresAtMillis", "atomicIngressStartedAtMillis", "coverage"]);
  if (evidence.schema !== "catch.whatsapp-setup-inventory/v1") {
    throw new Error("Unsupported offline evidence schema.");
  }
  const actual = scope(evidence.scope);
  if (SCOPE_KEYS.some((key) => actual[key] !== expected[key])) {
    throw new Error("Evidence scope differs from the reviewed trial.");
  }
  const reviewed = evidence.reviewedAtMillis;
  const expires = evidence.expiresAtMillis;
  const cutover = evidence.atomicIngressStartedAtMillis;
  if (!millis(reviewed) || !millis(expires) || !millis(cutover) ||
      cutover !== input.verifiedAtomicIngressStartedAtMillis ||
      cutover > reviewed || reviewed > input.nowMillis ||
      expires <= input.nowMillis || expires <= reviewed ||
      expires - reviewed > 24 * 60 * 60 * 1000) {
    throw new Error("Stale or inconsistent offline evidence timing.");
  }
  if (!Array.isArray(evidence.coverage) ||
      evidence.coverage.length < 1 || evidence.coverage.length > 128) {
    throw new Error("Historical evidence inventory required.");
  }
  let boundary = 0;
  for (const value of evidence.coverage) {
    const interval = object(value, ["fromMillis", "throughMillis",
      "artifactSha256", "provenanceSha256"]);
    if (!millis(interval.fromMillis) || !millis(interval.throughMillis) ||
        interval.fromMillis !== boundary ||
        interval.throughMillis <= interval.fromMillis ||
        interval.throughMillis > reviewed ||
        typeof interval.artifactSha256 !== "string" ||
        !hash(interval.artifactSha256) ||
        typeof interval.provenanceSha256 !== "string" ||
        !hash(interval.provenanceSha256)) {
      throw new Error("Incomplete or invalid historical evidence inventory.");
    }
    boundary = interval.throughMillis;
  }
  if (boundary < cutover) {
    throw new Error("Historical evidence does not reach atomic ingress.");
  }
  // Do not return a readiness-shaped record, deployment parameters, or a
  // callable payload. Every remaining authority check belongs to its owner.
  return Object.freeze({
    kind: "offline-review-plan" as const,
    evidenceSha256,
    grantsReadinessAuthority: false as const,
    grantsDeploymentAuthority: false as const,
    grantsSendAuthority: false as const,
    requiredIndependentChecks: Object.freeze([
      "Audit actual historical artifacts and provenance for complete STOPs.",
      "Verify deployed atomic STOP ingress and exact cutover.",
      "Verify current staff, recipient, preferences and permanent STOP state.",
      "Approve audited readiness provisioning, expiry and revocation.",
      "Approve exact deployment delta and scoped parameter materialization.",
      "Verify pinned sender credential metadata and narrow access.",
      "Review inbound and exact reply through authenticated App Check flow.",
      "Preserve consumed claims on unknown outcomes; never reset to retry.",
    ]),
  });
}
