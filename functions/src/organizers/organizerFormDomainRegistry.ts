import {randomBytes} from "node:crypto";
import {resolveCname, resolveTxt} from "node:dns/promises";
import type {firestore} from "firebase-admin";
import {requireOrganizerManager} from "../shared/organizerManagerAuthority";
import {
  activateFormDomain, normalizeCustomFormHost,
  normalizeHostingTarget, parseOrganizerFormDomain, resolveCustomFormHost,
  revokeFormDomain, verifyFormDomain,
  type DomainProbe, type OrganizerFormDomain,
} from "./organizerFormDomains";

const COLLECTION = "organizerFormDomains";
const PENDING_LEASE_MS = 48 * 60 * 60 * 1000;

function requireHostname(hostname: string): string {
  const normalized = normalizeCustomFormHost(hostname);
  if (!normalized || normalized !== hostname) {
    throw new Error("Invalid custom hostname");
  }
  return hostname;
}

/** Probe failures return no evidence. DNS is checked against the record. */
export async function probeFormDomain(
  hostname: string
): Promise<DomainProbe | null> {
  if (!normalizeCustomFormHost(hostname)) return null;
  try {
    const [txt, cname] = await Promise.all([
      resolveTxt(`_catch-verify.${hostname}`), resolveCname(hostname),
    ]);
    return {
      hostname, txtValues: txt.map((parts) => parts.join("")),
      cnameTarget: cname.length === 1 ? cname[0] : null,
      checkedAtMillis: Date.now(),
    };
  } catch {
    return null;
  }
}

export async function reserveOrganizerFormDomain(
  db: firestore.Firestore,
  input: {hostname: string; organizerId: string; formId: string;
    actorUid: string},
  nowMillis: number,
  trustedHostingTarget: string,
  assertManager: typeof requireOrganizerManager = requireOrganizerManager
): Promise<OrganizerFormDomain> {
  const hostname = requireHostname(input.hostname);
  const expectedCname = normalizeHostingTarget(trustedHostingTarget);
  if (!expectedCname ||
      !Number.isFinite(nowMillis)) throw new Error("Invalid hosting target");
  const domainRef = db.collection(COLLECTION).doc(hostname);
  const formRef = db.collection("organizerForms").doc(input.formId);
  return db.runTransaction(async (tx) => {
    await assertManager({db, organizerId: input.organizerId,
      actorUid: input.actorUid, transaction: tx});
    const [existing, form] = await Promise.all([
      tx.get(domainRef), tx.get(formRef),
    ]);
    if (!form.exists || form.get("organizerId") !== input.organizerId ||
        form.get("status") !== "published" ||
        typeof form.get("publicFormId") !== "string") {
      throw new Error("Published form ownership is required");
    }
    const previous = existing.exists ?
      parseOrganizerFormDomain(existing.data()) : null;
    if (existing.exists && !previous) throw new Error("Invalid domain record");
    if (previous && previous.status !== "revoked" &&
        !(previous.status === "pending" &&
          previous.pendingExpiresAtMillis <= nowMillis)) {
      throw new Error("Hostname is already reserved");
    }
    // A revoked hostname can be reassigned only with a fresh challenge and DNS
    // proof. The old binding cannot be reactivated.
    const record: OrganizerFormDomain = {
      hostname, organizerId: input.organizerId, formId: input.formId,
      publicFormId: form.get("publicFormId") as string,
      ownershipChallenge: `catch-verification=${
        randomBytes(24).toString("base64url")}`,
      expectedCname, status: "pending",
      certificateStatus: "pending", verifiedAtMillis: null,
      generation: (previous?.generation ?? 0) + 1,
      reservedAtMillis: nowMillis,
      pendingExpiresAtMillis: nowMillis + PENDING_LEASE_MS,
    };
    tx.set(domainRef, record);
    return record;
  });
}

/** Trusted backend operation. Never accepts browser-supplied TXT. */
export async function verifyOrganizerFormDomain(
  db: firestore.Firestore, hostname: string, probe: DomainProbe | null,
  nowMillis: number, expectedOrganizerId?: string,
  operator?: {expected: OrganizerFormDomain; actorUid: string;
    assertManager?: typeof requireOrganizerManager}
): Promise<OrganizerFormDomain> {
  requireHostname(hostname);
  return db.runTransaction(async (tx) => {
    const ref = db.collection(COLLECTION).doc(hostname);
    const snap = await tx.get(ref);
    if (!snap.exists || !probe) {
      throw new Error("Domain is not reserved or DNS is unavailable");
    }
    const record = parseOrganizerFormDomain(snap.data());
    if (!record || (expectedOrganizerId &&
        record.organizerId !== expectedOrganizerId)) {
      throw new Error("Invalid domain owner or record");
    }
    if (operator) {
      if (!sameFormDomainBinding(record, operator.expected)) {
        throw new Error("Domain reservation changed");
      }
      await (operator.assertManager ?? requireOrganizerManager)({db,
        organizerId: record.organizerId, actorUid: operator.actorUid,
        transaction: tx});
    }
    const verified = verifyFormDomain(record, probe,
      nowMillis);
    tx.set(ref, verified);
    return verified;
  });
}

/** Immutable reservation identity carried across provider and DNS reads. */
export function sameFormDomainBinding(
  current: OrganizerFormDomain, expected: OrganizerFormDomain
): boolean {
  return (["hostname", "organizerId", "formId", "publicFormId",
    "ownershipChallenge", "expectedCname", "generation", "reservedAtMillis",
    "pendingExpiresAtMillis"] as const)
    .every((key) => current[key] === expected[key]);
}

/** Operator-only evidence from the exact, live Hosting resource. */
export interface FormDomainCertificateEvidence {
  projectId: string;
  siteId: string;
  hostname: string;
  observedAtMillis: number;
  expiresAtMillis: number;
}

/** Check current manager, reservation and publication together. This is a
 * read-only transaction; external provider writes still need a fresh check.
 */
export async function assertOrganizerFormDomainBinding(
  db: firestore.Firestore, expected: OrganizerFormDomain, actorUid: string,
  statuses: readonly OrganizerFormDomain["status"][],
  assertManager: typeof requireOrganizerManager = requireOrganizerManager
): Promise<OrganizerFormDomain> {
  requireHostname(expected.hostname);
  return db.runTransaction(async (tx) => {
    const current = parseOrganizerFormDomain((await tx.get(db.collection(
      COLLECTION).doc(expected.hostname))).data());
    if (!current || !sameFormDomainBinding(current, expected) ||
        !statuses.includes(current.status)) {
      throw new Error(
        "Domain reservation changed");
    }
    await assertManager({db, organizerId: current.organizerId,
      actorUid, transaction: tx});
    // Revocation and provider cleanup remain possible after unpublication.
    if (!statuses.includes("revoked")) {
      const form = await tx.get(db.collection("organizerForms")
        .doc(current.formId));
      if (!form.exists || form.get("status") !== "published" ||
          form.get("organizerId") !== current.organizerId ||
          form.get("publicFormId") !== current.publicFormId) {
        throw new Error("Published form binding changed");
      }
    }
    return current;
  });
}

/** Activate atomically; no intermediate caller-controlled certificate flag.
 * Provider evidence is accepted only by this trusted operator entry point.
 */
export async function activateOrganizerFormDomain(
  db: firestore.Firestore,
  input: {expected: OrganizerFormDomain; probe: DomainProbe | null;
    certificate: FormDomainCertificateEvidence | null; actorUid: string;
    trustedProjectId: string},
  nowOrClock: number | (() => number),
  assertManager: typeof requireOrganizerManager = requireOrganizerManager
): Promise<OrganizerFormDomain> {
  const {expected, probe, certificate} = input;
  requireHostname(expected.hostname);
  if (!parseOrganizerFormDomain(expected) || !probe || !certificate) {
    throw new Error("Domain, DNS or certificate evidence is unavailable");
  }
  return db.runTransaction(async (tx) => {
    const ref = db.collection(COLLECTION).doc(expected.hostname);
    const record = parseOrganizerFormDomain((await tx.get(ref)).data());
    if (!record || !sameFormDomainBinding(record, expected) ||
        !["verified", "active"].includes(record.status)) {
      throw new Error("Domain verification changed");
    }
    await assertManager({db, organizerId: record.organizerId,
      actorUid: input.actorUid, transaction: tx});
    const form = await tx.get(db.collection("organizerForms")
      .doc(record.formId));
    if (!form.exists || form.get("status") !== "published" ||
        form.get("organizerId") !== record.organizerId ||
        form.get("publicFormId") !== record.publicFormId) {
      throw new Error("Published form binding changed");
    }
    // Read after all transaction reads, and again on transaction retries.
    const nowMillis = typeof nowOrClock === "function" ?
      nowOrClock() : nowOrClock;
    if (!Number.isSafeInteger(nowMillis) ||
        !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(input.trustedProjectId) ||
        certificate.projectId !== input.trustedProjectId ||
        certificate.hostname !== record.hostname ||
        !/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/u.test(
          certificate.siteId) ||
        `${certificate.siteId}.web.app` !== record.expectedCname ||
        !Number.isSafeInteger(certificate.observedAtMillis) ||
        certificate.observedAtMillis > nowMillis ||
        nowMillis - certificate.observedAtMillis > 5 * 60 * 1000 ||
        !Number.isSafeInteger(certificate.expiresAtMillis) ||
        certificate.expiresAtMillis <= nowMillis) {
      throw new Error("Hosting certificate evidence is stale or mismatched");
    }
    const active = activateFormDomain({...record, status: "verified",
      certificateStatus: "ready"}, probe, nowMillis);
    tx.set(ref, active);
    return active;
  });
}

export async function revokeOrganizerFormDomain(
  db: firestore.Firestore, hostname: string, organizerId: string,
  actorUid: string,
  assertManager: typeof requireOrganizerManager = requireOrganizerManager,
  expected?: OrganizerFormDomain
): Promise<void> {
  requireHostname(hostname);
  await db.runTransaction(async (tx) => {
    await assertManager({db, organizerId, actorUid, transaction: tx});
    const ref = db.collection(COLLECTION).doc(hostname);
    const snap = await tx.get(ref);
    const record = parseOrganizerFormDomain(snap.data());
    if (!record || record.organizerId !== organizerId ||
        (expected && !sameFormDomainBinding(record, expected))) {
      throw new Error("Domain is not owned by this organizer");
    }
    tx.set(ref, revokeFormDomain(record));
  });
}

/** Exact host, current DNS, and current form ownership all have to agree. */
export async function resolveOrganizerFormDomain(
  db: firestore.Firestore, requestHost: string,
  probeOrLoad: DomainProbe | null | (() => Promise<DomainProbe | null>),
  nowOrClock: number | (() => number)
): Promise<{organizerId: string; publicFormId: string} | null> {
  const hostname = normalizeCustomFormHost(requestHost);
  if (!hostname) return null;
  const domainRef = db.collection(COLLECTION).doc(hostname);
  const domainSnap = await domainRef.get();
  const record = parseOrganizerFormDomain(domainSnap.data());
  if (!record || record.status !== "active") return null;
  const probe = typeof probeOrLoad === "function" ?
    await probeOrLoad() : probeOrLoad;
  if (!probe) return null;
  // DNS can outlive revocation or reassignment. Read the binding and form in
  // one transaction, and never let this request switch reservation identity.
  return db.runTransaction(async (tx) => {
    const current = parseOrganizerFormDomain((await tx.get(domainRef)).data());
    if (!current || current.status !== "active" ||
        current.generation !== record.generation ||
        current.organizerId !== record.organizerId ||
        current.formId !== record.formId ||
        current.publicFormId !== record.publicFormId) return null;
    const formSnap = await tx.get(db.collection("organizerForms")
      .doc(current.formId));
    // Probe timestamps describe completion. Check time after DNS and reads,
    // including any transaction retry, without treating network time as future.
    const nowMillis = typeof nowOrClock === "function" ?
      nowOrClock() : nowOrClock;
    const resolved = resolveCustomFormHost(hostname, current, probe, nowMillis);
    if (!resolved || !formSnap.exists ||
        formSnap.get("organizerId") !== resolved.organizerId ||
        formSnap.get("publicFormId") !== resolved.publicFormId ||
        formSnap.get("status") !== "published") return null;
    return {organizerId: resolved.organizerId,
      publicFormId: resolved.publicFormId};
  });
}
